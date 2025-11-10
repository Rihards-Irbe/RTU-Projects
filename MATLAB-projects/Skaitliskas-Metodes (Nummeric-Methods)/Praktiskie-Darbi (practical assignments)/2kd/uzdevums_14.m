clc, clearvars, close all, format short g

xpoints = [1.0 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0 5.5 6.0 6.5 7.0 7.5 8.0]';
ypoints = [0.1 0.4 0.65 0.9 1.1 1.2 1.4 1.5 1.63 1.69 1.81 1.88 1.96 2.05 2.08]';

figure
plot(xpoints, ypoints, 'or', 'LineWidth', 3)
grid on, title('Datu punkti')

f1 = fittype('a + b *log(x)');

[p1, reg1] = fit(xpoints, ypoints, f1)

xx = linspace(min(xpoints), max(xpoints), 1000)';
y1 = feval(p1, xx);

figure
plot(xpoints, ypoints, 'or', xx, y1, 'k', 'LineWidth', 3)
legend('data', 'fitted curve'), grid on
title('Aproksimācija ar trigonometrisko funkciju y=a+bln(x)')

fprintf('\nAtbilde:\n')

adj  = [reg1.adjrsquare];
rmse = [reg1.rmse];

[~, order] = sortrows([-adj(:), rmse(:)]);
best_n = order(1);

fprintf('\n Vislabākā aproksimācija ir %d. funkcijai ',best_n)
