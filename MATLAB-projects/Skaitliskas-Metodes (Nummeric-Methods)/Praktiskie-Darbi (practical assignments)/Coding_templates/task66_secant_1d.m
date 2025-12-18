%% Generated from template: task66_secant_1d
%% 6.6 — Sekantu metode (1D)
%% 18-Dec-2025 03:05:07

clc, clearvars, format compact, close all, format longG

f = @(x) x.^3-2.*x-5;

plot_xmin = 2;
plot_xmax = 10;
plot_ymin = -40;
plot_ymax = 5;
h         = 0.01;

figure
x_pr = plot_xmin:h:plot_xmax;
plot(x_pr, f(x_pr), 'r', 'LineWidth', 3), grid on
title('Funkcijas f(x) grafiks')
xlabel('x'), ylabel('f(x)')
xlim([plot_xmin plot_xmax])
ylim([plot_ymin plot_ymax])
hold on
plot([plot_xmin plot_xmax], [0 0], 'k--')
hold off


iter = 6;
epsi = 0.0001;

x0 = 1.5;
x1 = 2.5;

% allow user to enter scalars or vectors
x0 = x0(:).';
x1 = x1(:).';

if numel(x0) ~= numel(x1)
    error('Sekantu metode: x0 un x1 vektoru garumiem jābūt vienādiem.');
end

n_roots = numel(x0);
xapp_val = zeros(1, n_roots);

for j = 1:n_roots
    xn = zeros(1, iter+2);
    xn(1) = x0(j);
    xn(2) = x1(j);

    for k = 1:iter
        k_2 = k + 2;
        k_1 = k + 1;

        f1 = f(xn(k_1));
        f0 = f(xn(k));

        den = (f1 - f0);
        if den == 0
            error('Sekantu metode: dalījums ar 0 (f(x_n)-f(x_{n-1}) = 0). Maini x0/x1.');
        end

        xn(k_2) = xn(k_1) - f1 * (xn(k_1) - xn(k)) / den;

        if abs(f(xn(k_2))) < epsi
            break
        end
    end

    xapp_val(j) = xn(k_2);
end

xapp_val = sort(xapp_val);



p = round(-log10(epsi));

if n_roots == 3
    fprintf('Atbilde. Sekantu metode: vienādojumam ir trīs saknes\n')
else
    fprintf('Atbilde. Sekantu metode: vienādojumam ir %d saknes\n', n_roots)
end

fprintf(' ')
for k = 1:n_roots
    if k == 1
        fprintf('x%d = %.4f', k, xapp_val(k));
    else
        fprintf(', x%d = %.4f', k, xapp_val(k));
    end
end
fprintf('\n')
fprintf(' ar precizitāti 10^(-%d)\n', p)
