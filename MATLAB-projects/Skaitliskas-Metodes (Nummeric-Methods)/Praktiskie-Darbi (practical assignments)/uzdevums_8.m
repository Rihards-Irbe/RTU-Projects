%% Atrisināt lineāru vienādojumu sistēmu, izmantojot Jakobi metodi, ja n = 30
clc, clearvars, format compact
n = 30;
A = zeros(n,n); B = ones(n,1);
for i = 1:(n - 1)
    A(i,i) = -3; A(i,i+1) = 1; A(i+1,i) = 1;
end
A(n,n) = -3;

if det(A) == 0
    disp('Matrica A ir singulāra')
    disp('Atbilde: Jakobi metodi nedrīkst izmantot'), return
end

fprintf('Matrica A ir nesingulāra.\n');
fun_prob3(A)

x_app = zeros(n, 1);
itermax = 7; %s
k = 1;
prnorm = zeros(itermax, 2);

for iter = 1:itermax
    k = k + 1;
    for i = 1:n
        res_sum = 0;
        for j = 1:n
            if j ~= i
                res_sum = res_sum + x_app(j, k-1) * A(i, j);
            end
        end
        x_app(i, k) = (B(i, 1) - res_sum) / A(i, i);
    end
    errnorm = norm(x_app(:, k) - x_app(:, k-1), 2);
    prnorm(iter, :) = [iter, errnorm];
end

fprintf('Iterācijas  Kļūda\n');
for i = 1:size(prnorm, 1)
    fprintf('%7.4f %7.4f\n', prnorm(i, 1), prnorm(i, 2));
end
fprintf('\n');

x_approx = x_app(:,k);
x_sol = linsolve(A,B); %vnk ar linsolve izpildīju, kā bija norādīts

epsi5_norm = norm(x_app(:, 6) - x_app(:, 5), 2); % ||e^5_2|| = x^5 - x^4 => norm(x_app(:, (n_1 + 1)) - x_app(:, (n_2 + 1)), E_n)
X_app6_norm = norm(x_app(:, 7), 2); % ||x^iterācijā||_n 6. iterācijā => norm(x_app(:, iterācijā+1), n),
sol_X4_norm = norm(x_sol - x_app(:, 5), 2); % ||x_sol - x^iterācija||_n => norm(x_sol - x_app(:, iterācija+1), n)

fprintf("epsi5_norm = \n");
fprintf('  %8.4f\n', epsi5_norm)

fprintf("X_app6_norm = \n");
fprintf('  %8.4f\n', X_app6_norm)

fprintf("sol_X4_norm = \n");
fprintf('  %8.4f\n', sol_X4_norm)

fprintf('x_approx = \n');
for i = 1:size(x_approx, 1)
    fprintf('%7.4f\n', x_approx(i, 1));
end
fprintf('\n');

fprintf('x_sol = \n');
for i = 1:size(x_sol, 1)
    fprintf('%7.4f\n', x_sol(i, 1));
end
fprintf('\n');

fprintf('Atbilde:\n');
fprintf(' iterāciju skaits = 5 --> kļūda = %.5f\n', prnorm(5, 2));
fprintf(' X_app6_norm = %.3f\n', X_app6_norm);
fprintf(' sol_X4_norm = %.5f\n', sol_X4_norm);

fprintf(' x_tuvinājumi:\n');
for i = 1:length(x_approx)
    fprintf('  %.5f', x_approx(i));
    if mod(i, 5) == 0
        fprintf('\n')
    end
end

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