function varargout = code_helpers(action, varargin)
% CODE_HELPERS  Dispatcher for shared helper utilities.
%
% Actions:
%   code_helpers('to_zero_form', s)
%   code_helpers('make_matlab_expr', s)
%   code_helpers('make_symbolic_expr', s)
%   code_helpers('normalize_filename', fname, defaultName)
%   code_helpers('format_value', v)
%   code_helpers('parse_vector', txt)
%   code_helpers('get_templates_dir')
%   code_helpers('sys2d_area_bounds', x1_area, x2_area) -> [x1min x1max x2min x2max]

    action = lower(string(action));

    switch action
        case "to_zero_form"
            varargout{1} = to_zero_form(varargin{1});

        case "make_matlab_expr"
            varargout{1} = make_matlab_expr(varargin{1});

        case "make_symbolic_expr"
            varargout{1} = make_symbolic_expr(varargin{1});

        case "normalize_filename"
            varargout{1} = normalize_filename(varargin{1}, varargin{2});

        case "format_value"
            varargout{1} = format_value(varargin{1});

        case "parse_vector"
            varargout{1} = parse_vector(varargin{1});

        case "get_templates_dir"
            baseDir = fileparts(mfilename('fullpath'));
            varargout{1} = fullfile(baseDir, "templates");

         case "safe_replace"
         % Safe string replacement for templates.
         % Converts ANY replacement value (numeric/vector/struct/etc) into char.
         if numel(varargin) < 3
             error("safe_replace requires (txt, old, new).");
         end
         txt = varargin{1};
         old = varargin{2};
         new = varargin{3};

         varargout{1} = local_safe_replace(txt, old, new);
         return;

        case "sys2d_area_bounds"
            % Returns [x1min x1max x2min x2max] from strings like "-1<=x1<=4"
            if numel(varargin) < 2
                error("sys2d_area_bounds requires (x1_area, x2_area).");
            end

            x1s = string(varargin{1});
            x2s = string(varargin{2});

            [x1min, x1max] = local_parse_ineq_bounds(x1s, "x1");
            [x2min, x2max] = local_parse_ineq_bounds(x2s, "x2");

            varargout{1} = [x1min, x1max, x2min, x2max];
            return;

        otherwise
            error("code_helpers: Unknown action '%s'", action);
    end
end

% =================== local functions ===================

function out = to_zero_form(s)
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

function expr = make_matlab_expr(expr)
    expr = char(string(expr));
    expr = strrep(expr, 'ln(', 'log(');
    expr = strrep(expr, 'arctg', 'atan');
    expr = preprocess_sqrt_power_numeric(expr);

    expr = regexprep(expr, 'e\^\(([^)]*)\)', 'exp($1)');
    expr = regexprep(expr, 'e\^([^\(\)\s]+)', 'exp($1)');

    expr = regexprep(expr, '(?<!\.)\^', '.^');
    expr = regexprep(expr, '(?<!\.)\*', '.*');
    expr = regexprep(expr, '(?<!\.)/',  './');
end

function expr = make_symbolic_expr(expr)
    expr = char(string(expr));
    expr = strrep(expr, 'ln(', 'log(');
    expr = strrep(expr, 'arctg', 'atan');
    expr = preprocess_sqrt_power_symbolic(expr);

    expr = regexprep(expr, 'e\^\(([^)]*)\)', 'exp($1)');
    expr = regexprep(expr, 'e\^([^\(\)\s]+)', 'exp($1)');

    expr = strrep(expr, '.^', '^');
    expr = strrep(expr, '.*', '*');
    expr = strrep(expr, './', '/');
end

function fname = normalize_filename(fname, default_name)
    fname = strtrim(string(fname));
    if fname == ""
        fname = string(default_name);
    end
    if ~endsWith(fname, ".m")
        fname = fname + ".m";
    end
    fname = char(fname);
end

function s = format_value(v)
% FORMAT_VALUE  Convert value to a MATLAB-literal-ish text (CHAR ROW).
% IMPORTANT: Always returns char row vector (not string), so it can be used
% safely as regexprep REPLACE when the input template is char.

    % strings -> char
    if isstring(v)
        if isempty(v)
            s = '';
            return;
        end
        if isscalar(v)
            s = char(v);
        else
            s = char(strjoin(v(:).', " "));
        end
        s = reshape(s, 1, []); % force row
        return;
    end

    % char -> char row
    if ischar(v)
        s = reshape(v, 1, []);
        return;
    end

    % numeric / logical
    if isnumeric(v) || islogical(v)
        if isempty(v)
            s = '[]';
        elseif isscalar(v)
            s = sprintf('%.16g', double(v));
        else
            s = mat2str(double(v), 16);
        end
        s = reshape(s, 1, []);
        return;
    end

    % cell -> join -> char row
    if iscell(v)
        s = char(strjoin(string(v), ";"));
        s = reshape(s, 1, []);
        return;
    end

    error("code_helpers: Unsupported type for format_value: %s", class(v));
end


function vec = parse_vector(txt)
    if isnumeric(txt) || islogical(txt)
        vec = double(txt); return;
    end
    s = strtrim(string(txt));
    if s == ""
        vec = [];
        return;
    end
    s = replace(s, ",", " ");
    vec = str2num(char(s)); %#ok<ST2NM>
end

function str_out = preprocess_sqrt_power_numeric(str_in)
    str_out = str_in;
    pattern = 'sqrt\^(\d+)';
    [start_idx, end_idx, tokens] = regexp(str_out, pattern, 'start', 'end', 'tokens');

    for i = numel(start_idx):-1:1
        n = tokens{i}{1};
        a = start_idx(i); b = end_idx(i);

        openp = b + 1;
        if openp > length(str_out) || str_out(openp) ~= '(', continue; end

        pc = 1; p = openp + 1;
        while p <= length(str_out) && pc > 0
            if str_out(p) == '(', pc = pc + 1;
            elseif str_out(p) == ')', pc = pc - 1;
            end
            p = p + 1;
        end
        if pc ~= 0, continue; end

        closep = p - 1;
        arg = str_out(openp+1:closep-1);
        rep = ['sqrt_power(' arg ', ' n ')'];
        str_out = [str_out(1:a-1) rep str_out(closep+1:end)];
    end
end

function str_out = preprocess_sqrt_power_symbolic(str_in)
    str_out = str_in;
    pattern = 'sqrt\^(\d+)';
    [start_idx, end_idx, tokens] = regexp(str_out, pattern, 'start', 'end', 'tokens');

    for i = numel(start_idx):-1:1
        n = tokens{i}{1};
        a = start_idx(i); b = end_idx(i);

        openp = b + 1;
        if openp > length(str_out) || str_out(openp) ~= '(', continue; end

        pc = 1; p = openp + 1;
        while p <= length(str_out) && pc > 0
            if str_out(p) == '(', pc = pc + 1;
            elseif str_out(p) == ')', pc = pc - 1;
            end
            p = p + 1;
        end
        if pc ~= 0, continue; end

        closep = p - 1;
        arg = str_out(openp+1:closep-1);
        rep = ['(' arg ')^(1/' n ')'];
        str_out = [str_out(1:a-1) rep str_out(closep+1:end)];
    end
end

function [mn, mx] = local_parse_ineq_bounds(s, varname)
    s = strtrim(string(s));
    s = replace(s, "≤", "<=");
    s = replace(s, "≥", ">=");
    s = regexprep(s, "\s+", ""); % remove spaces

    % Accept: a<=x1<=b, a<x1<=b, a<=x1<b, a>x1>=b, etc.
    num = "([+-]?\d*\.?\d+(?:[eE][+-]?\d+)?)";
    op  = "(<=|<|>=|>)";
    pat = "^" + num + op + varname + op + num + "$";

    tok = regexp(s, pat, "tokens", "once");
    if isempty(tok)
        error("Bad area format for %s: '%s'. Expected like -1<=%s<=4", varname, s, varname);
    end

    a = str2double(tok{1});
    b = str2double(tok{4});

    if ~isfinite(a) || ~isfinite(b)
        error("Area bounds must be numeric: '%s'.", s);
    end

    mn = min(a, b);
    mx = max(a, b);
end

function txt = local_safe_replace(txt, old, new)
    % Always operate on char vectors (template text)
    txt = local_any_to_char(txt);
    old = local_any_to_char(old);
    new = local_any_to_char(new);
    txt = strrep(txt, old, new);
end

function s = local_any_to_char(v)
    % Convert ANY input into a single char row vector.
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
        % Don't crash if something returns a struct (autofill often does)
        try
            s = jsonencode(v);
        catch
            s = '<struct>';
        end
    else
        s = char(string(v));
    end

    % Force row char (not char matrix)
    if size(s,1) > 1
        s = strjoin(cellstr(s), newline);
    end
end
