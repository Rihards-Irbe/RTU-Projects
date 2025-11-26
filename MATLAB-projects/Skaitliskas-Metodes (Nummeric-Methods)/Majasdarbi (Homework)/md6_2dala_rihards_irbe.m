clc, clearvars, format compact, close all, format longG

%% 1. Uzdevums

f = @(x)0.2*x.^3 - 5*x + 5 - exp(0.3*x);

x_app = [0.5, 5, 10];
iter = 10;
syms x, fpr(x) = diff(f(x), x);

for j = 1:length(x_app)
    M = zeros(iter, 2);
    xn = x_app(j);
    for i = 1:iter
        xn = xn - f(xn)/double(fpr(xn));
        M(i,1) = xn; 
        M(i,2) = f(xn);
    end
    xapp_val(j) = M(iter,1);
end

[max_root, idx] = max(xapp_val);

fprintf('Atbilde:\n')
fprintf(' x = %.4f\n', max_root)
format

%% 2. Uzdevums

y_curve = @(x) 2 - 2*sin(2.2*x);

x = linspace(-6, 6, 2000);

t = linspace(0, 2*pi, 500);
x_ellipse = 6*cos(t);
y_ellipse = sqrt(3)*sin(t);

figure;
hold on;
grid on;
axis equal;

plot(x_ellipse, y_ellipse, 'b', 'LineWidth', 2);
plot(x, y_curve(x), 'r', 'LineWidth', 2);

xlabel('x');
ylabel('y');
title('Funkcijas grafiks');

hold off;

% pec grafika noteicu 8

%% 3. Uzdevums

f1 = @(x,y) 3*y.^2 - 2*x.^2 - 16;
f2 = @(x,y) x.^3 + y.^3 - 4*x.*y - 2;

syms x y
xapp = [2 -2];
xpr = [x y];
fun = [3*y^2 - 2*x^2 - 16, x^3 + y^3 - 4*x*y - 2];

fun_pr = [diff(fun(1), x) diff(fun(1), y);
          diff(fun(2), x) diff(fun(2), y)];

iter = 2;
M_pr = zeros(iter, 3);

for k = 1:iter
    for i = 1:2
        B(i,1) = -double(subs(fun(i), xpr, xapp));
        for j = 1:2
            A(i,j) = double(subs(fun_pr(i,j), xpr, xapp));
        end
    end
    
    xdelta = A\B;
    xapp = xapp + xdelta';
    
    M_pr(k,1) = xapp(1);
    M_pr(k,2) = xapp(2);
    M_pr(k,3) = norm(xapp);
end

fprintf('Atbilde:\n')
fprintf(' ||z^(2)||₂ = %.4f\n', M_pr(iter,3))

%% 4. Uzdevums

f = @(x) cos(x - 0.4) - sin(2*x - 7).*sqrt(x + 2) - 0.3*x.^3;

x_pr = -2:0.01:5;
plot(x_pr, f(x_pr), 'r', 'LineWidth', 3), hold on
plot(x_pr, zeros(size(x_pr)), 'k--', 'LineWidth', 1.5)
grid on
title('Funkcijas grafiks')
xlabel('x'), ylabel('f(x)')
legend('f(x)', 'f(x) = 0', 'Location', 'best')
hold off

%% 5. Uzdevums

clc;
clear;
close all;

f = @(x) x.^4 - 0.7*x.^3 - 5*x.^2 + 0.2*cos(x);

x = linspace(-5, 5, 5000);

figure;
plot(x, f(x), 'b', 'LineWidth', 2);
hold on;
grid on;

yline(0, '--r', 'LineWidth', 1.5);

xlabel('x');
ylabel('f(x)');
title('Funkcijas grafiks');

hold off;

% pec grafika noteicu 5, bet vajag palielinat, lai redzetu sos 4 saskarien
% punktus