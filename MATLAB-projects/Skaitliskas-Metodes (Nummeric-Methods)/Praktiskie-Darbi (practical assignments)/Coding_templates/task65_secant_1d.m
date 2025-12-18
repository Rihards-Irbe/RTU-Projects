clc, clearvars, format compact, close all, format longG

f = 0.3*e^(x) + 0.2*x^2 = 4*x + 8;

plot_xmin = 0;
plot_xmax = 2;
plot_ymin = -4;
plot_ymax = 4;
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

x0 = 1;
x1 = 1.5;

% allow user to enter scalars or vectors (multiple roots)
x0 = x0(:).';
x1 = x1(:).';

if numel(x0) ~= numel(x1)
    error('Sekanšu metode: x0 un x1 vektoru garumiem jābūt vienādiem.');
end

n_roots  = numel(x0);
xapp_val = zeros(1, n_roots);

for j = 1:n_roots
    xnm1 = x0(j);   % x_{n-1}
    xn   = x1(j);   % x_n

    for k = 1:iter
        f_n   = f(xn);
        f_nm1 = f(xnm1);

        den = (f_n - f_nm1);
        if den == 0
            error('Sekanšu metode: dalījums ar 0 (f(x_n)-f(x_{n-1}) = 0). Maini x0/x1.');
        end

        xnp1 = xn - f_n * (xn - xnm1) / den;

        xnm1 = xn;
        xn   = xnp1;

        if abs(f(xn)) < epsi
            break
        end
    end

    xapp_val(j) = xn;
end

xapp_val = sort(xapp_val);

min_root = min(xapp_val);
max_root = max(xapp_val);

fprintf('Vismazākā sakne: %.4f\n', min_root);
fprintf('Vislielākā sakne: %.4f\n', max_root);


p = max(0, round(-log10(epsi)));

fprintf('Atbilde. Sekanšu metode: vienādojumam ir %d saknes\n', n_roots)

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
