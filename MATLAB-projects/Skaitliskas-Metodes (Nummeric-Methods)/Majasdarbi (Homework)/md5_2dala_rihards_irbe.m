clc, clearvars, close all, format short

%% 1. Uzdevums

f = @(x) 1 ./ ( (1+x).^2 + sqrt(log(x+2) + 3*x ));

xpoints = (1.2:0.2:3).';
ypoints = f(xpoints);

figure
plot(xpoints, ypoints, 'ob', 'MarkerFaceColor','b', 'LineWidth',1.5)
grid on, title('Datu punkti')

ft = fittype('a + b*x + c*cos(x)', 'independent','x','dependent','y');

[p, reg] = fit(xpoints, ypoints, ft)

xx   = linspace(min(xpoints), max(xpoints), 1000).';
yfit = feval(p, xx);

x0 = 1.33;
y_x0 = feval(p, x0);
fprintf('y(%.2f) = %.4f\n', x0, y_x0);

%% 2. Uzdevums

f = @(x) (log(1+sqrt(x)) + cos(x) + x.^3) ./ (1 + x.^2 + sqrt(log(x+2)));

xpoints = (1.4:0.2:3.2)'; 
ypoints = f(xpoints);

figure
plot(xpoints, ypoints, 'or', 'LineWidth', 3)
grid on, title('Datu punkti')

ft = fittype('a + b*sin(2*x) + c*(x+1)', 'independent','x','dependent','y');
[p, reg] = fit(xpoints, ypoints, ft)

xx   = linspace(min(xpoints), max(xpoints), 1000)';
yfit = feval(p, xx);

x0 = 1.71;
y_x0  = feval(p, x0);
f_x0  = f(x0);
int_err = abs(y_x0 - f_x0);

fprintf('Aproksimācijas kļūda x_0(%.2f) = %.4f\n',x0, int_err);

%% 3. Uzdevums

g = @(t) exp( sqrt(t) .* sin(3*t.^2 + 1) ) + cos(2*t);
F = @(x) arrayfun(@(x0) integral(g, 0, x0, 'AbsTol', 1e-10, 'RelTol', 1e-10), x);

xpoints = 3:1:9;
ypoints = F(xpoints);

x0 = 3.42;
int_res = interp1(xpoints, ypoints, x0, 'spline');

fprintf('s(%.2f) = %.4f\n', x0, int_res);

%% 4. Uzdevums

g = @(t) (1 + sqrt(t.^3)) ./ (5 + cos(t) + sqrt(5 + sin(2*t) + t.^2));
f = @(x) arrayfun(@(x0) integral(g,0,x0,'AbsTol',1e-10,'RelTol',1e-10), x);

xpoints = (5:1:14)'; 
ypoints = f(xpoints);

figure
plot(xpoints, ypoints, 'or', 'LineWidth', 3)
grid on, title('Datu punkti')

karta = 4;

poly_value = sprintf('poly%d', karta);;

[p, reg] = fit(xpoints, ypoints, poly_value)
p = polyfit(xpoints, ypoints, karta);

xx = linspace(min(xpoints), max(xpoints), 1000);

x0      = 8.88;
int_res = polyval(p, x0)

fprintf('Polinoma vērtība punktā x_0(%.2f) = %.4f\n', x0, int_res)

%% 5. Uzdevums

f = @(x) x.*exp(-0.1*x) ./ (2 + cos(2*x) + sqrt(3 + sin(2*x)));

xpoints = (5:1:13)'; 
ypoints = f(xpoints);

karta = 3;

poly_value = sprintf('poly%d', karta);
[p, reg] = fit(xpoints, ypoints, poly_value)
p = polyfit(xpoints, ypoints, karta);

x0   = 7.25;
g_x0 = polyval(p, x0);
int_res = interp1(xpoints, ypoints, x0, 'spline');
int_err = abs(int_res - g_x0);

fprintf('Aproksimācijas kļūda x_0(%.2f) = %.4f\n',x0, int_err);
