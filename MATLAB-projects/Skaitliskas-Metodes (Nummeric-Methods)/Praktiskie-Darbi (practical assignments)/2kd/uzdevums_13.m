clc, clearvars, close all, format short g

xpoints = [1.0 2.8 4.2 5.6 7.1 8.5 10.2 11.7]';
ypoints = [-0.85 2.9 3.5 1.78 3.07 7.08 8.52 6.95]';

figure
plot(xpoints, ypoints, 'or', 'LineWidth', 3)
grid on, title('Datu punkti')

f1 = fittype('a*x.*log(x) + b*x.*sin(x) + c*x.*cos(x)','independent','x','dependent','y');

f2 = fittype('a*x + b*x.*log(x) + c*x.*sin(x) + d*x.*cos(x)', 'independent','x','dependent','y');

[p1, reg1] = fit(xpoints, ypoints, f1)
[p2, reg2] = fit(xpoints, ypoints, f2)

xx = linspace(min(xpoints), max(xpoints), 1000)';
y1 = feval(p1, xx);
y2 = feval(p2, xx);

figure
plot(xpoints, ypoints, 'or', xx, y1, 'k', 'LineWidth', 3)
legend('data', 'fitted curve'), grid on
title('Aproksimācija ar trigonometrisko funkciju y=a+b*sinx+c*cosx')

figure
plot(xpoints, ypoints, 'or', xx, y2, 'k', 'LineWidth', 3)
legend('data', 'fitted curve'), grid on
title('Aproksimācija ar trigonometrisko funkciju y = a+b*sinx+c*cosx+d*sin2x')

fprintf('\nAtbilde:\n')

adj  = [reg1.adjrsquare, reg2.adjrsquare];
rmse = [reg1.rmse,       reg2.rmse];

[~, order] = sortrows([-adj(:), rmse(:)]);
best_n = order(1);

fprintf('\n Vislabākā aproksimācija ir %d. funkcijai ',best_n)
