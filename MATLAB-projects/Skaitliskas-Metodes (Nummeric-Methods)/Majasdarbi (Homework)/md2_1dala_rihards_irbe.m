%% 1. Uzdevums

clc, clearvars, format compact
A = [
    6.3, -2, 2, -1;
    3, 8.8, -3.3, -2;
    2, -5.1, 12, 3.6;
    2.2, -3, 1, 9
    ];

B = [-4.2; -3; 5.2; -1.5];
if det(A) == 0
    disp('Matrica A ir singulārā ')
    disp(' Atbilde: Jakobi metodi nedrīkst izmantot'), return
end
disp('Matrica A ir nesingulārā')
fun_prob3(A)                        % pārbaude: Jakobi metode konverģē
n = length(B);
x_app = zeros(n,1);                 % sākuma tuvinājums X^(0) = (0, -1, -1, 0)^T
x_app(:,1) = [0; -1; -1; 0];        % dotais sākuma tuvinājums
iter = 0;                           % iterāciju skaits
itermax = 6;                        % maksimālais iterāciju skaits
epsi = 0.001;                       % epsi=10^(-3) (aprēķinu precizitāte)
errnorm = 1;                        % kļūdas norma
prnorm = zeros(itermax, 2);         % datu masīvs rezultātu saglabāšanai (6x2)
k = 1;

while errnorm > epsi && iter < itermax
    k = k+1; iter = iter+1;
    for i = 1:n
        res_sum = 0;
        for j = 1:n
            if j~=i
                res_sum = res_sum + x_app(j,k-1)*A(i,j);
            end
        end
        x_app(i,k) = (B(i,1)-res_sum)/A(i,i);
    end
    errnorm = norm(B - A*x_app(:,k), 2); % ||B - AX^(k)||_2
    prnorm(iter,:) = [iter, errnorm];
end
%disp('Iter.numurs Kļūda')
%disp(prnorm) % Ctrl+Enter
% turpinājums
x_approx = x_app(:,k);
x_sol = linsolve(A,B);
% turpinājums
[row,col] = size(prnorm);
disp('Atbilde:')
fprintf(' iterāciju skaits = %.0f -->', prnorm(row,1))
fprintf(' kļūda = %.4f\n', prnorm(row,2))

%% 2. Uzdevums

clc, clearvars, format compact
v = [-0.7, -4, 6, 2.7, -5.3, 4, -6.6, 9];

norm_v6 = norm(v, 6);
% turpinājums
disp('Atbilde:')
fprintf(' vektora norma(p=6) = %.4f\n', norm_v6)

%% 3. Uzdevums

clc, clearvars, format compact
A = [
    5, 2, -1;
    -2, 6, 3;
    2, -9, 12
    ];

B = [-1; -5; 6];
if det(A) == 0
    disp('Matrica A ir singulārā ')
    disp(' Atbilde: Jakobi metodi nedrīkst izmantot'), return
end
disp('Matrica A ir nesingulārā')
fun_prob3(A)                % pārbaude: Jakobi metode konverģē
n = length(B);
x_app = zeros(n,1);         % sākuma tuvinājums X^(0) = (0, -1, 0)^T
x_app(:,1) = [0; -1; 0];    % dotais sākuma tuvinājums
iter = 0;                   % iterāciju skaits
itermax = 6;                % maksimālais iterāciju skaits
epsi = 0.001;               % epsi=10^(-3) (aprēķinu precizitāte)
errnorm = 1;                % kļūdas norma
prnorm = zeros(itermax, 2); % datu masīvs rezultātu saglabāšanai (6x2)
k = 1;
while errnorm > epsi && iter < itermax
    k = k+1; iter = iter+1;
    for i = 1:n
        res_sum = 0;
        for j = 1:n
            if j~=i
                res_sum = res_sum + x_app(j,k-1)*A(i,j);
            end
        end
        x_app(i,k) = (B(i,1)-res_sum)/A(i,i);
    end
    errnorm = norm(x_app(:,k) - x_app(:,k-1), 2); % ||ε^(n)||_2 = ||X^(n) - X^(n-1)||_2
    prnorm(iter,:) = [iter, errnorm];
end
%disp('Iter.numurs Kļūda')
%disp(prnorm) % Ctrl+Enter
% turpinājums
x_approx = x_app(:,k);
x_sol = linsolve(A,B);
% turpinājums
[row,col] = size(prnorm);
disp('Atbilde:')
fprintf(' iterāciju skaits = %.0f -->', prnorm(row,1))
fprintf(' kļūda = %.4f\n', prnorm(row,2))

%% 4. Uzdevums

clc, clearvars, format compact

n = 12;
a = [0, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2];
b = [-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2];
c = [5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 0];
d = [2; 2; 2; 2; 2; 2; 2; 2; 2; 2; 2; 2];

ksi = zeros(1, n+1); eta = zeros(1, n+1);
for i = 1:n
    ksi(i+1) = c(i)/(b(i)-a(i)*ksi(i));
    eta(i+1) = (a(i)*eta(i)-d(i))/(b(i)-a(i)*ksi(i));
end
X(n) = eta(n+1); % aprēķināt x
for i = n-1:-1:1
    X(i) = ksi(i+1)*X(i+1)+eta(i+1);
end
% Ctrl+Enter

% turpinājums
disp('Atbilde:')
fun_prob16(a,b,c) % pārbaude: Faktorizācijas metode ir stabila

%% 5. Uzdevums

clc, clearvars, format compact

n = 6;
a = [0, 1, 2, 3, 4, 5];
b = [9, 9, 9, 9, 9, 9];
c = [5, 4, 3, 2, 1, 0];
d = [6; 5; 4; 3; 2; 1];

ksi = zeros(1, n+1); eta = zeros(1, n+1);
for i = 1:n
    ksi(i+1) = c(i)/(b(i)-a(i)*ksi(i));
    eta(i+1) = (a(i)*eta(i)-d(i))/(b(i)-a(i)*ksi(i));
end
X(n) = eta(n+1); % aprēķināt x
for i = n-1:-1:1
    X(i) = ksi(i+1)*X(i+1)+eta(i+1);
end

% Aprēķināt f(x₁)
x1 = X(1);
f_x1 = (1 + log(x1^2 + 3*x1 + 7)) / (3 + sqrt(2 + sin(4*x1) + x1^3) - 5*x1);

% turpinājums
disp('Atbilde:')
fun_prob16(a,b,c) % pārbaude: Faktorizācijas metode ir stabila
fprintf(' f(x1) = %.4f\n', f_x1)

%% Ārējās funkcijas
function fun_prob3(A_mat)
 [row,col] = size(A_mat);
 for i = 1:row
    sum =0;
    for j = 1:col
        if i~=j
            sum = sum+abs(A_mat(i,j));
        end
    end
    if abs(A_mat(i,i)) <= sum
      disp(' Neizpildâs konverìences pietiekamais nosacîjums')
      fprintf(' rindas numurs %.0f: --> %.0f < %.0f \n', i,A_mat(i,i),sum ) 
      return
    end
 end
 disp(' Izpildâs konver.pietiekamais nosacîjums - Jakobi metode konverìç')
end

function fun_prob16(a_el,b_el,c_el)
   n = length(a_el);
   for i = 1:n
      if abs(b_el(i)) < ( abs(a_el(i))+abs(c_el(i)) )
         disp(' Faktorizâcijas metode nav stabila'), return
      end
    end
    disp(' Faktorizâcijas metode ir stabila')  
end