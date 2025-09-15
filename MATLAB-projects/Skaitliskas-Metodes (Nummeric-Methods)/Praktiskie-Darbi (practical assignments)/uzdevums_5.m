%1.5. uzdevums. Atrisināt lineāru vienādojumu sistēmu, izmantojot
%   a) Gausa metodi;
%   b) LU dekompozīciju;
%   c) Hoļecka metodi;
%   d) QR dekompozīciju;
%   e) atrast koeficientu matricas determinantu un inverso matricu.

A = [
    4, 4, 5, 5;
    2, 0, 3, -1;
    1, 1, -5, 0;
    0, 3, 2, 0
    ];

B = [0; 10; -10; 1];
[row,col] = size(A);

Aaug = [A B];
A_rank = rank(A)
Aaug_rank = rank(Aaug)

%% a) Gausa metode

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
    X_gen = sol(:,col+1);
    
    disp('Atbilde:');
    disp(' '  + LVS_case);
    fprintf(' x1 = %g, x2 = %g, x3 = %g, x4 = %g \n', X_gen(1:4))
else
    disp('Atbilde:');
    disp(' '  + LVS_case + '\n');
end

%% b) LU dekompozīcija

ni = fun_prob12(A);
if ni == 2 
   disp('Vismaz viens no galveniem minoriem ir vienāds ar nulli')
   disp('Atbilde:  LU metodi nedrīkst izmantot'), return
else
   disp('Visi galvenie minori nav vienādi ar nulli')
end

[L,U,P] = lu(A)

Amat = P*L*U        % matrica A
Y = linsolve(L,P*B) % vai Y = L\(P*B)  
X = U\Y

disp('Atbilde:')
fprintf(' x1 = %.0f; x2 = %.0f; x3 = %.0f, x4 = %.0f \n',X)

% ārēja funkcija (1.12.piemērs) LU metode
% pārbaude: galvenie minori nav vienādi ar nulli
function ni = fun_prob12(A_mat)
   ni = 1;
   [row,col] = size(A_mat);
   for i = 1:row
      if det(A_mat(1:i,1:i))~=0
      else ni = 2; break
      end
   end
end