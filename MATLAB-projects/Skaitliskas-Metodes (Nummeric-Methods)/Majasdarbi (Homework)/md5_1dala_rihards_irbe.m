clc, clearvars, close all, format short g

%% 1. Uzdevums

f = @(x) (4 + x.^2 + x.^3).^(1/3) ./ (3 + cos(x) + sqrt(2 + sin(2*x)));

xpoints = (1:1:9)'; 
ypoints = f(xpoints);

disp(table(round(xpoints,4), round(ypoints,4), 'VariableNames', {'x','f(x)'}))

figure
plot(xpoints, ypoints, 'ob', 'MarkerFaceColor','b', 'LineWidth',1.5)
grid on, title('Datu punkti no f(x)'), xlabel x, ylabel('f(x)')

ft = fittype('a + 2*b*x + c*cos(2*x)', 'independent','x','dependent','y');

[p, reg] = fit(xpoints, ypoints, ft)

xx   = linspace(min(xpoints), max(xpoints), 1000)';
yfit = feval(p, xx);

figure
plot(xpoints, ypoints, 'ob', 'MarkerFaceColor','b', 'LineWidth',1.5), hold on
plot(xx, yfit, 'r-', 'LineWidth', 2.5)
grid on, hold off
title('Aproksimējošā funkcija')
legend('dati','fitted curve','Location','best')

%% 2.Uzdevums

f = @(x) (x.^2 + log(2*x + 5)) ./ (x.^2 + sqrt(2*x + 3) + 2);

xpoints = (3:1:12)'; 
ypoints = f(xpoints);

figure
plot(xpoints, ypoints, 'or', 'LineWidth', 3)
grid on, title('Datu punkti')

karta = 4;

poly_value = sprintf('poly%d', karta);;

[p, reg] = fit(xpoints, ypoints, poly_value)
p = polyfit(xpoints, ypoints, karta);

xx = linspace(min(xpoints), max(xpoints), 1000);

yapprox = polyval(p, xx);
figure
plot(xpoints, ypoints, 'or', xx, yapprox, 'k', 'LineWidth', 3)
legend('data', 'fitted curve'), grid on
title(sprintf('Aproksimācija ar %d kārtas polinomu', karta))

coef_x1 = p(end-1);
fprintf('Koeficients pie x^1: %.4f\n', coef_x1)

%% 3. Uzdevums

f = @(x) (x.^2 + log(2*x + 5)) ./ (x.^2 + sqrt(2*x + 3) + 2);

xpoints = (1:1:10)'; 
ypoints = f(xpoints);

figure
plot(xpoints, ypoints, 'or', 'LineWidth', 3)
grid on, title('Datu punkti')

karta = 5;

poly_value = sprintf('poly%d', karta);;

[p, reg] = fit(xpoints, ypoints, poly_value)
p = polyfit(xpoints, ypoints, karta);

xx = linspace(min(xpoints), max(xpoints), 1000);

yapprox = polyval(p, xx);
figure
plot(xpoints, ypoints, 'or', xx, yapprox, 'k', 'LineWidth', 3)
legend('data', 'fitted curve'), grid on
title(sprintf('Aproksimācija ar %d kārtas polinomu', karta))

x0      = 5.33;
int_res = polyval(p, x0)

fprintf('Polinoma vērtība punktā x_0(%.f) = %.4f\n', x0, int_res)

%% 4. Uzdevums

g = @(t) (3 + 3*t.^2) ./ sqrt( 2*t + log(4 + 3*t + 2*t.^2) );
f = @(x) arrayfun(@(x0) integral(g, 0, x0, 'AbsTol',1e-10, 'RelTol',1e-10), x);

xpoints = (0:0.5:4.5)'; 
ypoints = f(xpoints);

disp(table(round(xpoints,4), round(ypoints,4), 'VariableNames', {'x','f(x)'}))

figure
plot(xpoints, ypoints, 'or', 'LineWidth', 3)
grid on, title('Datu punkti')

karta = 4;

poly_value = sprintf('poly%d', karta);;

[p, reg] = fit(xpoints, ypoints, poly_value)
p = polyfit(xpoints, ypoints, karta);

xx = linspace(min(xpoints), max(xpoints), 1000);

yapprox = polyval(p, xx);
figure
plot(xpoints, ypoints, 'or', xx, yapprox, 'k', 'LineWidth', 3)
legend('data', 'fitted curve'), grid on
title(sprintf('Aproksimācija ar %d kārtas polinomu', karta))

coef_x0 = p(end);
fprintf('Koeficients pie x^0: %.4f\n', coef_x0)

%% 5. Uzdevums

syms x
g = @(t) cos(12*t.^2 + sqrt(t.^3 + 6));
f = @(x0) arrayfun(@(z) integral(g,0,z,'AbsTol',1e-10,'RelTol',1e-10), x0);

xnodes = 1.4:0.1:2.0;
ynodes = f(xnodes);

coef = ynodes;
m = numel(xnodes);
for k = 2:m
    coef(k:m) = (coef(k:m) - coef(k-1:m-1)) ./ ...
                (xnodes(k:m) - xnodes(1:m-k+1));
end

pol = coef(m);
for k = m-1:-1:1
    pol = pol*(x - xnodes(k)) + coef(k);
end
polyn(x) = collect(pol);

x0 = 1.74;
int_res = double(polyn(x0));
f_res  = f(x0);
int_err   = abs(int_res - f_res);

fprintf('Interpolācijas kļūda punktā x_0(%.2f) = %.4f\n', x0, int_err);
