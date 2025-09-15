%1.1 uzdevums. Atrisināt lineāru vienādojumu sistēmu, izmantojot Gausa metodi.

A = [
    3, -1, 4;
    2, 3, 1;
    1, -5, -3
    ];

B = [-3; 5; 3];
[row,col] = size(A);

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

    sol = rref(Aaug) %rref(Aaug) izpilda gausa metodi
    X_main = ['x1'; 'x2'; 'x3'];
    
    X_value = zeros(col,1);
    for i = 1:col
        X_value(i) = sol(i, col+1);
    end
    solution = table(X_main, X_value)

    disp('Atbilde:');
    disp(' '  + LVS_case);
    disp(solution);
else
    disp('Atbilde:');
    disp(' '  + LVS_case);
end
