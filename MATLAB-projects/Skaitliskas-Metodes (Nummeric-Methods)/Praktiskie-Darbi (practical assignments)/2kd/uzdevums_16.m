clc, clearvars, close all, format short

f = @(x) (x.^3 + log(x.^2 + 2)) ./ (x.^3 + sqrt(5*x + 7) + 6);

xpoints = (0.2:0.3:2.9)'; % [0.2;2.9] intervāls ar soli 0.3
ypoints = f(xpoints);

disp(table(round(xpoints,4), round(ypoints,4), 'VariableNames', {'xpoints','ypoints'}))

figure
plot(xpoints, ypoints, 'ob', 'MarkerFaceColor','b', 'LineWidth',1.5)
grid on
title('Datu punkti')

ft = fittype('a + b*x + c*cos(x) + d*sin(2*x)', 'independent','x','dependent','y');

[p, reg] = fit(xpoints, ypoints, ft)

xx   = linspace(min(xpoints), max(xpoints), 1000)';
yfit = feval(p, xx);

figure
plot(xpoints, ypoints, 'ob', 'MarkerFaceColor','b', 'LineWidth',1.5), hold on
plot(xx, yfit, 'k', 'LineWidth', 2.5)
grid on, hold off
title('Aproksimācija ar funkciju y = a+b*x+c*cosx+dsin2x')
legend('data','fitted curve','Location','best')

x0     = 2.22;
yhat   = feval(p, x0);
f_res  = f(x0);
apr_error = abs(yhat - f_res) % y(x) un f(x) punktā x_0 <- jeb interpolācijas kļūdas formulas izpilde

fprintf('\nAtbilde:\n');
fprintf(' Aproksimācijas kļūda punktā (2.22) = %.4f\n', apr_error);
