%% 1. Uzdevums

clc, clearvars, format compact

A = [
    9.3, 2.5, -3.2, 1.2;
    -5.1, 8.3, -1.3, 1.2;
    -3.5, 2.3, 11.8, -2.4;
    -2.3, 2.2, -1.9, 7.9
    ];

B = [-2.2; -4.3; 3.3; -5.2];

if det(A) == 0
    disp('Matrica A ir singulārā ')
    disp(' Atbilde: Jakobi metodi nedrīkst izmantot'), return
end
disp('Matrica A ir nesingulārā')
fun_prob3(A)                % pārbaude: Jakobi metode konverģē

n = length(B);
x_app = zeros(n,7);
x_app(:,1) = [-1; -2; 1; 2];
itermax = 6;

for iter = 2:itermax+1
    for i = 1:n
        res_sum = 0;
        for j = 1:n
            if j~=i
                res_sum = res_sum + A(i,j)*x_app(j,iter-1);
            end
        end
        x_app(i,iter) = (B(i)-res_sum)/A(i,i);
    end
end

x_approx = x_app(:,end);
x_sol = linsolve(A,B);
disp('Atbilde:')
fprintf(' kļūda = %.4f\n', norm(x_approx,2))

%% 2. Uzdevums

clc, clearvars, format compact

n = 6;
a = [0, 1, 2, 3, 4, 5];
b = [7, 7, 7, 7, 7, 7];
c = [5, 4, 3, 2, 1, 0];
d = [-1; -2; -3; -4; -5; -6];

ksi = zeros(1, n+1); eta = zeros(1, n+1);

for i = 1:n
    ksi(i+1) = c(i)/(b(i)-a(i)*ksi(i));
    eta(i+1) = (d(i)-a(i)*eta(i))/(b(i)-a(i)*ksi(i));
end

X = zeros(n,1);
X(n) = eta(n+1);
for i = n-1:-1:1
    X(i) = ksi(i+1)*X(i+1)+eta(i+1);
end

% rezultāta izvade
disp('Atbilde:')
fun_prob16(a,b,c)
fprintf(' x6 = %.4f\n', X(6))

%% 3. Uzdevums

clc, clearvars, format compact
A = [-8.2, 3, -3, 1; 4, -9.3, 1.2, -3; -2, -4.3, 12, 1.5; -1, -2.2, -3, 7];  
B = [-5.2; -4; 3.2; -0.5];
if det(A) == 0
    disp('Matrica A ir singulârâ ')
    disp(' Atbilde:  Jakobi metodi nedrîkst izmantot'), return
end
disp('Matrica A ir nesingulârâ')
fun_prob3(A)         % pārbaude: Jakobi metode konverģē

% turpinâjums
x_app = [0; -1; 1; -1];
n = length(B);
iter = 0;            % iterâciju skaits
itermax = 7;         % maksimālais iterāciju skaits
prnorm = zeros(1,2); % datu masîvs rezultâtu saglabâðanai
k = 1;

for iter = 1:itermax
    k = k+1;
    for i = 1:n
      res_sum = 0;
      for j = 1:n
         if j~=i
           res_sum =res_sum+x_app(j,k-1)*A(i,j);
         end
      end
      x_app(i,k) =(B(i,1)-res_sum)/A(i,i);
    end
    errnorm  =norm(x_app(:,k)-x_app(:,k-1));
    prnorm(iter,:) =[iter,errnorm];
end
%disp('Iter.numurs Kļūda')
%disp(prnorm) % Ctrl+Enter

% turpinâjums
x_approx = x_app(:,k);

% turpinâjums 
[row,col] = size(prnorm);
disp(' Atbilde:')
fprintf(' x1 (7 iterācijā): %.4f\n', x_approx(1))

%% 4. Uzdevums

clc, clearvars, format compact
A = [9.1, 4.5, -3, -1.2; -4, 8.3, 2, 1.5; 3, -2, 10, -4.4; 4.3, -1.2, -1, 6.9];  
B = [-4.2; -3.3; 2; 6];
if det(A) == 0
    disp('Matrica A ir singulârâ ')
    disp(' Atbilde:  Jakobi metodi nedrîkst izmantot'), return
end
disp('Matrica A ir nesingulârâ')
fun_prob3(A)         % pārbaude: Jakobi metode konverģē

n = length(B);
x_app = zeros(4,1);  % sâkuma tuvinâjums 
iter = 0;            % iterâciju skaits
itermax = 10;        % maksimālais iterāciju skaits
prnorm = zeros(1,2); % datu masîvs rezultâtu saglabâðanai
k = 1;

for iter = 1:itermax
    k = k+1;
    for i = 1:n
      res_sum = 0;
      for j = 1:n
         if j~=i
           res_sum =res_sum+x_app(j,k-1)*A(i,j);
         end
      end
      x_app(i,k) =(B(i,1)-res_sum)/A(i,i);
    end
    errnorm  =norm(x_app(:,k)-x_app(:,k-1));
    prnorm(iter,:) =[iter,errnorm];
end
%disp('Iter.numurs Kļūda')
%disp(prnorm) % Ctrl+Enter

% turpinâjums
x_approx = x_app(:,k);
x_sol = linsolve(A,B) % Ctrl+Enter

% turpinâjums 
[row,col] = size(prnorm);
disp('Atbilde:')
norm_val = norm(x_sol - x_approx, 2);
fprintf('noorma = %.4f\n', norm_val)

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