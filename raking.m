function [s, s_error] = raking(A, P, x, opts)
arguments
    A (:,:,:) double
    P (:,:) double
    x (:,1) double
    opts.s_exp = [];
    opts.verbose = false;
end
%UNTITLED18 Summary of this function goes here
%   Detailed explanation goes here
Q = size(A,1);
K = size(A,2);
F = size(A,3);
assert(isequal(size(P), [Q, F]));
assert(isequal(size(x), [K, 1]));

s = zeros(F,1);
for f=1:F
    s(f) = (A(:,:,f)*x)\P(:,f);
end

if ~isempty(opts.s_exp)
    s_error = scale_invariant_mse(s, opts.s_exp);
else
    s_error = nan;
end

if opts.verbose
    fprintf("s error: %.2f dB\n", 10*log10(s_error));
end

end

