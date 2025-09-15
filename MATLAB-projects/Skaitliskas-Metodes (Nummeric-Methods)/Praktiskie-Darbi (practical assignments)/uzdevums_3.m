% 1.3. uzdevums. Atrisināt lineāru vienādojumu sistēmu, izmantojot Gausa metodi. Noteikt
% vispārīgo atrisinājumu un atrast x_1, ja x_4 = -2.

A = [
    3, -3, 3, 6;
    3, 6, -3, 7;
    3, -9, 3, 1
    ];

B = [6; 1; 7];
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

    syms x4, X_gen = sol(:,col+1)-sol(:,col).*x4

    X_part = subs(X_gen,x4,-2) % ja x_4 = -2
    x_ver = X_part(1) % x_1

    disp('Atbilde:');
    disp(' ' + LVS_case);
    fprintf(' x1 = %s, x2 = %s, x3 = %s;\n', X_gen(1:3))
    fprintf(' kur x4 - jebkurš reāls skaitlis\n')
    fprintf('\n');
    fprintf(' x1 = %s', x_ver);
else
    disp('Atbilde:');
    disp(' ' + LVS_case);
end