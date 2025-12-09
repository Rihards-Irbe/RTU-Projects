clc, clearvars, format compact, close all

%% 1. Uzdevums

x_int = [0.55 2.55];
y0 = [-1.22; -1.11; 1.33];

opts = odeset('RelTol',1e-8,'AbsTol',1e-10);
sol = ode45(@fun_q3, x_int, y0, opts);

x = 0.55:0.01:2.55;
Y = deval(sol, x);

figure
plot(x, Y(2,:), 'r', 'LineWidth', 3)
xlabel('x'), ylabel('y''(x)')
title('Funkcijas y''(x) grafiks')
grid on

%% 2. Uzdevums

dy_dx = @(x, y) [0.5 * y(1)^2 + x * y(2); 
                 -0.5 * y(2)^2 + y(1) * y(2)];

x_int = [0.33, 0.89];
y0 = [1.45; 0.85];

sol = ode45(dy_dx, x_int, y0);

sol_x = sol.x';
sol_y = sol.y';

y_value = deval(sol, 0.66);

fprintf('Atbilde:\n')
fprintf(' y2(0.66) = %.4f\n', y_value(2))

%% 3. Uzdevums

x_int = [1 3.2];
y0 = 1.7;

opts = odeset('RelTol',1e-8,'AbsTol',1e-10);
sol = ode45(@fun_last, x_int, y0, opts);

x = 1:0.01:3.2;
y = deval(sol, x);

figure
plot(x, y, 'r', 'LineWidth', 3)
xlabel('x'), ylabel('y(x)')
title('Funkcijas y(x) grafiks')
grid on


%% 4. Uzdevums

x_int = [0.22, 6.77];
y0 = [0.38; 1.55];

sol = ode45(@fun_kosi, x_int, y0);

sol_x = sol.x';
sol_y = sol.y';

y_value = deval(sol, 3.44);

fprintf('Atbilde:\n')
fprintf(' y''(3.44) = %.4f\n', y_value(2))

%% 5. Uzdevums

x_int = [0.22, 6.66];
y0 = [-1.77; 2.33; 1.28];

sol = ode45(@fun_kosi2, x_int, y0);

sol_x = sol.x';
sol_y = sol.y';

y_value = deval(sol, 4.32);

fprintf('Atbilde:\n')
fprintf(' y(4.32)   = %.4f\n', y_value(1))


%% Ārējā funkcija

function dy_dx = fun_kosi(x, y)
    dy_dx = zeros(2, 1);
    dy_dx(1) = y(2);
    dy_dx(2) = (4 + x.^2 - (1 + 3.*x).*y(2) - 2.*x.*y(1)) ./ (1 + 3.*exp(x));
end

function dy_dx = fun_kosi2(x, y)
    dy_dx = zeros(3, 1);
    dy_dx(1) = y(2);
    dy_dx(2) = y(3);
    dy_dx(3) = 3 + 2.*x.^2 - (2 + atan(x)).*y(2) - (5 + 2.*x + 3.*x.^2).*y(3) - log(5 + 2.*x).*y(1);
end

function dy_dx = fun_q3(x, y)
    dy_dx = zeros(3,1);
    dy_dx(1) = y(2);
    dy_dx(2) = y(3);

    coef = 9./sqrt(3*x) + cos(x);
    lterm = log(3 + sqrt(2*x));

    dy_dx(3) = exp(2*x + 5) ...
               - coef.*y(3) ...
               - lterm.*y(2) ...
               - (4 + x.^2).*y(1);
end

function dydx = fun_last(x, y)
    dydx = x.*exp(-y) + (sin(x).^2)./sqrt(5 + x.^3);
end