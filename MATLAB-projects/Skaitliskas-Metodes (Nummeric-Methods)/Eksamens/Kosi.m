clc, clearvars, format compact, close all


%% example: Atrisināt košī problēmu: <equation>, y(2) = 4 intervālā [2,6]. Aprēķināt y(3.11) ar precizitāti epsilon = 0.0001.
x_int = [2 6];  % intervālā [2,6]
y0 = 4;         % y(2) = 4
% y0 = [4; 5; 8];  % [y(1); y'(1); y''(1)] -- (y(1)=4, y'(1)=5, y''(1)=8)
options = odeset('RelTol',1e-5,'AbsTol',1e-8);  % precizitāti ε = 0.0001

sol = ode45(@fun_prob4, x_int, y0, options);
sol_x = sol.x';
sol_y = sol.y(1,:)';

x = (2:0.01:6);  % Punktu skaits: x = [2.00, 2.01, 2.02, 2.03, ..., 5.98, 5.99, 6.00]
y = deval(sol, x);

y_value = deval(sol, 3.11);  % y(<value>), šinī piemērā aprēķināt y(3.11)
%y_value = deval(sol, 3.72, 3); y'' ir 3 komponente
fprintf('y(3.11) = %.4f\n', y_value);

function dydx = fun_prob4(x,y)
      dydx = -(atan(x + 1) + y.*(log(x) + ((x + 2)./(x.^2 + 4)).^(1./3)))./(cos(x) + (x.^2 + 1).^(1./2));
end

%% cits example: Atrisināt Košī problēmu: <equation>, y(1) = 4, y'(1) = 5, y'''(1) = 8 intervālā [1,7]. Aprēķināt y"(3.72) ar precizitāti epsilon = 0.0001.

x_int = [1 7];
y0 = [4; 5; 8];
options = odeset('RelTol',1e-5,'AbsTol',1e-8);  % precizitāti ε = 0.0001

sol = ode45(@fun_prob8, x_int, y0, options);
sol_x = sol.x';
sol_y = sol.y(1,:)';

x = (1:0.01:7);
y = deval(sol, x);

y_value = deval(sol, 3.72, 3);
fprintf('y"(3.72) = %.4f\n', y_value);

function dy_dx = fun_prob8(x,y)
   dy_dx = zeros(3,1);
   dy_dx(1) = y(2);
   dy_dx(2) = y(3);
   dy_dx(3) = sin(x) - y(1).*log(x.^2 + 2) - y(2).*(x + x.^3 + 1).^(1./2) - y(3).*(atan(x) + 3);
end