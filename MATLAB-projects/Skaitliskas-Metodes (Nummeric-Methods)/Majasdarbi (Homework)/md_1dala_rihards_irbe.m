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

l_32 = L(3,2);

x = l_32;
fl_32 = (3 + 2*x + 5*x^2 + sin(2*x)) / (1 + x + sqrt(1 + 2*cos(3*x)) + 2*x^3)

%% 2. uzdevums

A = [
    -2, 4, 7, 1;
     1, 0, -4, 6;
     2, 7, 1, 9;
     0, 4, 3, 5
    ];

ni = fun_prob12(A);
if ni == 2
    disp('Vismaz viens no galveniem minoriem ir vienāds ar nulli')
    disp('Atbilde: LU metodi nedrīkst izmantot'), return
else
    disp('Visi galvenie minori nav vienādi ar nulli')
end

[L, U, P] = lu(A);

l_32 = L(3,2);
fprintf('l_32 = %.4f\n', l_32)

%% 3. uzdevums

A = [
    1, 3, 3, 2, 1, 0;
     2, 6, 9, 5, 4, 3;
     -1, -3, 3, 0, 1, 2;
     1, 3, 6, 3, 3, 3
    ];

B = [1;2;1;1];

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
       
    syms x2 x4 x6, X_gen = sol(:,end) - sol(:,2)*x2 - sol(:,4)*x4 - sol(:,6)*x6;
    disp('Atbilde:');
    disp(' ' + LVS_case);
    fprintf(' x1 = %s, x3 = %s, x5 = %s; \n', X_gen(1:3));
else
    disp('Atbilde:');
    disp(' ' + LVS_case);
end

%%4. uzdevums

A = [
    0, 1, 2, -1;
    2, -3, 2, 0;
    2, -4, 0, 1;
    -2, 5, -3, 3
    ];

B = [2; -2; 3;1];
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

    sol = rref(Aaug)
    X_main = ['x1'; 'x2'; 'x3'; 'x4'];
    
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

%% 5. uzdevums

A = [
    1, 7, 2, 2;
    2, 14, 4, 2;
    5, 9, 9, 3;
    ];

B = [5; 4; 3];
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
    
    syms x3 x4
    
    X_gen = sol(1:row, col+1) - sol(1:row, 3)*x3 - sol(1:row, 4)*x4;
    X_gen(3) = x3;
    X_gen(4) = x4;
    
    x_part = subs(X_gen(1), x3, -2.04);
    x1_ver = x_part(1);

    disp('Atbilde:');
    disp(' ' + LVS_case);
    fprintf(' x1 = %.4f', x1_ver);

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