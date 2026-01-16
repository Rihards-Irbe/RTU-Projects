function equation_converter()
% EQUATION_CONVERTER - Terminal tool to convert equations to MATLAB code
% Now with ODE system generation for ode45 solver
    fprintf('\n=== EQUATION CONVERTER ===\n');
    fprintf('Convert your equation notation to MATLAB code\n');
    fprintf('Type "exit" or "quit" to stop\n\n');

    while true
        fprintf('Enter equation: ');
        eq = input('', 's');
        eq = strtrim(string(eq));

        if eq == "" || lower(eq) == "exit" || lower(eq) == "quit"
            fprintf('\nGoodbye!\n');
            break;
        end

        fprintf('\n--- CONVERSIONS ---\n');

        % Show equation type
        [has_derivative, order] = check_derivative_type(eq);
        fprintf('[EQUATION TYPE]\n');
        if has_derivative
            fprintf(' This is a differential equation\n');
            if order == 1
                fprintf(' Order: 1st (contains yp)\n');
            elseif order == 2
                fprintf(' Order: 2nd (contains ypp)\n');
            elseif order == 3
                fprintf(' Order: 3rd (contains yppp)\n');
            end
        else
            fprintf(' This is an algebraic equation\n');
        end

        try
            show_equation_preview(char(eq), 'LaTeX Preview');
            fprintf('\n[LATEX PREVIEW] - Figure window opened\n');
        catch ME
            fprintf('\n[LATEX PREVIEW] - Error: %s\n', ME.message);
        end

        fprintf('\n[RAW EQUATION]\n');
        fprintf(' eq_str = ''%s'';\n', eq);

        if contains(eq,'=')
            zero_form = to_zero_form(eq);
            fprintf('\n[ZERO FORM]\n');
            fprintf(' f_zero = ''%s'';\n', zero_form);
        end

        try
            expr_sym = make_symbolic_expr(eq);
            fprintf('\n[SYMBOLIC EXPR]\n');
            fprintf(' f_sym = %s;\n', expr_sym);
        catch ME
            fprintf('\n[SYMBOLIC EXPR] - Error: %s\n', ME.message);
        end

        try
            expr_num = make_matlab_expr(eq);
            if has_derivative
                fprintf('\n[FIRST-ORDER ODE FUNCTION]\n');
                fprintf(' For use with ode45 (single equation):\n');
                fprintf(' function dydx = ode_fun(x, y)\n');
                fprintf(' dydx = %s;\n', expr_num);
                fprintf(' end\n');

                % Also show the solved form for yp
                fprintf('\n[SOLVED FOR dy/dx]\n');
                yp_expr = solve_for_yp(eq);
                fprintf(' dy/dx = %s\n', yp_expr);

                % Show ode45 usage example
                fprintf('\n[USAGE EXAMPLE for ode45]\n');
                fprintf(' %% Define integration interval\n');
                fprintf(' x_span = [x0 x_end]; %% e.g., [0 10]\n');
                fprintf(' y0 = initial_value; %% Initial condition y(x0)\n');
                fprintf(' \n');
                fprintf(' %% Solve ODE\n');
                fprintf(' [x_sol, y_sol] = ode45(@ode_fun, x_span, y0);\n');
                fprintf(' \n');
                fprintf(' %% Plot solution\n');
                fprintf(' plot(x_sol, y_sol, ''b-'', ''LineWidth'', 2);\n');
                fprintf(' xlabel(''x''); ylabel(''y(x)'');\n');
                fprintf(' grid on;\n');

                % New Latvian format for order 1
                if order == 1
                    fprintf('%% ārēja funkcija ( 7.4.piemērs ).\n');
                    fprintf('%% definēsim diferenciālvienādojuma labo pusi.\n');
                    fprintf('function dydx = fun_prob4(x,y)\n');
                    fprintf('      dydx = %s;\n', expr_num);
                    fprintf('end\n');
                end
            else
                fprintf('\n[VECTORIZED FUNCTION]\n');
                fprintf(' f = @(x,y) %s;\n', expr_num);
            end
        catch ME
            fprintf('\n[FUNCTION GENERATION] - Error: %s\n', ME.message);
        end

        % For higher-order ODEs, show system conversion
        if has_derivative && order > 1
            fprintf('\n[ODE SYSTEM CONVERSION]\n');
            fprintf(' For %dnd-order ODE, convert to system:\n', order);
            fprintf(' Let z1 = y, z2 = y'', z3 = y'''', etc.\n');

            try
                [system_code, highest_deriv_expr] = generate_ode_system(eq, order);
                fprintf('\n Generated system function:\n');
                fprintf('%s\n', system_code);

                % Show usage example for higher-order ODE
                fprintf('\n Usage with ode45:\n');
                fprintf(' %% Initial conditions: [y(0), y''(0), y''''(0), ...]\n');
                fprintf(' y0 = zeros(%d, 1);\n', order);
                fprintf(' y0(1) = initial_y;\n');
                fprintf(' y0(2) = initial_yp;\n');
                if order >= 3
                    fprintf(' y0(3) = initial_ypp;\n');
                end
                fprintf(' \n');
                fprintf(' %% Solve system\n');
                fprintf(' [x_sol, z_sol] = ode45(@ode_system, [x0 x_end], y0);\n');
                fprintf(' \n');
                fprintf(' %% Extract solution\n');
                fprintf(' y = z_sol(:,1); %% y(x)\n');
                fprintf(' yp = z_sol(:,2); %% y''(x)\n');
                if order >= 3
                    fprintf(' ypp = z_sol(:,3); %% y''''(x)\n');
                end

                % New Latvian format for system
                piemers_str = '7.6.piemērs';
                prob_num = '6';
                if order == 3
                    piemers_str = '7.8.piemērs';
                    prob_num = '8';
                end
                fprintf('%% ārēja funkcija ( %s ).\n', piemers_str);
                fprintf('%% definēsim diferenciālvienādojumu sistēmas labo pusi.\n');
                fprintf('function dy_dx = fun_prob%s(x,y)\n', prob_num);
                fprintf('   dy_dx = zeros(%d,1);\n', order);
                for i = 1:order-1
                    fprintf('   dy_dx(%d) = y(%d);\n', i, i+1);
                end
                fprintf('   dy_dx(%d) = %s;\n', order, highest_deriv_expr);
                fprintf('end\n');
            catch ME2
                fprintf(' Error generating system: %s\n', ME2.message);
            end
        end

        fprintf('\n%s\n', repmat('-', 1, 60));
    end
end

% ================= CORE =================
function out = to_zero_form(s)
    s = strtrim(string(s));
    if contains(s,"=")
        p = split(s,"=");
        out = "(" + strtrim(p(1)) + ")-(" + strtrim(p(2)) + ")";
    else
        out = s;
    end
end

% ================= DERIVATIVE TYPE CHECK =================
function [has_derivative, order] = check_derivative_type(eq)
    eq_str = char(eq);
    has_derivative = false;
    order = 0;

    if contains(eq_str, 'yppp')
        has_derivative = true;
        order = 3;
    elseif contains(eq_str, 'ypp')
        has_derivative = true;
        order = 2;
    elseif contains(eq_str, 'yp')
        has_derivative = true;
        order = 1;
    end
end

% ================= SYMBOLIC =================
function expr = make_symbolic_expr(eq)
    s = to_zero_form(eq);
    s = replace(s,"ln(","log(");
    s = replace(s,"arctg","atan");

    ss = char(s);
    ss = preprocess_derivatives_symbolic(ss);
    ss = preprocess_roots(ss);

    % integral parsing
    ss = preprocess_integrals(ss, "symbolic");

    % FIX: handle e^FUNC(...) before generic e^...
    ss = preprocess_exp_calls(ss);

    ss = regexprep(ss,'e\^\(([^)]*)\)','exp($1)');
    ss = regexprep(ss,'e\^([^\(\)\s]+)','exp($1)');

    ss = strrep(ss,'.^','^');
    ss = strrep(ss,'.*','*');
    ss = strrep(ss,'./','/');

    expr = string(ss);
end

function ss = preprocess_derivatives_symbolic(ss)
    ss = regexprep(ss,'yppp','diff(y,x,3)');
    ss = regexprep(ss,'ypp','diff(y,x,2)');
    ss = regexprep(ss,'yp','diff(y,x)');
end

% ================= NUMERIC =================
function expr = make_matlab_expr(eq)
    s = to_zero_form(eq);
    s = replace(s,"ln(","log(");
    s = replace(s,"arctg","atan");

    ss = char(s);
    ss = preprocess_roots(ss);

    % integral parsing
    ss = preprocess_integrals(ss, "numeric");

    % FIX: handle e^FUNC(...) before generic e^...
    ss = preprocess_exp_calls(ss);

    ss = regexprep(ss,'e\^\(([^)]*)\)','exp($1)');
    ss = regexprep(ss,'e\^([^\(\)\s]+)','exp($1)');

    [has_derivative, order] = check_derivative_type(eq);
    if has_derivative
        expr = solve_ode_for_highest_derivative(eq, order);
    else
        ss = regexprep(ss,'(?<!\.)\^','.^');
        ss = regexprep(ss,'(?<!\.)\*','.*');
        ss = regexprep(ss,'(?<!\.)/','./');
        expr = string(ss);
    end
end

% ================= EXPONENTIAL FIX (NEW) =================
function ss = preprocess_exp_calls(ss)
% Converts e^FUNC(arg) into exp(FUNC(arg)) so that:
%   e^sqrt(t)  -> exp(sqrt(t))   (fixes exp(sqrt)(t) bug)
%   e^sin(x)   -> exp(sin(x))
% Also works with spaces: e^ sqrt ( t )

    ss = char(ss);

    % Case: e^FUNC( ... )  where FUNC is a name and (...) is one-level parentheses
    % This is sufficient for your inputs like sqrt(t), sin(x), cos(t+1), etc.
    ss = regexprep(ss, 'e\^\s*([a-zA-Z]\w*)\s*\(([^()]*)\)', 'exp($1($2))');
end

% ================= ODE SOLVING =================
function expr = solve_ode_for_highest_derivative(eq, order)
    eq_str = char(eq);

    if order == 3
        eq_str = strrep(eq_str, 'yppp', 'D3');
        eq_str = strrep(eq_str, 'ypp', 'D2');
        eq_str = strrep(eq_str, 'yp', 'D1');
        eq_str = strrep(eq_str, 'y', 'Y');
        syms x Y D1 D2 D3
    elseif order == 2
        eq_str = strrep(eq_str, 'ypp', 'D2');
        eq_str = strrep(eq_str, 'yp', 'D1');
        eq_str = strrep(eq_str, 'y', 'Y');
        syms x Y D1 D2
        D3 = 0;
    elseif order == 1
        eq_str = strrep(eq_str, 'yp', 'D1');
        eq_str = strrep(eq_str, 'y', 'Y');
        syms x Y D1
        D2 = 0;
        D3 = 0;
    end

    eq_str = regexprep(eq_str, 'ln\(', 'log(');
    eq_str = regexprep(eq_str, 'arctg', 'atan');
    eq_str = preprocess_roots(eq_str);
    eq_str = preprocess_integrals(eq_str, "symbolic");

    % FIX here too
    eq_str = preprocess_exp_calls(eq_str);

    eq_str = regexprep(eq_str, 'e\^\(([^)]*)\)', 'exp($1)');
    eq_str = regexprep(eq_str, 'e\^([^\(\)\s]+)', 'exp($1)');

    if contains(eq_str, '=')
        parts = split(string(eq_str), '=');
        lhs = strtrim(parts(1));
        rhs = strtrim(parts(2));
        sym_eq = str2sym(char(lhs + " - (" + rhs + ")"));
    else
        sym_eq = str2sym(char(eq_str));
    end

    if order == 1
        sol = solve(sym_eq, D1);
        expr = char(sol);
        expr = strrep(expr, 'Y', 'y');
        expr = regexprep(expr,'(?<!\.)\^','.^');
        expr = regexprep(expr,'(?<!\.)\*','.*');
        expr = regexprep(expr,'(?<!\.)/','./');
    else
        expr = '[See ODE System Conversion above]';
    end
end

function yp_expr = solve_for_yp(eq)
    s = to_zero_form(eq);
    s = replace(s, "ln(", "log(");
    s = replace(s, "arctg", "atan");
    ss = char(s);
    ss = preprocess_roots(ss);
    ss = preprocess_integrals(ss, "symbolic");

    % FIX here too
    ss = preprocess_exp_calls(ss);

    ss = regexprep(ss,'e\^\(([^)]*)\)','exp($1)');
    ss = regexprep(ss,'e\^([^\(\)\s]+)','exp($1)');

    ss = strrep(ss, 'yp', 'D');
    ss = strrep(ss, 'y', 'Y');

    syms x Y D
    eq_sym = str2sym(ss);
    sol = solve(eq_sym, D);

    yp_expr = char(sol);
    yp_expr = strrep(yp_expr, 'Y', 'y');
    yp_expr = regexprep(yp_expr,'(?<!\.)\^','.^');
    yp_expr = regexprep(yp_expr,'(?<!\.)\*','.*');
    yp_expr = regexprep(yp_expr,'(?<!\.)/','./');
end

% ================= ROOT HANDLING =================
function ss = preprocess_roots(ss)
    % Keep sqrt(expr) as sqrt(expr) because MATLAB supports it directly.
    % Only convert sqrt^n(expr) -> (expr)^(1/n)

    pat = 'sqrt\^(\d+)\s*\(';
    [st,en,tok] = regexp(ss, pat, 'start', 'end', 'tokens');

    for i = numel(st):-1:1
        n = tok{i}{1};
        openp = en(i);
        depth = 1;
        p = openp + 1;

        while p <= length(ss) && depth > 0
            if ss(p) == '('
                depth = depth + 1;
            elseif ss(p) == ')'
                depth = depth - 1;
            end
            p = p + 1;
        end

        if depth ~= 0
            error('sqrt^n parsing error: unmatched parentheses.');
        end

        arg = ss(openp+1 : p-2);
        rep = ['(' arg ')^(1/' n ')'];
        ss = [ss(1:st(i)-1) rep ss(p:end)];
    end
end

% ================= INTEGRAL HANDLING =================
function ss = preprocess_integrals(ss, mode)
% mode = "symbolic" or "numeric"
% Supports:
%   int[U L](expr)   (your example)
%   int[L,U](expr)
%   int[L U](expr)

    ss = char(ss);

    pat = 'int\s*\[\s*([^\]]+?)\s*\]\s*\(';
    [st,en,tok] = regexp(ss, pat, 'start','end','tokens');

    for i = numel(st):-1:1
        lims_raw = strtrim(tok{i}{1});

        openp = en(i);
        depth = 1;
        p = openp + 1;
        while p <= length(ss) && depth > 0
            if ss(p) == '('
                depth = depth + 1;
            elseif ss(p) == ')'
                depth = depth - 1;
            end
            p = p + 1;
        end
        if depth ~= 0
            error('Integral parsing error: unmatched parentheses.');
        end

        integrand = ss(openp+1 : p-2);

        lims_raw = regexprep(lims_raw, '\s+', ' ');
        lims_raw = strrep(lims_raw, ',', ' ');
        parts = strsplit(strtrim(lims_raw), ' ');

        if numel(parts) ~= 2
            error('Integral limits must have exactly 2 entries: int[U L](...) or int[L,U](...)');
        end

        upper = parts{1};
        lower = parts{2};

        if contains(integrand, 't')
            var = 't';
        else
            var = 'x';
        end

        if strcmpi(mode, "symbolic")
            rep = sprintf('int(%s,%s,%s,%s)', integrand, var, lower, upper);
        else
            rep = sprintf('integral(@(%s) %s, %s, %s)', var, integrand, lower, upper);
        end

        ss = [ss(1:st(i)-1) rep ss(p:end)];
    end
end

% ================= ODE SYSTEM GENERATION =================
function [system_code, highest_deriv_expr] = generate_ode_system(eq, order)
    eq_str = char(eq);

    if order >= 3
        eq_str = strrep(eq_str, 'yppp', 'D3');
    end
    if order >= 2
        eq_str = strrep(eq_str, 'ypp', 'D2');
    end
    if order >= 1
        eq_str = strrep(eq_str, 'yp', 'D1');
    end
    eq_str = strrep(eq_str, 'y', 'Y');

    eq_str = regexprep(eq_str, 'ln\(', 'log(');
    eq_str = regexprep(eq_str, 'arctg', 'atan');
    eq_str = preprocess_roots(eq_str);
    eq_str = preprocess_integrals(eq_str, "symbolic");

    % FIX here too
    eq_str = preprocess_exp_calls(eq_str);

    eq_str = regexprep(eq_str, 'e\^\(([^)]*)\)', 'exp($1)');
    eq_str = regexprep(eq_str, 'e\^([^\(\)\s]+)', 'exp($1)');

    syms x Y D1 D2 D3
    if contains(eq_str, '=')
        parts = split(string(eq_str), '=');
        lhs = strtrim(parts(1));
        rhs = strtrim(parts(2));
        sym_eq = str2sym(char(lhs + " - (" + rhs + ")"));
    else
        sym_eq = str2sym(char(eq_str));
    end

    if order == 3
        highest_deriv_sol = solve(sym_eq, D3);
        highest_deriv_expr = char(highest_deriv_sol);
        highest_deriv_expr = strrep(highest_deriv_expr, 'Y', 'y(1)');
        highest_deriv_expr = strrep(highest_deriv_expr, 'D1', 'y(2)');
        highest_deriv_expr = strrep(highest_deriv_expr, 'D2', 'y(3)');
    elseif order == 2
        highest_deriv_sol = solve(sym_eq, D2);
        highest_deriv_expr = char(highest_deriv_sol);
        highest_deriv_expr = strrep(highest_deriv_expr, 'Y', 'y(1)');
        highest_deriv_expr = strrep(highest_deriv_expr, 'D1', 'y(2)');
    else
        highest_deriv_expr = '0';
    end

    highest_deriv_expr = regexprep(highest_deriv_expr,'(?<!\.)\^','.^');
    highest_deriv_expr = regexprep(highest_deriv_expr,'(?<!\.)\*','.*');
    highest_deriv_expr = regexprep(highest_deriv_expr,'(?<!\.)/','./');

    system_code = sprintf('function dydx = ode_system(x, y)\n');
    system_code = [system_code sprintf(' dydx = zeros(%d, 1);\n', order)];

    for i = 1:order-1
        system_code = [system_code sprintf(' dydx(%d) = y(%d);\n', i, i+1)];
    end

    system_code = [system_code sprintf(' dydx(%d) = %s;\n', order, highest_deriv_expr)];
    system_code = [system_code 'end'];
end

% ================= LATEX =================
function show_equation_preview(eq_raw, fig_name)
    eq_raw = strtrim(eq_raw);

    if contains(eq_raw,'int[') && ~contains(eq_raw,'=')
        try
            eq = ['$' integral_to_latex(eq_raw) '$'];
        catch
            eq = ['$' expr_to_latex(eq_raw) '$'];
        end
    elseif contains(eq_raw,'=')
        p = split(eq_raw,'=');
        L = expr_to_latex(p{1});
        R = expr_to_latex(p{2});
        eq = ['$' L '=' R '$'];
    else
        eq = ['$' expr_to_latex(eq_raw) '=0$'];
    end

    figure('Name',fig_name,'Color','w','Position',[100 100 900 160]);
    axis off
    text(0.5,0.5,eq,'Interpreter','latex','FontSize',20,...
        'HorizontalAlignment','center');
end

function s = integral_to_latex(in_raw)
    in_raw = strtrim(in_raw);

    tok = regexp(in_raw, 'int\s*\[\s*([^\]]+?)\s*\]\s*\((.*)\)\s*$', 'tokens', 'once');
    if isempty(tok)
        error('Cannot parse integral for LaTeX preview.');
    end

    lims_raw = strtrim(tok{1});
    integrand = strtrim(tok{2});

    lims_raw = regexprep(lims_raw, '\s+', ' ');
    lims_raw = strrep(lims_raw, ',', ' ');
    parts = strsplit(strtrim(lims_raw), ' ');
    if numel(parts) ~= 2
        error('Integral limits must have 2 entries.');
    end

    upper = parts{1};
    lower = parts{2};

    if contains(integrand,'t')
        var = 't';
    else
        var = 'x';
    end

    L = expr_to_latex(lower);
    U = expr_to_latex(upper);
    I = expr_to_latex(integrand);

    s = ['\int_{' L '}^{' U '} ' I '\,d' var];
end

function s = expr_to_latex(s)
    s = char(strtrim(s));
    s = regexprep(s,'yppp','y^{\prime\prime\prime}');
    s = regexprep(s,'ypp','y^{\prime\prime}');
    s = regexprep(s,'yp','y^{\prime}');
    s = strrep(s,'ln(','\ln(');
    s = strrep(s,'cos(','\cos(');
    s = strrep(s,'sin(','\sin(');
    s = strrep(s,'tan(','\tan(');
    s = strrep(s,'arctg','\arctan');

    s = regexprep(s,'sqrt\^(\d+)\(([^()]+)\)','\\sqrt[$1]{$2}');
    s = regexprep(s,'sqrt\(([^()]+)\)','\\sqrt{$1}');

    s = regexprep(s,'e\^\(([^)]*)\)','\\exp\{$1\}');
    s = regexprep(s,'e\^([^\(\)\s]+)','\\exp\{$1\}');

    s = regexprep(s,'\^([a-zA-Z0-9]+)','^{$1}');
    s = regexprep(s,'\^\(([^)]*)\)','^{$1}');

    s = regexprep(s,'(\([^()]+\)|[a-zA-Z0-9\.]+)\s*/\s*(\([^()]+\)|[a-zA-Z0-9\.]+)',...
        '\\frac{$1}{$2}');

    s = strrep(s,'*','\,');
end
