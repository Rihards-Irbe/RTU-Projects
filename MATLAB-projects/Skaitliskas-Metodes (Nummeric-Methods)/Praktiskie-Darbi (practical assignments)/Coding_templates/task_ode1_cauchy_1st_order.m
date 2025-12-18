%% Koši problēma (1. kārtas ODE) ar ode45
clc; clearvars; close all; format compact

% ===== Inputs from template fields =====
xspan = [1 3];     % [x0 x1]
y0    = 2;                % y(x0)
xq    = 1.95;                % query point
epsi  = 0.0001;              % target accuracy (tolerances)
target_var = "yp"; % "y" or "yp"
ndp   = 4;               % digits after decimal

% ODE must use symbols: x, y, yp
% Example input:  yp - y*e^-y = sin(x+y)
syms x y yp

% (yp - y*exp(-y))-(sin(x + y)) converts:
%   lhs=rhs -> (lhs)-(rhs)
%   ln(..)->log(..)
%   e^(..)/e^a -> exp(..)/exp(a)
eq = str2sym("(yp - y*exp(-y))-(sin(x + y))");

% Solve for yp (i.e., y')
yp_sym = solve(eq, yp);
if isempty(yp_sym)
    error("Could not solve the ODE for yp. Make sure ode_eq contains yp and is solvable for it.");
end
yp_sym = yp_sym(1);

% Numeric RHS: yp = f(x,y)
yp_fn = matlabFunction(yp_sym, 'Vars', [x, y]);

% ode45 tolerances derived from epsi
rt = max(1e-12, epsi/100);
at = max(1e-12, epsi/1000);
opts = odeset('RelTol', rt, 'AbsTol', at);

ode = @(xv, yv) yp_fn(xv, yv);

sol = ode45(ode, xspan, y0(:), opts);

% Evaluate y(xq) then compute y'(xq) from the ODE itself
yq  = deval(sol, xq);
ypq = yp_fn(xq, yq(1));

tv = lower(strtrim(target_var));
if tv == "y"
    fprintf("y(%.6g) = %.*f\n", xq, ndp, yq(1));
elseif tv == "yp" || tv == "y'" || tv == "yprime"
    fprintf("y'(%.6g) = %.*f\n", xq, ndp, ypq);
else
    error("target_var must be 'y' or 'yp'. Got: %s", target_var);
end
