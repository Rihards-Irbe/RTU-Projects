clc, clearvars, format compact
A =[
    1, 4, 7, -1, 5;
    8, 2, -3, 4, 10;
    6, 12, -2, 7, 4;
    3, -4, 9, 0, 11;
    5, 6, -4, 2, 8
    ];

n = length(A(1, :));
x_app = ones(n,1); e_mas(:,1) = x_app/norm(x_app);
x_app(:,2) = A*e_mas; e_mas(:,2) = x_app(:,2)/norm(x_app(:,2));
k = 2; epsi = 10^(-3); iter_max = 20; k_iter = 0;
while norm(e_mas(:,k)-e_mas(:,k-1)) > epsi && k <= iter_max
 x_app(:,k+1) = A*e_mas(:,k);
 e_mas(:,k+1) = x_app(:,k+1)/norm(x_app(:,k+1));
 k_iter = k_iter+1; lambda = dot( x_app(:,k+1)',e_mas(:,k));
 x_pr = x_app(:,k+1); e_pr = e_mas(:,k+1);
 k = k+1;
end

k_iter, lambda
eig_val_maxv = eigs(A,1)

disp('Atbilde:')
disp([' iterāciju skaits = ' num2str(k_iter) ])
disp([' lielākā īpašvērtība = ' num2str(lambda) '( ar prec. ' num2str(epsi) ')'])