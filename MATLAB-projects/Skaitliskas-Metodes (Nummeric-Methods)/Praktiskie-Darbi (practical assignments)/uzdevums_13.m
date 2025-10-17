clc, clearvars, format compact
A = [
    16, 3, 4, 2;
    3, 12 , 2, -1;
    4, 2, 8, -1;
    2, -1, -1, 2
    ];

B = [25;16;13;2];

if det(A) == 0
 disp('Matrica A ir singulāra')
 disp('Atbilde: minimālo nesaistes metodi nedrīkst izmantot')
 return
end
disp('Matrica A ir nesingulāra')

ni = fun_prob10(A); % pārbaude, vai matrica ir pozitīvi definēta
if ni == 2
 disp('Koeficientu matrica nav pozitīvi definēta')
 disp('Atbilde: minimālo nesaistes metodi nedrīkst izmantot')
 return
end
check=isequal(A,A');
if check==0
 disp('Koeficientu matrica nav simetriska')
 disp('Atbilde: minimālo nesaistes metodi nedrīkst izmantot')
 return
end
disp('Koeficientu matrica ir simetriska un pozitīvi definēta ')

% 2.10. piemēra turpinājums
n = length(B);
k_iter = 0; epsi = 10^(-3);itermax =300;
x_app=zeros(n,1);
r = A*x_app-B; norm_r = norm(r);
while norm_r > epsi && k_iter < itermax
 k_iter =k_iter+1;
 tau = ((A*r)'*r)/norm(A*r)^2;
 x_app = x_app-(tau*r')';r = A*x_app-B; norm_r = norm(r);
end
k_iter,tau, x_app, norm_r
x_sol = linsolve(A,B)

disp('Atbilde:')
fprintf(' iter. skaits = %.f, nesaistes norma = %.8f\n', k_iter,norm_r)
disp([' x_tuvinājumi: {' num2str(x_app(:)') '}'])

%% ārēja funkcija(2.10. piemērs.) Minimālās nesaistes metode
% pārbaude: vai matrica ir pozitīvi definēta
function ni = fun_prob10(A_mat)
 ni = 1;
 [row,col] = size(A_mat);
 for i = 1:row
 if det(A_mat(1:i,1:i))>0
 else ni = 2; break
 end
 end
end