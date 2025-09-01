%1. Darbibas ar matricam
A = [4,2,-1,-3;1,3,1,2;3,4,-2,1;5,-2,2,3]; % Seit define matricu vertibas (x_1, y_1, z_1, d_1)
B = [9;-10;-15;3]; % Seit tiek definetas matricas atrisinajumu vertibas: (x_1, y_1, z_1, d_1 | ;x, y, z, d;)
[row,col] = size(A); %row, col vertibas matlab saglabajas sadi, var ari:
%{
values = size(A);
row = values(1);
col = values(2);
disp("row value: ");
disp(row);
disp("col value: ");
disp(col);
%}

Aaug = [A B]; % vnk pievieno matricai A B matricu gala, no (x_1, y_1, z_1, d_1) uz (x_1, y_1, z_1, d_1 x)
A_rank = rank(A); % rank(A) aprekina matricas rangu so izmanto, lai noteiktu cik atrisinajumi ir sim linearajam vienadojumam
Aaug_rank = rank(Aaug); % tiesi tas pats, tikai ar matricu, kurai ir pievienots x, y, z, d
sol = rref(Aaug); % sis izpilda visas nepieciesamas darbibas, lai nonaktu pie gausa metodes gala matricu, kur pedejas kolonnas vertibas ir sis sistemas atrisinajums (x, y, z ,d vertibas).

%2. atbilzu/masivu vertibu iestatisana un izprintesana tabulas forma
solution_variables = ['x'; 'y'; 'z'; 'd'];
%solution_answers = sol(:, col+1); -- Isaks variants, ka itiret cauri atbildem un saglabat gausa medodes pedejas vertibas
solution_answers = zeros(col,1); %zeros inicializes masivu un sapildis to ar 0, tas izskatas sadi [x = 0, y = 0, z = 0, d = 0];
for i = 1:col
    solution_answers(i) = sol(i, col+1); %masivam pievieno atbildes vertibas sol(current iteracija, col{4} + 1, jo x_1, y_1, z_1, d_1 | atb un vjg iegut atb vertibu.
end
disp('atbilzu tabula: ');
solution = table(solution_variables, solution_answers);
disp(solution);