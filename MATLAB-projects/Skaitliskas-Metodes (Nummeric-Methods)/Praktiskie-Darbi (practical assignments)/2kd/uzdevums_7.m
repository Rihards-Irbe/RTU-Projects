clc, clearvars, close all, format short

f = @(x) x.^2 .* cos(nthroot(x.^2,3));           % f(x) = x^2*cos( 3√(x^2) )
xnodes = 2:1:6;                                  % [2,3,4,5,6] => intervāls [2;6] ar soli 1
ynodes = f(xnodes);

coef = ynodes; 
m = numel(xnodes);
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
coefpol  = sym2poly(polyn)

x0 = 2.5;
pol_res = double(polyn(x0))                       % (a) interpolācijas rezultāts P(2.5)

n = length(coefpol)-1;                            % šeit n=4
idx_x3 = 1 + (n-3);                               % indekss koeficientam pie x^3
coef_x3 = coefpol(idx_x3);                        % (b) atbilde

f_res   = f(x0)
pol_error = abs(pol_res - f_res)                  % (c) |P(2.5)-f(2.5)| <- jeb interpolācijas kļūdas formulas izpilde

spl_res = interp1(xnodes, ynodes, x0, 'spline')   % (d) splaina rezultāts S(2.5)
f_res

spl_error = abs(spl_res - f_res)                  % (e) |S(2.5)-f(2.5)| <- jeb interpolācijas kļūdas formulas izpilde

x1 = 4;
spl_error_2 = abs(interp1(xnodes, ynodes, x1, 'spline') - f(x1));

fprintf('Atbilde:\n');
fun_prob6(coefpol)
fprintf(' interpolācijas rezultāts punktā (2.5) = %.4f \n', pol_res)
fprintf(' b) koef_x^3 = %.5f\n', coef_x3);
fprintf(' c) interpolācijas kļūda punktā (2.5) = %.6f\n', pol_error);
fprintf(' d) interpolācijas rezultāts punktā (2.5) = %.4f\n', spl_res);
fprintf(' e) interpolācijas kļūda punktā (2.5) = %.6f\n', spl_error);
fprintf(' f) interpolācijas kļūda punktā (x=4) = %.f,\n', spl_error_2);
fprintf(' tā kā punkts x=4 ir interpolācijas mezgla punkts\n');

%% Ārējā funkcija polinoma drukāšanai
function fun_prob6(koef)
    m = length(koef);
    fprintf(' a) Ņūtona interpolācijas polinoms: \n')
    n = m-1;
    for i = 1:m
        if koef(i) < 0
        fprintf(' %.4fx^%.0f',koef(i),n)
        else
            fprintf(' +')
            fprintf('%.4fx^%.0f',koef(i),n)
        end
       n = n-1;
    end
    fprintf('\n')
end
