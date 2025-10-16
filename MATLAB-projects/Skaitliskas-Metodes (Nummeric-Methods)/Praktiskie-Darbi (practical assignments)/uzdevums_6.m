% uzlabots kods: Atrisināt lineāru vienādojumu sistēmu, izmantojot Gausa
% metodi ar noteiktu konfigurāciju

A = [
    1, 1, 1, 1, 1;
    1, 2, 2, 4, 2;
    1, 2, 3, -1, 3
];
B = [3; 5; 6];

x_values = [0, 0, 0, -2, -1];  % x_n <vērtība>

x_find = [0, 0, 1];  % Kuru x atrast

[row, col] = size(A);
Aaug = [A B];
A_rank = rank(A)
Aaug_rank = rank(Aaug)
possible_solutions = true;

if (A_rank == Aaug_rank) && (A_rank == col)
    LVS_case = "LVS ir saderīga un noteikta (viens vienīgs atrisinājums)";
elseif (A_rank == Aaug_rank) && (Aaug_rank < col)
    LVS_case = "LVS ir saderīga un nenoteikta (bezgalīgi daudz atrisinājumu)";
elseif A_rank ~= Aaug_rank
    LVS_case = "LVS ir nesaderīga (neviena atrisinājuma)";
    possible_solutions = false;
end

if possible_solutions
    sol = sym(rref(Aaug))
    
    known_vars = find(x_values ~= 0);
    target_var = find(x_find == 1);
    
    pivot_cols = [];
    for i = 1:min(row, col)
        for j = 1:col
            if sol(i, j) == 1
                pivot_cols = [pivot_cols, j];
                break;
            end
        end
    end
    free_cols = setdiff(1:col, pivot_cols);
    
    syms_array = sym(zeros(1, col));
    for i = 1:length(free_cols)
        syms_array(free_cols(i)) = sym(sprintf('x%d', free_cols(i)));
    end
    
    X_gen = sym(zeros(col, 1));
    
    for i = 1:length(free_cols)
        X_gen(free_cols(i)) = syms_array(free_cols(i));
    end
    
    for i = 1:length(pivot_cols)
        pc = pivot_cols(i);
        X_gen(pc) = sol(i, col+1);
        
        for j = 1:length(free_cols)
            fc = free_cols(j);
            if sol(i, fc) ~= 0
                X_gen(pc) = X_gen(pc) - sol(i, fc) * syms_array(fc);
            end
        end
    end
    
    X_part = X_gen;
    for i = 1:length(known_vars)
        var_idx = known_vars(i);
        var_sym = sym(sprintf('x%d', var_idx));
        X_part = subs(X_part, var_sym, x_values(var_idx));
    end
    
    X_gen
    X_part
    X_part(target_var)
    
    disp('Atbilde:');
    fprintf(' %s\n', LVS_case);
    
    fprintf(' ');
    first = true;
    for i = 1:col
        if ismember(i, pivot_cols)
            if ~first
                fprintf(', ');
            end
            fprintf('x%d = %s', i, char(X_gen(i)));
            first = false;
        end
    end
    fprintf(';\n');
    
    if ~isempty(free_cols)
        fprintf(' kur ');
        for i = 1:length(free_cols)
            if i > 1
                fprintf(', ');
            end
            fprintf('x%d', free_cols(i));
        end
        fprintf(' - jebkuri reāli skaitļi\n');
    end

    if ~isempty(target_var)
        fprintf('\n');
        fprintf(' x%d = %s\n', target_var, char(X_part(target_var)));
    end
else
    disp('Atbilde:');
    disp(' ' + LVS_case);
end