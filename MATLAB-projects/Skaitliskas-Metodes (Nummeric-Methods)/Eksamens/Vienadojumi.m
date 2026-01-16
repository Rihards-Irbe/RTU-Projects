%% Izmantojot Ņūtona metodi, atrast vienādojuma 3*x^4 - x^3 + x^2 - x - 4 = -2 cos x tuvināto sakni pēc 5 iterācijām, ja sākuma tuvinājums x_0 = 0. Atbildi dod ar četriem cipariem aiz komata.

clc; clearvars; close all; format longG

syms x

f = @(x) (3.*x.^4 - x.^3 + x.^2 - x - 4)-(-2.*cos(x));
fp(x) = diff(f(x), x);

x0 = 0;
iter = 5;

xn = x0;
M = zeros(iter,2);

for i = 1:iter
    xn = xn - double(f(xn)) / double(fp(xn));
    M(i,1) = xn;
    M(i,2) = double(f(xn));
end

fprintf('After %d iterations: x = %.4f\n', iter, M(iter,1))

%% Sastādīt funkcijas f(x) = int[x 0](ln(t + 5) + e ^sqrt(t)) * dt vienādi attālinātu vērtību tabulu intervālā [2.4;3.2] ar soli 0.2. Interpolēt tabulu
%  ar Ņūtona interpolācijas polinomu p_n(x). Aprēķināt p_n (2.96). Atbildi dod ar četriem cipariem aiz komata.

clc, clearvars, close all, format short

syms x
f = @(x,y) integral(@(t) log(t+5) + exp(sqrt(t)), 0, x);

xnodes = 2.4:0.2:3.2;
ynodes = arrayfun(f, xnodes);
%ynodes = f(xnodes);

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

pn = 2.96;
int_res = double(polyn(pn))

fprintf('\nAtbilde:\n');
fprintf('interpolācijas rezultāts punktā (2.96) = %.4f\n', int_res);