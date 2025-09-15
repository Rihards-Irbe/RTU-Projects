% 1.4. uzdevums. Atrisināt lineāru vienādojumu sistēmu, izmantojot Gausa metodi. Noteikt
% vispārīgo atrisinājumu un atrast x_2, ja x_3 = -1, x_4 = 3.

A = [
    1, 2, 1, -3;
    2, 1, -2, 9;
    3, 3, -1, 6;
    4, 5, 0, 3
    ];

B = [5; -2; 3; 8];
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

    sol = sym(rref(Aaug))

    syms x3 x4
    X_gen = sol(1:col, col+1) - sol(1:col, 3)*x3 - sol(1:col, 4)*x4
    X_gen(3) = x3;
    X_gen(4) = x4;

    X_part = subs(X_gen, [x3, x4], [-1, 3])
    x2_ver = X_part(2)

    disp('Atbilde:');
    disp(' ' + LVS_case);
    fprintf(' x1 = %s, x2 = %s, x3 = %s;\n', X_gen(1:3))
    fprintf(' kur x3, x4 - jebkuri reāli skaitļi\n')
    fprintf('\n');
    fprintf(' x2 = %s', x2_ver);

else
    disp('Atbilde:');
    disp(' ' + LVS_case);
end