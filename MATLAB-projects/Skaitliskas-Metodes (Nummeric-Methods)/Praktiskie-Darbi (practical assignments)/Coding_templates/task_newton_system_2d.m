%% Ņūtona metode — 2D sistēma
clc, clearvars, format compact, close all, format longG

% ---- System definition ----
syms x1 x2
xpr = [x1 x2];

fun1 = sin(3*x2-2)-4*x1+5;
fun2 = 2*x2-cos(x1+4)-7;

fun    = [fun1; fun2];
fun_pr = jacobian(fun, xpr);

% Numeric handles (for plot feature)
f1 = matlabFunction(fun1, 'Vars', xpr);
f2 = matlabFunction(fun2, 'Vars', xpr);

% ---- Apgabals (inequality input) ----
x1_area = "0<=x1<=5";
x2_area = "0<=x2<=5";

b = code_helpers('sys2d_area_bounds', x1_area, x2_area);
x1min = b(1); x1max = b(2);
x2min = b(3); x2max = b(4);



% ---- Newton iteration (book style) ----
xapp = [1.28 3.76];
xapp = xapp(:).';  % force row [x1 x2]

iter = 50;
epsi = 1e-07;

k = 0;
sol_norm = 1;
M_pr = zeros(iter, 3);   % [x1 x2 norm]

while sol_norm > epsi && k < iter
    for i = 1:2
        B(i,1) = -double(subs(fun(i), [x1 x2], xapp));
        for j = 1:2
            A(i,j) = double(subs(fun_pr(i,j), [x1 x2], xapp));
        end
    end

    xdelta = A \ B;          % 2x1
    xapp   = xapp + xdelta.'; % keep row

    c = double(subs(fun, [x1 x2], xapp));
    sol_norm = norm(c);

    k = k + 1;
    M_pr(k,1:2) = xapp;
    M_pr(k,3)   = sol_norm;
end

M_pr = M_pr(1:k,:);

disp('          x1                    x2                  kļūdas norma')
disp(M_pr)

% ---- Output: chosen variable ----
target_var  = "x1";
find_digits = 3;

if ~ismember(target_var, ["x1","x2"])
    error('target_var must be "x1" or "x2". Got: %s', target_var);
end

idx = 1;
if target_var == "x2", idx = 2; end

fmt = sprintf('%%.%df', find_digits);
fprintf('%s = %s\n', target_var, sprintf(fmt, xapp(idx)));


format
