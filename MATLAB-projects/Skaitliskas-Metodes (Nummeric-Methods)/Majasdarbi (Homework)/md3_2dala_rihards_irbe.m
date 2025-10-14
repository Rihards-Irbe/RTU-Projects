%% 1. Uzdevums
clc, clearvars, format compact

% Uzdevuma dati
A = [22, 1, 6.3, 3;
     1, 5, 4, 4;
     6.3, 4, 30, 6;
     3, 4, 6, 15];
B = [-1; 9; -15; 7];

% Pārbaude vai matrica ir nesingulāra
if det(A) == 0
    disp('Matrica A ir singulārā ')
    disp(' Atbilde: vienkāršo iterāciju metodi nedrīkst izmantot')
    return
end
disp('Matrica A ir nesingulārā ')

% Pārbaude vai matrica ir pozitīvā definīta
ni = fun_prob5(A);
if ni == 2
    disp('Koeficientu matrica nav pozitīvi definīta')
    disp(' Atbilde: vienkāršo iterāciju metodi nedrīkst izmantot')
    return
end

% Pārbaude vai matrica ir simetriskā
check = isequal(A, A');
if check == 0
    disp('Koeficientu matrica nav simetriskā')
    disp(' Atbilde: vienkāršo iterāciju metodi nedrīkst izmantot')
    return
end
disp('Koeficientu matrica ir simetriskā un pozitīvi definīta ')

lambda = eig(A);
lambda_min = min(lambda);
lambda_max = max(lambda);

% Optimālais parametrs tau (lai metode konverģētu visātrāk)
tau_opt = 2 / (lambda_min + lambda_max);

% Rezultāts
disp('Atbilde:');
fprintf('Iterāciju parametram τ jābūt %.4f, lai metode konverģētu visātrāk.\n', tau_opt);

%% 2. Uzdevums

%% Minimālās nesaistes metode
clc, clearvars, format compact

% Uzdevuma dati
A = [5.3, 6.4, 8;
     6.4, 25.3, 4.6;
     8, 4.6, 31];
B = [-1.5; -2.6; -3.7];

% Pārbaude vai matrica ir nesingulāra
if det(A) == 0
    disp('Matrica A ir singulārā ')
    disp(' Atbilde: minimālās nesaistes metodi nedrīkst izmantot')
    return
end
disp('Matrica A ir nesingulārā ')

% Pārbaude vai matrica ir pozitīvā definīta
ni = fun_prob5(A);
if ni == 2
    disp('Koeficientu matrica nav pozitīvi definīta')
    disp(' Atbilde: minimālās nesaistes metodi nedrīkst izmantot')
    return
end

% Pārbaude vai matrica ir simetriskā
check = isequal(A, A');
if check == 0
    disp('Koeficientu matrica nav simetriskā')
    disp(' Atbilde: minimālās nesaistes metodi nedrīkst izmantot')
    return
end
disp('Koeficientu matrica ir simetriskā un pozitīvi definīta ')

% Minimālās nesaistes metode
k_iter = 0; 
epsi = 10^(-3); 
itermax = 37; % izpildīt 37 iterācijas
x_app = [1; 1; 0]; % sākuma tuvinājums X^(0) = (1, 1, 0)^T
r = A * x_app - B; 
norm_r = norm(r);

% Saglabā tau vērtības
tau_values = zeros(itermax, 1);

while k_iter < itermax
    k_iter = k_iter + 1;
    tau = ((A * r)' * r) / norm(A * r)^2;
    tau_values(k_iter) = tau; % saglabā tau vērtību
    x_app = x_app - (tau * r')';
    r = A * x_app - B;
    norm_r = norm(r); % nesaistes norma iterācijā ar numuru n
end

% Precīzais risinājums ar linsolve
x_sol = linsolve(A, B);

% τ₃₇ vērtība
tau_37 = tau_values(37);

% Rezultāti
disp('Atbilde:')
fprintf('\nτ₃₇ = %.4f\n', tau_37)

%% 3. Uzdevums

%% Minimālās nesaistes metode
clc, clearvars, format compact

% Uzdevuma dati
A = [5.6, 4.5, 6;
     4.5, 16.8, 2.7;
     6, 2.7, 17];
B = [-2.3; -23; -3.4];

% Pārbaude vai matrica ir nesingulāra
if det(A) == 0
    disp('Matrica A ir singulārā ')
    disp(' Atbilde: minimālās nesaistes metodi nedrīkst izmantot')
    return
end
disp('Matrica A ir nesingulārā ')

% Pārbaude vai matrica ir pozitīvā definīta
ni = fun_prob5(A);
if ni == 2
    disp('Koeficientu matrica nav pozitīvi definīta')
    disp(' Atbilde: minimālās nesaistes metodi nedrīkst izmantot')
    return
end

% Pārbaude vai matrica ir simetriskā
check = isequal(A, A');
if check == 0
    disp('Koeficientu matrica nav simetriskā')
    disp(' Atbilde: minimālās nesaistes metodi nedrīkst izmantot')
    return
end
disp('Koeficientu matrica ir simetriskā un pozitīvi definīta ')

% Minimālās nesaistes metode
k_iter = 0; 
epsi = 10^(-3); 
itermax = 22; % izpildīt 22 iterācijas
x_app = [2; 0; 2]; % sākuma tuvinājums X^(0) = (2, 0, 2)^T
r = A * x_app - B; 
norm_r = norm(r);

while k_iter < itermax
    k_iter = k_iter + 1;
    tau = ((A * r)' * r) / norm(A * r)^2;
    x_app = x_app - (tau * r')';
    r = A * x_app - B;
    norm_r = norm(r); % nesaistes norma iterācijā ar numuru n
end

% Precīzais risinājums ar linsolve
x_sol = linsolve(A, B);

% Aprēķina ||X^(22)||_2 - ||X_S||_2
norma_X22 = norm(x_app, 2);
norma_XS = norm(x_sol, 2);
starpiba = norma_X22 - norma_XS;

% Rezultāti
disp('Atbilde:')
fprintf('||X^(22)||_2 - ||X_S||_2 = %.4f\n', starpiba)

%% 4. Uzdevums

clc, clearvars, format compact
A = [8, 5, 12.2, 6.4; 5, 10, 6, 9.8; 12.2, 6, 118, 15; 6.4, 9.8, 15, 19];
B = [5.3; -6.2; 7.3; -4.6];
if det(A) == 0        % pârbaude vai matrica ir nesingulâra
    disp('Matrica A ir singulârâ ')
    disp(' Atbilde:  vienkârðo iterâciju metodi nedrîkst izmantot')
    return
end
disp('Matrica A ir nesingulârâ ')

ni = fun_prob5(A);     % pârbaude vai matrica ir pozitivâ definçta
if ni == 2 
    disp('Koeficientu matrica nav pozitîvi definçta') 
    disp(' Atbilde:  vienkârðo iterâciju metodi nedrîkst izmantot')
    return
end
check = isequal(A,A');  % pârbaude vai matrica ir simetriskâ
if check==0 
    disp('Koeficientu matrica nav simetriskâ')
    disp(' Atbilde:  vienkârðo iterâciju metodi nedrîkst izmantot')
    return
end
disp('Koeficientu matrica ir simetriskâ un pozitîvi definçta ')

% turpinâjums  
tau=0.014; 
x_app = zeros(4,1); % sâkuma tuvinâjums
resid = B - A * x_app;
for k_iter = 1:25
    x_app = x_app + tau * resid;
    resid = B - A * x_app;
end
norm_resid = norm(resid, 2);
k_iter, x_app, norm_resid, x_sol = linsolve(A, B);   % Ctrl+Enter

% turpinâjums
disp('Atbilde:')
disp([' nesaisistes norma = ' num2str(norm_resid, '%.4f') ])

%% 5. Uzdevums

clc, clearvars, format compact
A = [9.1, 2, 3.4, 8; 2, 9, 14.2, 2.3; 3.4, 14.2, 93, 4; 8, 2.3, 4, 27];
B = [-3.3; -4.3; -5.3; -6.3];
if det(A) == 0        % pârbaude vai matrica ir nesingulâra
    disp('Matrica A ir singulârâ ')
    disp(' Atbilde:  vienkârðo iterâciju metodi nedrîkst izmantot')
    return
end
disp('Matrica A ir nesingulârâ ')

ni = fun_prob5(A);     % pârbaude vai matrica ir pozitivâ definçta
if ni == 2 
    disp('Koeficientu matrica nav pozitîvi definçta') 
    disp(' Atbilde:  vienkârðo iterâciju metodi nedrîkst izmantot')
    return
end
check = isequal(A,A');  % pârbaude vai matrica ir simetriskâ
if check==0 
    disp('Koeficientu matrica nav simetriskâ')
    disp(' Atbilde:  vienkârðo iterâciju metodi nedrîkst izmantot')
    return
end
disp('Koeficientu matrica ir simetriskâ un pozitîvi definçta ')

% turpinâjums  
[V, D] = eig(A);
lambda = diag(D);
lambda_min = min(lambda);
lambda_max = max(lambda);
tau = 2 / (lambda_min + lambda_max);
x_app = zeros(4,1); % sâkuma tuvinâjums
resid = B - A * x_app;
for k_iter = 1:24
    x_app = x_app + tau * resid;
    resid = B - A * x_app;
end
x_sol = linsolve(A, B);
norm_error = norm(x_app - x_sol, 2);
norm_sol = norm(x_sol, 2);

% turpinâjums
disp('Atbilde:')
disp([' ||X^(24) - X_s||_2 = ' num2str(norm_error, '%.4f') ])
%% Ārējās funkcijas

function ni = fun_prob5(A_mat)
 ni = 1;
 [row,col] = size(A_mat);
 for i = 1:row
 if det(A_mat(1:i,1:i))>0
 else ni = 2; break
 end
 end
end