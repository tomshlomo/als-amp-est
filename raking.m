function [s, s_error] = raking(H, P, x, opts)
arguments
    H (:,:,:) double
    P (:,:) double
    x (:,1) double
    opts.s_exp = [];
    opts.verbose = false;
end
%UNTITLED18 Summary of this function goes here
%   Detailed explanation goes here
Q = size(H,1);
K = size(H,2);
F = size(H,3);
assert(isequal(size(P), [Q, F]));
assert(isequal(size(x), [K, 1]));

s = zeros(F,1);
for f=1:F
    s(f) = (H(:,:,f)*x)\P(:,f);
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

