%% Atrisināt lineāru vienādojumu sistēmu, izmantojot vienkāršās iterācijas metodi.

clc, clearvars, format compact
format longG

A = [
    16, 3, 4, 2;
    3, 12, 2, -1;
    4, 2, 8, -1;
    2, -1, -1, 2
    ];

B = [25; 16; 13; 2];
if det(A) == 0
    disp('Matrica A ir singulāra')
    disp('Atbilde: vienkāršo iterāciju metodi nedrīkst izmantot')
    return
end
disp('Matrica A ir nesingulāra')

% Pārbaude: vai matrica ir simetriska un pozitīvi definēta
ni = fun_prob10(A); % pārbaude, vai matrica ir pozitīvi definēta
if ni == 2
    disp('Koeficientu matrica nav pozitīvi definēta')
    disp('Atbilde: vienkāršo iterāciju metodi nedrīkst izmantot')
    return
end
check = isequal(A, A');
if check == 0
    disp('Koeficientu matrica nav simetriska')
    disp('Atbilde: vienkāršo iterāciju metodi nedrīkst izmantot')
    return
end
disp('Koeficientu matrica ir simetriska un pozitīvi definēta')

% Vienkāršās iterācijas metode
n = length(B);
x_app = zeros(n, 16); % Matrica, lai saglabātu 0. iterāciju + 15 iterācijas
x_app(:, 1) = zeros(n, 1); % Sākuma tuvinājums: x^(0) = [0; 0; 0; 0]
tau = 0.02; % Fiksēts iterāciju parametrs
epsi = 0.001; % Precizitāte (nav kritiska, jo veicam 15 iterācijas)
itermax = 15; % Tieši 15 iterācijas
k_iter = 0;
resid = B - A * x_app(:, 1); % Sākotnējais atlikums

while k_iter < itermax
    k_iter = k_iter + 1;
    x_app(:, k_iter + 1) = x_app(:, k_iter) + tau * resid; % Jaunā iterācija
    resid = B - A * x_app(:, k_iter + 1); % Atjaunot atlikumu
end

% Aprēķināt normas
x_app15_norm = norm(x_app(:, 16), 2); % ||x^(15)||_2 15. iterācijā
resid15_norm = norm(B - A * x_app(:, 16), 2); % ||B - A x^(15)||_2 15. iterācijā

% Precīzs risinājums
x_sol = linsolve(A, B);

% Izvade
disp('Atbilde:')
fprintf('Iterāciju skaits = %d\n', k_iter)
fprintf('Atrisinājuma norma ||x^(15)||_2 15. iterācijā: %.8f\n', x_app15_norm)
fprintf('Nesaistes norma ||B - A x^(15)||_2 15. iterācijā: %.8f\n', resid15_norm)
fprintf('Precīzs risinājums: { %.4f, %.4f, %.4f, %.4f }\n', x_sol(:))
fprintf('Tuvinājums x^(15): { %.4f, %.4f, %.4f, %.4f }\n', x_app(:, 16))

% Konverģences pārbaude
diff_norm = norm(x_sol - x_app(:, 16));
if diff_norm < epsi
    fprintf('Metode konverģē ar ε = %.3f pēc %d iterācijām.\n', epsi, k_iter)
else
    fprintf('Metode nav pilnībā konverģējusi pēc %d iterācijām (atšķirība: %.8f).\n', k_iter, diff_norm)
end

% Eksperiments, lai noteiktu mazāko τ
tau_values = [0.01, 0.02, 0.03, 0.04, 0.05];
min_tau = 0;
for t = tau_values
    x_test = zeros(n, 1);
    resid_test = B - A * x_test;
    k = 0;
    while k < itermax && norm(resid_test) > epsi
        k = k + 1;
        x_test = x_test + t * resid_test;
        resid_test = B - A * x_test;
    end
    if norm(resid_test) < epsi
        min_tau = t;
        break;
    end
end
if min_tau > 0
    fprintf('Mazākais τ, ar kuru metode konverģē: %.2f\n', min_tau)
else
    fprintf('Nav atrasts τ ≤ 0.05, ar kuru metode konverģē 15 iterācijās.\n')
end

%% Ārējās funkcijas
% Pārbaude: vai matrica ir pozitīvi definēta
function ni = fun_prob10(A_mat)
    ni = 1;
    [row, col] = size(A_mat);
    for i = 1:row
        if det(A_mat(1:i, 1:i)) <= 0
            ni = 2;
            break
        end
    end
end

% Pārbaude: vai Jakobi metode konverģē (nav nepieciešama, bet saglabāta)
function fun_prob3(A_mat)
    [row, col] = size(A_mat);
    for i = 1:row
        sum = 0;
        for j = 1:col
            if i ~= j
                sum = sum + abs(A_mat(i, j));
            end
        end
        if abs(A_mat(i, i)) <= sum
            disp('Neizpildās konverģences pietiekamais nosacījums')
            fprintf('rindas numurs %.0f: --> %.0f < %.0f \n', i, A_mat(i, i), sum)
            return
        end
    end
    disp('Izpildās conve. pietiekamais nosacījums - Jakobi metode konverģē')
end