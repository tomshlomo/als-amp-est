function V = em32_steering_matrix(doa, f)
arguments
    doa (:, 2)
    f (:, 1)
end

[omega_mic(:,1), omega_mic(:,2), ~, r] = sampling_schemes.em32();
Q = size(omega_mic, 1);
K = size(doa, 1);
J = length(f);
c = soundspeed();
kr = 2*pi*f*r(1)/c;
N = ceil(max(kr))+3;
Yh_doa = conj(shmat(N, doa, true, true));
Y_mic = shmat(N, omega_mic, true, false);
V = zeros(Q, K, J);
for j=1:J
    b = bn(N, kr(j), "directionInterpertation", "doa", ...
        "outputForm", "vecduplicated", ...
        "sphereType", "rigid").';
    V(:,:,j) = Y_mic * (b .* Yh_doa);
end

end

