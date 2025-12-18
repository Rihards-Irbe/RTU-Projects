function varargout = code_template_engine(action, varargin)
% CODE_TEMPLATE_ENGINE  Robust template renderer (NO regexprep replacements).
%
% This version never calls regexprep with a REPLACE argument.
% It uses string + replace() so you will not get:
%   "The 'REPLACE' input must be either a char row vector..."
%
% Supported actions (aliases included):
%   code_template_engine('render', templateOrIdOrPath, inputsStruct, meta?, opts?)
%   code_template_engine('render_text', ...)
%   code_template_engine('render_template', ...)
%   code_template_engine('scan', templateOrPathOrText)
%
% Notes:
% - templateOrIdOrPath can be:
%     * template ID from registry.json (e.g. "task_newton_system_2d")
%     * a full path to a .tmpl
%     * raw template text

    action = lower(string(action));

    switch action
        case {"render","render_text","render_template"}
            tplArg = varargin{1};
            inputs = struct();
            if numel(varargin) >= 2 && isstruct(varargin{2})
                inputs = varargin{2};
            end

            meta = struct();
            if numel(varargin) >= 3 && (isstruct(varargin{3}) || isempty(varargin{3}))
                meta = varargin{3};
                if isempty(meta), meta = struct(); end
            end

            opts = struct();
            if numel(varargin) >= 4 && isstruct(varargin{4})
                opts = varargin{4};
            end

            [tplText, metaResolved] = local_resolve_template(tplArg, meta);
            if isempty(fieldnames(meta)) && ~isempty(fieldnames(metaResolved))
                meta = metaResolved;
            end

            out = local_render(string(tplText), inputs, meta, opts);
            varargout{1} = char(out);

        case {"scan","scan_placeholders"}
            txt = local_read_any(varargin{1});
            varargout{1} = local_scan_placeholders(string(txt));

        otherwise
            error("code_template_engine: Unknown action '%s'", action);
    end
end

% ============================ Core render ============================

function out = local_render(txt, inputs, meta, opts)
    % 1) Apply feature slots: %<FEATURE:slot>
    if ~isempty(meta) && isstruct(meta) && isfield(meta,'features')
        txt = local_apply_features(txt, inputs, meta, opts);
    end

    % 2) Replace placeholders: <var(x)>, <expr(eq)>, <equation(eq)>, <func(eq)>
    out = local_apply_placeholders(txt, inputs);
end

% ============================ Features ==============================

function txt = local_apply_features(txt, inputs, meta, opts)
    raw = char(txt);

    % Find all markers like: %<FEATURE:plot>
    pat = '%<FEATURE:([A-Za-z]\w*)>';
    [mAll, tokAll] = regexp(raw, pat, 'match', 'tokens');

    if isempty(mAll)
        return;
    end

    featsReg = local_load_features_registry();
    featsInMeta = local_normalize_struct_array(meta.features);

    for k = 1:numel(mAll)
        marker = string(mAll{k});
        slot   = string(tokAll{k}{1});

        insertText = "";

        for i = 1:numel(featsInMeta)
            if ~isfield(featsInMeta(i),'slot'), continue; end
            if string(featsInMeta(i).slot) ~= slot, continue; end

            featName = "";
            if isfield(featsInMeta(i),'feature')
                featName = string(featsInMeta(i).feature);
            end

            enabled = false;
            if isfield(featsInMeta(i),'enabled')
                enabled = logical_default(featsInMeta(i).enabled);
            end

            % opts.features_enabled override
            enabled = local_apply_enabled_override(enabled, featName, opts);

            if ~enabled
                continue;
            end

            featFile = local_feature_file(featsReg, featName);
            if featFile == ""
                error("Feature '%s' not found in features.json.", featName);
            end

            featText = local_read_feature_template(featFile);
            featText = local_apply_placeholders(string(featText), inputs);

            if strlength(strtrim(insertText)) == 0
                insertText = featText;
            else
                insertText = insertText + newline + featText;
            end
        end

        % Replace marker with insertText (or blank)
        txt = replace(txt, marker, insertText);
    end
end

function enabled = local_apply_enabled_override(enabled0, featName, opts)
    enabled = enabled0;

    if ~isstruct(opts) || ~isfield(opts,'features_enabled') || isempty(opts.features_enabled)
        return;
    end

    ov = opts.features_enabled;
    if iscell(ov) && all(cellfun(@isstruct, ov)), ov = [ov{:}]; end
    if ~isstruct(ov), return; end

    for i = 1:numel(ov)
        if ~isfield(ov(i),'feature') || ~isfield(ov(i),'enabled'), continue; end
        if string(ov(i).feature) == featName
            enabled = logical_default(ov(i).enabled);
            return;
        end
    end
end

function featsReg = local_load_features_registry()
    tplDir = local_templates_dir();

    candidates = [
        fullfile(tplDir, "features.json")
        fullfile(tplDir, "features", "features.json")
    ];

    featsReg = struct([]);
    for i = 1:size(candidates,1)
        p = candidates(i,:);
        if exist(p,'file')
            s = jsondecode(fileread(p));
            featsReg = local_normalize_struct_array(s);
            return;
        end
    end

    % If missing, just return empty; rendering will error only if you use features.
    featsReg = struct([]);
end

function featFile = local_feature_file(featsReg, featName)
    featFile = "";
    if isempty(featsReg), return; end

    for i = 1:numel(featsReg)
        if isfield(featsReg(i),'feature') && string(featsReg(i).feature) == featName
            if isfield(featsReg(i),'file')
                featFile = string(featsReg(i).file);
                return;
            end
        end
    end
end

function txt = local_read_feature_template(featFile)
    tplDir = local_templates_dir();

    % Features may live in templates/features/
    p1 = fullfile(tplDir, "features", char(featFile));
    p2 = fullfile(tplDir, char(featFile));

    if exist(p1,'file')
        txt = fileread(p1); return;
    end
    if exist(p2,'file')
        txt = fileread(p2); return;
    end

    error("Feature template not found: %s", featFile);
end

% ============================ Placeholders ==========================

function txt = local_apply_placeholders(txt, inputs)
    raw = char(txt);

    pat = '<\s*(var|expr|equation|func)\s*\(\s*([A-Za-z]\w*)\s*\)\s*>';
    [mAll, tokAll] = regexp(raw, pat, 'match', 'tokens');

    if isempty(mAll)
        return;
    end

    for k = 1:numel(mAll)
        whole = string(mAll{k});
        kind  = string(tokAll{k}{1});
        key   = string(tokAll{k}{2});

        val = local_get_required_input(inputs, key);

        rep = "";
        switch kind
            case "var"
                rep = local_format_literal(val);

            case "equation"
                rep = string(val);

            case "expr"
                % symbolic expression (no element-wise ops)
                rep = local_make_symbolic_expr(string(val));

            case "func"
                % numeric / vectorized expression (element-wise ops)
                rep = local_make_matlab_expr(string(val));

            otherwise
                rep = local_format_literal(val);
        end

        txt = replace(txt, whole, rep);
    end
end

function v = local_get_required_input(inputs, key)
    if ~isstruct(inputs) || ~isfield(inputs, key)
        error("Template missing required input: %s", key);
    end
    v = inputs.(key);
end

function s = local_format_literal(v)
    % Always return STRING SCALAR, usable in replace() reliably.
    if isstring(v)
        if isempty(v), s = ""; return; end
        if isscalar(v), s = v; else, s = strjoin(v(:).', " "); end
        return;
    end
    if ischar(v)
        s = string(v);
        return;
    end
    if isnumeric(v) || islogical(v)
        if isempty(v)
            s = "[]";
        elseif isscalar(v)
            s = string(sprintf('%.16g', double(v)));
        else
            s = string(mat2str(double(v), 16));
        end
        return;
    end
    if iscell(v)
        s = strjoin(string(v), ";");
        return;
    end
    error("code_template_engine: unsupported value type for <%s>: %s", "var", class(v));
end

% ============================ Expression helpers ====================

function out = local_to_zero_form(s)
    s = strtrim(string(s));
    if contains(s, "=")
        parts = split(s, "=");
        if numel(parts) >= 2
            left  = strtrim(parts(1));
            right = strtrim(parts(2));
            if right == "0"
                out = left;
            else
                out = "(" + left + ")-(" + right + ")";
            end
            return;
        end
    end
    out = s;
end

function expr = local_make_matlab_expr(eq)
    % vectorized numeric expression
    s = local_to_zero_form(eq);
    s = replace(s, "ln(", "log(");
    s = replace(s, "arctg", "atan");

    % e^(...) and e^x -> exp(...)
    ss = char(s);
    ss = regexprep(ss, 'e\^\(([^)]*)\)', 'exp($1)');
    ss = regexprep(ss, 'e\^([^\(\)\s]+)', 'exp($1)');

    % sqrt^n(x) -> sqrt_power(x,n)
    ss = local_sqrt_power_numeric(ss);

    % element-wise ops
    ss = regexprep(ss, '(?<!\.)\^', '.^');
    ss = regexprep(ss, '(?<!\.)\*', '.*');
    ss = regexprep(ss, '(?<!\.)/',  './');

    expr = string(ss);
end

function expr = local_make_symbolic_expr(eq)
    % symbolic-friendly expression
    s = local_to_zero_form(eq);
    s = replace(s, "ln(", "log(");
    s = replace(s, "arctg", "atan");

    ss = char(s);
    ss = regexprep(ss, 'e\^\(([^)]*)\)', 'exp($1)');
    ss = regexprep(ss, 'e\^([^\(\)\s]+)', 'exp($1)');

    % sqrt^n(x) -> (x)^(1/n)
    ss = local_sqrt_power_symbolic(ss);

    % ensure normal ops (not element-wise)
    ss = strrep(ss, '.^', '^');
    ss = strrep(ss, '.*', '*');
    ss = strrep(ss, './', '/');

    expr = string(ss);
end

function ss = local_sqrt_power_numeric(ss)
    pat = 'sqrt\^(\d+)';
    [st, en, tok] = regexp(ss, pat, 'start', 'end', 'tokens');
    for i = numel(st):-1:1
        n = tok{i}{1};
        openp = en(i) + 1;
        if openp > length(ss) || ss(openp) ~= '('
            continue;
        end
        % find matching )
        pc = 1; p = openp + 1;
        while p <= length(ss) && pc > 0
            if ss(p) == '(', pc = pc + 1; end
            if ss(p) == ')', pc = pc - 1; end
            p = p + 1;
        end
        if pc ~= 0, continue; end
        closep = p - 1;
        arg = ss(openp+1 : closep-1);
        rep = ['sqrt_power(' arg ', ' n ')'];
        ss = [ss(1:st(i)-1) rep ss(closep+1:end)];
    end
end

function ss = local_sqrt_power_symbolic(ss)
    pat = 'sqrt\^(\d+)';
    [st, en, tok] = regexp(ss, pat, 'start', 'end', 'tokens');
    for i = numel(st):-1:1
        n = tok{i}{1};
        openp = en(i) + 1;
        if openp > length(ss) || ss(openp) ~= '('
            continue;
        end
        pc = 1; p = openp + 1;
        while p <= length(ss) && pc > 0
            if ss(p) == '(', pc = pc + 1; end
            if ss(p) == ')', pc = pc - 1; end
            p = p + 1;
        end
        if pc ~= 0, continue; end
        closep = p - 1;
        arg = ss(openp+1 : closep-1);
        rep = ['(' arg ')^(1/' n ')'];
        ss = [ss(1:st(i)-1) rep ss(closep+1:end)];
    end
end

% ============================ Scan helper ===========================

function items = local_scan_placeholders(txt)
    raw = char(txt);
    pat = '<\s*(var|expr|equation|func)\s*\(\s*([A-Za-z]\w*)\s*\)\s*>';
    m = regexp(raw, pat, 'match');
    items = unique(string(m), 'stable');
end

% ============================ Template resolution ===================

function [tplText, meta] = local_resolve_template(tplArg, metaIn)
    meta = metaIn;
    tplText = "";

    % 1) If tplArg is a file path
    p = char(string(tplArg));
    if exist(p,'file')
        tplText = fileread(p);
        return;
    end

    s = string(tplArg);

    % 2) If it looks like raw template text
    if contains(s, newline) || contains(s, "<var(") || contains(s, "%<FEATURE:")
        tplText = s;
        return;
    end

    % 3) Otherwise treat as template ID and load from registry
    tplId = strtrim(s);
    [metaLoaded, tplLoaded] = local_load_template_by_id(tplId);
    meta = metaLoaded;
    tplText = tplLoaded;
end

function [meta, tplText] = local_load_template_by_id(tplId)
    tplDir = local_templates_dir();
    regPath = fullfile(tplDir, "registry.json");
    if ~exist(regPath,'file')
        error("registry.json not found at: %s", regPath);
    end
    reg = jsondecode(fileread(regPath));
    reg = local_normalize_struct_array(reg);

    idx = [];
    for i = 1:numel(reg)
        if isfield(reg(i),'id') && string(reg(i).id) == tplId
            idx = i; break;
        end
    end
    if isempty(idx)
        error("Template id not found in registry: %s", tplId);
    end

    meta = reg(idx);
    tplPath = fullfile(tplDir, string(meta.template_file));
    if ~exist(tplPath,'file')
        error("Template file not found: %s", tplPath);
    end
    tplText = fileread(tplPath);
end

function txt = local_read_any(x)
    p = char(string(x));
    if exist(p,'file')
        txt = fileread(p);
    else
        txt = char(string(x));
    end
end

function dirp = local_templates_dir()
    % Prefer your existing helper if available
    try
        dirp = code_helpers("get_templates_dir");
        dirp = char(string(dirp));
        return;
    catch
    end

    % Fallback: same folder as this file + /templates
    baseDir = fileparts(mfilename('fullpath'));
    dirp = fullfile(baseDir, "templates");
end

function arr = local_normalize_struct_array(x)
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
    error("Unsupported JSON format: expected struct/struct[]/cell of structs.");
end

function b = logical_default(v)
    try
        if isempty(v), b = false; else, b = logical(v); end
    catch
        b = false;
    end
end
