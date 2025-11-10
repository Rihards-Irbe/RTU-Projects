clc, clearvars, close all, format short

xnodes = [-1.000  -0.960  -0.860  -0.790   0.220   0.500   0.930];
ynodes = [-1.000  -0.151   0.894   0.986   0.895   0.500  -0.306];

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

x_pr = linspace(xnodes(1), xnodes(end), 2001);
figure
plot(x_pr, double(polyn(x_pr)),'r-','LineWidth',2), hold on
plot(xnodes, ynodes,'ob','MarkerFaceColor','b')
hold off, grid on
title('Ņūtona interpolācijas polinoms')
legend('polinoms','doti punkti','Location','best')

spl_vals = interp1(xnodes, ynodes, x_pr, 'spline');
figure
plot(x_pr, spl_vals,'k--','LineWidth',2), hold on
plot(xnodes, ynodes,'ob','MarkerFaceColor','b')
hold off, grid on
title('Splaina interpolācija')
legend('splains','doti punkti','Location','best')

figure
plot(x_pr, double(polyn(x_pr)),'r-','LineWidth',2), hold on
plot(x_pr, spl_vals,'k--','LineWidth',2)
plot(xnodes, ynodes,'ob','MarkerFaceColor','b')
hold off, grid on
title('Ņūtona interpolācijas polinoms un splains')
legend('polinoms','splains','doti punkti','Location','best')


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
