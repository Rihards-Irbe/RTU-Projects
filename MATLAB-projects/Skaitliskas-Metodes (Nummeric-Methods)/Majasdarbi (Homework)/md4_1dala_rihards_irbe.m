clc, clearvars, format compact, close all

%% 1. Uzdevums
f = @(x) sqrt( x.^(3/4) + 2*cos(x) );
xnodes = 5:11;
x2 = xnodes(2); x3 = xnodes(3);

dd1 = (f(x3) - f(x2)) / (x3 - x2);

fprintf('f[x2, x3] = %.4f\n', dd1);

%% 2. Uzdevums
syms x
f = @(x) (log(x+5) + tan(x)) .* (x.^(4/5) + (2*x + x.^2).*tan(x));
xnodes = 1:3:13;  
ynodes = f(xnodes);  
coef = ynodes;
m = length(xnodes);
for k = 2:m
    coef(k:m) = (coef(k:m) - coef(k-1:m - 1))./...
                (xnodes(k:m) - xnodes(1:(m + 1)-k));
end
pol = coef(m);
for k = m - 1:-1:1
   pol = pol*(x - xnodes(k)) + coef(k);
end
polyn(x) = collect(pol);
coefpol = sym2poly(polyn);
x0 = 4.82;
int_res = double(polyn(x0));
f_res = f(x0);
int_error = abs(int_res - f_res);

disp('Atbilde:')
disp(['Interpolācijas polinoma vērtība P(4.82) = ', num2str(int_res, '%.4f')])

%% 3. Uzdevums
syms x
f = @(x) sin(2 + nthroot(1 + x.^2, 3)) .* acot(3 + 3.*x + x.^3);

xnodes = 1:1:5;
ynodes = f(xnodes);

coef = ynodes;
m = numel(xnodes);
for k = 2:m
    coef(k:m) = (coef(k:m) - coef(k-1:m-1)) ./ ...
                (xnodes(k:m) - xnodes(1:(m+1-k)));
end

pol = sym(coef(m));
for k = m-1:-1:1
    pol = expand(pol*(x - xnodes(k)) + coef(k));
end
polyn(x) = collect(pol);

x1 = 2.23;
p_x1   = double(polyn(x1));
spl_x1 = interp1(xnodes, ynodes, x1, 'spline');
difference = abs(p_x1 - spl_x1);

fprintf('Atbilde:\n');
fprintf('|p(x₁) - spl(x₁)| punktā x₁ = %.2f: %.4f\n', x1, difference);


%% 4. Uzdevums

f = @(x) log(x+4) .* sqrt( (x.^4).^(1/3) + exp(-0.3*x) );

xnodes = 1:3:10;
ynodes = f(xnodes);

x0 = 5.43;
int_res = interp1(xnodes, ynodes, x0, 'spline');
f_res   = f(x0);
int_err = abs(int_res - f_res);

fprintf('Atbilde: |f^(%.2f) - f(%.2f)| = %.4f\n', x0, x0, int_err);

%% 5. Uzdevums

f = @(x)(log(x.^2 + 7) + 3*x) .* sin((2*x + x.^3).^(1/3));

xnodes = (4:2:10);
ynodes = f(xnodes);
m = length(xnodes);
coef = ynodes;

for k = 2:m
    coef(k:m) = (coef(k:m) - coef(k-1:m-1)) ./ ...
                (xnodes(k:m) - xnodes(1:m-k+1));
end

syms x
pol = coef(m);
for k = m-1:-1:1
    pol = pol*(x - xnodes(k)) + coef(k);
end

polyn(x) = collect(pol);
coefpol = sym2poly(polyn);

x_pr = 4:0.01:10;
figure('Position', [100, 100, 900, 600])
plot(x_pr, polyn(x_pr), 'r-', 'LineWidth', 2.5)
hold on
plot(x_pr, f(x_pr), 'b--', 'LineWidth', 2)
plot(xnodes, ynodes, 'og', 'MarkerSize', 10, 'MarkerFaceColor', 'g')
hold off
title('Ņūtona interpolācijas polinoms', 'FontSize', 14)
xlabel('x', 'FontSize', 12)
ylabel('f(x)', 'FontSize', 12)
legend('Polinoms', 'Funkcija', 'Mezgli', ...
       'Location', 'best', 'FontSize', 11)
grid on
