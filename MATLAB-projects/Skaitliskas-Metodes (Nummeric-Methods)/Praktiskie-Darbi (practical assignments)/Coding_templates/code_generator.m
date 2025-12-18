function varargout = code_generator(action, varargin)
% CODE_GENERATOR  Template-driven code generator (registry + templates + features + autofill).
%
% Main actions:
%   reg  = code_generator('load_registry')
%   freg = code_generator('load_features_registry')
%   txt  = code_generator('render', templateId, inputsStruct, opts)
%   out  = code_generator('generate', templateId, inputsStruct, outFile, opts)
%   code_generator('add_template', metaStruct, templateText)
%   code_generator('update_template', oldId, metaStruct, templateText)
%
% Notes:
% - Uses SAFE string replacement (never MATLAB replace()) to avoid:
%     "The 'REPLACE' input must be either a char row vector..."
% - Fills missing inputs from defaults in registry (so GUI doesn't prompt).
% - Skips required-check for inputs owned by disabled features.
% - Autofill args are resolved by key names listed in registry.autofill(i).args.
% - Supports registry formats where fields can be struct OR struct-array OR cell array.

action = lower(string(action));

switch action
    case "load_registry"
        reg = local_load_registry();
        varargout{1} = reg;

    case "load_features_registry"
        feats = local_load_features_registry();
        varargout{1} = feats;

    case "render"
        % ('render', templateId, inputsStruct, opts)
        templateId = string(varargin{1});
        inputsIn   = varargin{2};
        opts       = struct();
        if numel(varargin) >= 3 && ~isempty(varargin{3})
            opts = varargin{3};
        end
        txt = local_render(templateId, inputsIn, opts);
        varargout{1} = txt;

    case "generate"
        % ('generate', templateId, inputsStruct, outFile, opts)
        templateId = string(varargin{1});
        inputsIn   = varargin{2};
        outFile    = string(varargin{3});
        opts       = struct();
        if numel(varargin) >= 4 && ~isempty(varargin{4})
            opts = varargin{4};
        end
        txt = local_render(templateId, inputsIn, opts);

        outPath = local_write_output(outFile, txt);
        varargout{1} = outPath;

    case "add_template"
        % ('add_template', metaStruct, templateText)
        meta = varargin{1};
        tplText = varargin{2};
        local_add_template(meta, tplText);

    case "update_template"
        % ('update_template', oldId, metaStruct, templateText)
        oldId  = string(varargin{1});
        meta   = varargin{2};
        tplText = varargin{3};
        local_update_template(oldId, meta, tplText);

    otherwise
        error("code_generator: Unknown action '%s'", action);
end

end

% =========================================================================
% RENDER / GENERATE
% =========================================================================

function txt = local_render(templateId, inputsIn, opts)
    reg = local_load_registry();
    meta = local_get_meta(reg, templateId);

    meta = local_normalize_meta(meta);

    % Normalize incoming inputs
    if isempty(inputsIn)
        inputsIn = struct();
    end
    if ~isstruct(inputsIn)
        error("code_generator('render'): inputsStruct must be a struct.");
    end

    % Resolve effective enabled features/autofill (meta defaults overridden by opts)
    enabledFeatures = local_enabled_features(meta, opts);
    enabledAutofill = local_enabled_autofill(meta, opts);

    % Fill missing from defaults (including feature-owned defaults; later we skip required checks if feature disabled)
    inputs = local_fill_defaults(meta, inputsIn);

    % Run enabled autofill (and inject provided outputs into inputs)
    inputs = local_apply_autofill(meta, inputs, enabledAutofill);
    inputs = local_apply_input_aliases(inputs); 

    % Load template file text
    tplDir = local_templates_dir();
    tplPath = fullfile(tplDir, string(meta.template_file));
    if exist(tplPath, 'file') ~= 2
        error("Template file not found: %s", tplPath);
    end
    txt = fileread(tplPath);
    txt = local_any_to_char(txt);

    % Insert features by slot markers: %<FEATURE:slot>
    txt = local_insert_features(txt, meta, enabledFeatures);

    % Substitute placeholders: <var(x)>, <expr(eq)>, <equation(eq)>, <func(eq)>
    txt = local_substitute_placeholders(txt, meta, inputs, enabledFeatures);

    % Clean up any remaining feature markers (disabled / unknown)
    txt = regexprep(txt, '%<FEATURE:[^>]+>', '');

    % Ensure trailing newline
    if ~endsWith(string(txt), newline)
        txt = [txt newline];
    end
end

function outPath = local_write_output(outFile, txt)
    outFile = strtrim(string(outFile));
    if outFile == ""
        outFile = "generated_task.m";
    end
    if ~endsWith(outFile, ".m")
        outFile = outFile + ".m";
    end
    outPath = char(outFile);

    fid = fopen(outPath, 'w');
    if fid < 0
        error("Could not open output file for writing: %s", outPath);
    end
    cleanup = onCleanup(@() fclose(fid)); %#ok<NASGU>
    fwrite(fid, txt);
end

% =========================================================================
% FEATURES
% =========================================================================

function txt = local_insert_features(txt, meta, enabledFeatures)
    % Build slot -> concatenated code
    featsReg = local_load_features_registry();
    featMap = containers.Map('KeyType','char','ValueType','char');
    for i = 1:numel(featsReg)
        f = featsReg(i);
        if isfield(f,'feature') && isfield(f,'file')
            featMap(char(string(f.feature))) = char(string(f.file));
        end
    end

    % meta.features is struct array
    if isempty(meta.features)
        return;
    end

    slotCode = containers.Map('KeyType','char','ValueType','char');

    for i = 1:numel(meta.features)
        f = meta.features(i);
        fname = strtrim(string(local_getfield(f,'feature')));
        slot  = strtrim(string(local_getfield(f,'slot')));

        if fname == "" || slot == ""
            continue;
        end

        if ~any(enabledFeatures == fname)
            continue; % disabled -> do not insert
        end

        if ~isKey(featMap, char(fname))
            error("Feature '%s' not found in features.json registry.", fname);
        end

        featFile = featMap(char(fname));
        featPath = fullfile(local_templates_dir(), "features", featFile);
        if exist(featPath,'file') ~= 2
            % also allow flat: templates/<featurefile>
            featPath2 = fullfile(local_templates_dir(), featFile);
            if exist(featPath2,'file') ~= 2
                error("Feature template file not found: %s", featPath);
            end
            featPath = featPath2;
        end

        code = fileread(featPath);
        code = local_any_to_char(code);

        if isKey(slotCode, char(slot))
            slotCode(char(slot)) = [slotCode(char(slot)) newline code];
        else
            slotCode(char(slot)) = code;
        end
    end

    % Replace markers
    ks = keys(slotCode);
    for i = 1:numel(ks)
        slot = ks{i};
        marker = ['%<FEATURE:' slot '>'];
        txt = local_safe_replace(txt, marker, slotCode(slot));
    end
end

function enabled = local_enabled_features(meta, opts)
    % Start from meta defaults
    enabled = strings(0,1);
    for i = 1:numel(meta.features)
        f = meta.features(i);
        if logical(local_getfield(f,'enabled',false))
            nm = strtrim(string(local_getfield(f,'feature')));
            if nm ~= ""
                enabled(end+1) = nm; %#ok<AGROW>
            end
        end
    end

    % Override by opts.features_enabled (array of structs with fields feature/enabled)
    if isfield(opts,'features_enabled') && ~isempty(opts.features_enabled)
        ov = opts.features_enabled;
        if isstruct(ov)
            for i = 1:numel(ov)
                nm = strtrim(string(local_getfield(ov(i),'feature')));
                en = logical(local_getfield(ov(i),'enabled',false));
                if nm == "", continue; end
                if en
                    if ~any(enabled == nm), enabled(end+1) = nm; end %#ok<AGROW>
                else
                    enabled = enabled(enabled ~= nm);
                end
            end
        end
    end

    enabled = unique(enabled,'stable');
end

function enabled = local_enabled_autofill(meta, opts)
    enabled = strings(0,1);
    for i = 1:numel(meta.autofill)
        a = meta.autofill(i);
        if logical(local_getfield(a,'enabled',false))
            fn = strtrim(string(local_getfield(a,'fn')));
            if fn ~= ""
                enabled(end+1) = fn; %#ok<AGROW>
            end
        end
    end

    % Override by opts.autofill_enabled (array of structs with fields fn/enabled)
    if isfield(opts,'autofill_enabled') && ~isempty(opts.autofill_enabled)
        ov = opts.autofill_enabled;
        if isstruct(ov)
            for i = 1:numel(ov)
                fn = strtrim(string(local_getfield(ov(i),'fn')));
                en = logical(local_getfield(ov(i),'enabled',false));
                if fn == "", continue; end
                if en
                    if ~any(enabled == fn), enabled(end+1) = fn; end %#ok<AGROW>
                else
                    enabled = enabled(enabled ~= fn);
                end
            end
        end
    end

    enabled = unique(enabled,'stable');
end

% =========================================================================
% AUTOFILL
% =========================================================================

function inputs = local_apply_autofill(meta, inputs, enabledAutofill)
    if isempty(meta.autofill)
        return;
    end

    for i = 1:numel(meta.autofill)
        af = meta.autofill(i);
        fn = strtrim(string(local_getfield(af,'fn')));
        if fn == "" || ~any(enabledAutofill == fn)
            continue;
        end

        argsKeys = local_to_string_list(local_getfield(af,'args',strings(0,1)));
        provides = local_to_string_list(local_getfield(af,'provides',strings(0,1)));

        % Resolve arg values from inputs
        argVals = cell(1, numel(argsKeys));
        for k = 1:numel(argsKeys)
            key = strtrim(argsKeys(k));
            if key == ""
                error("Autofill '%s' has empty arg key.", fn);
            end
            if ~isfield(inputs, key)
                error("Autofill '%s' missing input '%s' (required to call autofill).", fn, key);
            end
            argVals{k} = inputs.(key);
        end

        % Validate whitelisted (if callable_functions exists)
        if exist('callable_functions','file') == 2
            try
                if ~callable_functions('exists', fn)
                    error("Autofill function not registered: %s", fn);
                end
            catch ME
                error("Autofill registry check failed for '%s': %s", fn, ME.message);
            end
        end

        % CALL THE REAL FUNCTION DIRECTLY (robust vs broken callable_functions('call'))
        outs = local_call_with_outputs(fn, argVals, provides);

        % Apply provides into inputs
        if ~isempty(provides)
            for k = 1:numel(provides)
                key = char(provides(k));
                inputs.(key) = outs{k};
            end
        end
    end
end

function outs = local_call_with_outputs(fn, argVals, provides)
nOut = numel(provides);
outs = cell(1, nOut);

% 1) Preferred path: use callable_functions dispatcher (so autofills do NOT need to exist as separate top-level functions)
if exist('callable_functions','file') == 2
    try
        if callable_functions('exists', fn)
            tmp = callable_functions('call', fn, argVals{:});  % we made this return a STRUCT

            if nOut == 0
                return;
            end

            if isstruct(tmp)
                for k = 1:nOut
                    key = char(provides(k));
                    if ~isfield(tmp, key)
                        error("Callable function returned struct missing field '%s'.", key);
                    end
                    outs{k} = tmp.(key);
                end
                return;
            end

            % If someone returns non-struct and you requested 1 output
            if nOut == 1
                outs{1} = tmp;
                return;
            end

            error("Callable function returned non-struct but provides has %d outputs.", nOut);
        end
    catch ME
        error("Autofill dispatch failed for '%s': %s", fn, ME.message);
    end
end

% 2) Fallback: direct feval if it exists on path
if exist(fn,'file') ~= 2 && exist(fn,'builtin') ~= 5
    error("Autofill function not found on path: %s", fn);
end

if nOut == 0
    feval(fn, argVals{:});
elseif nOut == 1
    outs{1} = feval(fn, argVals{:});
else
    [outs{:}] = feval(fn, argVals{:});
end
end


% =========================================================================
% PLACEHOLDERS
% =========================================================================

function txt = local_substitute_placeholders(txt, meta, inputs, enabledFeatures)
    % Find all placeholders
    % <equation(key)>, <expr(key)>, <var(key)>, <func(key)>
    inputs = local_apply_input_aliases(inputs);
    pat = '<\s*(equation|expr|var|variable|func|function)\s*\(\s*([A-Za-z]\w*)\s*\)\s*>';
    toks = regexp(txt, pat, 'tokens');

    if isempty(toks)
        % still validate required inputs present (for non-feature-owned)
        local_validate_required_inputs(meta, inputs, enabledFeatures);
        return;
    end

    % Validate required inputs (feature-aware)
    local_validate_required_inputs(meta, inputs, enabledFeatures);

    for i = 1:numel(toks)
        kind = lower(string(toks{i}{1}));
        key  = string(toks{i}{2});
        fullToken = "<" + kind + "(" + key + ")>";

        if ~isfield(inputs, char(key))
            inputs = local_fill_defaults(meta, inputs);
            inputs = local_apply_input_aliases(inputs);   % <-- ADD THIS
            if ~isfield(inputs, char(key))
                error("Template missing required input: %s", key);
            end
        end

        v = inputs.(char(key));
        rep = local_render_token(kind, key, v);

        txt = local_safe_replace(txt, char(fullToken), rep);
    end
end

function rep = local_render_token(kind, key, v)
    %#ok<INUSD>
    switch kind
        case {"var","variable"}
            rep = local_any_to_char(v);

        case "equation"
            % raw equation string as user typed (no forced conversion)
            rep = local_any_to_char(v);

        case "expr"
            % symbolic-friendly expression in zero form
            s0 = code_helpers('to_zero_form', string(v));
            rep = code_helpers('make_symbolic_expr', s0);
            rep = local_any_to_char(rep);

        case {"func","function"}
            % numeric anonymous function (vectorized)
            s0 = code_helpers('to_zero_form', string(v));
            expr = code_helpers('make_matlab_expr', s0);
            expr = local_any_to_char(expr);

            % Detect 2D vs 1D by variable names
            if contains(string(expr), "x2") || contains(string(expr), "x_2") || contains(string(expr), "x1")
                rep = ['@(x1,x2) ' expr];
            else
                rep = ['@(x) ' expr];
            end

        otherwise
            rep = local_any_to_char(v);
    end
end

function local_validate_required_inputs(meta, inputs, enabledFeatures)
    % Required means: must exist after defaults/autofill, UNLESS input belongs to disabled feature.
    inputs = local_apply_input_aliases(inputs);
    for i = 1:numel(meta.inputs)
        inp = meta.inputs(i);
        key = strtrim(string(local_getfield(inp,'key')));
        if key == ""
            continue;
        end

        req = logical(local_getfield(inp,'required',false));
        if ~req
            continue;
        end

        feat = strtrim(string(local_getfield(inp,'feature',"")));
        if feat ~= "" && ~any(enabledFeatures == feat)
            continue; % feature disabled -> do not require
        end

        if ~isfield(inputs, char(key))
            error("Template missing required input: %s", key);
        end

        % also reject blank strings
        vv = inputs.(char(key));
        if (isstring(vv) || ischar(vv)) && strtrim(string(vv)) == ""
            error("Template missing required input: %s", key);
        end
    end
end

% =========================================================================
% REGISTRY / META I/O
% =========================================================================

function reg = local_load_registry()
    p = local_registry_path();
    if exist(p,'file') ~= 2
        error("registry.json not found: %s", p);
    end
    raw = fileread(p);
    raw = strtrim(string(raw));
    if raw == ""
        reg = struct([]);
        return;
    end
    reg = jsondecode(char(raw));

    % Ensure struct array
    if isstruct(reg)
        % ok
    elseif iscell(reg) && all(cellfun(@isstruct, reg))
        reg = [reg{:}];
    else
        error("registry.json must decode to struct array.");
    end

    % Normalize each meta a little (features/autofill sometimes come as struct)
    for i = 1:numel(reg)
        reg(i) = local_normalize_meta(reg(i));
    end
end

function feats = local_load_features_registry()
    tplDir = local_templates_dir();

    candidates = [
        fullfile(tplDir, "features.json")
        fullfile(tplDir, "features", "features.json")
    ];

    fpath = "";
    for i = 1:size(candidates,1)
        if exist(candidates(i), 'file') == 2
            fpath = string(candidates(i));
            break;
        end
    end

    if fpath == ""
        feats = struct([]);
        return;
    end

    raw = fileread(char(fpath));
    raw = strtrim(string(raw));
    if raw == ""
        feats = struct([]);
        return;
    end

    feats = jsondecode(char(raw));

    if isstruct(feats)
        % ok
    elseif iscell(feats) && all(cellfun(@isstruct, feats))
        feats = [feats{:}];
    else
        error("features.json must decode to struct array.");
    end
end

function meta = local_get_meta(reg, templateId)
    ids = string({reg.id});
    idx = find(ids == string(templateId), 1);
    if isempty(idx)
        error("Template id not found in registry: %s", templateId);
    end
    meta = reg(idx);
end

function meta = local_normalize_meta(meta)
    % Normalize inputs
    meta.inputs   = local_norm_struct_array(local_getfield(meta,'inputs',struct([])));
    meta.features = local_norm_struct_array(local_getfield(meta,'features',struct([])));
    meta.autofill = local_norm_struct_array(local_getfield(meta,'autofill',struct([])));

    % Also allow single autofill struct (old registry) -> convert to 1-element array
    if isstruct(meta.autofill) && numel(meta.autofill) == 1
        % ok
    end
end

function arr = local_norm_struct_array(x)
    if isempty(x)
        arr = struct([]);
        return;
    end
    if isstruct(x)
        arr = x;
        return;
    end
    if iscell(x) && all(cellfun(@isstruct, x))
        arr = [x{:}];
        return;
    end
    % Sometimes jsondecode gives a struct with fields but meant as single object
    if isobject(x)
        error("Unsupported registry field type: %s", class(x));
    end
    error("Unsupported registry format: expected struct or cell-of-struct.");
end

function inputs = local_fill_defaults(meta, inputs)
    for i = 1:numel(meta.inputs)
        inp = meta.inputs(i);
        key = strtrim(string(local_getfield(inp,'key')));
        if key == ""
            continue;
        end
        if ~isfield(inputs, char(key)) || isempty(inputs.(char(key)))
            def = local_getfield(inp,'default',[]);
            if ~isempty(def) || (ischar(def) || isstring(def))
                inputs.(char(key)) = def;
            end
        end
    end
end

function local_add_template(meta, tplText)
    reg = local_load_registry();
    meta = local_normalize_meta(meta);

    id = string(local_getfield(meta,'id'));
    if any(string({reg.id}) == id)
        error("Template id already exists: %s", id);
    end

    % Write template file
    tplDir = local_templates_dir();
    tplFile = string(local_getfield(meta,'template_file'));
    if strtrim(tplFile) == ""
        tplFile = id + ".tmpl";
        meta.template_file = char(tplFile);
    end
    tplPath = fullfile(tplDir, tplFile);
    local_write_text_file(tplPath, tplText);

    % Append to registry + save
    reg(end+1) = meta; %#ok<AGROW>
    local_save_registry(reg);
end

function local_update_template(oldId, meta, tplText)
    reg = local_load_registry();
    meta = local_normalize_meta(meta);

    ids = string({reg.id});
    idx = find(ids == string(oldId), 1);
    if isempty(idx)
        error("Template id not found for update: %s", oldId);
    end

    % If id changed, ensure no conflict
    newId = string(local_getfield(meta,'id'));
    if newId ~= string(oldId) && any(ids == newId)
        error("Cannot rename template to existing id: %s", newId);
    end

    % Write template file
    tplDir = local_templates_dir();
    tplFile = string(local_getfield(meta,'template_file'));
    if strtrim(tplFile) == ""
        tplFile = newId + ".tmpl";
        meta.template_file = char(tplFile);
    end
    tplPath = fullfile(tplDir, tplFile);
    local_write_text_file(tplPath, tplText);

    % Update registry entry
    reg(idx) = meta;
    local_save_registry(reg);
end

function local_save_registry(reg)
    p = local_registry_path();
    try
        txt = jsonencode(reg, 'PrettyPrint', true);
    catch
        txt = jsonencode(reg);
    end
    local_write_text_file(p, txt);
end

function local_write_text_file(path, txt)
    path = char(string(path));
    fid = fopen(path, 'w');
    if fid < 0
        error("Could not write file: %s", path);
    end
    cleanup = onCleanup(@() fclose(fid)); %#ok<NASGU>
    fwrite(fid, local_any_to_char(txt));
    fwrite(fid, newline);
end

function p = local_registry_path()
    p = fullfile(local_templates_dir(), "registry.json");
end

function d = local_templates_dir()
    % Use your helper if present; otherwise relative to this file
    if exist('code_helpers','file') == 2
        try
            d = code_helpers('get_templates_dir');
            d = char(string(d));
            return;
        catch
        end
    end
    d = fullfile(fileparts(mfilename('fullpath')), "templates");
end

% =========================================================================
% SAFE REPLACE (kills MATLAB replace() type errors)
% =========================================================================

function txt = local_safe_replace(txt, old, new)
    txt = local_any_to_char(txt);
    old = local_any_to_char(old);
    new = local_any_to_char(new);
    txt = strrep(txt, old, new);
end

function s = local_any_to_char(v)
    if isempty(v)
        s = '';
        return;
    end

    if ischar(v)
        s = v;
    elseif isstring(v)
        if isscalar(v)
            s = char(v);
        else
            s = strjoin(cellstr(v(:)), newline);
        end
    elseif isnumeric(v) || islogical(v)
        if isscalar(v)
            s = sprintf('%.16g', double(v));
        else
            s = mat2str(v, 16);
        end
    elseif iscell(v)
        try
            s = strjoin(cellstr(string(v)), ';');
        catch
            s = char(string(v));
        end
    elseif isstruct(v)
        try
            s = jsonencode(v);
        catch
            s = '<struct>';
        end
    else
        s = char(string(v));
    end

    if size(s,1) > 1
        s = strjoin(cellstr(s), newline);
    end
end

function v = local_getfield(s, field, default)
    if nargin < 3, default = []; end
    if isstruct(s) && isfield(s, field)
        v = s.(field);
    else
        v = default;
    end
end

function arr = local_to_string_list(v)
    if isempty(v)
        arr = strings(0,1);
        return;
    end
    if isstring(v)
        arr = v(:);
        return;
    end
    if ischar(v)
        arr = string(v);
        return;
    end
    if iscell(v)
        arr = string(v(:));
        return;
    end
    arr = string(v);
end

function inputs = local_apply_input_aliases(inputs)
% Allows templates to use either:
%   target_var <-> find_var
%   ndp        <-> find_digits

    if ~isstruct(inputs)
        return;
    end

    alias = {
        'find_var',    'target_var'
        'target_var',  'find_var'
        'find_digits', 'ndp'
        'ndp',         'find_digits'
    };

    for i = 1:size(alias,1)
        src = alias{i,1};
        dst = alias{i,2};

        if isfield(inputs, src) && ~isfield(inputs, dst)
            inputs.(dst) = inputs.(src);
        end
    end
end
