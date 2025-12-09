clc, clearvars, format compact, close all

fprintf('=======================================================\n');
fprintf('  VIENĀDOJUMU RISINĀTĀJA ĢENERATORS\n');
fprintf('  (Automātiski atrod saknes un ģenerē .m failu)\n');
fprintf('=======================================================\n\n');

fprintf('Izvēlieties uzdevuma tipu:\n');
fprintf('  1 - Vienādojuma/sistēmas risinājums (standarta)\n');
fprintf('  2 - Reālu sakņu skaita noteikšana\n');
fprintf('  3 - Sistēmas risinājums ar normas aprēķinu\n');
fprintf('  4 - Tikai grafiks (vienādojuma/sistēmas vizualizācija)\n');
task_type = input('Ievadiet izvēli (1, 2, 3 vai 4): ');

while ~ismember(task_type, [1, 2, 3, 4])
    fprintf('Kļūda! Ievadiet 1, 2, 3 vai 4.\n');
    task_type = input('Ievadiet izvēli (1, 2, 3 vai 4): ');
end

if task_type == 2
    fprintf('\n=======================================================\n');
    fprintf('REĀLU SAKŅU SKAITA NOTEIKŠANA\n');
    fprintf('(Automātiski atrod un saskaita reālās saknes)\n');
    fprintf('=======================================================\n\n');
    
    fprintf('Vai ir vairākas funkcijas (sistēma)?\n');
    fprintf('  1 - Viena funkcija\n');
    fprintf('  2 - Vairākas funkcijas (sistēma)\n');
    system_type = input('Ievadiet izvēli (1 vai 2): ');
    
    while ~ismember(system_type, [1, 2])
        fprintf('Kļūda! Ievadiet 1 vai 2.\n');
        system_type = input('Ievadiet izvēli (1 vai 2): ');
    end
    
    if system_type == 1
        fprintf('\nIevadiet vienādojumu:\n');
        fprintf('Piemērs: x^3 - 6*x^2 + 11*x - 6\n');
        fprintf('Piemērs: x^2-4*x+4 = 2*cos(2*x)\n\n');
        f_str = input('Vienādojums: ', 's');
        
        f_str = to_zero_form(f_str);
        fprintf('Pārveidots uz: %s = 0\n\n', f_str);
        
        fprintf('Ievadiet x ass intervālu sakņu meklēšanai:\n');
        x_min = input('x_min [noklusējums: -10]: ');
        if isempty(x_min), x_min = -10; end
        x_max = input('x_max [noklusējums: 10]: ');
        if isempty(x_max), x_max = 10; end
        
        fprintf('\nIevadiet izveidojamā faila nosaukumu:\n');
        filename = input('Faila nosaukums [noklusējums: count_real_roots.m]: ', 's');
        filename = normalize_filename(filename, 'count_real_roots.m');
        
        fid = fopen(filename, 'w');
        
        fprintf(fid, '%%%% Uzdevums: Reālu sakņu skaita noteikšana (1D)\n');
        fprintf(fid, 'clc, clearvars, format compact, close all, format longG\n\n');
        
        fprintf(fid, '%% Palīgfunkcija sqrt^n apstrādei\n');
        fprintf(fid, 'function y = sqrt_power(x, n)\n');
        fprintf(fid, '    y = x.^(1/n);\n');
        fprintf(fid, 'end\n\n');
        
        f_str_matlab = make_matlab_expr(f_str);
        
        fprintf(fid, 'f = @(x) %s;\n\n', f_str_matlab);
        fprintf(fid, 'x_min = %g; x_max = %g;\n\n', x_min, x_max);
        
        fprintf(fid, 'n_points = 2000;\n');
        fprintf(fid, 'x_grid = linspace(x_min, x_max, n_points);\n');
        fprintf(fid, 'f_values = f(x_grid);\n\n');
        
        fprintf(fid, 'sign_changes = find(diff(sign(f_values)) ~= 0);\n');
        fprintf(fid, 'n_intervals = length(sign_changes);\n\n');
        
        fprintf(fid, 'x_roots = [];\n');
        fprintf(fid, 'f_roots = [];\n');
        fprintf(fid, 'tolerance = 1e-6;\n\n');
        
        fprintf(fid, 'for i = 1:n_intervals\n');
        fprintf(fid, '    idx = sign_changes(i);\n');
        fprintf(fid, '    a = x_grid(idx);\n');
        fprintf(fid, '    b = x_grid(idx+1);\n');
        fprintf(fid, '    if f(a) * f(b) < 0\n');
        fprintf(fid, '        try\n');
        fprintf(fid, '            [xr, fv, ef] = fzero(f, [a b]);\n');
        fprintf(fid, '            if ef > 0 && abs(fv) < tolerance\n');
        fprintf(fid, '                if isempty(x_roots) || all(abs(xr - x_roots) > tolerance)\n');
        fprintf(fid, '                    x_roots = [x_roots, xr];\n');
        fprintf(fid, '                    f_roots = [f_roots, fv];\n');
        fprintf(fid, '                end\n');
        fprintf(fid, '            end\n');
        fprintf(fid, '        catch\n');
        fprintf(fid, '        end\n');
        fprintf(fid, '    end\n');
        fprintf(fid, 'end\n\n');
        
        fprintf(fid, 'n_roots = length(x_roots);\n');
        fprintf(fid, 'fprintf(''=======================================================\\n'');\n');
        fprintf(fid, 'fprintf(''Vienādojumam f(x)=0\\n'');\n');
        fprintf(fid, 'fprintf(''Intervālā [%%g, %%g] ir %%d reāla(s) sakne(s).\\n'', x_min, x_max, n_roots);\n');
        fprintf(fid, 'fprintf(''=======================================================\\n\\n'');\n\n');
        
        fprintf(fid, 'if n_roots > 0\n');
        fprintf(fid, '    fprintf(''Sakņu koordinātas (x, f(x)):\\n'');\n');
        fprintf(fid, '    for i = 1:n_roots\n');
        fprintf(fid, '        fprintf(''  %%d) x = %%.6f, f(x) = %%.3e\\n'', i, x_roots(i), f_roots(i));\n');
        fprintf(fid, '    end\n');
        fprintf(fid, 'else\n');
        fprintf(fid, '    fprintf(''Nav atrasta neviena sakne dotajā intervālā.\\n'');\n');
        fprintf(fid, 'end\n\n');
        
        fprintf(fid, '%% Grafiks\n');
        fprintf(fid, 'x_plot = linspace(x_min, x_max, 1000);\n');
        fprintf(fid, 'y_plot = f(x_plot);\n');
        fprintf(fid, 'figure(''Position'', [100, 100, 800, 600]);\n');
        fprintf(fid, 'hold on; grid on; box on;\n');
        fprintf(fid, 'plot(x_plot, y_plot, ''b-'', ''LineWidth'', 2);\n');
        fprintf(fid, 'plot([x_min x_max], [0 0], ''k--'');\n');
        fprintf(fid, 'if n_roots > 0\n');
        fprintf(fid, '    plot(x_roots, zeros(size(x_roots)), ''ro'', ''MarkerFaceColor'', ''r'');\n');
        fprintf(fid, 'end\n');
        fprintf(fid, 'xlabel(''x''); ylabel(''f(x)'');\n');
        fprintf(fid, 'title(sprintf(''f(x)=0, sakņu skaits: %%d'', n_roots));\n');
        fprintf(fid, 'xlim([x_min x_max]);\n');
        fprintf(fid, 'ymax = max(abs(y_plot)); if ymax == 0, ymax = 1; end\n');
        fprintf(fid, 'ylim([-1.2*ymax 1.2*ymax]);\n');
        fprintf(fid, 'hold off;\n');
        
        fclose(fid);
        
        fprintf('\n=======================================================\n');
        fprintf('PABEIGTS!\n');
        fprintf('=======================================================\n\n');
        fprintf('Fails izveidots: %s\n', filename);
        fprintf('Lai izpildītu: run %s\n\n', filename);
        type(filename);
        return;
    end
    
    if system_type == 2
        n_funcs = input('\nCik funkcijas sistēmā? ');
        fprintf('\nCik mainīgie sistēmā? (x1, x2, x3, ...): ');
        n_vars = input('');
        
        var_names = cell(1, n_vars);
        for i = 1:n_vars
            var_names{i} = sprintf('x%d', i);
        end
        
        fprintf('\nIevadiet funkcijas:\n');
        fprintf('Pieejamie mainīgie: %s\n\n', strjoin(var_names, ', '));
        
        f_strs_converted = cell(n_funcs, 1);
        for i = 1:n_funcs
            f_str = input(sprintf('Funkcija %d: ', i), 's');
            f_strs_converted{i} = to_zero_form(f_str);
        end
        
        fprintf('\nIevadiet izveidojamā faila nosaukumu:\n');
        filename = input('Faila nosaukums [noklusējums: count_real_roots.m]: ', 's');
        filename = normalize_filename(filename, 'count_real_roots.m');
        
        fid = fopen(filename, 'w');
        
        fprintf(fid, '%%%% Uzdevums: Sistēmas reālo sakņu noteikšana (vizuāli)\n');
        fprintf(fid, 'clc, clearvars, format compact, close all, format longG\n\n');
        
        fprintf(fid, 'function y = sqrt_power(x, n)\n');
        fprintf(fid, '    y = x.^(1/n);\n');
        fprintf(fid, 'end\n\n');
        
        fprintf(fid, '%% Funkciju apraksti\n');
        for i = 1:n_funcs
            f_matlab = make_matlab_expr(f_strs_converted{i});
            fprintf(fid, 'f%d = @(', i);
            for j = 1:n_vars
                fprintf(fid, 'x%d', j);
                if j < n_vars, fprintf(fid, ','); end
            end
            fprintf(fid, ') %s;\n', f_matlab);
        end
        fprintf(fid, '\n');
        
        if n_vars == 2
            fprintf(fid, 'x1_range = linspace(-10, 10, 401);\n');
            fprintf(fid, 'x2_range = linspace(-10, 10, 401);\n');
            fprintf(fid, '[X1, X2] = meshgrid(x1_range, x2_range);\n\n');
            for i = 1:n_funcs
                fprintf(fid, 'F%d = f%d(X1, X2);\n', i, i);
            end
            fprintf(fid, '\n');
            fprintf(fid, 'figure(''Position'', [100, 100, 900, 700]);\n');
            fprintf(fid, 'hold on; grid on; box on;\n');
            
            colors = {'r','b','g','m','c'};
            for i = 1:n_funcs
                col = colors{mod(i-1, numel(colors))+1};
                fprintf(fid, '[~, h%d] = contour(X1, X2, F%d, [0 0], ''LineWidth'', 2, ''LineColor'', ''%s'');\n', i, i, col);
                fprintf(fid, 'set(h%d, ''DisplayName'', sprintf(''f%%d=0'', %d));\n', i, i);
            end
            
            fprintf(fid, 'xlabel(''x_1''); ylabel(''x_2'');\n');
            fprintf(fid, 'title(''Kontūru krustpunkti (potenciālās saknes)'');\n');
            fprintf(fid, 'legend(''Location'', ''best'');\n');
            fprintf(fid, 'axis equal; xlim([-10 10]); ylim([-10 10]);\n');
            fprintf(fid, 'hold off;\n');
        else
            fprintf(fid, 'fprintf(''Sistēmai ar %d mainīgajiem nav pieejama vienkārša grafiskā metode.\\n'');\n', n_vars);
        end
        
        fclose(fid);
        
        fprintf('\n=======================================================\n');
        fprintf('PABEIGTS!\n');
        fprintf('=======================================================\n\n');
        fprintf('Fails izveidots: %s\n', filename);
        fprintf('Lai izpildītu: run %s\n\n', filename);
        type(filename);
        return;
    end
end

if task_type == 3
    fprintf('\n=======================================================\n');
    fprintf('SISTĒMAS RISINĀJUMS AR NORMAS APRĒĶINU\n');
    fprintf('=======================================================\n\n');
    
    n_funcs = input('Cik funkcijas sistēmā? ');
    n_vars = n_funcs;
    
    var_names = cell(1, n_vars);
    for i = 1:n_vars
        var_names{i} = sprintf('x%d', i);
    end
    
    fprintf('\nIevadiet funkcijas (f(x)=0 formā):\n');
    fprintf('Pieejamie mainīgie: %s\n\n', strjoin(var_names, ', '));
    
    f_strs_converted = cell(n_funcs, 1);
    for i = 1:n_funcs
        f_str = input(sprintf('Funkcija %d: ', i), 's');
        f_strs_converted{i} = to_zero_form(f_str);
    end
    
    fprintf('\nIevadiet sākuma tuvinājumu (vektors):\n');
    fprintf('Piemērs: [2 -2]\n');
    xapp_input = input('Sākuma tuvinājums: ', 's');
    xapp = str2num(xapp_input);
    if isempty(xapp) || length(xapp) ~= n_vars
        fprintf('Nepareizi ievadīts. Izmantoju noklusējumu.\n');
        xapp = ones(1, n_vars);
    end
    
    fprintf('\nIevadiet iterāciju skaitu:\n');
    n_iter = input('Iterācijas [noklusējums: 2]: ');
    if isempty(n_iter), n_iter = 2; end
    
    fprintf('\nIevadiet izveidojamā faila nosaukumu:\n');
    filename = input('Faila nosaukums [noklusējums: solve_with_norm.m]: ', 's');
    filename = normalize_filename(filename, 'solve_with_norm.m');
    
    fid = fopen(filename, 'w');
    fprintf(fid, '%%%% Uzdevums: Sistēmas risinājums ar normas aprēķinu\n');
    fprintf(fid, 'clc, clearvars, format compact, close all\n\n');
    
    fprintf(fid, 'function y = sqrt_power(x, n)\n');
    fprintf(fid, '    y = x.^(1/n);\n');
    fprintf(fid, 'end\n\n');
    
    fprintf(fid, '%% Funkciju apraksti\n');
    for i = 1:n_funcs
        f_matlab = make_matlab_expr(f_strs_converted{i});
        fprintf(fid, 'f%d = @(', i);
        for j = 1:n_vars
            fprintf(fid, 'x%d', j);
            if j < n_vars, fprintf(fid, ','); end
        end
        fprintf(fid, ') %s;\n', f_matlab);
    end
    fprintf(fid, '\n');
    
    fprintf(fid, '%% Simboliskie mainīgie\n');
    fprintf(fid, 'syms');
    for i = 1:n_vars
        fprintf(fid, ' x%d', i);
    end
    fprintf(fid, '\n\n');
    
    fprintf(fid, 'xapp = [%s];\n', num2str(xapp, ' %g'));
    fprintf(fid, 'xpr = [');
    for i = 1:n_vars
        fprintf(fid, 'x%d', i);
        if i < n_vars, fprintf(fid, ' '); end
    end
    fprintf(fid, '];\n\n');
    
    fprintf(fid, 'fun = [');
    for i = 1:n_funcs
        f_sym = make_symbolic_expr(f_strs_converted{i});
        fprintf(fid, '%s', f_sym);
        if i < n_funcs, fprintf(fid, ', '); end
    end
    fprintf(fid, '];\n\n');
    
    fprintf(fid, 'fun_pr = jacobian(fun, xpr);\n\n');
    
    fprintf(fid, 'iter = %d;\n', n_iter);
    fprintf(fid, 'M_pr = zeros(iter, %d);\n\n', n_vars + 1);
    
    fprintf(fid, 'for k = 1:iter\n');
    fprintf(fid, '    A = double(subs(fun_pr, xpr, xapp));\n');
    fprintf(fid, '    B = -double(subs(fun, xpr, xapp)).'';\n');
    fprintf(fid, '    xdelta = A\\B;\n');
    fprintf(fid, '    xapp = xapp + xdelta.'';\n');
    for i = 1:n_vars
        fprintf(fid, '    M_pr(k,%d) = xapp(%d);\n', i, i);
    end
    fprintf(fid, '    M_pr(k,%d) = norm(xapp);\n', n_vars + 1);
    fprintf(fid, 'end\n\n');
    
    fprintf(fid, 'fprintf(''Atbilde:\\n'');\n');
    fprintf(fid, 'fprintf('' ||z^(%d)||_2 = %%.4f\\n'', M_pr(iter,%d));\n', n_iter, n_vars + 1);
    
    fclose(fid);
    
    fprintf('\n=======================================================\n');
    fprintf('PABEIGTS!\n');
    fprintf('=======================================================\n\n');
    fprintf('Fails izveidots: %s\n', filename);
    fprintf('Lai izpildītu: run %s\n\n', filename);
    
    type(filename);
    return;
end

if task_type == 4
    fprintf('\n=======================================================\n');
    fprintf('TIKAI GRAFIKI\n');
    fprintf('=======================================================\n\n');
    
    fprintf('Izvēlieties grafika tipu:\n');
    fprintf('  1 - Viena funkcija f(x)=0\n');
    fprintf('  2 - 2D sistēma: f1(x1,x2)=0 un f2(x1,x2)=0\n');
    graph_type = input('Ievadiet izvēli (1 vai 2): ');
    
    while ~ismember(graph_type, [1, 2])
        fprintf('Kļūda! Ievadiet 1 vai 2.\n');
        graph_type = input('Ievadiet izvēli (1 vai 2): ');
    end
    
    if graph_type == 1
        fprintf('\nIevadiet vienādojumu:\n');
        fprintf('Piemērs: cos(x-0.4) = sin(2*x-7)*sqrt(x+2) + 0.3*x^3\n\n');
        f_str = input('Vienādojums: ', 's');
        
        f_str = to_zero_form(f_str);
        fprintf('Pārveidots uz: %s = 0\n\n', f_str);
        
        fprintf('Ievadiet x ass intervālu grafikam:\n');
        x_min = input('x_min [noklusējums: -10]: ');
        if isempty(x_min), x_min = -10; end
        x_max = input('x_max [noklusējums: 10]: ');
        if isempty(x_max), x_max = 10; end
        
        fprintf('\nIevadiet izveidojamā faila nosaukumu:\n');
        filename = input('Faila nosaukums [noklusējums: plot_equation.m]: ', 's');
        filename = normalize_filename(filename, 'plot_equation.m');
        
        f_str_matlab = make_matlab_expr(f_str);
        
        fid = fopen(filename, 'w');
        fprintf(fid, '%%%% Uzdevums: Tikai grafiks (viena funkcija)\n');
        fprintf(fid, 'clc, clearvars, format compact, close all\n\n');
        
        fprintf(fid, 'function y = sqrt_power(x, n)\n');
        fprintf(fid, '    y = x.^(1/n);\n');
        fprintf(fid, 'end\n\n');
        
        fprintf(fid, 'f = @(x) %s;\n\n', f_str_matlab);
        fprintf(fid, 'x_min = %g; x_max = %g;\n', x_min, x_max);
        fprintf(fid, 'x = linspace(x_min, x_max, 1200);\n');
        fprintf(fid, 'y = f(x);\n\n');
        
        fprintf(fid, 'figure(''Position'', [100, 100, 800, 600]);\n');
        fprintf(fid, 'hold on; grid on; box on;\n');
        fprintf(fid, 'plot(x, y, ''b-'', ''LineWidth'', 2);\n');
        fprintf(fid, 'plot([x_min x_max], [0 0], ''k--'');\n');
        fprintf(fid, 'xlabel(''x''); ylabel(''f(x)'');\n');
        fprintf(fid, 'title(''Funkcijas f(x) grafiks (vienādojums f(x)=0)'');\n');
        fprintf(fid, 'xlim([x_min x_max]);\n');
        fprintf(fid, 'ymax = max(abs(y)); if ymax == 0, ymax = 1; end\n');
        fprintf(fid, 'ylim([-1.2*ymax 1.2*ymax]);\n');
        fprintf(fid, 'hold off;\n');
        
        fclose(fid);
        
        fprintf('\n=======================================================\n');
        fprintf('PABEIGTS!\n');
        fprintf('=======================================================\n\n');
        fprintf('Fails izveidots: %s\n', filename);
        fprintf('Lai izpildītu: run %s\n\n', filename);
        type(filename);
        return;
    end
    
    if graph_type == 2
        n_funcs = 2; n_vars = 2;
        
        fprintf('\nIevadiet 2 vienādojumus sistēmai:\n');
        fprintf('Var izmantot x,y vai x1,x2.\n\n');
        
        f_strs_converted = cell(n_funcs, 1);
        for i = 1:n_funcs
            eq = input(sprintf('Vienādojums %d: ', i), 's');
            eq = to_zero_form(eq);
            eq = regexprep(eq, '\<x\>', 'x1');
            eq = regexprep(eq, '\<y\>', 'x2');
            f_strs_converted{i} = eq;
        end
        
        fprintf('\nIevadiet zīmēšanas diapazonu:\n');
        x1_min = input('x1_min [noklusējums: -10]: ');
        if isempty(x1_min), x1_min = -10; end
        x1_max = input('x1_max [noklusējums: 10]: ');
        if isempty(x1_max), x1_max = 10; end
        x2_min = input('x2_min [noklusējums: -10]: ');
        if isempty(x2_min), x2_min = -10; end
        x2_max = input('x2_max [noklusējums: 10]: ');
        if isempty(x2_max), x2_max = 10; end
        
        fprintf('\nIevadiet izveidojamā faila nosaukumu:\n');
        filename = input('Faila nosaukums [noklusējums: plot_system2d.m]: ', 's');
        filename = normalize_filename(filename, 'plot_system2d.m');
        
        f_mat = cell(n_funcs, 1);
        for i = 1:n_funcs
            f_mat{i} = make_matlab_expr(f_strs_converted{i});
        end
        
        fid = fopen(filename, 'w');
        fprintf(fid, '%%%% Uzdevums: Tikai grafiks (2D sistēma)\n');
        fprintf(fid, 'clc, clearvars, format compact, close all\n\n');
        
        fprintf(fid, 'function y = sqrt_power(x, n)\n');
        fprintf(fid, '    y = x.^(1/n);\n');
        fprintf(fid, 'end\n\n');
        
        fprintf(fid, 'f1 = @(x1,x2) %s;\n', f_mat{1});
        fprintf(fid, 'f2 = @(x1,x2) %s;\n\n', f_mat{2});
        
        fprintf(fid, 'x1_min = %g; x1_max = %g;\n', x1_min, x1_max);
        fprintf(fid, 'x2_min = %g; x2_max = %g;\n\n', x2_min, x2_max);
        
        fprintf(fid, 'x1_range = linspace(x1_min, x1_max, 500);\n');
        fprintf(fid, 'x2_range = linspace(x2_min, x2_max, 500);\n');
        fprintf(fid, '[X1, X2] = meshgrid(x1_range, x2_range);\n\n');
        
        fprintf(fid, 'F1 = f1(X1, X2);\n');
        fprintf(fid, 'F2 = f2(X1, X2);\n\n');
        
        fprintf(fid, 'figure(''Position'', [100, 100, 900, 700]);\n');
        fprintf(fid, 'hold on; grid on; box on;\n');
        fprintf(fid, '[~, h1] = contour(X1, X2, F1, [0 0], ''LineWidth'', 2, ''LineColor'', ''r'');\n');
        fprintf(fid, 'set(h1, ''DisplayName'', ''f_1=0'');\n');
        fprintf(fid, '[~, h2] = contour(X1, X2, F2, [0 0], ''LineWidth'', 2, ''LineColor'', ''b'');\n');
        fprintf(fid, 'set(h2, ''DisplayName'', ''f_2=0'');\n\n');
        
        fprintf(fid, 'xlabel(''x_1''); ylabel(''x_2'');\n');
        fprintf(fid, 'title(''2D sistēmas kontūras'');\n');
        fprintf(fid, 'legend(''Location'', ''best'');\n');
        fprintf(fid, 'axis equal;\n');
        fprintf(fid, 'xlim([x1_min x1_max]); ylim([x2_min x2_max]);\n');
        fprintf(fid, 'hold off;\n');
        
        fclose(fid);
        
        fprintf('\n=======================================================\n');
        fprintf('PABEIGTS!\n');
        fprintf('=======================================================\n\n');
        fprintf('Fails izveidots: %s\n', filename);
        fprintf('Lai izpildītu: run %s\n\n', filename);
        type(filename);
        return;
    end
end

fprintf('Izvēlieties metodi:\n');
fprintf('  1 - Ņūtona metode (Newton''s method)\n');
fprintf('  2 - Sekanšu metode (Secant / Hordu)\n');
method = input('Ievadiet izvēli (1 vai 2): ');

while ~ismember(method, [1, 2])
    fprintf('Kļūda! Ievadiet 1 vai 2.\n');
    method = input('Ievadiet izvēli (1 vai 2): ');
end

fprintf('\nVai ir vairākas funkcijas (sistēma)?\n');
fprintf('  1 - Viena funkcija\n');
fprintf('  2 - Vairākas funkcijas (sistēma)\n');
system_type = input('Ievadiet izvēli (1 vai 2): ');

while ~ismember(system_type, [1, 2])
    fprintf('Kļūda! Ievadiet 1 vai 2.\n');
    system_type = input('Ievadiet izvēli (1 vai 2): ');
end

if system_type == 2 && method == 2
    fprintf('\n! Brīdinājums: Sekanšu/Hordu metode sistēmām nav atbalstīta.\n');
    fprintf('  Izmantošu Ņūtona metodi sistēmai.\n\n');
    method = 1;
end

if system_type == 2
    n_funcs = input('\nCik funkcijas sistēmā? ');
    fprintf('\nCik mainīgie sistēmā? (x1, x2, x3, ...): ');
    n_vars = input('');
    
    var_names = cell(1, n_vars);
    for i = 1:n_vars
        var_names{i} = sprintf('x%d', i);
    end
    
    fprintf('\nIevadiet funkcijas:\n');
    fprintf('Pieejamie mainīgie: %s\n\n', strjoin(var_names, ', '));
    
    f_strs_raw = cell(n_funcs, 1);
    f_strs_converted = cell(n_funcs, 1);
    for i = 1:n_funcs
        f_str = input(sprintf('Funkcija %d: ', i), 's');
        f_strs_raw{i} = f_str;
        f_strs_converted{i} = to_zero_form(f_str);
    end

else
    fprintf('\nIevadiet funkciju:\n');
    fprintf('Var izmantot =, ln, arctg, sqrt^n, int[lower,upper](...) = RHS\n\n');
    f_str_raw = input('Funkcija: ', 's');
    f_str = to_zero_form(f_str_raw);
    fprintf('Pārveidots uz: %s = 0\n\n', f_str);
end

fprintf('\nIevadiet precizitāti:\n');
epsi_input = input('Precizitāte [noklusējums: 1e-5]: ', 's');
if isempty(epsi_input)
    epsi = 1e-5;
else
    epsi = str2double(epsi_input);
    if isnan(epsi) || epsi <= 0
        epsi = 1e-5;
    end
end

fprintf('\nIevadiet maksimālo iterāciju skaitu:\n');
max_iter_display = input('Iterācijas [noklusējums: 6]: ');
if isempty(max_iter_display)
    max_iter_display = 6;
end

fprintf('\nVai uzdevumam ir īpaša izvade?\n');
fprintf('  1 - Standarta\n');
fprintf('  2 - Vismazākā sakne\n');
fprintf('  3 - Vislielākā sakne\n');
fprintf('  4 - Visas saknes\n');
fprintf('  5 - Vismazākais pozitīvs\n');
fprintf('  6 - Konkrēts mainīgais\n');
output_types_input = input('Ievadiet izvēli [noklusējums: 1]: ', 's');
output_types = parse_output_types(output_types_input);

find_min = ismember(2, output_types);
find_max = ismember(3, output_types);
find_all = ismember(4, output_types);
find_min_positive = ismember(5, output_types);
calc_specific_var = ismember(6, output_types);

specific_var = '';
if system_type == 2 && calc_specific_var
    fprintf('\nPieejamie mainīgie: %s\n', strjoin(var_names, ', '));
    specific_var = input('Kurš mainīgais jāaprēķina?: ', 's');
end

if system_type == 2
    fprintf('\nSākuma tuvinājumu izvēle:\n');
    fprintf('  1 - Noklusējums\n');
    fprintf('  2 - Manuāli\n');
    init_choice = input('Izvēle: ');
    
    if isempty(init_choice), init_choice = 1; end
    
    if init_choice == 1
        if n_vars == 2
            xapp = [0.9 0.6];
        else
            xapp = 0.5 * ones(1, n_vars);
        end
    else
        fprintf('\nIevadiet vektoru [x1 x2 ...]:\n');
        xapp_input = input('Tuvinājums: ', 's');
        xapp = str2num(xapp_input);
        if isempty(xapp) || length(xapp) ~= n_vars
            xapp = 0.5 * ones(1, n_vars);
        end
    end
else
    xapp = [];
end

user_newton_init = [];
user_secant_init = [];
user_interval_1d = [];

if system_type == 1
    has_integral = contains(f_str_raw, 'int[');
    
    if ~has_integral
        [x_apps, n_roots] = detect_initial_guesses_1d(f_str);
        fprintf('Atrastas %d sakne(s): %s\n', n_roots, mat2str(x_apps, 2));
    else
        x_apps = 5.0;
        n_roots = 1;
        fprintf('Atpazīts integrāļa vienādojums. Noklusējuma tuvinājums: %g\n', x_apps);
    end
    
    fprintf('\n=======================================================\n');
    fprintf('SĀKUMA TUVINĀJUMS (1D)\n');
    fprintf('=======================================================\n');
    
    if method == 1
        fprintf('Ņūtona metodei ievadi intervālu [no līdz].\n');
        fprintf('Piemērs: [0 1.5]\n');
        x_input = input('Sākuma tuvinājums [no līdz] [Enter = automātiski]: ', 's');
        
        if ~isempty(strtrim(x_input))
            vec = str2num(x_input);
            if numel(vec) == 2
                user_interval_1d = vec(:).';
                user_newton_init = mean(vec);
                x_apps = user_newton_init;
                n_roots = 1;
                fprintf('Izmantošu intervāla viduspunkta tuvinājumu: %.4f\n', user_newton_init);
            elseif numel(vec) == 1
                user_newton_init = vec;
                x_apps = user_newton_init;
                n_roots = 1;
            else
                fprintf('Nepareizs formāts. Izmantoju automātiski atrasto tuvinājumu.\n');
            end
        end
        
    else
        fprintf('Sekanšu/Hordu metodei ievadi divus sākuma tuvinājumus [no līdz].\n');
        fprintf('Piemērs: [0 1.5]\n');
        tmp = input('Sākuma tuvinājumi [no līdz] [Enter = automātiski]: ', 's');
        
        if ~isempty(strtrim(tmp))
            vec = str2num(tmp);
            if numel(vec) == 2
                user_secant_init = vec(:).';
                x_apps = user_secant_init(1);
                n_roots = 1;
            else
                fprintf('Nepareizs formāts. Izmantoju automātiski atrasto tuvinājumu.\n');
            end
        end
    end
    fprintf('\n');
else
    x_apps = [];
    n_roots = 0;
end

fprintf('\n=======================================================\n');
fprintf('PRIEKŠSKATĪJUMS PIRMS KODA ĢENERĒŠANAS\n');
fprintf('=======================================================\n');

fprintf('Uzdevuma tips: %s\n', task_label(task_type));
fprintf('Metode: %s\n', method_label(method));

if system_type == 1
    fprintf('Tips: Viena funkcija\n');
else
    fprintf('Tips: Sistēma (%d funkcijas, %d mainīgie)\n', n_funcs, n_vars);
end

fprintf('Precizitāte: %g\n', epsi);
fprintf('Iterāciju skaits (tabulai/ģenerācijai): %d\n', max_iter_display);

fprintf('Īpašā izvade: %s\n', output_types_to_text(output_types));

if system_type == 1
    if method == 1
        if ~isempty(user_interval_1d)
            fprintf('Sākuma intervāls (Newton): [%g %g] -> viduspunkts %g\n', ...
                user_interval_1d(1), user_interval_1d(2), user_newton_init);
        else
            fprintf('Sākuma tuvinājumi (Newton, auto/enkuri): %s\n', mat2str(x_apps, 4));
        end
    else
        if ~isempty(user_secant_init)
            fprintf('Sākuma intervāls (Sekanšu/Hordu): [%g %g]\n', ...
                user_secant_init(1), user_secant_init(2));
        else
            fprintf('Sākuma tuvinājumi (Sekanšu, auto/enkuri): %s\n', mat2str(x_apps, 4));
        end
    end
else
    fprintf('Sākuma tuvinājums (sistēma): %s\n', mat2str(xapp, 4));
end

fprintf('=======================================================\n\n');

if system_type == 1
    show_equation_preview(f_str_raw, 'Vienādojuma priekšskatījums');
else
    for i = 1:n_funcs
        show_equation_preview(f_strs_raw{i}, sprintf('Vienādojums %d priekšskatījums', i));
    end
end

fprintf('\nIevadiet faila nosaukumu:\n');
filename = input('Nosaukums [noklusējums: solve_equation.m]: ', 's');
filename = normalize_filename(filename, 'solve_equation.m');

fprintf('\nĢenerē kodu...\n');

fid = fopen(filename, 'w');

if method == 1
    fprintf(fid, '%%%% Ņūtona metode\n');
else
    fprintf(fid, '%%%% Sekanšu (Hordu) metode\n');
end
fprintf(fid, 'clc, clearvars, format compact, close all, format longG\n\n');

fprintf(fid, '%% Palīgfunkcija sqrt^n apstrādei\n');
fprintf(fid, 'function y = sqrt_power(x, n)\n');
fprintf(fid, '    y = x.^(1/n);\n');
fprintf(fid, 'end\n\n');

if system_type == 1
    
    has_integral = contains(f_str_raw, 'int[');
    
    if has_integral
        [a_lim, b_lim, integrand_str, rhs_str] = parse_integral_equation(f_str_raw);
        
        integrand_matlab = make_matlab_expr(integrand_str);
        rhs_matlab = preprocess_sqrt_power_new(strrep(rhs_str, 'ln(', 'log('));
        rhs_matlab = strrep(rhs_matlab, 'arctg', 'atan');
        
        fprintf(fid, '%% Integrāļa vienādojums\n');
        fprintf(fid, 'f = @(a) integral(@(x) %s, %g, %g) - (%s);\n\n', ...
            integrand_matlab, a_lim, b_lim, rhs_matlab);
    else
        f_str_matlab = make_matlab_expr(f_str);
        fprintf(fid, 'f = @(x) %s;\n\n', f_str_matlab);
    end
    
    fprintf(fid, 'epsi = %.12g;\n', epsi);
    fprintf(fid, 'iter = %d;\n\n', max_iter_display);
    
    if method == 1
        
        if find_min || find_max || find_all || find_min_positive
            if isempty(x_apps)
                x_apps = 1.0; n_roots = 1;
            end
            
            fprintf(fid, '%% Sākuma tuvinājumu kopa\n');
            fprintf(fid, 'x_app = [%s];\n', num2str(x_apps, ' %.10g'));
            fprintf(fid, 'xapp_val = zeros(1, length(x_app));\n');
            fprintf(fid, 'syms x; fpr(x) = diff(f(x), x);\n\n');
            
            fprintf(fid, 'for j = 1:length(x_app)\n');
            fprintf(fid, '    xn = x_app(j);\n');
            fprintf(fid, '    M = zeros(iter,2);\n');
            fprintf(fid, '    for i = 1:iter\n');
            fprintf(fid, '        xn = xn - f(xn)/double(fpr(xn));\n');
            fprintf(fid, '        M(i,1) = xn; M(i,2) = f(xn);\n');
            fprintf(fid, '    end\n');
            fprintf(fid, '    xapp_val(j) = M(iter,1);\n');
            fprintf(fid, 'end\n\n');
            
            if find_min_positive
                fprintf(fid, 'pos = xapp_val(xapp_val > 0);\n');
                fprintf(fid, 'if isempty(pos)\n');
                fprintf(fid, '    result = xapp_val(1);\n');
                fprintf(fid, 'else\n');
                fprintf(fid, '    result = min(pos);\n');
                fprintf(fid, 'end\n');
                fprintf(fid, 'fprintf(''Atbilde. Ņūtona metode: x = %%.4f\\n'', result)\n');
            elseif find_min
                fprintf(fid, '[result, ~] = min(xapp_val);\n');
                fprintf(fid, 'fprintf(''Atbilde. Ņūtona metode: x = %%.4f\\n'', result)\n');
            elseif find_max
                fprintf(fid, '[result, ~] = max(xapp_val);\n');
                fprintf(fid, 'fprintf(''Atbilde. Ņūtona metode: x = %%.4f\\n'', result)\n');
            else
                fprintf(fid, 'fprintf(''Atbilde. Ņūtona metode: saknes (aproks.)\\n'')\n');
                fprintf(fid, 'disp(xapp_val)\n');
            end
            
        else
            if isempty(x_apps), x_apps = 1.0; n_roots = 1; end
            fprintf(fid, 'x_app = %.10g;\n', x_apps(1));
            fprintf(fid, 'syms x; fpr(x) = diff(f(x), x);\n');
            fprintf(fid, 'xn = x_app; M = zeros(iter,2);\n');
            fprintf(fid, 'for i = 1:iter\n');
            fprintf(fid, '    xn = xn - f(xn)/double(fpr(xn));\n');
            fprintf(fid, '    M(i,1) = xn; M(i,2) = f(xn);\n');
            fprintf(fid, 'end\n\n');
            fprintf(fid, 'fprintf(''Atbilde. Ņūtona metode: x = %%.4f\\n'', M(iter,1))\n');
        end
    end
    
    if method == 2
        
        if ~isempty(user_secant_init)
            fprintf(fid, '%% Lietotāja sākuma tuvinājumi\n');
            fprintf(fid, 'x0 = %.10g;\n', user_secant_init(1));
            fprintf(fid, 'x1 = %.10g;\n', user_secant_init(2));
            fprintf(fid, 'M = zeros(iter,2);\n');
            fprintf(fid, 'for i = 1:iter\n');
            fprintf(fid, '    f0 = f(x0); f1 = f(x1);\n');
            fprintf(fid, '    if abs(f1 - f0) < 1e-12, break; end\n');
            fprintf(fid, '    x2 = x1 - f1*(x1 - x0)/(f1 - f0);\n');
            fprintf(fid, '    M(i,1) = x2; M(i,2) = f(x2);\n');
            fprintf(fid, '    if abs(M(i,2)) < epsi, break; end\n');
            fprintf(fid, '    x0 = x1; x1 = x2;\n');
            fprintf(fid, 'end\n\n');
            fprintf(fid, 'fprintf(''Atbilde. Sekanšu metode: x = %%.4f\\n'', M(i,1))\n');
            
        else
            if isempty(x_apps)
                x_apps = 1.0; n_roots = 1;
            end
            
            if find_min || find_max || find_all || find_min_positive
                fprintf(fid, '%% Sākuma tuvinājumu kopa\n');
                fprintf(fid, 'x_app = [%s];\n', num2str(x_apps, ' %.10g'));
                fprintf(fid, 'xapp_val = zeros(1, length(x_app));\n\n');
                
                fprintf(fid, 'for j = 1:length(x_app)\n');
                fprintf(fid, '    x0 = x_app(j) - 0.5;\n');
                fprintf(fid, '    x1 = x_app(j) + 0.5;\n');
                fprintf(fid, '    M = zeros(iter,2);\n');
                fprintf(fid, '    for i = 1:iter\n');
                fprintf(fid, '        f0 = f(x0); f1 = f(x1);\n');
                fprintf(fid, '        if abs(f1 - f0) < 1e-12, break; end\n');
                fprintf(fid, '        x2 = x1 - f1*(x1 - x0)/(f1 - f0);\n');
                fprintf(fid, '        M(i,1) = x2; M(i,2) = f(x2);\n');
                fprintf(fid, '        if abs(M(i,2)) < epsi, break; end\n');
                fprintf(fid, '        x0 = x1; x1 = x2;\n');
                fprintf(fid, '    end\n');
                fprintf(fid, '    xapp_val(j) = M(i,1);\n');
                fprintf(fid, 'end\n\n');
                
                if find_min_positive
                    fprintf(fid, 'pos = xapp_val(xapp_val > 0);\n');
                    fprintf(fid, 'if isempty(pos)\n');
                    fprintf(fid, '    result = xapp_val(1);\n');
                    fprintf(fid, 'else\n');
                    fprintf(fid, '    result = min(pos);\n');
                    fprintf(fid, 'end\n');
                    fprintf(fid, 'fprintf(''Atbilde. Sekanšu metode: x = %%.4f\\n'', result)\n');
                elseif find_min
                    fprintf(fid, '[result, ~] = min(xapp_val);\n');
                    fprintf(fid, 'fprintf(''Atbilde. Sekanšu metode: x = %%.4f\\n'', result)\n');
                elseif find_max
                    fprintf(fid, '[result, ~] = max(xapp_val);\n');
                    fprintf(fid, 'fprintf(''Atbilde. Sekanšu metode: x = %%.4f\\n'', result)\n');
                else
                    fprintf(fid, 'fprintf(''Atbilde. Sekanšu metode: saknes (aproks.)\\n'')\n');
                    fprintf(fid, 'disp(xapp_val)\n');
                end
                
            else
                fprintf(fid, 'x_app = %.10g;\n', x_apps(1));
                fprintf(fid, 'x0 = x_app - 0.5;\n');
                fprintf(fid, 'x1 = x_app + 0.5;\n');
                fprintf(fid, 'M = zeros(iter,2);\n');
                fprintf(fid, 'for i = 1:iter\n');
                fprintf(fid, '    f0 = f(x0); f1 = f(x1);\n');
                fprintf(fid, '    if abs(f1 - f0) < 1e-12, break; end\n');
                fprintf(fid, '    x2 = x1 - f1*(x1 - x0)/(f1 - f0);\n');
                fprintf(fid, '    M(i,1) = x2; M(i,2) = f(x2);\n');
                fprintf(fid, '    if abs(M(i,2)) < epsi, break; end\n');
                fprintf(fid, '    x0 = x1; x1 = x2;\n');
                fprintf(fid, 'end\n\n');
                fprintf(fid, 'fprintf(''Atbilde. Sekanšu metode: x = %%.4f\\n'', M(i,1))\n');
            end
        end
    end
end

if system_type == 2
    
    fprintf(fid, '\n%% ==================== SISTĒMA (Ņūtona metode) ====================\n');
    
    fprintf(fid, 'syms');
    for i = 1:n_vars
        fprintf(fid, ' x%d', i);
    end
    fprintf(fid, '\n');

    for i = 1:n_funcs
        f_matlab = make_matlab_expr(f_strs_converted{i});
        fprintf(fid, 'f%d = @(', i);
        for j = 1:n_vars
            fprintf(fid, 'x%d', j);
            if j < n_vars, fprintf(fid, ','); end
        end
        fprintf(fid, ') %s;\n', f_matlab);
    end
    
    fprintf(fid, '\n');
    
    fprintf(fid, 'xpr = [');
    for i = 1:n_vars
        fprintf(fid, 'x%d', i);
        if i < n_vars, fprintf(fid, ' '); end
    end
    fprintf(fid, '];\n');
    
    fprintf(fid, 'fun = [');
    for i = 1:n_funcs
        f_sym = make_symbolic_expr(f_strs_converted{i});
        fprintf(fid, '%s', f_sym);
        if i < n_funcs, fprintf(fid, ', '); end
    end
    fprintf(fid, '];\n');
    
    fprintf(fid, 'fun_pr = jacobian(fun, xpr);\n\n');
    
    fprintf(fid, 'epsi = %.12g;\n', epsi);
    fprintf(fid, 'iter = %d;\n', max_iter_display);
    fprintf(fid, 'xapp = [%s];\n\n', num2str(xapp, ' %g'));
    
    fprintf(fid, 'M_pr = zeros(iter, %d);\n', n_vars + 1);
    fprintf(fid, 'for k = 1:iter\n');
    fprintf(fid, '    A = double(subs(fun_pr, xpr, xapp));\n');
    fprintf(fid, '    B = -double(subs(fun, xpr, xapp)).'';\n');
    fprintf(fid, '    xdelta = A\\B;\n');
    fprintf(fid, '    xapp = xapp + xdelta.'';\n');
    fprintf(fid, '    c = double(subs(fun, xpr, xapp));\n');
    fprintf(fid, '    sol_norm = norm(c);\n');
    for i = 1:n_vars
        fprintf(fid, '    M_pr(k,%d) = xapp(%d);\n', i, i);
    end
    fprintf(fid, '    M_pr(k,%d) = sol_norm;\n', n_vars + 1);
    fprintf(fid, '    if sol_norm < epsi, break; end\n');
    fprintf(fid, 'end\n\n');
    
    fprintf(fid, 'fprintf(''Atbilde. Ņūtona metode: sistēmai atrasts tuvināts risinājums\\n'');\n');
    
    if ~isempty(specific_var)
        idx = str2double(regexprep(specific_var, '[^\d]', ''));
        if isnan(idx) || idx < 1 || idx > n_vars, idx = 1; end
        fprintf(fid, 'fprintf(''   %s = %%.4f\\n'', M_pr(k,%d));\n', specific_var, idx);
    else
        fprintf(fid, 'fprintf(''   ');
        for i = 1:n_vars
            fprintf(fid, 'x%d = %%.4f', i);
            if i < n_vars, fprintf(fid, ',  '); end
        end
        fprintf(fid, '\\n'', M_pr(k,1:%d));\n', n_vars);
    end
end

fclose(fid);

fprintf('\n=======================================================\n');
fprintf('PABEIGTS!\n');
fprintf('=======================================================\n\n');
fprintf('Fails izveidots: %s\n', filename);
fprintf('Lai izpildītu: run %s\n\n', filename);

type(filename);

function out = to_zero_form(s)
    s = strtrim(s);
    if contains(s, '=')
        parts = split(s, '=');
        if numel(parts) == 2
            left  = strtrim(parts{1});
            right = strtrim(parts{2});
            if strcmp(right, '0')
                out = left;
            else
                out = ['(' left ')-(' right ')'];
            end
            return;
        end
    end
    out = s;
end

function expr = make_matlab_expr(expr)
    expr = strrep(expr, 'ln(', 'log(');
    expr = strrep(expr, 'arctg', 'atan');
    expr = preprocess_sqrt_power_new(expr);
    
    expr = regexprep(expr, '(?<!\.)\^', '.^');
    expr = regexprep(expr, '(?<!\.)\*', '.*');
    expr = regexprep(expr, '(?<!\.)/',  './');
end

function expr = make_symbolic_expr(expr)
    expr = strrep(expr, 'ln(', 'log(');
    expr = strrep(expr, 'arctg', 'atan');
    expr = preprocess_sqrt_power_new(expr);
    
    expr = strrep(expr, '.^', '^');
    expr = strrep(expr, '.*', '*');
    expr = strrep(expr, './', '/');
end

function fname = normalize_filename(fname, default_name)
    if isempty(fname)
        fname = default_name;
    end
    if ~endsWith(fname, '.m')
        fname = [fname '.m'];
    end
end

function v = parse_output_types(s)
    if isempty(s)
        v = 1; return;
    end
    v = str2num(s);
    if isempty(v)
        v = 1;
    end
end

function [a_lim, b_lim, integrand_str, rhs_str] = parse_integral_equation(eq_str)
    eq_str = strtrim(eq_str);
    parts = split(eq_str, '=');
    
    if numel(parts) ~= 2
        error('Integrāļa vienādojumam jābūt formā: int[a,b](...) = RHS');
    end
    
    left = strtrim(parts{1});
    rhs_str = strtrim(parts{2});
    
    tok = regexp(left, ...
        'int\[\s*([-\d\.]+)\s*,\s*([-\d\.]+)\s*\]\((.*)\)\s*$', ...
        'tokens', 'once');
    
    if isempty(tok)
        error('Nevar nolasīt integrāli. Piemērs: int[2,3](sin(x)+a) = 4');
    end
    
    a_lim = str2double(tok{1});
    b_lim = str2double(tok{2});
    integrand_str = strtrim(tok{3});
    
    if isnan(a_lim) || isnan(b_lim)
        error('Integrāļa robežām jābūt skaitļiem.');
    end
    
    if a_lim > b_lim
        tmp = a_lim; a_lim = b_lim; b_lim = tmp;
    end
end

function [x_apps, n_roots] = detect_initial_guesses_1d(f_str)
    
    f_str_sym = make_symbolic_expr(f_str);
    syms x
    try
        fun = str2sym(f_str_sym);
        f_num = matlabFunction(fun);
    catch
        error('Nevar parsēt funkciju.');
    end
    
    test_x = 0.1:0.1:10;
    try
        test_y = arrayfun(f_num, test_x);
    catch
        test_y = double(subs(fun, x, test_x));
    end
    
    sign_changes = find(diff(sign(test_y)) ~= 0);
    
    if isempty(sign_changes)
        test_x = -10:0.1:10;
        try
            test_y = arrayfun(f_num, test_x);
        catch
            test_y = double(subs(fun, x, test_x));
        end
        sign_changes = find(diff(sign(test_y)) ~= 0);
    end
    
    x_apps = [];
    for i = 1:length(sign_changes)
        idx = sign_changes(i);
        left = test_x(idx);
        right = test_x(idx+1);
        x0 = round((left + right)/2 * 10) / 10;
        x_apps = [x_apps, x0];
    end
    
    if isempty(x_apps)
        x_apps = 2.0;
    end
    
    x_apps = unique(x_apps);
    n_roots = length(x_apps);
end

function str_out = preprocess_sqrt_power_new(str_in)
    str_out = str_in;
    
    pattern = 'e\^\(([^)]*)\)';
    str_out = regexprep(str_out, pattern, 'exp($1)');
    
    pattern2 = 'e\^([^\(\)\s]+)';
    str_out = regexprep(str_out, pattern2, 'exp($1)');
    
    str_out = strrep(str_out, 'arctg', 'atan');
    
    pattern = 'sqrt\^(\d+)';
    [start_idx, end_idx, tokens] = regexp(str_out, pattern, 'start', 'end', 'tokens');
    
    for i = length(start_idx):-1:1
        n = tokens{i}{1};
        start_pos = start_idx(i);
        end_pos = end_idx(i);
        
        open_paren_pos = end_pos + 1;
        if open_paren_pos > length(str_out) || str_out(open_paren_pos) ~= '('
            continue;
        end
        
        paren_count = 1;
        close_paren_pos = open_paren_pos + 1;
        
        while close_paren_pos <= length(str_out) && paren_count > 0
            if str_out(close_paren_pos) == '('
                paren_count = paren_count + 1;
            elseif str_out(close_paren_pos) == ')'
                paren_count = paren_count - 1;
            end
            close_paren_pos = close_paren_pos + 1;
        end
        
        if paren_count == 0
            close_paren_pos = close_paren_pos - 1;
            argument = str_out(open_paren_pos+1:close_paren_pos-1);
            replacement = ['sqrt_power(', argument, ', ', n, ')'];
            str_out = [str_out(1:start_pos-1), replacement, str_out(close_paren_pos+1:end)];
        end
    end
end

function t = task_label(task_type)
    switch task_type
        case 1, t = 'Standarta risinājums';
        case 2, t = 'Reālu sakņu skaita noteikšana';
        case 3, t = 'Sistēma ar normas aprēķinu';
        case 4, t = 'Tikai grafiks';
        otherwise, t = 'Nezināms';
    end
end

function m = method_label(method)
    switch method
        case 1, m = 'Ņūtona metode';
        case 2, m = 'Sekanšu / Hordu metode';
        otherwise, m = 'Nezināma metode';
    end
end

function s = output_types_to_text(output_types)
    if isempty(output_types) || isequal(output_types, 1)
        s = 'Standarta';
        return;
    end
    
    names = {};
    if ismember(2, output_types), names{end+1} = 'Vismazākā sakne'; end
    if ismember(3, output_types), names{end+1} = 'Vislielākā sakne'; end
    if ismember(4, output_types), names{end+1} = 'Visas saknes'; end
    if ismember(5, output_types), names{end+1} = 'Vismazākais pozitīvs'; end
    if ismember(6, output_types), names{end+1} = 'Konkrēts mainīgais'; end
    
    if isempty(names)
        s = 'Standarta';
    else
        s = strjoin(names, ', ');
    end
end


function show_equation_preview(eq_raw, fig_name)
    eq_raw = strtrim(eq_raw);

    if nargin < 2 || isempty(fig_name)
        fig_name = 'Vienādojuma priekšskatījums';
    end

    try
        if contains(eq_raw, 'int[')
            [a_lim, b_lim, integrand_str, rhs_str] = parse_integral_equation(eq_raw);

            integrand_ltx = expr_to_latex_ordered(integrand_str);
            rhs_ltx       = expr_to_latex_ordered(rhs_str);

            eq_ltx = ['$\int_{' num2str(a_lim) '}^{' num2str(b_lim) '} ' ...
                      integrand_ltx '\,dx = ' rhs_ltx '$'];

        elseif contains(eq_raw, '=')
            parts = split(eq_raw, '=');
            if numel(parts) == 2
                left_str  = strtrim(parts{1});
                right_str = strtrim(parts{2});
            else
                left_str = eq_raw; right_str = '0';
            end

            left_ltx  = expr_to_latex_ordered(left_str);
            right_ltx = expr_to_latex_ordered(right_str);

            eq_ltx = ['$' left_ltx '=' right_ltx '$'];

        else
            expr_ltx = expr_to_latex_ordered(eq_raw);
            eq_ltx = ['$' expr_ltx '=0$'];
        end

        figure('Name', fig_name, 'Color', 'w');
        axis off
        text(0.02, 0.5, eq_ltx, ...
            'Interpreter','latex', ...
            'FontSize', 18);

    catch ME
        fprintf('(Brīdinājums) Neizdevās ģenerēt LaTeX priekšskatījumu: %s\n', ME.message);

        try
            if (exist('sym','class') == 8)
                f0 = to_zero_form(eq_raw);
                f0_sym = str2sym(make_symbolic_expr(convert_sqrt_power_to_fractional(f0)));
                disp('--- Vienādojuma simboliskais priekšskatījums f(x)=0 ---');
                pretty(f0_sym);
            end
        catch
        end
    end
end


function ltx = expr_to_latex_ordered(expr_str)

    s = strtrim(expr_str);

    s = strrep(s, 'arctg', '\arctan');
    s = strrep(s, 'atan',  '\arctan');
    s = strrep(s, 'ln(',   '\ln(');
    s = strrep(s, 'log(',  '\log(');

    s = regexprep(s, 'e\^\(([^)]*)\)', '\\exp($1)');
    s = regexprep(s, 'e\^([^\(\)\s]+)', '\\exp($1)');

    s = strrep(s, '.*', '*');
    s = strrep(s, './', '/');
    s = strrep(s, '.^', '^');

    s = convert_sqrt_power_to_latex(s);

    s = replace_sqrt_calls_for_latex(s);

    s = fix_power_parentheses_for_latex(s);

    s = regexprep(s, '\*', '\\cdot ');

    s = regexprep(s, '\s+', ' ');
    s = strtrim(s);

    ltx = s;
end


function s = convert_sqrt_power_to_latex(str_in)

    s = str_in;

    pattern = 'sqrt\^(\d+)';
    [start_idx, end_idx, tokens] = regexp(s, pattern, 'start', 'end', 'tokens');

    for i = length(start_idx):-1:1
        n = tokens{i}{1};
        start_pos = start_idx(i);
        end_pos   = end_idx(i);

        open_paren_pos = end_pos + 1;
        if open_paren_pos > length(s) || s(open_paren_pos) ~= '('
            continue;
        end

        paren_count = 1;
        p = open_paren_pos + 1;
        while p <= length(s) && paren_count > 0
            if s(p) == '('
                paren_count = paren_count + 1;
            elseif s(p) == ')'
                paren_count = paren_count - 1;
            end
            p = p + 1;
        end

        if paren_count ~= 0
            continue;
        end

        close_paren_pos = p - 1;
        argument = s(open_paren_pos+1 : close_paren_pos-1);

        replacement = ['\left(' argument '\right)^{1/' n '}'];

        s = [s(1:start_pos-1) replacement s(close_paren_pos+1:end)];
    end
end


function s = replace_sqrt_calls_for_latex(s)

    key = 'sqrt(';
    idx = strfind(s, key);

    for k = numel(idx):-1:1
        start_pos = idx(k);
        open_paren_pos = start_pos + length('sqrt');

        if open_paren_pos > length(s) || s(open_paren_pos) ~= '('
            continue;
        end

        paren_count = 1;
        p = open_paren_pos + 1;
        while p <= length(s) && paren_count > 0
            if s(p) == '('
                paren_count = paren_count + 1;
            elseif s(p) == ')'
                paren_count = paren_count - 1;
            end
            p = p + 1;
        end

        if paren_count ~= 0
            continue;
        end

        close_paren_pos = p - 1;
        argument = s(open_paren_pos+1 : close_paren_pos-1);

        replacement = ['\sqrt{' argument '}'];

        s = [s(1:start_pos-1) replacement s(close_paren_pos+1:end)];
    end
end


function s = fix_power_parentheses_for_latex(str_in)

    s = str_in;
    idx = strfind(s, '^(');

    for k = numel(idx):-1:1
        caret_pos = idx(k);
        open_paren_pos = caret_pos + 1;

        paren_count = 1;
        p = open_paren_pos + 1;
        while p <= length(s) && paren_count > 0
            if s(p) == '('
                paren_count = paren_count + 1;
            elseif s(p) == ')'
                paren_count = paren_count - 1;
            end
            p = p + 1;
        end

        if paren_count ~= 0
            continue;
        end

        close_paren_pos = p - 1;
        exponent = s(open_paren_pos+1 : close_paren_pos-1);

        replacement = ['^{' exponent '}'];

        s = [s(1:caret_pos-1) replacement s(close_paren_pos+1:end)];
    end
end


function str_out = convert_sqrt_power_to_fractional(str_in)
    str_out = str_in;

    pattern = 'sqrt\^(\d+)';
    [start_idx, end_idx, tokens] = regexp(str_out, pattern, 'start', 'end', 'tokens');

    for i = length(start_idx):-1:1
        n = tokens{i}{1};
        start_pos = start_idx(i);
        end_pos = end_idx(i);

        open_paren_pos = end_pos + 1;
        if open_paren_pos > length(str_out) || str_out(open_paren_pos) ~= '('
            continue;
        end

        paren_count = 1;
        close_paren_pos = open_paren_pos + 1;

        while close_paren_pos <= length(str_out) && paren_count > 0
            if str_out(close_paren_pos) == '('
                paren_count = paren_count + 1;
            elseif str_out(close_paren_pos) == ')'
                paren_count = paren_count - 1;
            end
            close_paren_pos = close_paren_pos + 1;
        end

        if paren_count == 0
            close_paren_pos = close_paren_pos - 1;
            argument = str_out(open_paren_pos+1:close_paren_pos-1);

            replacement = ['(' argument ')^(1/' n ')'];

            str_out = [str_out(1:start_pos-1), replacement, str_out(close_paren_pos+1:end)];
        end
    end
end

