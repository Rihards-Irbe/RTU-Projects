clc, clearvars, close all, format long g

xnodes = ((1:11)-10)/10

y = @(x) erf(x);
ynodes = y(xnodes);

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

x_pr = linspace(xnodes(1), xnodes(end), 2001);
figure
plot(x_pr, double(polyn(x_pr)),'r-', ...
     x_pr, y(x_pr),'k--', ...
     xnodes, ynodes,'ob','LineWidth',2)
grid on
title('Ņūtona interpolācijas polinoms')
legend('polinoms','y = erf(x)','mezgli','Location','best')

err = y(x_pr) - double(polyn(x_pr));
figure
plot(x_pr, err, 'g--', 'LineWidth', 2)
grid on
title('Interpolācijas kļūda')

fun_prob3(coefpol)

%% Ārējā funkcija polinoma drukāšanai
function fun_prob3(koef)
   m = length(koef); n = m-1;
   fprintf('\n Atbilde. Ņūtona interpolācijas polinoms:\n  '); % fprintf('\n Atbilde. \n  Ņūtona %.0f. kārtas interpolācijas polinoms:\n  ', n);
   for i = 1:m
      if koef(i) < 0
         fprintf(' %.6gx^%d', koef(i), n);
      else
         fprintf(' +%.6gx^%d', koef(i), n);
      end
      n = n-1;
   end
   fprintf('\n')
end
