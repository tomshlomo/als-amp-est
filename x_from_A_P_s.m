function [x, residual_norm, x_error] = x_from_A_P_s(A, P, s, opts)
%UNTITLED19 Summary of this function goes here
%   Detailed explanation goes here
arguments
    A (:,:,:) double
    P (:,:) double
    s (:,1) double
    opts.x_exp = [];
    opts.real_flag = true;
    opts.verbose = false;
end
Q = size(A,1);
K = size(A,2);
F = size(A,3);
assert(isequal(size(P), [Q, F]));
assert(isequal(size(s), [F, 1]));

As = A .* reshape(s, [1, 1, F]); % [Q, K, F]
As = permute(As, [1, 3, 2]); % [Q, F, K]
As = reshape(As, [], K); % [QF, K];
P = P(:); % [QF, 1];

if opts.real_flag
    x = lsreal(As, P);
else
    x = As\P;
end

residual_norm = norm(P-As*x);

if ~isempty(opts.x_exp)
    x_error = scale_invariant_mse(x, opts.x_exp);
else
    x_error = nan;
end

if opts.verbose
    fprintf("x error: %.2f dB\n", 10*log10(x_error));
    fprintf("residual norm (normalized): %.2f dB\n", 20*(log10(residual_norm) - log10(norm(P))));
end

end

