clc, clearvars, format compact
A = [2, 3, -1, 5; 3, -5, 2, -1; 1, 4, -3, 3];
B = [7; -3; 8];
Aaug = [A B];
[row, col] = size(A);
A_rank = rank(A);
Aaug_rank = rank(Aaug);
sol = sym(rref(Aaug)); %sym aizstaj decimalskaitlus ar dalveida skaitliem
disp(sol);
syms x4, X_gen = sol(:,5)-sol(:,4).*x4; %syms nozime kad mainiga definejumu uzskatis ka vienadojumu, proti, nepildis nekadas matematiskas darbibas
% x4 var iedomaties, ka slideri tas veiks darbibas ar x1, x2, x3 un x4.
disp(X_gen); % basically uzrakstija vienadojumu, ka bija noradits X_gen mainiga definejuma