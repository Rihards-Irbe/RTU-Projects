clc, clearvars, format compact, close all, format longG

f = 0.3*e^(x) + 0.2*x^2 - 4*x - 8;

% <FEATURE:plot>

syms x
fun    = 0.3*exp(x) + 0.2*x^2 - 4*x - 8;
fun_pr = diff(fun, x);

iter = 8;
epsi = 0.0001;

x_app   = [-1.8 4.3];
n_roots = 2;

xapp_val = zeros(1, n_roots);

for j = 1:n_roots
    xn = x_app(j);
    for i = 1:iter
        f_val   = double(subs(fun, x, xn));
        f_prime = double(subs(fun_pr, x, xn));
        xn = xn - f_val / f_prime;

        if abs(double(subs(fun, x, xn))) < epsi
            break
        end
    end
    xapp_val(j) = xn;
end

xapp_val = sort(xapp_val);

% <FEATURE:after_sort>

p = round(-log10(epsi));

fprintf('Atbilde. Ņūtona metode: vienādojumam ir %d saknes\n', n_roots)

fprintf(' ')
for k = 1:n_roots
    if k == 1
        fprintf('x%d = %.4f', k, xapp_val(k));
    else
        fprintf(', x%d = %.4f', k, xapp_val(k));
    end
end
fprintf('\n')
fprintf(' ar precizitāti 10^(-%d)\n', p)
