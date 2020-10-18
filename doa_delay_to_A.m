function A = doa_delay_to_A(omega, tau, f, array_type, N)
%UNTITLED15 Summary of this function goes here
%   Detailed explanation goes here
arguments
    omega (:,2)
    tau (:,1)
    f (:,1)
    array_type (1,1) string
    N (1,1) = 3
end
assert(size(omega,1)==size(tau,1));

switch array_type
    case "em32"
        V = em32_steering_matrix(omega, f);
    case "anm"
        V = conj(shmat(N, omega, true, true)); % Q x K
end
E = exp(-1i*2*pi*f*tau.'); % F x K
A = V .* permute(E, [3, 2, 1]);

end

