%% Atrisināt lineāru vienādojumu sistēmu, izmantojot Jakobi metodi. 

clc, clearvars, format compact
format longG

A = [
    3, -7, 3;
    -4, 1, 2;
    1, 2, 5
    ];

B = [29;2;17];
if det(A) == 0
 disp('Matrica A ir singulāra')
 disp('Atbilde: Jakobi metodi nedrīkst izmantot'), return
end

fun_prob3(A)

n = length(B);
x_app = zeros(n, 1);
iter = 0;               % iterāciju skaits
itermax = 20;           % maksimālais iterāciju skaits
epsi = 0.001;           % epsi=10^(-3) (aprēķinu precizitāte)
errnorm = 1;            % kļūdas norma
prnorm = zeros(1,2);    % datu masīvs rezultātu saglabāšanai
k = 1;
diverges = false;

while errnorm > epsi && iter < itermax
 k = k+1; iter = iter+1;
 for i = 1:n
 res_sum = 0;
 for j = 1:n
 if j~=i
 res_sum =res_sum+x_app(j,k-1)*A(i,j);
 end
 end
 x_app(i,k) =(B(i,1)-res_sum)/A(i,i);
 end
 errnorm =norm(x_app(:,k)-x_app(:,k-1));
 prnorm(iter,:) =[iter,errnorm];

 if iter > 1 && errnorm > prnorm(iter-1,2)
    diverges = true;
 end
end
disp('Iter. numurs Kļūda')
disp(prnorm)
x_approx = x_app(:,k)
x_sol = linsolve(A,B)

[row,col] = size(prnorm);
disp('Atbilde:')
fprintf('iterāciju skaits = %.0f\n',prnorm(row,1))
fprintf('kļūda (aug) = %.4f\n' ,prnorm(row,2))
if diverges
    fprintf("Jakobi metode diverģē")
else
    fprintf('x_tuvinājumi: { %.4f , %.4f, %.4f }\n',x_approx(:)')
end

% ārējā funkcija (2.3. piemērs). Jakobi metode
% pārbaude: vai Jakobi metode konverģē?
function fun_prob3(A_mat)
 [row,col] = size(A_mat);
for i = 1:row
 sum =0;
 for j = 1:col
 if i~=j
 sum =sum+abs(A_mat(i,j));
 end
 end
 if abs(A_mat(i,i)) <= sum
 disp('Neizpildās konverģences pietiekamais nosacījums')
 fprintf('rindas numurs %.0f: --> %.0f < %.0f \n', i,A_mat(i,i),sum )
 return
 end
end
 disp('Izpildās konver. pietiekamais nosacījums - Jakobi metode konverģē')
end