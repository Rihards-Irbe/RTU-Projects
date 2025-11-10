clc, clearvars, close all, format short


xnodes = [2.1  2.6  3.1  3.6  4.1  4.6  5.1  5.6];
ynodes = [2.15 3.35 3.87 4.15 3.74 3.30 2.71 2.33];

coef = ynodes;
m = numel(xnodes);
for k = 2:m
    coef(k:m) = (coef(k:m) - coef(k-1:m-1)) ./ ...
                (xnodes(k:m) - xnodes(1:m-k+1));
end

syms x
pol = coef(m);
for k = m-1:-1:1
    pol = pol*(x - xnodes(k)) + coef(k);
end
polyn(x) = collect(pol);
coefpol  = sym2poly(polyn)
fun_prob6(coefpol)

x_pr = linspace(xnodes(1), xnodes(end), 1000);
spl_vals = interp1(xnodes, ynodes, x_pr, 'spline');

figure
plot(x_pr, double(polyn(x_pr)), 'r-', 'LineWidth', 2), hold on
plot(x_pr, spl_vals, 'k--', 'LineWidth', 2)
plot(xnodes, ynodes, 'ob', 'MarkerFaceColor','b', 'LineWidth', 1.5)
hold off, grid on
title('3.4. uzdevums: polinoms un kubiskais splains')
legend('Ņūtona polinoms','kubiskais splains','doti punkti', ...
       'Location','best')

%% Ārējā funkcija polinoma drukāšanai
function fun_prob6(koef)
    m = length(koef);
    fprintf('\n Atbilde. Ņūtona interpolācijas polinoms: \n')
    n = m-1;
    for i = 1:m
        if koef(i) < 0
        fprintf(' %.4fx^%.0f',koef(i),n)
        else
            fprintf(' +')
            fprintf('%.4fx^%.0f',koef(i),n)
        end
       n = n-1;
    end
    fprintf('\n')
end
