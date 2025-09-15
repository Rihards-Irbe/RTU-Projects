clc, clearvars, format compact
A = [3, -1, 2; 1, 2, -4; 2, -5, 1];
B = [9; -11; 14];
ni = fun_prob12(A);
if ni == 2
    disp('Vismaz viens no galveniem minoriem ir vienads ar nulli')
    disp('Atiblde:  LU metodi nedrikst izmantot')
else
    disp('Visi galvenie minori nav vienadi ar nulli')
end

[L, U, P] = lu(A); % sadala matricu 3 dalas L - apakštrīstūrveida madricu, U - augštrīsstūrveida matricu, P - permutācijas matricu
Amat = P*L*U; % Šis definejums kalpos, ka parbaude vai LU faktorizacija ir pareiza, proti atjaunojot matricu (Amat vertibai) jābūt vienādai ar sākotnējo A(vai ļoti tuvu, ja ir decimālskaitļi)
Y = linsolve(L,P*B); %Šeit tiek atrasta starpsolījuma vektors Y. nez ko tas nozime
X = U\Y; % backslash operators: risina lineāro sistēmu
% X = risinājums sistēmai A*X = B.
disp("Y =");
disp(Y);
disp("X =");
disp(X);

disp("atbilde: ");
fprintf('x1 = %.0f; x2 = %.0f; x3 = %.0f\n', X) % vnk izprintes secigi atbildes no X un %.0f nozime decimaplsakitlis ar 0 cipariem aiz komata.
function ni = fun_prob12(A_matrix) % function {atgriezeniskais mainigais} = {funkcijas nosaukums}({padotie mainigie})
    ni = 1;
    [row,col] = size(A_matrix);
    for i = 1:row
        if det(A_matrix(1:i,1:i))~=0 % parbauda pakapeniski, vai matricas ;seciba: (1x1, 2x2, 3x3); determinants nav vienads ar 0
        else ni = 2; break
        end
    end
end