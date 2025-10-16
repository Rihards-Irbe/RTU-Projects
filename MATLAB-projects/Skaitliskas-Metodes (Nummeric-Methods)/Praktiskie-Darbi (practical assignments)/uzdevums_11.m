clc, clearvars, format compact
A =[
    9, 2, 5;
    2, 18, 6;
    5, 6, 27
    ];

B =[1;6;2];
if det(A) == 0
 disp('Matrica A ir singulāra')
 disp('Atbilde: vienkāršo iterāciju metodi nedrīkst izmantot')
 return
end
disp('Matrica A ir nesingulāra')
ni = fun_prob5(A); % pārbaude, vai matrica ir pozitivi definēta
if ni == 2
 disp('Koeficientu matrica nav pozitīvi definēta')
 disp('Atbilde: vienkāršo iterāciju metodi nedrīkst izmantot')
 return
end
check=isequal(A,A');
if check==0
 disp('Koeficientu matrica nav simetriska')
 disp('Atbilde: vienkāršo iterāciju metodi nedrīkst izmantot')
 return
end
disp('Koeficientu matrica ir simetriska un pozitīvi definēta')

tau = 0.01;
epsi = 10^(-2);                     % aprēķinu precizitāte
itermax = 12;                       % max iterāciju skaits
n = length(B);
x_app = zeros(n, itermax + 1);      % Matrica, lai saglabātu visas iterācijas (0. iterācija + 12 iterācijas)
x_app(:, 1) = zeros(n, 1);          % Sākuma tuvinājums x^(0) = [0; 0; 0]

k_iter = 0;
resid = B - A * x_app(:, 1);

while norm(resid) > epsi && k_iter < itermax
 x_app = x_app + tau*resid;
 resid=B-A*x_app; k_iter = k_iter +1;
end
k_iter, x_app, x_sol=linsolve(A,B)

x_app12_norm = norm(x_app(:, 13), 2)
resid_norm = norm(B - A * x_app(:, 13), 2)

disp('Atbilde:')
disp(['iter. skaits = ' num2str(k_iter) ])
fprintf(' x_tuvinājumi: { %.4f, %.4f, %.4f }\n',x_app(:, 1))
fprintf(' x_app12_norm = %.4f\n', x_app12_norm);
fprintf(' resid_norm = %.4f\n', resid_norm);
%% ārējā funkcija(2.5. piemērs). Vienkāršā iterāciju metode
% pārbaude: vai matrica ir pozitīvi definēta
function ni = fun_prob5(A_mat)
 ni = 1;
 [row,col] = size(A_mat);
 for i = 1:row
 if det(A_mat(1:i,1:i))>0
 else ni = 2; break
 end
 end
end