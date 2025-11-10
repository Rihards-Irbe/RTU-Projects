clc, clearvars, close all, format short g

xpoints = [1 2 3 4 5 6 7 8 9 10]';
ypoints = [2.0 1.3 1.0 0.7 0.5 0.33 0.21 0.17 0.13 0.09]';

figure
plot(xpoints, ypoints, 'or', 'LineWidth', 3)
grid on, title('Datu punkti')

f1 = fittype('a + b/x + c/x^2');

[p1, reg1] = fit(xpoints, ypoints, f1)

xx = linspace(min(xpoints), max(xpoints), 1000)';
y1 = feval(p1, xx);

figure
plot(xpoints, ypoints, 'or', xx, y1, 'k', 'LineWidth', 3)
legend('data', 'fitted curve'), grid on
title('Aproksimācija ar trigonometrisko funkciju y=a + b/x + c/x^2')

fprintf('\nAtbilde:\n')

adj  = [reg1.adjrsquare];
rmse = [reg1.rmse];

[~, order] = sortrows([-adj(:), rmse(:)]);
best_n = order(1);

fprintf('\n Vislabākā aproksimācija ir %d. funkcijai ',best_n)
