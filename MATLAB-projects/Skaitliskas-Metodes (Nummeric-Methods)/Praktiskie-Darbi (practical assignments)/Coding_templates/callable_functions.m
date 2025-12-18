function out = callable_functions(action, varargin)
% CALLABLE_FUNCTIONS  Whitelist + dispatcher for autofill functions.
%
% Supported:
%   callable_functions('list')               -> string array of names
%   callable_functions('exists', fn)         -> logical
%   callable_functions('call', fn, args...)  -> returns STRUCT with fields of provided outputs
%
% IMPORTANT:
% - Always returns a STRUCT from 'call' so code_generator can map provides safely.
% - Implements auto_guess_sys2d (NEW+OLD signatures) so it does NOT need to exist as a separate top-level function.

action = lower(string(action));

switch action
    case "list"
        out = [
            "auto_roots_1d"
            "auto_guess_sys2d"
        ];

    case "exists"
        fn = string(varargin{1});
        out = any(callable_functions("list") == fn);

    case "call"
        fn = string(varargin{1});
        args = varargin(2:end);

        if ~callable_functions("exists", fn)
            error("Autofill function not registered: %s", fn);
        end

        switch fn
            case "auto_roots_1d"
                % args: (eq, xmin, xmax, h)
                [x_app, n_roots] = local_auto_roots_1d(args{:});
                out = struct('x_app', x_app, 'n_roots', n_roots);

            case "auto_guess_sys2d"
                % args: (eq1, eq2, ...bounds..., hscan)
                xapp = local_auto_guess_sys2d(args{:});
                out = struct('xapp', xapp);

            otherwise
                error("Autofill function registered but not implemented: %s", fn);
        end

    otherwise
        error("callable_functions: Unknown action '%s'", action);
end
end

% ======================================================================
% AUTO: 1D roots guesses (sign change grid)
% ======================================================================

function [x_app, n_roots] = local_auto_roots_1d(eq_raw, xmin, xmax, h)
eq_raw = string(eq_raw);
xmin = double(xmin); xmax = double(xmax); h = double(h);

if ~(isfinite(xmin) && isfinite(xmax) && isfinite(h)) || h <= 0 || xmax <= xmin
    error("auto_roots_1d: invalid scan settings xmin=%g xmax=%g h=%g.", xmin, xmax, h);
end

% zero-form + numeric vectorized expr
f0   = code_helpers("to_zero_form", eq_raw);
expr = string(code_helpers("make_matlab_expr", f0));   % already element-wise
fh   = str2func("@(x) " + expr);

xg = xmin:h:xmax;
yg = fh(xg);
yg(~isfinite(yg)) = NaN;

y1 = yg(1:end-1);
y2 = yg(2:end);

ok  = isfinite(y1) & isfinite(y2);
idx = find(ok & (y1 .* y2 < 0));

mids = (xg(idx) + xg(idx+1)) / 2;

zidx = find(isfinite(yg) & abs(yg) < 1e-10);
zpts = xg(zidx);

x_app = [mids(:); zpts(:)].';
x_app = round(x_app * 10) / 10;
x_app = unique(x_app, 'stable');

n_roots = numel(x_app);
if n_roots == 0
    error("auto_roots_1d found 0 roots in [%g,%g] with h=%g.", xmin, xmax, h);
end
end

% ======================================================================
% AUTO: 2D start guess (grid minimum of |f1|+|f2|)
% Supports BOTH signatures:
%   NEW: auto_guess_sys2d(eq1, eq2, x1_area, x2_area, hscan)
%        x1_area like "-1<=x1<=4"
%        x2_area like "-3<=x2<=2"
%   OLD: auto_guess_sys2d(eq1, eq2, x1min, x1max, x2min, x2max, hscan)
% Returns: xapp row [x1 x2]
% ======================================================================

function xapp = local_auto_guess_sys2d(eq1, eq2, varargin)
eq1 = string(eq1); eq2 = string(eq2);

if numel(varargin) == 3
    % NEW: (x1_area, x2_area, hscan)
    x1_area = string(varargin{1});
    x2_area = string(varargin{2});
    hscan   = double(varargin{3});

    [x1min, x1max] = local_parse_area_bounds(x1_area, "x1");
    [x2min, x2max] = local_parse_area_bounds(x2_area, "x2");

elseif numel(varargin) == 5
    % OLD: (x1min, x1max, x2min, x2max, hscan)
    x1min = double(varargin{1});
    x1max = double(varargin{2});
    x2min = double(varargin{3});
    x2max = double(varargin{4});
    hscan = double(varargin{5});

else
    error("auto_guess_sys2d: expected NEW (5 total args) or OLD (7 total args). Got %d total.", 2 + numel(varargin));
end

if ~isfinite(hscan) || hscan <= 0
    hscan = 0.05;
end

if x1min > x1max, t=x1min; x1min=x1max; x1max=t; end
if x2min > x2max, t=x2min; x2min=x2max; x2max=t; end

% numeric handles (vectorized)
f1 = local_make_fn2(eq1);
f2 = local_make_fn2(eq2);

% grid size (bounded)
nx = round((x1max - x1min)/hscan) + 1;
ny = round((x2max - x2min)/hscan) + 1;
nx = max(51, min(401, nx));
ny = max(51, min(401, ny));

x1_range = linspace(x1min, x1max, nx);
x2_range = linspace(x2min, x2max, ny);
[X1, X2] = meshgrid(x1_range, x2_range);

F1 = f1(X1, X2);
F2 = f2(X1, X2);

score = abs(F1) + abs(F2);
score(~isfinite(score)) = inf;

[~, idx] = min(score(:));
xapp = [X1(idx), X2(idx)];
end

function fh = local_make_fn2(eq)
% Converts "something=0" or "lhs=rhs" into numeric vectorized @(x1,x2) ...
s = string(eq);
s = strtrim(s);

% to zero-form if '=' present
if contains(s, "=")
    parts = split(s, "=");
    if numel(parts) >= 2
        lhs = strtrim(parts(1));
        rhs = strtrim(parts(2));
        s = "(" + lhs + ")-(" + rhs + ")";
    end
end

% normalize
s = replace(s, "ln(", "log(");
s = replace(s, "arctg", "atan");

% element-wise ops
ss = char(s);
ss = regexprep(ss, '(?<!\.)\^', '.^');
ss = regexprep(ss, '(?<!\.)\*', '.*');
ss = regexprep(ss, '(?<!\.)/',  './');

fh = str2func(['@(x1,x2) ' ss]);
end

function [mn, mx] = local_parse_area_bounds(s, varname)
% Accepts "-1<=x1<=4", "-1<x1<=4", etc. Also tolerates spaces and unicode ≤ ≥.
s = string(s);
s = strtrim(s);
s = replace(s, "≤", "<=");
s = replace(s, "≥", ">=");
s = regexprep(s, "\s+", "");

num = "([+-]?\d*\.?\d+(?:[eE][+-]?\d+)?)";
op  = "(<=|<|>=|>)";
pat = "^" + num + op + varname + op + num + "$";

tok = regexp(char(s), char(pat), "tokens", "once");
if isempty(tok)
    error("Bad area format for %s: '%s'. Expected like -1<=%s<=4", varname, char(s), varname);
end

a = str2double(tok{1});
b = str2double(tok{4});
if ~isfinite(a) || ~isfinite(b)
    error("Area bounds must be numeric: '%s'.", char(s));
end

mn = min(a,b);
mx = max(a,b);
end
