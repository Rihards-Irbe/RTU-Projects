%1.2 uzdevums. Atrisināt lineāru vienādojumu sistēmu, izmantojot Gausa metodi. Noteikt vispārīgo atrisinājumu.

A = [
    3, -1, 4;
    2, 3, 1;
    7, 5, 6
    ];

B = [-1; 1; 1];
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
    
    syms z, X_gen = sol(:,col+1)-sol(:,col).*z

    disp('Atbilde:');
    disp(' ' + LVS_case);

    fprintf(' x = %s, y = %s; ', X_gen(1:2));
    fprintf(' z - jebkuri reāli skaitļi\n');

else
    disp('Atbilde:');
    disp(' '  + LVS_case);
end