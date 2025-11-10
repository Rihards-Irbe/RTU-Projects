clc, clearvars, close all, format short

xpoints = [-1.0 -0.49 0 0.51 0.98 1.51 1.99 2.49 3.01]';
ypoints = [-0.98 0.48 1.98 3.51 4.99 6.49 7.98 9.51 10.99]';

figure
plot(xpoints, ypoints, 'or', 'LineWidth', 3)
grid on, title('Datu punkti')

max_karta = 4;
adj  = zeros(1, max_karta);
rmse = zeros(1, max_karta);

for n = 1:max_karta
    poly_value = sprintf('poly%d', n);
    [p, reg] = fit(xpoints, ypoints, poly_value)

    p = polyfit(xpoints, ypoints, n);
    xx = linspace(min(xpoints), max(xpoints), 1000);
    yapprox = polyval(p, xx);

    figure
    plot(xpoints, ypoints, 'or', xx, yapprox, 'k', 'LineWidth', 3)
    legend('data', 'fitted curve'), grid on
    title(sprintf('Aproksimācija ar %d kārtas polinomu', n))

    fun_prob1(p);

    adj(n)  = reg.adjrsquare;
    rmse(n) = reg.rmse;
end


[~, order] = sortrows([-adj(:), rmse(:)]);
best_n = order(1);

fprintf('\n Vislabākā aproksimācija ir %d. kārtas polinoms ',best_n)

function fun_prob1(koef)
 m = length(koef); n = m-1;
 fprintf('\n Atbilde. %.0f. kārtas polinoms: \n ', n)
 for i = 1:m
   if koef(i) < 0, fprintf(' %.4fx^%.0f', koef(i), n);
   else,            fprintf(' +%.4fx^%.0f', koef(i), n);
   end
   n = n-1;
 end
 fprintf('\n')
end
