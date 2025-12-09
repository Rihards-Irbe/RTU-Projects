clc, clearvars, format compact, close all

%% 1. Uzdevums

x_int = [0.22 6.77];

y0 = [0.38; 1.55];

sol = ode45(@fun_koshi, x_int, y0);

sol_x = sol.x';
sol_y = sol.y';

x = 0.22:0.01:6.77;
y = deval(sol, x);

figure
plot(x, y(2,:), 'r', 'LineWidth', 3)
xlabel('x'), ylabel('y''(x)')
title('Funkcijas y''(x) grafiks')
grid on

%% 2. Uzdevums

x_int = [0.12 0.94];

y0 = [-1.5; -1.3];

sol = ode45(@fun_koshi_sys, x_int, y0);

sol_x = sol.x';
sol_y = sol.y';

y_057 = deval(sol, 0.57);
y1_057 = y_057(1);

disp('Atbilde:')
fprintf(' y1(0.57) = %.4f \n', y1_057)

x = 0.12:0.01:0.94;
y = deval(sol, x);

figure
plot(x, y(1,:), 'r', x, y(2,:), 'b', 'LineWidth', 3)
legend('y1(x)', 'y2(x)')
xlabel('x'), ylabel('y1(x), y2(x)')
title('Funkciju y1(x) un y2(x) grafiki')
grid on

%% 3. Uzdevums

x_int = [0.55 2.55];

y0 = [-1.22; -1.11; 1.33];

opts = odeset('RelTol',1e-8,'AbsTol',1e-10);

sol = ode45(@fun_koshi3, x_int, y0, opts);

sol_x = sol.x';
sol_y = sol.y';

y_value = deval(sol, 2.11);
y2prime_211 = y_value(3);

disp('Atbilde:')
fprintf(' y''''(2.11) = %.4f\n', y2prime_211)

x = 0.55:0.01:2.55;
y = deval(sol, x);

figure
plot(x, y(1,:), 'r', 'LineWidth', 3)
xlabel('x'), ylabel('y(x)')
title('Funkcijas y(x) grafiks'), grid on

figure
plot(x, y(2,:), 'g', x, y(3,:), 'b', 'LineWidth', 3)
legend('y''(x)', 'y''''(x)')
xlabel('x'), ylabel('y''(x), y''''(x)')
title('Funkciju y''(x) un y''''(x) grafiki'), grid on

%% 4. Uzdevums
clc, clearvars, format compact, close all

x_int = [1 4.3];
y0 = 2.32;

opts = odeset('RelTol',1e-8,'AbsTol',1e-10);

sol = ode45(@fun_koshi1, x_int, y0, opts);

y_256 = deval(sol, 2.56);

disp('Atbilde:')
fprintf(' y(2.56) = %.4f\n', y_256)

x = 1:0.01:4.3;
y = deval(sol, x);

figure
plot(x, y, 'r', 'LineWidth', 3)
xlabel('x'), ylabel('y(x)')
title('Funkcijas y(x) grafiks')
grid on

%% 5. Uzdevums

x_int = [0.2 0.9];
y0 = [1.25; 1.33];

sol = ode45(@fun_koshi_last, x_int, y0);

sol_x = sol.x';
sol_y = sol.y';

x = 0.2:0.01:0.9;
y = deval(sol, x);

figure
plot(x, y(2,:), 'r', 'LineWidth', 3)
xlabel('x'), ylabel('y_2(x)')
title('Funkcijas y_2(x) grafiks')
grid on

%% Ārējā funkcija

function dy_dx = fun_koshi(x, y)
    dy_dx = zeros(2,1);
    dy_dx(1) = y(2);
    dy_dx(2) = (4 + x.^2 - (1 + 3*x).*y(2) - 2*x.*y(1)) ./ (1 + 3*exp(x));
end

function dy_dx = fun_koshi_sys(x, y)
    dy_dx = zeros(2,1);
    dy_dx(1) = (1/3)*x.^2 + x.*y(1);
    dy_dx(2) = -(1/3)*x.^2 + x.*y(2);
end

function dy_dx = fun_koshi3(x, y)
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

function dydx = fun_koshi1(x, y)
    dydx = x.*exp(-y) - cos(x.^2 + 2*x + 3);
end

function dy_dx = fun_koshi_last(x, y)
    dy_dx = zeros(2,1);
    dy_dx(1) = 0.5*y(1).^2 + x.*y(2);
    dy_dx(2) = -0.5*y(2).^2 + y(1).*y(2);
end