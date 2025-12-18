function out = code_template_engine(templateText, inputs)
% CODE_TEMPLATE_ENGINE Replace placeholders:
%   <equation(key)>  -> @(x) <matlab_expr_of_zero_form>
%   <expr(key)>      -> <symbolic_expr_of_zero_form>
%   <var(key)> or <variable(key)> -> formatted scalar/vector/string
%   <func(key)> or <function(key)> -> function handle like @auto_roots_1d
    out = string(templateText);
    pattern = '<\s*(equation|expr|var|variable|func|function)\s*\(\s*([A-Za-z]\w*)\s*\)\s*>';
    [matches, starts, ends, tokens] = regexp(out, pattern, 'match', 'start', 'end', 'tokens'); %#ok<ASGLU>

    for i = numel(starts):-1:1
        kind = lower(string(tokens{i}{1}));
        key  = string(tokens{i}{2});

        if ~isfield(inputs, key)
            error("Template missing required input: %s", key);
        end
        val = inputs.(key);
        rep = "";

        switch kind
            case "equation"
                f0  = code_helpers("to_zero_form", string(val));
                fM  = code_helpers("make_matlab_expr", f0);
                rep = "@(x) " + string(fM);

            case "expr"
                f0  = code_helpers("to_zero_form", string(val));
                fS  = code_helpers("make_symbolic_expr", f0);
                rep = string(fS);

            case {"var","variable"}
                rep = code_helpers("format_value", val);

            case {"func","function"}
                % Allow empty/optional function placeholders
                if isempty(val) || ((isstring(val) || ischar(val)) && strtrim(string(val)) == "")
                    rep = "[]";  % or you could use: rep = "@(x)x" for a dummy function
                else
                    rep = format_function_handle(val);
                end

            otherwise
                error("Unknown placeholder kind: %s", kind);
        end

        out = extractBefore(out, starts(i)) + rep + extractAfter(out, ends(i));
    end
    out = char(out);
end

function rep = format_function_handle(val)
    if isa(val, 'function_handle')
        s = string(func2str(val));
        if startsWith(s, "@")
            rep = s;
        else
            rep = "@" + s;
        end
        return;
    end

    if isstring(val) || ischar(val)
        s = strtrim(string(val));
        if s == ""
            error("Function placeholder value is empty.");
        end
        if startsWith(s, "@")
            rep = s;
        else
            rep = "@" + s;
        end
        return;
    end

    error("Function placeholder expects string/char/function_handle, got: %s", class(val));
end