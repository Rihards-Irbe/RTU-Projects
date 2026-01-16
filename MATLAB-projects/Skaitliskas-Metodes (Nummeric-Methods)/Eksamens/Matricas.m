%% Dota vienādojuma sistēma Ax = B (Aug), kur A = <matrica> un B = <matrica> Apzīmēsim ar C sistēmas paplašināto matricu pēc Matlab komandas rref izpildes. Atrast elementu c_14. Atbildi dod ar cētriem cipariem aiz komata

clc, clearvars, format long

A = [ 2  -1   3   5   7;
      6   4   1  -2   3;
      3  -2   4   1   0 ];

B = [ -2;
       3;
       5 ];

Aug = [A B];

C = rref(Aug);

c_14 = C(1,4); % c_14 elements

fprintf('c_14 = %.4f\n', c_14)

%% Dota sistēma AX = B, kur A = <matrix>, B = <matrix> un X = <matrix>. Pielietot minimālās nesaistes metodi x^(n+1) = x^n + t_n+1(B - Ax^n), n = 0,1,...
%  un izpildīt 17 iterācijas, izmantojot sākuma tuvinājumu X^0 = (1 -1 0) ^ T. Aprēķināt T_17. Atbildi dot ar četriem cipariem aiz komata.

clc, clearvars, format compact
A = [
    7, 8, 10;
    8, 49 , 12;
    10, 12, 56;
    ];

B = [0;-3;7];

if det(A) == 0
 disp('Matrica A ir singulāra')
 disp('Atbilde: minimālo nesaistes metodi nedrīkst izmantot')
 return
end
disp('Matrica A ir nesingulāra')

ni = fun_prob10(A); % pārbaude, vai matrica ir pozitīvi definēta
if ni == 2
 disp('Koeficientu matrica nav pozitīvi definēta')
 disp('Atbilde: minimālo nesaistes metodi nedrīkst izmantot')
 return
end
check=isequal(A,A');
if check==0
 disp('Koeficientu matrica nav simetriska')
 disp('Atbilde: minimālo nesaistes metodi nedrīkst izmantot')
 return
end
disp('Koeficientu matrica ir simetriska un pozitīvi definēta ')

% 2.10. piemēra turpinājums
n = length(B);
k_iter = 0;
epsi = 10^(-4);
itermax =17;
%x_app=zeros(n,1);
x_app = [1;-1;0] %nosacījums
r = A*x_app-B; norm_r = norm(r);
while norm_r > epsi && k_iter < itermax
 k_iter =k_iter+1;
 tau = ((A*r)'*r)/norm(A*r)^2;
 x_app = x_app-(tau*r')';r = A*x_app-B; norm_r = norm(r);
end
k_iter,tau, x_app, norm_r
x_sol = linsolve(A,B)

disp('Atbilde:')
fprintf(' tau = %.4f\n', tau)

%% ārēja funkcija(2.10. piemērs.) Minimālās nesaistes metode
% pārbaude: vai matrica ir pozitīvi definēta
function ni = fun_prob10(A_mat)
 ni = 1;
 [row,col] = size(A_mat);
 for i = 1:row
 if det(A_mat(1:i,1:i))>0
 else ni = 2; break
 end
 end
end

%% Dota sistēma AX=B, kur A = <matrica>, B = <matrica> un X = <matrica>. Pielietot Jakobi metodi un izpildīt 13 iterācijas,
%  izmantojot sākuma tuvinājumu X^0 = (1 1 -2 1)^T. Aprēķināt nezināmo x_2 13. iterācijā. Atbildi dod ar četriem cipariem aiz komata.

clc, clearvars, format compact
format longG

A = [
    8, 3, -5, 1;
    4, 6, -3, 1;
    3, 2, 5, -6;
    2, 1, -4, 7
    ];

B = [3;1;5;9];
if det(A) == 0
 disp('Matrica A ir singulāra')
 disp('Atbilde: Jakobi metodi nedrīkst izmantot'), return
end

fun_prob3(A)

n = length(B);
x_app = [1;1;-2;1] %nosacījums

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

x2_13 = x_app(2,14);
fprintf('Atbilde: x2 13. iterācijā = %.4f\n', x2_13);

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

%% Dota sistēma AX=B, kur A = <matrica>, B = <matrica> un X = <matrica>. Izpildīt 11 iterācijas ar vienkāršo iterāciju metodi, izmantojot sākuma tuvinājumu X^0 = (0 0 0 0)^T. Aprēķinos izmantot optimālo parametra T vērtību.
% Atrisināt šo sistēmu arī ar komandu linsolve (ar komandu linsolve iegūto
% rezultātu apzīmēšim ar Xs). Cik liela norma ||X_s - X^11||_2? Atbildi dod ar četriem cipariem aiz komata.

clc, clearvars, format compact
format longG

A =[
    7, 1, 3, 8;
    1, 9, 14, 2;
    3, 14, 81, 4;
    8, 2, 4, 27
];

B = [7;-2;6;8];

% --- checks (keep yours) ---
if det(A) == 0
    disp('Matrica A ir singulāra')
    disp('Atbilde: vienkāršo iterāciju metodi nedrīkst izmantot')
    return
end
disp('Matrica A ir nesingulāra')

ni = fun_prob5(A);
if ni == 2
    disp('Koeficientu matrica nav pozitīvi definēta')
    disp('Atbilde: vienkāršo iterāciju metodi nedrīkst izmantot')
    return
end
if ~isequal(A,A')
    disp('Koeficientu matrica nav simetriska')
    disp('Atbilde: vienkāršo iterāciju metodi nedrīkst izmantot')
    return
end
disp('Koeficientu matrica ir simetriska un pozitīvi definēta')

% --- REQUIRED: tau_opt ---
lam = eig(A);
tau = 2/(min(lam) + max(lam));

n = length(B);
itermax = 11;

% store x^(0)...x^(11) in columns 1..12
x_app = zeros(n, itermax+1);   % x^(0)=0 is already column 1

for k = 1:itermax
    resid = B - A*x_app(:,k);                 % r^(k-1)
    x_app(:,k+1) = x_app(:,k) + tau*resid;    % x^(k)
end

Xs = linsolve(A,B);
resid_norm = norm(Xs - x_app(:,12), 2);

disp('Atbilde:')
fprintf('tau_opt = %.10f\n', tau);
fprintf('||Xs - X^(11)||_2 = %.4f\n', resid_norm);

% --- external function unchanged ---
function ni = fun_prob5(A_mat)
    ni = 1;
    [row,~] = size(A_mat);
    for i = 1:row
        if det(A_mat(1:i,1:i)) <= 0
            ni = 2; break
        end
    end
end
