%% Atrisināt lineāru vienādojumu sistēmu, izmantojot Jakobi metodi. 

clc, clearvars, format compact
format longG

A = [
    2, 14, 10;
    14, 2, 8;
    10, 8, 2
    ];

B = [8;6;2];
if det(A) == 0
 disp('Matrica A ir singulāra')
 disp('Atbilde: Jakobi metodi nedrīkst izmantot'), return
end

fun_prob3(A)

n = length(B);
x_app = zeros(n, 1); %Sākuma tuvinājums ir x_1^(0) = 0, x_2^(0) = 0, x_3^(0) = 0. Interpretēt rezultātus, tapec jo tas ir atkarigs no matricas lielumu

iter = 0;               % iterāciju skaits
itermax = 13;           % maksimālais iterāciju skaits
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
x_approx = x_app(:,k);
x_sol = linsolve(A,B); % Atrisināt šo sistēmu, arī izmantojot komandu linsolve (ar komandu linsol;ve) iegūto rezultātu apzīmēsim ar x_sol).

epsil11_norm = norm(x_app(:, 12) - x_app(:, 11), 2) %Cik liela ir kļūdas norma ||E^(11)||_2 11. iterācijā, kur E^(n) = x(n) - x(n-1)?
X_app10_norm = norm(x_app(:, 11), 2) %Kāda ir atrisnājuma norma ||x^(10)||_2 10. iterācijā
epsil13_norm = norm(x_app(:, 14) - x_app(:, 13), 2) %Cik liela ir kļūdas norma ||E^(13)||_2 13. iterācijā
sol_X10_norm = norm(x_sol - x_app(:, 11), 2) %Cik liela ir norma ||x_sol - x^(10)||_2 ?

x_approx
x_sol

[row,col] = size(prnorm);
disp('Atbilde:')
fprintf(' iterāciju skaits = %.0f --> kļūda = %.5f (kļūda aug)\n', prnorm(end, 1), epsil13_norm);
fprintf(' iterāciju skaits = %.0f --> kļūda = %.5f (kļūda aug)\n', prnorm(11, 1), epsil11_norm);
fprintf(' X_app10_norm = %.4f\n', X_app10_norm);
fprintf(' sol_X10_norm = %.4f\n', sol_X10_norm);
fprintf(' Kļūda aug - ')

if diverges
    fprintf("Jakobi metode diverģē \n")
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