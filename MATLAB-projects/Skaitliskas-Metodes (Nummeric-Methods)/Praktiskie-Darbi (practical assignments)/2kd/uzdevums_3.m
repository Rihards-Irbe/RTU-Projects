clc, clearvars, close all, format short

f = @(x) x.^3 .* sqrt(cos(x) + x);

xnodes = 3:1:8; %intervālā [3;8] un solis ir pa vidu, šinī uzdevumā 1
ynodes = f(xnodes);

x0 = 6.5;
int_res = interp1(xnodes, ynodes, x0, 'spline') % atbilde uz 1) Atrast interpolācijas rezultātu punktā x_0 = 6.5
f_res   = f(x0)
int_error = abs(int_res - f_res) %atbilde uz 3) 

x1 = 6;
int_res_2 = interp1(xnodes, ynodes, x1, 'spline');
int_error_2 = abs(int_res_2 - f(x1)); % atbilde uz 4) Kāda ir interpolācijas kļūda punktā x_1 = 6 jābūt ~0, jo mezgls)

pp = spline(xnodes, ynodes);
r  = find(pp.breaks <= x0, 1, 'last');
if r == numel(pp.breaks), r = r-1; end
c = pp.coefs(r,:);

coef_cubic_local = c(1);

syms x
b = pp.breaks(r);
poly_local = c(1)*(x-b)^3 + c(2)*(x-b)^2 + c(3)*(x-b) + c(4); % atbilde uz 2) prob formula, kur ja vjg 3 pakāpi, tāpēc sākās ar c(1)*(x-b)^n pakāpe un iet otrādi
poly_global(x) = expand(poly_local);
coefpoly_global = sym2poly(poly_global);
coef_x3_global  = coefpoly_global(1);

fprintf('\nAtbilde (kubiskais splains):\n');
fprintf('1) interpolācijas rezultāts punktā (6.5) = %.4f\n', int_res);
fprintf('2) interpolācijas kļūda punktā (6.5) = %.5f\n', int_error);
fprintf('3) interpolācijas kļūda punktā (6) = %.f,\n', int_error_2);
fprintf('tā kā punkts x=6 ir interpolācijas mezgla punkts\n');