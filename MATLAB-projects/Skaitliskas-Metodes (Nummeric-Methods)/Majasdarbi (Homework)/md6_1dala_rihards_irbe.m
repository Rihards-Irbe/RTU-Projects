clc, clearvars, format compact, close all, format longG

%% 1. Uzdevums

x = linspace(-10, 10, 400);
y = linspace(-5, 5, 400);
[X, Y] = meshgrid(x, y);

f1 = X.^2/12 + Y.^2 - 3;
f2 = sin(2.2*X) + 0.5*Y - 1;

figure;
hold on;
contour(X, Y, f1, [0 0], 'LineWidth', 2);
contour(X, Y, f2, [0 0], 'LineWidth', 2);
hold off;

grid on;
xlabel('x1');
ylabel('x2');
title('Divu liniju krustojums');
axis equal;

%% 2. Uzdevums

integ = @(a,x) (a + 4*sqrt(x)).^(1/3) .* atan(x.^3 + 4);

for a = 1:20
    fun = @(x) integ(a, x);
    int_val(a) = integral(fun, 2, 3) - 4;
end

a_pr = 1:20;
plot(a_pr, int_val, 'r', 'LineWidth', 3)
title('Funkcijas f(a) grafiks intervālā [1; 20]')
xlabel('a'), ylabel('f(a)'), grid on

iter = 6;
a_xn = zeros(1, iter+2);
a_xn = [5 8]; % sākuma tuvinājumi (pielāgot pēc grafika!)

for i = 1:2
    fun = @(x) integ(a_xn(i), x);
    f_val(i) = integral(fun, 2, 3) - 4; % MAINĪTS: f_val nevis f
end

for k = 1:iter
    k1 = k+1;
    i = k+2;
    a_xn(i) = a_xn(k1) - f_val(k1)*(a_xn(k1) - a_xn(k))/(f_val(k1) - f_val(k));
    fun = @(x) integ(a_xn(i), x);
    f_val(i) = integral(fun, 2, 3) - 4; % MAINĪTS: f_val nevis f
    M_pr(k,1) = a_xn(i);
    M_pr(k,2) = f_val(i); % MAINĪTS: f_val nevis f
end

fprintf('   a = %.4f \n', M_pr(iter,1))
format

%% 3. Uzdevums

f = @(x) (x - 2).^3 + 2.*x - 1 + 5.*atan(x);

x_val = linspace(-1, 3, 100);
for i = 1:length(x_val)
    f_val(i) = f(x_val(i));
end

plot(x_val, f_val, 'r', 'LineWidth', 3)
hold on
plot(x_val, zeros(size(x_val)), 'k--')
title(['Funkcijas f(x) grafiks'])
xlabel('x'), ylabel('f(x)'), grid on

iter = 2;
x_n = zeros(1, iter+2);
x_n = [0 1.5];

for i = 1:2
    f_n(i) = f(x_n(i));
end

for k = 1:iter
    k1 = k+1;
    i = k+2;
    x_n(i) = x_n(k1) - f_n(k1)*(x_n(k1) - x_n(k))/(f_n(k1) - f_n(k));
    f_n(i) = f(x_n(i));
    M_pr(k,1) = x_n(i);
    M_pr(k,2) = f_n(i);
end

fprintf('   x = %.4f \n', M_pr(iter,1))

%% 4. Uzdevums

f = @(x)0.2*x.^3 - 5*x + 5 - exp(0.3*x);

x_pr = -10:0.01:10;
plot(x_pr, f(x_pr), 'r', 'LineWidth', 3)
grid on, title('Funkcijas f(x) grafiks intervālā [-10,10]')

figure, x_pr = -5:0.01:15;
plot(x_pr, f(x_pr), 'r', 'LineWidth', 3)
grid on, title('Funkcijas f(x) grafiks intervālā [-5,15]')

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

fprintf('   x = %.4f\n', max_root)
format

%% 5. Uzdevums

f1 = @(x1,x2) sin(x2-2) - 2.5*x1 + 5;
f2 = @(x1,x2) 1.5*x2 + cos(2*x1-3) + 1;

xapp = [1, -1];

syms x1 x2
fun = [ sin(x2-2) - 2.5*x1 + 5;
        1.5*x2 + cos(2*x1-3) + 1 ];
fun_pr = [ diff(fun(1), x1), diff(fun(1), x2);
           diff(fun(2), x1), diff(fun(2), x2) ];

epsi = 1e-7; k = 0;
sol_norm = 1;
xapp_pr = xapp;
M_pr = [];

while sol_norm > epsi
    for i = 1:2
        B(i,1) = -double(subs(fun(i), [x1 x2], xapp));
        for j = 1:2
            A(i,j) = double(subs(fun_pr(i,j), [x1 x2], xapp));
        end
    end
    xdelta = A\B;
    xapp = xapp + xdelta';
    c = double(subs(fun, [x1 x2], xapp));
    sol_norm = norm(c);
    k = k + 1;
    M_pr(k,1:2) = xapp;
    M_pr(k,3)   = sol_norm;
end

fprintf('x2 = %.4f\n', M_pr(k,2))
format