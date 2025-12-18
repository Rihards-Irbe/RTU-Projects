%% Koši problēma (2. kārtas ODE) ar ode45
clc; clearvars; close all; format compact

% ===== Inputs from template fields =====
xspan = [3 8];          % [x0 x1]
yinit = [2; 11];        % [y(x0); y'(x0)]
xq    = 7.46;                      % query point
epsi  = 0.0001;                    % target accuracy (used to set tolerances)
target_var = "yp";       % "y" | "yp" | "ypp"
ndp   = 4;                     % digits after decimal

% ODE must be written using symbols: x, y, yp, ypp
% You MAY type:
%   ln(x)   (will be converted to log(x))
%   e^...   (will be converted to exp(...)), e.g. e^-y -> exp(-y)
syms x y yp ypp

ode_expr = ((9 + x^2*log(x))*ypp - (3 + x*sqrt(x))*yp + x*y)-(sin(x + 4));              % zero-form expression (LHS-RHS)

ypp_sym = solve(ode_expr, ypp);

if isempty(ypp_sym)
    error("Could not solve the ODE for ypp. Ensure ode_eq contains ypp and is solvable for it.");
end
ypp_sym = ypp_sym(1);

ypp_fn = matlabFunction(ypp_sym, 'Vars', [x, y, yp]);

% ode45 tolerances derived from epsi
rt = max(1e-12, epsi/100);
at = max(1e-12, epsi/1000);
opts = odeset('RelTol', rt, 'AbsTol', at);

ode = @(xv, Y) [ ...
    Y(2); ...
    ypp_fn(xv, Y(1), Y(2)) ...
];

sol = ode45(ode, xspan, yinit, opts);

Yq = deval(sol, xq);
yq  = Yq(1);
ypq = Yq(2);
yppq = ypp_fn(xq, yq, ypq);

tv = lower(strtrim(string(target_var)));
switch tv
    case "y"
        fprintf("y(%.6g) = %.*f\n", xq, ndp, yq);
    case {"yp","y'","yprime"}
        fprintf("y'(%.6g) = %.*f\n", xq, ndp, ypq);
    case {"ypp","y''","ypp"}
        fprintf("y''(%.6g) = %.*f\n", xq, ndp, yppq);
    otherwise
        error("target_var must be 'y', 'yp' or 'ypp'. Got: %s", string(target_var));
end
