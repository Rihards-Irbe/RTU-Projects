%% 1. Uzdevums

clc, clearvars, format compact
% Uzdevuma dati
A = [7.2, 1, 3.3, 8;
     1, 9, 13, 2;
     3.3, 13, 84, 4.4;
     8, 2, 4.4, 30];
B = [-2.5; 3.3; -7.7; 8.6];

if det(A) == 0 % pārbaude vai matrica ir nesingulāra
    disp('Matrica A ir singulārā ')
    disp(' Atbilde: vienkāršo iterāciju metodi nedrīkst izmantot')
    return
end
disp('Matrica A ir nesingulārā ')

ni = fun_prob5(A); % pārbaude vai matrica ir pozitīvā definīta
if ni == 2
    disp('Koeficientu matrica nav pozitīvi definīta')
    disp(' Atbilde: vienkāršo iterāciju metodi nedrīkst izmantot')
    return
end

check = isequal(A, A'); % pārbaude vai matrica ir simetriskā
if check == 0
    disp('Koeficientu matrica nav simetriskā')
    disp(' Atbilde: vienkāršo iterāciju metodi nedrīkst izmantot')
    return
end
disp('Koeficientu matrica ir simetriskā un pozitīvi definīta ')

% Vienkāršo iterāciju metode
% Jāaprēķina optimālais tau vērtība (nevis fiksēta vērtība)
lambda_min = min(eig(A));
lambda_max = max(eig(A));
tau_optimal = 2 / (lambda_min + lambda_max);

epsi = 10^(-3); % aprēķinu precizitāte
itermax = 19; % max iterāciju skaits (pēc uzdevuma)
x_app = zeros(4, 1); % sākuma tuvinājums X^(0) = (0, 0, 0, 0)^T
k_iter = 0; 
resid = B - A * x_app;

% Saglabā vēsturi, lai aprēķinātu normu pēc 19 iterācijām
while norm(resid) > epsi && k_iter < itermax
    x_app = x_app + tau_optimal * resid;
    resid = B - A * x_app; 
    k_iter = k_iter + 1;
end

% Precīzais risinājums ar linsolve
x_sol = linsolve(A, B);

% Aprēķina normu ||X_S - X^(19)||_2
norma_starpiba = norm(x_sol - x_app, 2);

% Rezultāti
disp('Atbilde:')
fprintf('||X_S - X^(19)||_2 = %.4f\n', norma_starpiba)

%% 2. Uzdevums

%% Minimālās nesaistes metode
clc, clearvars, format compact

% Uzdevuma dati
A = [4.8, 3.3, 5;
     3.3, 16.8, 5.5;
     5, 5.5, 12.8];
B = [5.4; -6.3; 54];

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
itermax = 19; % pēc uzdevuma - 19 iterācijas
x_app = [-1; -1; -2]; % sākuma tuvinājums X^(0) = (-1, -1, -2)^T
r = A * x_app - B; 
norm_r = norm(r);

while norm_r > epsi && k_iter < itermax
    k_iter = k_iter + 1;
    tau = ((A * r)' * r) / norm(A * r)^2;
    x_app = x_app - (tau * r')';
    r = A * x_app - B;
    norm_r = norm(r); % nesaistes norma iterācijā ar numuru n
end

% Precīzais risinājums ar linsolve
x_sol = linsolve(A, B);

% Aprēķina normu ||X_S - X^(19)||_2
norma_starpiba = norm(x_sol - x_app, 2);

% Rezultāti
disp('Atbilde:')
fprintf('||X_S - X^(19)||_2 = %.4f\n', norma_starpiba)

%% 3. Uzdevums

%% Minimālās nesaistes metode
clc, clearvars, format compact

% Uzdevuma dati
A = [8.5, 9.3, 12;
     9.3, 64, 10.7;
     12, 10.7, 73];
B = [9.6; 7.6; 3.6];

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
itermax = 25; % pēc uzdevuma - 25 iterācijas
x_app = [0; -1; 0]; % sākuma tuvinājums X^(0) = (0, -1, 0)^T
r = A * x_app - B; 
norm_r = norm(r);

while norm_r > epsi && k_iter < itermax
    k_iter = k_iter + 1;
    tau = ((A * r)' * r) / norm(A * r)^2;
    x_app = x_app - (tau * r')';
    r = A * x_app - B;
    norm_r = norm(r); % nesaistes norma iterācijā ar numuru n
end

% Precīzais risinājums ar linsolve
x_sol = linsolve(A, B);

% x₂ vērtība pēc 25 iterācijām
x2_25 = x_app(2);

% Rezultāti
disp('Atbilde:')
fprintf('Iterāciju skaits = %d, nesaistes norma = %.8f\n', k_iter, norm_r)
fprintf('x_tuvinājumi : { %.4f, %.4f, %.4f }\n', x_app(:))
fprintf('\nx₂ pēc 25 iterācijām = %.4f\n', x2_25)

%% 4. Uzdevums

clc;
clearvars;
format compact;

% Uzdevuma dati
A = [28, 2.5, 6.5, 10.1;
     2.5, 13, 16, 4;
     6.5, 16, 144, 6;
     10.1, 4, 6, 36];
B = [3; -12; 3; -4.8];

% Pārbaude vai matrica ir nesingulāra
if det(A) == 0
    disp('Matrica A ir singulāra');
    disp('Atbilde: vienkāršo iterāciju metodi nedrīkst izmantot');
    return;
end
disp('Matrica A ir nesingulāra');

% Pārbaude vai matrica ir pozitīvi definīta
ni = fun_prob5(A); % <- ensure this function exists
if ni == 2
    disp('Koeficientu matrica nav pozitīvi definīta');
    disp('Atbilde: vienkāršo iterāciju metodi nedrīkst izmantot');
    return;
end

% Pārbaude vai matrica ir simetriska
check = isequal(A, A');
if check == 0
    disp('Koeficientu matrica nav simetriska');
    disp('Atbilde: vienkāršo iterāciju metodi nedrīkst izmantot');
    return;
end
disp('Koeficientu matrica ir simetriska un pozitīvi definīta');

% Aprēķinām īpašvērtības
lambda = eig(A);
lambda_max = max(lambda);

% Augšējā robeža parametram tau
tau_upper = 2 / lambda_max;

% Rezultāts
disp('Atbilde:');
fprintf('Iterāciju parametram τ jābūt mazākam par %.4f, lai metode konverģētu.\n', tau_upper);

%% 5. Uzdevums

%% Vienkāršo iterāciju metode
clc, clearvars, format compact

% Uzdevuma dati
A = [6, 3, 11, 7;
     3, 12, 5, 11;
     11, 5, 98, 15;
     7, 11, 15, 21];
B = [-2.5; 4.2; -5.3; 8.6];

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

% Vienkāršo iterāciju metode
tau = 0.017; % dotais parametrs
epsi = 10^(-3);
itermax = 13; % izpildīt tieši 13 iterācijas
x_app = zeros(4, 1); % sākuma tuvinājums X^(0) = (0, 0, 0, 0)^T
k_iter = 0;
resid = B - A * x_app;

% Izpilda tieši 13 iterācijas
while k_iter < itermax
    x_app = x_app + tau * resid;
    resid = B - A * x_app;
    k_iter = k_iter + 1;
end

% Tuvinātā atrisinājuma norma pēc 13. iterācijas
norma_X13 = norm(x_app, 2);

% Rezultāti
disp('Atbilde:')
fprintf('\n||X^(13)||_2 = %.4f\n', norma_X13)

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