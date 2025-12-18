%% Koši problēma (1. kārtas ODE) ar ode45
clc; clearvars; close all; format compact

% ===== Inputs from template fields =====
xspan = [1 3];   % interval [x0 x1]
y0    = 2;              % y(x0)
xq    = 1.95;              % query point
epsi  = 0.0001;            % target accuracy (used for tolerances)
target_var = "y"; % "y" or "yp"
ndp   = 4;             % digits after decimal

% ODE must be written using symbols: x, y, yp
% Example:  yp - y*exp(-y) = sin(x + y)
syms x y yp
eq = str2sym("(yp - y*exp(-y))-(sin(x+y))");        % zero-form expression == 0

yp_sym = solve(eq, yp);
if isempty(yp_sym)
    error("Could not solve the ODE for yp. Make sure ode_eq contains yp (y') and is solvable for it.");
end
rhs = yp_sym(1);
rhs_fn = matlabFunction(rhs, 'Vars', [x, y]);

% ode45 tolerances derived from epsi
rt = max(1e-12, epsi/100);
at = max(1e-12, epsi/1000);
opts = odeset('RelTol', rt, 'AbsTol', at);

sol = ode45(@(xv,yv) rhs_fn(xv,yv), xspan, y0, opts);

yq = deval(sol, xq);
yq = yq(1);

tv = lower(strtrim(string(target_var)));
if tv == "y"
    fprintf("y(%.6g) = %.*f\n", xq, ndp, yq);
elseif tv == "yp" || tv == "y'" || tv == "yprime"
    ypval = rhs_fn(xq, yq);
    fprintf("y'(%.6g) = %.*f\n", xq, ndp, ypval);
else
    error("target_var must be 'y' or 'yp'. Got: %s", target_var);
end
