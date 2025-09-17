%% 1. uzdevums

clc, clearvars, format compact
A = [
    2, 3, -2, -1;
    3, 9, 1, 5;
    -2, 1, 12, 3;
    -1, 5, 3, 20
    ];

B = [-1; 2; -3; 6];

check = isequal(A,A');
if check == 0
    disp('Koeficientu matrica nav simetriskâ')
    disp('Atbilde:  Hoïecka metodi nedrîkst izmantot'), return
end

ni = fun_prob14(A);
if ni == 2 
  disp('Koeficientu matrica nav pozitîvi definçta')
  disp('Atbilde:  Hoïecka metodi nedrîkst izmantot'), return
end
disp('Koeficientu matrica ir simetriskâ un pozitîvi definçta ')

L = chol(A,'lower') ;
Amat = L*L';
Y = L\B;
X = L'\Y;

y_1 = Y(1);

fprintf('y_1 = %.4f\n', y_1);

%% 2. uzdevums

A = [
    4, 1, 3, -2;
    1, 5, 2, 4;
    3, 2, 8, 3;
    -2, 4, 3, 12
    ];

B = [-2; 3; 5; 4];
if det(A) == 0
 disp('Matrica A ir singulāra');
 disp(' Atbilde: atstarošanas metodi nedrīkst izmantot'), return
end
disp disp('Matrica A ir nesingulāra');
[Q,R] = qr(A);

q_33 = Q(3, 3);
fprintf('q_33 = %.4f\n', q_33)

%% 3. uzdevums

A = [
    1, 2, 1, -3;
     -1, 1, 3, 0;
     3, 4, -1, 6;
     4, 3, -4, 6
    ];

B = [7;4;5;1];

[row,col] = size(A);

Aaug = [A B];
A_rank = rank(A);
Aaug_rank = rank(Aaug);

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
    sol = sym(rref(Aaug));
       
    syms x4, X_gen = sol(:, end) - sol(:, 4)*x4;
    
    disp('Atbilde:');
    disp(' ' + LVS_case);
    fprintf(' x1 = %s, x2 = %s, x3 = %s;\n', X_gen(1:3));
else
    disp('Atbilde:');
    disp(' ' + LVS_case);
end

%% 4. uzdevums

A = [
    -3, 1, 3, 1, 5;
    6, 1, 1, 3, 1;
    0, 2, 1, -5, 1
    ];

B = [3; 2; 1];
[row,col] = size(A);

Aaug = [A B];
A_rank = rank(A);
Aaug_rank = rank(Aaug);

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

    sol = sym(rref(Aaug));

    syms x4 x5
    X_gen = sol(1:row, col+1) - sol(1:row, 4)*x4 - sol(1:row, 5)*x5;
    X_gen(4) = x4;
    X_gen(5) = x5;

    X_part = subs(X_gen, [x4, x5], [-1.02, 3.11]);
    x2_ver = X_part(2);

    disp('Atbilde:');
    disp(' ' + LVS_case);
    fprintf(' x2 = %.4f', double(x2_ver));

else
    disp('Atbilde:');
    disp(' ' + LVS_case);
end

%%Ārējās funkcijas
function ni = fun_prob14(A_mat)
    ni = 1;
    [row,col] = size(A_mat);
    for i = 1:row
        if det(A_mat(1:i,1:i))>0
        else 
            ni = 2; 
            break
        end
    end
end

function ni = fun_prob12(A_mat)
   ni = 1;
   [row,col] = size(A_mat);
   for i = 1:row
      if det(A_mat(1:i,1:i))~=0
      else ni = 2; break
      end
   end
end