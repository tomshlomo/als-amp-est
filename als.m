function [x, s, residual_norm, x_error, s_error] = als(A, P, opts)
arguments
    A (:,:,:) double
    P (:,:) double
    opts.x_exp = []
    opts.s_exp = []
    opts.max_iters = 10;
    opts.x0;
    opts.real_flag = true;
    opts.plot_flag = false;
    opts.verbose = true
end

Q = size(A,1);
K = size(A,2);
F = size(A,3);
assert(isequal(size(P), [Q, F]));
if opts.verbose; fprintf("F = %d\nK = %d\nQ = %d\n", F, K, Q); end

norm_P = norm(P, "fro");
P = P./norm_P;
x_exp = opts.x_exp;
s_exp = opts.s_exp / norm_P;

x = nan(K, opts.max_iters+1);
x_error = nan(opts.max_iters+1, 1);
s_error = nan(opts.max_iters+1, 1);
residual_norm = nan(opts.max_iters+1, 1);

if isfield(opts, "x0") && ~isempty(opts.x0)
    assert(length(opts.x0)==K);
    x(:,1) = opts.x0;
else
    x(1,1) = 1;
    x(2:end,1) = 0;
end
if ~isempty(x_exp)
    x_error(1) = scale_invariant_mse(x(:,1), x_exp);
    if opts.verbose; fprintf("x error init: %.2f dB\n", 10*log10(x_error(1))); end
end

for i=2:opts.max_iters+1
    verbose = opts.verbose && i==opts.max_iters+1;
    
    %% Estimate s (raking)
    [s, s_error(i)] = raking(A, P, x(:,i-1), "s_exp", s_exp, "verbose", verbose || (opts.verbose && i==2));
    
    %% Estimate x
    [x(:,i), residual_norm(i), x_error(i)] = x_from_A_P_s(A, P, s, "real_flag", opts.real_flag, "verbose", verbose, "x_exp", x_exp);
end

if opts.plot_flag
    figure;
    tiledlayout(2,1);
    nexttile();
    plot(x.', '.-');
    nexttile();
    plot(10*log10([s_error, x_error, residual_norm.^2]));
    legend("s", "x", "residual");
end
end

