function Y = shmat(N, omega, is_complex, transpose_flag)
% Author: Tom Shlomo, 2020
arguments
    N (1,1) double
    omega (:,2) double % should be [theta, phi], both in radians.
    is_complex (1,1) logical = true
    transpose_flag (1,1) logical = false
end

assert(is_complex, "Sorry, real SH are not implemented (yet)");
G = size(omega, 1);
Q = (N+1)^2;

cos_th = cos(omega(:,1));
if ~transpose_flag
    Y = zeros(G, Q);
    phase_m_positive = [ones(G, 1), exp(1i * (1 : N) .* omega(:, 2))] / sqrt(2 * pi);
    % the sqrt(2*pi) is due to our normalization stadard.
    phase_m_negative = conj(phase_m_positive(:, end : -1 : 2));
%     phase_m_negative(1:2:end) = -phase_m_negative(1:2:end);
    phase_m_positive(:, 2 : 2 : end) = -phase_m_positive(:, 2 : 2 : end);
else
    Y = zeros(Q, G);
    phase_m_positive = [ones(1, G); exp(1i * (1 : N).' .* omega(:, 2).')] / sqrt(2 * pi);
    phase_m_negative = conj(phase_m_positive(end : -1 : 2, :));
    phase_m_positive(2 : 2 : end, :) = -phase_m_positive(2 : 2 : end, :);
end
[n_vec, ~] = i2nm(1:Q);

for n=0:N
    v = legendre(n, cos_th, "norm"); % n+1 x G
    v = v([end : -1 : 1, 2 : end], :);
    if ~transpose_flag
        v = v.'; % G x n+1
        phase = [phase_m_negative(:, end - n + 1 : end), phase_m_positive(:, 1 : n + 1)];
        Y(:, n_vec == n) = v .* phase;
    else
        phase = [phase_m_negative(end - n + 1 : end, :); phase_m_positive(1 : n + 1, :)];
        Y(n_vec == n, :) = v .* phase;
    end
end


end
