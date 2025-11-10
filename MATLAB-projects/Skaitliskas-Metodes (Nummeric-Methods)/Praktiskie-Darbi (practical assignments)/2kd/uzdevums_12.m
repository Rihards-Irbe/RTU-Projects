clc, clearvars, close all, format short g

xpoints = [3.3 3.8 4.5 5.4 6.1 6.8 7.5 8.2]';
ypoints = [3.42 3.37 2.59 1.88 1.63 2.30 3.90 5.70]';

figure
plot(xpoints, ypoints, 'or', 'LineWidth', 3)
grid on, title('Datu punkti')

f1 = fittype('a + b*sin(x) + c*cos(x)', 'independent','x','dependent','y');
f2 = fittype('a + b*sin(x) + c*cos(x) + d*sin(2*x)', 'independent','x','dependent','y');

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
