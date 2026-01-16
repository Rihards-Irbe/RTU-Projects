%% 1. Uzdevums

xspan = [0.22 6.77];

% Initial conditions:
% y(0.22) = 0.38
% y'(0.22) = 1.55
y0 = [0.38; 1.55];

odefun = @(x,Y) [
    Y(2);
    (4 + x.^2 - (1+3*x).*Y(2) - 2*x.*Y(1)) ./ (1 + 3*exp(x))
];

sol = ode45(odefun, xspan, y0);

x = linspace(0.22, 6.77, 500);
y = deval(sol, x);

figure
plot(x, y(2,:), 'r', 'LineWidth', 3)
xlabel('x')
ylabel('y''(x)')
title('Funkcijas y''(x) grafiks')
grid on
