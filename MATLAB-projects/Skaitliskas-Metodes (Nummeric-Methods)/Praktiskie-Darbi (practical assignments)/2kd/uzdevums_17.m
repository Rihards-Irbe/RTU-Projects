clc, clearvars, close all, format short

f = @(x) (2*x.^2) ./ (4 + exp(-0.2*x));

xpoints = (2:0.5:8)'; 
ypoints = f(xpoints);

disp(table(round(xpoints,4), round(ypoints,4), 'VariableNames', {'x','f(x)'}))

figure
plot(xpoints, ypoints, 'ob', 'MarkerFaceColor','b', 'LineWidth',1.5)
grid on
title('Datu punkti')

xx      = linspace(min(xpoints), max(xpoints), 1000)';
f_res  = interp1(xpoints, ypoints, xx, 'spline');

x1   = 6.1;
h_x0 = interp1(xpoints, ypoints, x1, 'spline')

[p, reg] = fit(xpoints, ypoints, 'poly2')
g_res = feval(p, xx);                                     % g(x) uz xx
g_x1   = feval(p, x1);                                    % g(6.1)

x_1_error = abs(h_x0 - g_x1)

fprintf('\nAtbilde:\n');
fprintf(' Kļūda punktā (6.1) = %.4f\n', x_1_error);

figure
plot(xx, g_res, 'r-', 'LineWidth', 2), hold on
plot(xpoints, ypoints, 'ob', 'MarkerFaceColor','b', 'LineWidth', 1.2)
grid on, hold off
title('Aproksimācija ar otrās kārtas polinomu')
legend('fitted curve','data','Location','best')
