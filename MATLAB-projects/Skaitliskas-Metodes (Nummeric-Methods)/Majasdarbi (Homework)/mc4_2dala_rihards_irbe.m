clc, clearvars, format compact, close all

%% 1. Uzdevums

syms x
f = @(x) cos(exp(x) + 3) + 3*x;

xnodes = 4:1:10;
ynodes = f(xnodes);
coef   = ynodes;

m = length(xnodes);
for k = 2:m
    coef(k:m) = (coef(k:m) - coef(k-1:m-1)) ./ ...
                (xnodes(k:m) - xnodes(1:(m+1)-k));
end

pol = coef(m);
for k = m-1:-1:1
    pol = pol*(x - xnodes(k)) + coef(k);
end

polyn(x) = collect(pol);
coefpol  = sym2poly(polyn);

n = length(coefpol)-1;
idx = n - 5 + 1;
coef_x5 = coefpol(idx);

fprintf('Koeficients pie x^5: %.4f\n', coef_x5);

%% 2. Uzdevums

clc, clearvars, format compact, close all

f = @(x) (2 + log(1 + 2*x)) .* (x + 2 + 3*x.^2);

xnodes = 3:2:11;
ynodes = f(xnodes);

m = numel(xnodes);
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

x_pr = 3:0.01:11;
err  = abs(f(x_pr) - double(polyn(x_pr)));

figure('Position',[100,100,900,520])
plot(x_pr, err, 'm-', 'LineWidth', 2.5)
grid on
title('Interpolācijas kļūda', 'FontSize', 14)

%% 3. Uzdevums

% f(x) = sin^2(x) * sqrt( ln(3 + cos x) + 5 * 4√x )
f = @(x) (sin(x).^2) .* sqrt( log(3 + cos(x)) + 5*x.^(1/4) );

% Vienādi attālināti mezgli [5,13] ar soli 2
xnodes = 5:2:13;                % [5 7 9 11 13]
ynodes = f(xnodes);

% Kubiskais splains (not-a-knot)
x0 = 6.45;
spl_val = interp1(xnodes, ynodes, x0, 'spline');

fprintf('spl(%.2f) = %.4f\n', x0, spl_val);

%% 4. Uzdevums

f = @(x) log(5 + cos(2*x) + sin(x)) .* (5 + atan(x)).^(1/4);

xnodes = 2:1:6;
ynodes = f(xnodes);

x_pr = linspace(2,6,1001);

spl_vals = interp1(xnodes, ynodes, x_pr, 'spline');
err      = abs(f(x_pr) - spl_vals);

figure('Position',[100,100,900,520])
plot(x_pr, err, 'm-', 'LineWidth', 2.5), grid on
title('Interpolācijas kļūda')

%% 5. Uzdevums

f = @(x) sin( 2 + (1 + x.^2).^(1/3) ) .* acot(3 + 3*x + x.^3);

xnodes = 1:1:5;
ynodes = f(xnodes);

x_pr = linspace(1,5,1001);

spl_vals = interp1(xnodes, ynodes, x_pr, 'spline');

figure('Position',[120,100,900,520])
plot(x_pr, f(x_pr), 'b--', 'LineWidth', 2), hold on
plot(x_pr, spl_vals, 'r-', 'LineWidth', 2.5)
plot(xnodes, ynodes, 'ok', 'MarkerFaceColor','g', 'MarkerSize',8)
hold off, grid on
title('Splaina interpolācija', 'FontSize', 13)
legend('funkcija', 'splains', 'mezgli', 'Location','best')


%% ārējas funkcijas %%  ārējas funkcijas  %%   ārējas funkcijas %%%%%%%%%%
% pamatprogrammas beigas

% ārēja funkcija (3.3.piemērs). interpolācja
% polinoma drukāšana
function fun_prob3(koef)
   m = length(koef);
   fprintf('\n Atbilde. \n  Ņūtona %.0f.kārtas interpolācijas polinoms:\n  ', m-1)
   n = m-1;
   for i = 1:m
      if koef(i) < 0, fprintf(' %.4fx^%.0f', koef(i), n)
      else,            fprintf(' +%.4fx^%.0f', koef(i), n)
      end
      n = n-1;
   end
   fprintf('\n')
end

