function out = auto_guess_sys2d_area(eq1, eq2, x1_area, x2_area, hscan)
% Autofill: finds a reasonable start xapp inside the given area strings.

    eq1 = string(eq1); eq2 = string(eq2);
    x1_area = string(x1_area); x2_area = string(x2_area);

    b = code_helpers("sys2d_area_bounds", x1_area, x2_area);
    x1min = b(1); x1max = b(2); x2min = b(3); x2max = b(4);

    h = double(hscan);
    if ~isfinite(h) || h <= 0, h = 0.05; end

    e1 = code_helpers("to_zero_form", eq1);
    e2 = code_helpers("to_zero_form", eq2);

    e1m = code_helpers("make_matlab_expr", e1);
    e2m = code_helpers("make_matlab_expr", e2);

    % local sqrt_power so numeric expression can evaluate
    sqrt_power = @(x,n) x.^(1/n); %#ok<NASGU>

    f1 = str2func(char("@(x1,x2) " + string(e1m)));
    f2 = str2func(char("@(x1,x2) " + string(e2m)));

    x1v = x1min:h:x1max;
    x2v = x2min:h:x2max;
    if numel(x1v) < 2, x1v = linspace(x1min, x1max, 201); end
    if numel(x2v) < 2, x2v = linspace(x2min, x2max, 201); end

    [X1, X2] = meshgrid(x1v, x2v);
    F1 = f1(X1, X2);
    F2 = f2(X1, X2);

    score = abs(F1) + abs(F2);
    score(~isfinite(score)) = inf;

    [~, idx] = min(score(:));
    out = struct("xapp", [X1(idx), X2(idx)]);
end
