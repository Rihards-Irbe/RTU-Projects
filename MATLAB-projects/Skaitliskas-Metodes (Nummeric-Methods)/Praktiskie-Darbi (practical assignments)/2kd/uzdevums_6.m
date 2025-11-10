clc, clearvars, close all, format short

xnodes = -3:0.5:3;
ynodes = [-1 -1 -1 -0.98 -0.79 -0.46 0 0.46 0.79 0.98 1 1 1];

x_pr = linspace(xnodes(1), xnodes(end), 2001);

y_hermite = interp1(xnodes, ynodes, x_pr, 'pchip');
y_spline  = interp1(xnodes, ynodes, x_pr, 'spline');

figure
plot(x_pr, y_hermite, 'r-',  'LineWidth', 2), hold on
plot(x_pr, y_spline,  'k--', 'LineWidth', 2)
plot(xnodes, ynodes, 'ob', 'MarkerFaceColor','b')
hold off, grid on
title('Ermīta interpolācija un splains')
legend('splains','Ermīta interpolācija','mezgli', 'Location','best')
