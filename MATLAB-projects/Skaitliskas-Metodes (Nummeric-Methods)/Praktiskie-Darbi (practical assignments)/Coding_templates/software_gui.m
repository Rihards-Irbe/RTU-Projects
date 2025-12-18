function software_gui
% SOFTWARE_GUI  Template-driven GUI:
%   - pick template
%   - fill inputs (feature-owned inputs only show if feature enabled)
%   - preview / generate .m
%   - add/edit templates (Inputs + Autofill + Features + code)
%
% Requires (same folder):
%   - code_generator.m
%   - code_helpers.m
%   - code_template_engine.m
%   - callable_functions.m
%
% Templates:
%   templates/registry.json
%   templates/*.tmpl
%
% Features:
%   templates/features.json OR templates/features/features.json
%   templates/features/*.tmpl

    fig = uifigure('Name','Code Generator (Templates)', 'Position',[120 120 1100 720]);

    root = uigridlayout(fig, [1 2]);
    root.ColumnWidth = {340, '1x'};
    root.RowHeight = {'1x'};
    root.ColumnSpacing = 10;
    root.RowSpacing = 10;
    root.Padding = [10 10 10 10];

    % ================= LEFT: template list =================
    left = uipanel(root, 'Title','Templates');
    leftGL = uigridlayout(left, [3 1]);
    leftGL.RowHeight = {'1x', 130, 44};
    leftGL.RowSpacing = 8;
    leftGL.Padding = [8 8 8 8];

    [reg, titles, ids] = loadRegistryAndList();

    lb = uilistbox(leftGL, ...
        'Items', cellstr(titles), ...
        'ItemsData', cellstr(ids), ...
        'Value', char(ids(1)));

    desc = uitextarea(leftGL, 'Editable','off', 'Value', {'Select a template...'});
    desc.Layout.Row = 2;

    btnBar = uigridlayout(leftGL, [1 3]);
    btnBar.Layout.Row = 3;
    btnBar.ColumnWidth = {'1x','1x','1x'};
    btnBar.RowHeight = {34};
    btnBar.ColumnSpacing = 10;
    btnBar.Padding = [0 0 0 0];

    uibutton(btnBar, 'Text','Reload',       'ButtonPushedFcn', @(~,~)reloadRegistry());
    uibutton(btnBar, 'Text','Add template', 'ButtonPushedFcn', @(~,~)openTemplateEditor("add"));
    uibutton(btnBar, 'Text','Edit template','ButtonPushedFcn', @(~,~)openTemplateEditor("edit"));

    % ================= RIGHT: options + fields + output =================
    right = uipanel(root, 'Title','Inputs / Features / Autofill');
    rightGL = uigridlayout(right, [4 1]);
    rightGL.RowHeight = {200, '1x', 120, 52};
    rightGL.RowSpacing = 10;
    rightGL.Padding = [8 8 8 8];

    % ---- Tabs: Features + Autofill ----
    tabsPanel = uipanel(rightGL, 'Title','Options');
    tabsGL = uigridlayout(tabsPanel, [1 1]);
    tabsGL.Padding = [8 8 8 8];

    tabs = uitabgroup(tabsGL);

    tabFeatures = uitab(tabs, 'Title','Features');
    featGL = uigridlayout(tabFeatures, [2 1]);
    featGL.RowHeight = {'1x', 22};
    featGL.RowSpacing = 6;
    featGL.Padding = [8 8 8 8];

    featuresTbl = uitable(featGL, ...
        'Data', cell(0,4), ...
        'ColumnName', {'enabled','feature','slot','description'}, ...
        'ColumnEditable', [true false false false], ...
        'RowName', {});
    tipFeat = uilabel(featGL, 'Text', ...
        'Tip: disabling a feature hides its variables and stops inserting its code.', ...
        'FontAngle','italic');
    tipFeat.Layout.Row = 2;

    tabAutofill = uitab(tabs, 'Title','Autofill');
    autoGL = uigridlayout(tabAutofill, [2 1]);
    autoGL.RowHeight = {'1x', 22};
    autoGL.RowSpacing = 6;
    autoGL.Padding = [8 8 8 8];

    autofillTbl = uitable(autoGL, ...
        'Data', cell(0,4), ...
        'ColumnName', {'enabled','fn','args(...)','provides'}, ...
        'ColumnEditable', [true false false false], ...
        'RowName', {});
    tipAuto = uilabel(autoGL, 'Text', ...
        'Tip: enabled autofill rows are called once and can fill multiple outputs (provides).', ...
        'FontAngle','italic');
    tipAuto.Layout.Row = 2;

    % ---- Scrollable Fields panel ----
    formScroll = uipanel(rightGL, 'Title','Fields', 'Scrollable','on');
    fig.WindowScrollWheelFcn = @onWheelScroll;

    % ---- Output panel ----
    bottom = uipanel(rightGL, 'Title','Output');
    bottomGL = uigridlayout(bottom, [2 2]);
    bottomGL.ColumnWidth = {220, '1x'};
    bottomGL.RowHeight = {28, 28};
    bottomGL.Padding = [12 12 12 12];
    bottomGL.RowSpacing = 10;
    bottomGL.ColumnSpacing = 10;

    uilabel(bottomGL, 'Text','Output file:');
    outFileField = uieditfield(bottomGL, 'text', 'Value','generated_task.m');

    uilabel(bottomGL, 'Text','Status:');
    status = uieditfield(bottomGL, 'text', 'Editable','off', 'Value','Ready.');

    % ---- Buttons ----
    btnRow = uigridlayout(rightGL, [1 3]);
    btnRow.ColumnWidth = {'1x','1x','1x'};
    btnRow.RowHeight = {34};
    btnRow.Padding = [12 0 12 12];
    btnRow.ColumnSpacing = 10;

    uibutton(btnRow, 'Text','Render Preview', 'ButtonPushedFcn', @(~,~)doPreview());
    uibutton(btnRow, 'Text','Generate .m',    'ButtonPushedFcn', @(~,~)doGenerate());
    uibutton(btnRow, 'Text','Open Output',    'ButtonPushedFcn', @(~,~)doOpen());

    lastGenerated = "";

    lb.ValueChangedFcn = @(src,~)onSelect(string(src.Value));
    featuresTbl.CellEditCallback = @(~,~)onOptionsChanged();
    autofillTbl.CellEditCallback = @(~,~)onOptionsChanged();

    onSelect(string(lb.Value));

    % ================= callbacks =================

    function reloadRegistry()
        [reg, titles, ids] = loadRegistryAndList();
        lb.Items = cellstr(titles);
        lb.ItemsData = cellstr(ids);
        lb.Value = char(ids(1));
        onSelect(string(lb.Value));
        status.Value = "Registry reloaded.";
    end

    function onSelect(selectedId)
        meta = getMetaById(reg, selectedId);
        desc.Value = {char(string(meta.description))};

        fillFeaturesTable(meta);
        fillAutofillTable(meta);
        rebuildFields(meta);

        outFileField.Value = char(string(meta.id) + ".m");
        status.Value = "Fill fields and generate.";
    end

    function onOptionsChanged()
        try
            meta = getMetaById(reg, string(lb.Value));
            rebuildFields(meta);
        catch
        end
    end

    function fillFeaturesTable(meta)
        ft = normalizeFeatures(getfield_or_empty(meta,'features'));
        if isempty(ft)
            featuresTbl.Data = cell(0,4);
            return;
        end
        data = cell(numel(ft), 4);
        for i = 1:numel(ft)
            data{i,1} = logicalDefault(getfield_or_empty(ft(i),'enabled'));
            data{i,2} = char(string(getfield_or_empty(ft(i),'feature')));
            data{i,3} = char(string(getfield_or_empty(ft(i),'slot')));
            data{i,4} = char(string(getfield_or_empty(ft(i),'description')));
        end
        featuresTbl.Data = data;
    end

    function fillAutofillTable(meta)
        af = normalizeAutofill(getfield_or_empty(meta,'autofill'));
        if isempty(af)
            autofillTbl.Data = cell(0,4);
            return;
        end
        data = cell(numel(af), 4);
        for i = 1:numel(af)
            data{i,1} = logicalDefault(getfield_or_empty(af(i),'enabled'));
            data{i,2} = char(string(getfield_or_empty(af(i),'fn')));
            data{i,3} = char("args(" + renderList(getfield_or_empty(af(i),'args')) + ")");
            data{i,4} = char("provides(" + renderList(getfield_or_empty(af(i),'provides')) + ")");
        end
        autofillTbl.Data = data;
    end

    function s = renderList(v)
        if isempty(v), s = ""; return; end
        vv = string(v);
        vv = vv(strtrim(vv) ~= "");
        if isempty(vv), s = ""; return; end
        s = strjoin(cellstr(vv), ';');
    end

    function enabledFeatures = enabledFeaturesList()
        enabledFeatures = strings(0,1);
        if isempty(featuresTbl.Data), return; end
        d = featuresTbl.Data;
        for i = 1:size(d,1)
            en = false;
            try, en = logical(d{i,1}); catch, end
            nm = "";
            try, nm = string(d{i,2}); catch, end
            nm = strtrim(nm);
            if en && nm ~= ""
                enabledFeatures(end+1) = nm; %#ok<AGROW>
            end
        end
        enabledFeatures = unique(enabledFeatures, 'stable');
    end

    function providesKeys = enabledAutofillProvides(meta)
        providesKeys = strings(0,1);
        af = normalizeAutofill(getfield_or_empty(meta,'autofill'));
        if isempty(af) || isempty(autofillTbl.Data), return; end

        d = autofillTbl.Data;
        for i = 1:min(size(d,1), numel(af))
            en = false;
            try, en = logical(d{i,1}); catch, end
            if en
                pv = getfield_or_empty(af(i),'provides');
                if ~isempty(pv)
                    providesKeys = [providesKeys; string(pv(:))]; %#ok<AGROW>
                end
            end
        end
        providesKeys = unique(providesKeys, 'stable');
    end

    function rebuildFields(meta)
        delete(formScroll.Children);

        inputsArr = normalizeInputs(meta.inputs);
        if isempty(inputsArr)
            uilabel(formScroll, 'Text','(No inputs for this template)');
            formScroll.UserData = struct('controls',struct(), 'disabledKeys', strings(0,1));
            return;
        end

        enabledFeat = enabledFeaturesList();
        provides = enabledAutofillProvides(meta);

        visible = false(1, numel(inputsArr));
        for i = 1:numel(inputsArr)
            key  = string(getfield_or_empty(inputsArr(i),'key'));
            feat = string(getfield_or_empty(inputsArr(i),'feature'));
            if strtrim(key) == "", continue; end
            if strtrim(feat) ~= "" && ~any(enabledFeat == feat)
                continue;
            end
            visible(i) = true;
        end

        showArr = inputsArr(visible);
        nShow = numel(showArr);

        if nShow == 0
            uilabel(formScroll, 'Text','(No fields to show. Enable a feature or check inputs.)');
            formScroll.UserData = struct('controls',struct(), 'disabledKeys', strings(0,1));
            return;
        end

        formGL = uigridlayout(formScroll, [nShow 2]);
        formGL.ColumnWidth = {260, '1x'};
        formGL.RowHeight = repmat({28}, 1, nShow);
        formGL.RowSpacing = 10;
        formGL.Padding = [12 12 12 12];

        controls = struct();
        disabledKeys = strings(0,1);

        for i = 1:nShow
            inp = showArr(i);
            key   = string(getfield_or_empty(inp,'key'));
            label = string(getfield_or_empty(inp,'label'));
            type  = string(getfield_or_empty(inp,'type'));
            feat  = string(getfield_or_empty(inp,'feature'));

            if strtrim(feat) ~= ""
                labelShown = "[" + feat + "] " + label;
            else
                labelShown = label;
            end

            uilabel(formGL, 'Text', char(labelShown + " (" + key + "):"));

            ctrl = makeControlForInput(formGL, inp, type);

            if any(provides == key)
                try, ctrl.Enable = 'off'; catch, end
                try, ctrl.Tooltip = "Provided by enabled autofill. Disable autofill to edit manually."; catch, end
                disabledKeys(end+1) = key; %#ok<AGROW>
            end

            controls.(key) = ctrl;
        end

        formScroll.UserData = struct('controls',controls, 'disabledKeys',disabledKeys);
    end

    function ctrl = makeControlForInput(parentGL, inp, type)
        t = lower(string(type));

        switch t
            case {"equation1d","string"}
                val = "";
                if isfield(inp,'default') && ~isempty(inp.default), val = string(inp.default); end
                ctrl = uieditfield(parentGL, 'text', 'Value', char(val));

            case {"double","int"}
                def = [];
                if isfield(inp,'default'), def = inp.default; end
                val = coerceDoubleScalar(def, 0);
                if t == "int", val = round(val); end
                ctrl = uieditfield(parentGL, 'numeric', 'Value', val);

            case "vector"
                val = "[ ]";
                if isfield(inp,'default') && ~isempty(inp.default)
                    try, val = mat2str(double(inp.default), 16); catch, val = "[ ]"; end
                end
                ctrl = uieditfield(parentGL, 'text', 'Value', char(val));

            otherwise
                ctrl = uieditfield(parentGL, 'text', 'Value', '');
        end
    end

    function [meta, inputsStruct, opts] = collectInputs()
        selectedId = string(lb.Value);
        meta = getMetaById(reg, selectedId);

        ui = formScroll.UserData;
        controls = ui.controls;
        disabledKeys = ui.disabledKeys;

        inputsStruct = struct();

        inputsArr = normalizeInputs(meta.inputs);
        enabledFeat = enabledFeaturesList();

        for i = 1:numel(inputsArr)
            inp = inputsArr(i);
            key  = string(getfield_or_empty(inp,'key'));
            typ  = lower(string(getfield_or_empty(inp,'type')));
            feat = string(getfield_or_empty(inp,'feature'));

            if strtrim(key) == "", continue; end
            if strtrim(feat) ~= "" && ~any(enabledFeat == feat), continue; end
            if ~isfield(controls, key), continue; end
            if any(disabledKeys == key), continue; end

            ctrl = controls.(key);

            switch typ
                case {"equation1d","string"}
                    v = string(ctrl.Value);
                case "double"
                    v = double(ctrl.Value);
                case "int"
                    v = round(double(ctrl.Value));
                case "vector"
                    v = code_helpers("parse_vector", string(ctrl.Value));
                otherwise
                    v = string(ctrl.Value);
            end

            if logicalDefault(getfield_or_empty(inp,'required'))
                if (isstring(v) || ischar(v)) && strtrim(string(v)) == ""
                    error("Field '%s' is required.", key);
                end
                if isnumeric(v) && isempty(v)
                    error("Field '%s' is required.", key);
                end
            end

            mn = getfield_or_empty(inp,'min');
            if ~isempty(mn) && isnumeric(v) && isscalar(v)
                if v < double(mn)
                    error("Field '%s' must be >= %g.", key, double(mn));
                end
            end

            inputsStruct.(key) = v;
        end

        opts = struct();

        if ~isempty(featuresTbl.Data)
            d = featuresTbl.Data;
            ov = struct('feature',{},'enabled',{});
            for i = 1:size(d,1)
                nm = strtrim(string(d{i,2}));
                if nm == "", continue; end
                en = false;
                try, en = logical(d{i,1}); catch, end
                ov(end+1).feature = nm; %#ok<AGROW>
                ov(end).enabled = en;
            end
            if ~isempty(ov), opts.features_enabled = ov; end
        end

        if ~isempty(autofillTbl.Data)
            d = autofillTbl.Data;
            af = normalizeAutofill(getfield_or_empty(meta,'autofill'));
            ov = struct('fn',{},'enabled',{});
            for i = 1:min(size(d,1), numel(af))
                fn = strtrim(string(d{i,2}));
                if fn == "", continue; end
                en = false;
                try, en = logical(d{i,1}); catch, end
                ov(end+1).fn = fn; %#ok<AGROW>
                ov(end).enabled = en;
            end
            if ~isempty(ov), opts.autofill_enabled = ov; end
        end
    end

    function doPreview()
        try
            [meta, inputs, opts] = collectInputs();
            txt = code_generator('render', string(meta.id), inputs, opts);

            f2 = uifigure('Name','Rendered Preview', 'Position',[160 160 920 640]);
            ta = uitextarea(f2, 'Position',[10 10 900 620]);
            ta.Value = splitlines(string(txt));
            status.Value = "Preview rendered.";
        catch ME
            uialert(fig, ME.message, 'Preview error');
            status.Value = "Preview error.";
        end
    end

    function doGenerate()
        try
            [meta, inputs, opts] = collectInputs();
            outFile = string(outFileField.Value);

            msg = sprintf("Generate file?\n\nTemplate: %s\nOutput: %s", string(meta.title), outFile);
            sel = uiconfirm(fig, msg, 'Confirm', 'Options',{'Yes','No'}, 'DefaultOption',1, 'CancelOption',2);
            if ~strcmp(sel,'Yes')
                status.Value = "Cancelled.";
                return;
            end

            if exist(outFile,'file')
                sel2 = uiconfirm(fig, "File exists. Overwrite?", "Overwrite", ...
                    'Options',{'Overwrite','Cancel'}, 'DefaultOption',2, 'CancelOption',2);
                if ~strcmp(sel2,'Overwrite')
                    status.Value = "Cancelled (no overwrite).";
                    return;
                end
            end

            outPath = code_generator('generate', string(meta.id), inputs, outFile, opts);
            lastGenerated = string(outPath);
            status.Value = "Generated: " + lastGenerated;
        catch ME
            uialert(fig, ME.message, 'Generate error');
            status.Value = "Generate error.";
        end
    end

    function doOpen()
        if strlength(lastGenerated) == 0
            uialert(fig, "Nothing generated yet.", "Info");
            return;
        end
        if exist(lastGenerated,'file')
            edit(lastGenerated);
        else
            uialert(fig, "File not found: " + lastGenerated, "Error");
        end
    end

    % ========================= TEMPLATE EDITOR =========================

    function openTemplateEditor(mode)
        mode = lower(string(mode));
        selectedId = string(lb.Value);
    
        meta0 = struct(); tplText0 = '';
        if mode == "edit"
            meta0 = getMetaById(reg, selectedId);
            tplDir = code_helpers("get_templates_dir");
            tplPath = fullfile(tplDir, string(meta0.template_file));
            tplText0 = fileread(tplPath);
        end
    
        ed = uifigure('Name', sprintf('%s Template', upper(mode)), 'Position',[160 90 1220 860]);
    
        rootEd = uigridlayout(ed, [3 1]);
        rootEd.RowHeight = {310, '1x', 56};
        rootEd.Padding = [10 10 10 10];
        rootEd.RowSpacing = 10;
    
        top = uipanel(rootEd, 'Title','Meta / Schema');
        topGL = uigridlayout(top, [1 2]);
        topGL.ColumnWidth = {'1x', '1.25x'};
        topGL.Padding = [10 10 10 10];
        topGL.ColumnSpacing = 10;
    
        metaP = uipanel(topGL, 'Title','Meta');
        metaGL = uigridlayout(metaP, [4 2]);
        metaGL.ColumnWidth = {150,'1x'};
        metaGL.RowHeight = {28, 28, 28, '1x'};
        metaGL.RowSpacing = 8;
        metaGL.Padding = [10 10 10 10];
    
        uilabel(metaGL, 'Text','Title:');
        titleF = uieditfield(metaGL,'text','Value','My new task');
    
        uilabel(metaGL, 'Text','ID:');
        idF = uieditfield(metaGL,'text','Value','my_task');
    
        uilabel(metaGL, 'Text','Template file:');
        tplFileF = uieditfield(metaGL,'text','Value','');
    
        uilabel(metaGL, 'Text','Description:');
        descA = uitextarea(metaGL,'Value',{'Solve <equation(eq)> ...'});
    
        tabs2 = uitabgroup(topGL);
    
        tabInputs = uitab(tabs2, 'Title','Inputs schema');
        inGL = uigridlayout(tabInputs, [2 1]);
        inGL.RowHeight = {'1x', 34};
        inGL.Padding = [10 10 10 10];
        inGL.RowSpacing = 8;
    
        colsInputs = {'key','label','type','default','required','min','feature'};
        tblInputs = uitable(inGL, ...
            'Data', cell(0, numel(colsInputs)), ...
            'ColumnName', colsInputs, ...
            'ColumnEditable', true(1,numel(colsInputs)), ...
            'RowName', {});
    
        uibutton(inGL, 'Text','Sync keys from placeholders', ...
            'ButtonPushedFcn', @(~,~)syncFromPlaceholders());
    
        tabAuto = uitab(tabs2, 'Title','Autofill');
        autoGL2 = uigridlayout(tabAuto, [2 1]);
        autoGL2.RowHeight = {'1x', 22};
        autoGL2.Padding = [10 10 10 10];
        autoGL2.RowSpacing = 8;
    
        colsAuto = {'enabled','fn','args(...)','provides'};
        tblAuto = uitable(autoGL2, ...
            'Data', cell(0,4), ...
            'ColumnName', colsAuto, ...
            'ColumnEditable', [true true true true], ...
            'RowName', {});
        uilabel(autoGL2, 'Text', ...
            'Format: args(eq;xmin;xmax;h)  |  provides(x_app;n_roots)', 'FontAngle','italic');
    
        try
            fnList = callable_functions('list');
            tblAuto.ColumnFormat = { 'logical', cellstr(fnList), 'char', 'char' };
        catch
        end
    
        tabFeat = uitab(tabs2, 'Title','Features');
        featGL2 = uigridlayout(tabFeat, [2 1]);
        featGL2.RowHeight = {'1x', 22};
        featGL2.Padding = [10 10 10 10];
        featGL2.RowSpacing = 8;
    
        tblFeat = uitable(featGL2, ...
            'Data', cell(0,4), ...
            'ColumnName', {'enabled','feature','slot','description'}, ...
            'ColumnEditable', [true true true true], ...
            'RowName', {});
        uilabel(featGL2, 'Text', ...
            'Each enabled feature is inserted at %<FEATURE:slot> marker. Feature-owned inputs use inputs.feature = featureName.', ...
            'FontAngle','italic');
    
        try
            featsReg = code_generator('load_features_registry');
            featNames = string({featsReg.feature});
            if ~isempty(featNames)
                tblFeat.ColumnFormat = { 'logical', cellstr(featNames), 'char', 'char' };
            end
        catch
        end
    
        mid = uipanel(rootEd, 'Title','Template code');
        midGL = uigridlayout(mid, [1 2]);
        midGL.ColumnWidth = {'1x', 320};
        midGL.Padding = [10 10 10 10];
        midGL.ColumnSpacing = 10;
    
        codeA = uitextarea(midGL, 'Value', splitlines(""));
    
        side = uipanel(midGL, 'Title','Placeholders');
        sideGL = uigridlayout(side, [6 1]);
        sideGL.RowHeight = {22, '1x', 34, 34, 22, 22};
        sideGL.Padding = [10 10 10 10];
        sideGL.RowSpacing = 8;
    
        uilabel(sideGL, 'Text','Scanned from code:');
        phList = uilistbox(sideGL, 'Items', {'(click Scan)'} );
    
        uibutton(sideGL, 'Text','Scan placeholders', 'ButtonPushedFcn', @(~,~)scanPlaceholders());
        uibutton(sideGL, 'Text','Copy selected', 'ButtonPushedFcn', @(~,~)copySelected());
    
        uilabel(sideGL, 'Text','Supports: <equation>, <expr>, <var>, <func> and %<FEATURE:slot>', 'FontAngle','italic');
        statusEd = uilabel(sideGL, 'Text','Ready.', 'FontAngle','italic');
    
        bottom2 = uigridlayout(rootEd, [1 3]);
        bottom2.ColumnWidth = {'1x','1x','1x'};
        bottom2.RowHeight = {34};
        bottom2.ColumnSpacing = 10;
    
        uibutton(bottom2, 'Text','Cancel', 'ButtonPushedFcn', @(~,~)close(ed));
        uibutton(bottom2, 'Text','Save',   'ButtonPushedFcn', @(~,~)saveTemplate());
    
        % ========================= PREFILL =========================
        if mode == "edit"
            titleF.Value   = char(string(meta0.title));
            idF.Value      = char(string(meta0.id));
            descA.Value    = splitlines(string(meta0.description));
            tplFileF.Value = char(string(meta0.template_file));
    
            % ---- Inputs schema table ----
            inArr = normalizeInputs(meta0.inputs);
            dataI = cell(numel(inArr), 7);
            for i = 1:numel(inArr)
                dataI{i,1} = asCharCell(getfield_or_empty(inArr(i),'key'));
                dataI{i,2} = asCharCell(getfield_or_empty(inArr(i),'label'));
                dataI{i,3} = asCharCell(getfield_or_empty(inArr(i),'type'));
    
                def = getfield_or_empty(inArr(i),'default');
                dataI{i,4} = asCharCell(def); % ALWAYS char
    
                dataI{i,5} = logicalDefault(getfield_or_empty(inArr(i),'required')); % logical scalar
    
                mn = getfield_or_empty(inArr(i),'min');
                dataI{i,6} = asCharCell(mn); % char
    
                dataI{i,7} = asCharCell(getfield_or_empty(inArr(i),'feature'));
            end
            tblInputs.Data = dataI;
    
            % ---- Autofill ----
            afArr = normalizeAutofill(getfield_or_empty(meta0,'autofill'));
            dataA = cell(numel(afArr), 4);
            for i = 1:numel(afArr)
                dataA{i,1} = logicalDefault(getfield_or_empty(afArr(i),'enabled'));
                dataA{i,2} = asCharCell(getfield_or_empty(afArr(i),'fn'));
                dataA{i,3} = asCharCell("args(" + renderList(getfield_or_empty(afArr(i),'args')) + ")");
                dataA{i,4} = asCharCell("provides(" + renderList(getfield_or_empty(afArr(i),'provides')) + ")");
            end
            tblAuto.Data = dataA;
    
            % ---- Features ----
            ftArr = normalizeFeatures(getfield_or_empty(meta0,'features'));
            dataF = cell(numel(ftArr), 4);
            for i = 1:numel(ftArr)
                dataF{i,1} = logicalDefault(getfield_or_empty(ftArr(i),'enabled'));
                dataF{i,2} = asCharCell(getfield_or_empty(ftArr(i),'feature'));
                dataF{i,3} = asCharCell(getfield_or_empty(ftArr(i),'slot'));
                dataF{i,4} = asCharCell(getfield_or_empty(ftArr(i),'description'));
            end
            tblFeat.Data = dataF;
    
            codeA.Value = splitlines(string(tplText0));
        else
            tblInputs.Data = {
                'eq','Vienādojums','equation1d','x^2-2=0', true,'','';
                'epsi','Precizitāte','double','1e-6',      true,'0',''
            };
            tblAuto.Data = cell(0,4);
            tblFeat.Data = cell(0,4);
            codeA.Value = splitlines("f=<equation(eq)>; epsi=<var(epsi)>; disp(f(1));");
            tplFileF.Value = '';
        end
    
        scanPlaceholders();
    
        % ========================= HELPERS =========================
        function c = asCharCell(v)
            % Return ONLY a char row vector (never string), suitable for uitable cell.
            if isempty(v)
                c = '';
                return;
            end
    
            if ischar(v)
                c = v;
            elseif isstring(v)
                if isscalar(v)
                    c = char(v);
                else
                    c = char(strjoin(v(:).', " "));
                end
            elseif isnumeric(v) || islogical(v)
                if isscalar(v)
                    c = num2str(v);      % scalar -> text
                else
                    c = mat2str(v);      % vector/matrix -> text
                end
            elseif iscell(v)
                try
                    c = char(strjoin(string(v), ";"));
                catch
                    c = '';
                end
            else
                try
                    c = char(string(v));
                catch
                    c = '';
                end
            end
    
            % Ensure single-row char
            if size(c,1) > 1
                c = strjoin(cellstr(c), ' ');
            end
        end
    
        function txt = joinTextArea(a)
            v = a.Value;
            if iscell(v), txt = strjoin(string(v), newline);
            else, txt = string(v);
            end
            txt = char(txt);
        end
    
        function items = parsePlaceholders(codeText)
            pat = '<\s*(equation|expr|var|variable|func|function)\s*\(\s*([A-Za-z]\w*)\s*\)\s*>';
            tokens = regexp(codeText, pat, 'tokens');
            items = strings(0,1);
            for ii = 1:numel(tokens)
                kind = string(tokens{ii}{1});
                key  = string(tokens{ii}{2});
                items(end+1) = "<" + kind + "(" + key + ")>"; %#ok<AGROW>
            end
            items = unique(items, 'stable');
        end
    
        function scanPlaceholders()
            codeText = joinTextArea(codeA);
            items = parsePlaceholders(codeText);
            if isempty(items)
                phList.Items = {'(none found)'};
            else
                phList.Items = cellstr(items);
                phList.Value = phList.Items{1};
            end
            statusEd.Text = sprintf("Found %d placeholder(s).", numel(items));
        end
    
        function copySelected()
            if isempty(phList.Items), return; end
            val = string(phList.Value);
            if val == "" || startsWith(val,"(none"), return; end
            clipboard('copy', char(val));
            statusEd.Text = "Copied: " + val;
        end
    
        function syncFromPlaceholders()
            codeText = joinTextArea(codeA);
            items = parsePlaceholders(codeText);
    
            keys = strings(0,1);
            for ii = 1:numel(items)
                tok = regexp(items(ii), '<\s*\w+\s*\(\s*([A-Za-z]\w*)\s*\)\s*>', 'tokens', 'once');
                if ~isempty(tok), keys(end+1) = string(tok{1}); end %#ok<AGROW>
            end
            keys = unique(keys,'stable');
    
            data = tblInputs.Data;
            if isempty(data), data = cell(0,7); end
            existing = strings(0,1);
            if ~isempty(data), existing = string(data(:,1)); end
    
            for k = 1:numel(keys)
                if ~any(existing == keys(k))
                    newRow = {char(keys(k)), char(keys(k)), 'string', '', true, '', ''};
                    data(end+1,:) = newRow; %#ok<AGROW>
                end
            end
    
            tblInputs.Data = data;
            statusEd.Text = "Inputs table synced.";
            scanPlaceholders();
        end
    
        % ========================= SAVE =========================
        function saveTemplate()
            try
                id  = strtrim(string(idF.Value));
                ttl = strtrim(string(titleF.Value));
                if id == "" || ttl == ""
                    error("ID and Title are required.");
                end
                if isempty(regexp(id, '^[A-Za-z]\w*$', 'once'))
                    error("ID must match ^[A-Za-z]\w*$.");
                end
    
                desc2 = joinTextArea(descA);
                codeText = joinTextArea(codeA);
                if strtrim(string(codeText)) == ""
                    error("Template code cannot be empty.");
                end
    
                tplFile = strtrim(string(tplFileF.Value));
                if tplFile == ""
                    tplFile = id + ".tmpl";
                end
                if ~endsWith(tplFile, ".tmpl")
                    tplFile = tplFile + ".tmpl";
                end
    
                % -------- inputs --------
                dataI = tblInputs.Data;
                if isempty(dataI), dataI = cell(0,7); end
    
                inputsArr = struct([]);
                for r = 1:size(dataI,1)
                    key = strtrim(string(dataI{r,1}));
                    if key == "", continue; end
    
                    inp = struct();
                    inp.key   = char(key);
                    inp.label = char(string(dataI{r,2}));
                    inp.type  = char(lower(string(dataI{r,3})));
    
                    defaultCell  = dataI{r,4};  % usually char
                    requiredCell = dataI{r,5};  % logical
                    minCell      = dataI{r,6};  % usually char
                    featureCell  = dataI{r,7};  % usually char
    
                    inp.required = false;
                    try, inp.required = logical(requiredCell); catch, end
    
                    inp.feature = char(strtrim(string(featureCell)));
    
                    % min (stored numeric or [] in JSON)
                    inp.min = [];
                    if ~(isempty(minCell) || strtrim(string(minCell))=="")
                        mn = str2double(string(minCell));
                        if ~isnan(mn), inp.min = mn; end
                    end
    
                    % default (parse back by type)
                    t = lower(string(inp.type));
                    if t == "vector"
                        if isempty(defaultCell) || strtrim(string(defaultCell)) == ""
                            inp.default = [];
                        else
                            inp.default = code_helpers("parse_vector", string(defaultCell));
                        end
                    elseif t == "double"
                        if isempty(defaultCell) || strtrim(string(defaultCell)) == ""
                            inp.default = [];
                        else
                            inp.default = str2double(string(defaultCell));
                        end
                    elseif t == "int"
                        if isempty(defaultCell) || strtrim(string(defaultCell)) == ""
                            inp.default = [];
                        else
                            inp.default = round(str2double(string(defaultCell)));
                        end
                    else
                        if isempty(defaultCell), inp.default = '';
                        else, inp.default = char(string(defaultCell));
                        end
                    end
    
                    inputsArr = [inputsArr, inp]; %#ok<AGROW>
                end
    
                % -------- autofill --------
                dataA = tblAuto.Data;
                if isempty(dataA), dataA = cell(0,4); end
    
                afList = struct('enabled',{},'fn',{},'args',{},'provides',{});
                for r = 1:size(dataA,1)
                    fn = strtrim(string(dataA{r,2}));
                    if fn == "", continue; end
    
                    af = struct();
                    af.enabled = false;
                    try, af.enabled = logical(dataA{r,1}); catch, end
                    af.fn = char(fn);
    
                    af.args     = cellstr(parseSpecList(string(dataA{r,3}), "args"));
                    af.provides = cellstr(parseSpecList(string(dataA{r,4}), "provides"));
    
                    afList(end+1) = af; %#ok<AGROW>
                end
    
                % -------- features --------
                dataF = tblFeat.Data;
                if isempty(dataF), dataF = cell(0,4); end
    
                ftList = struct('enabled',{},'feature',{},'slot',{},'description',{});
                for r = 1:size(dataF,1)
                    feat = strtrim(string(dataF{r,2}));
                    if feat == "", continue; end
    
                    ft = struct();
                    ft.enabled = false;
                    try, ft.enabled = logical(dataF{r,1}); catch, end
                    ft.feature     = char(feat);
                    ft.slot        = char(strtrim(string(dataF{r,3})));
                    ft.description = char(string(dataF{r,4}));
    
                    ftList(end+1) = ft; %#ok<AGROW>
                end
    
                meta = struct();
                meta.id = char(id);
                meta.title = char(ttl);
                meta.description = char(desc2);
                meta.template_file = char(tplFile);
                meta.inputs = inputsArr;
                meta.autofill = afList;
                meta.features = ftList;
    
                if mode == "edit"
                    oldId = selectedId;
                    code_generator('update_template', oldId, meta, codeText);
                else
                    code_generator('add_template', meta, codeText);
                end
    
                reloadRegistry();
                lb.Value = char(id);
                onSelect(id);
                close(ed);
    
            catch ME
                uialert(ed, ME.getReport('extended','hyperlinks','off'), "Save error");
            end
        end
    end


    % ================= Wheel scrolling =================
    function onWheelScroll(~, evt)
        try
            h = hittest(fig);
        catch
            return;
        end
        if isempty(h) || ~isvalid(h), return; end

        inside = false;
        p = h;
        while ~isempty(p) && isvalid(p)
            if p == formScroll
                inside = true;
                break;
            end
            if isprop(p,'Parent')
                p = p.Parent;
            else
                break;
            end
        end
        if ~inside, return; end

        sp = formScroll.ScrollPosition;
        step = 45;
        sp(2) = max(0, sp(2) + evt.VerticalScrollCount * step);
        formScroll.ScrollPosition = sp;
    end
end

% ===================== subfunctions =====================

function [reg, titles, ids] = loadRegistryAndList()
    reg = code_generator('load_registry');
    if isempty(reg)
        error("Registry is empty.");
    end
    ids = string({reg.id});
    titles = string({reg.title});
end

function meta = getMetaById(reg, id)
    id = string(id);
    idx = find(strcmp(string({reg.id}), id), 1);
    if isempty(idx)
        error("Template id not found in registry: %s", id);
    end
    meta = reg(idx);
end

function inputsArr = normalizeInputs(inputsField)
    if isempty(inputsField), inputsArr = struct([]); return; end
    if isstruct(inputsField), inputsArr = inputsField; return; end
    if iscell(inputsField) && all(cellfun(@isstruct, inputsField)), inputsArr = [inputsField{:}]; return; end
    error("Unsupported registry format for 'inputs'.");
end

function afArr = normalizeAutofill(afField)
    if isempty(afField), afArr = struct([]); return; end
    if isstruct(afField), afArr = afField; return; end
    if iscell(afField) && all(cellfun(@isstruct, afField)), afArr = [afField{:}]; return; end
    error("Unsupported registry format for 'autofill'.");
end

function ftArr = normalizeFeatures(ftField)
    if isempty(ftField), ftArr = struct([]); return; end
    if isstruct(ftField), ftArr = ftField; return; end
    if iscell(ftField) && all(cellfun(@isstruct, ftField)), ftArr = [ftField{:}]; return; end
    error("Unsupported registry format for 'features'.");
end

function v = getfield_or_empty(s, field)
    if isstruct(s) && isfield(s, field), v = s.(field); else, v = []; end
end

function b = logicalDefault(v)
    try
        if isempty(v), b = false; else b = logical(v); end
    catch
        b = false;
    end
end

function out = parseSpecList(s, prefix)
    s = strtrim(string(s));
    if s == "" || s == prefix+"()", out = strings(0,1); return; end

    pat = "^" + prefix + "\((.*)\)$";
    tok = regexp(s, pat, "tokens", "once");
    if ~isempty(tok)
        s = string(tok{1});
    end

    s = strrep(s, ",", ";");
    parts = split(s, ";");
    parts = strtrim(parts);
    parts = parts(parts ~= "");
    out = string(parts);
end

function v = coerceDoubleScalar(x, fallback)
    if nargin < 2, fallback = 0; end
    try
        if isempty(x), v = fallback; return; end
        if iscell(x), x = x{1}; end

        if isstring(x) || ischar(x)
            s = strtrim(string(x));
            if s == "", v = fallback; return; end
            v = str2double(s);
            if ~isfinite(v), v = fallback; end
            return;
        end

        if isnumeric(x) || islogical(x)
            x = double(x);
            if isscalar(x) && isfinite(x), v = x; else, v = fallback; end
            return;
        end

        v = fallback;
    catch
        v = fallback;
    end
end
