clc, clearvars, close all, format short

syms x
f = @(x) x.^3 .* sqrt(cos(x) + x);

xnodes = 3:1:8;
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
coefpol  = sym2poly(polyn);
disp('coefpol ='), disp(coefpol)

x0 = 6.5;
int_res = double(polyn(x0))
f_res   = f(x0)
int_err = abs(int_res - f_res)

n = length(coefpol) - 1;
idx_x3 = 1 + (n - 3);
coef_x3 = coefpol(idx_x3);


x1 = 6;
err_x1 = abs(double(polyn(x1)) - f(x1));

fprintf('\nAtbilde:\n');
fprintf('1) interpolācijas rezultāts punktā (6.5) = %.4f\n', int_res);
fprintf('2) koef_x^3 = %.4f\n', coef_x3);
fprintf('3) interpolācijas kļūda punktā (6.5) = %.5f\n', int_err);
fprintf('4) interpolācijas kļūda punktā (x=6) = %.f, \n', err_x1);
fprintf('tā kā punkts x=6 ir interpolācijas mezgla punkts\n');
