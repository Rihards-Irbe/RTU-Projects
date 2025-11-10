clc, clearvars, close all, format short

xpoints = [0 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0]';
ypoints = [20.00 51.58 68.73 75.46 74.36 67.09 54.73 37.98 17.28]';

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
