function p = anm2p(anm, fs, r, omega_q, sphereType, isComplexSH)
arguments
    anm (:,:) double
    fs (1,1) double
    r (1,1) double
    omega_q (:,2) double
    sphereType (1,1) string {mustBeMember(sphereType, ["open", "rigid"])}
    isComplexSH (1,1) logical = true
end
%%
N = sqrt(size(anm,2))-1;

%% pad with zeros to reduce time aliasing
c = soundspeed();
pad = ceil(r/c * fs * 100); % r/c*100 is just a bound on the length of the impulse response of the system from anm to p.
anm(end+1:end+1+pad, :) = 0; 

%% FFT
% todo: implement anm2p as a MIMO filter, not by sampling in the frequency
% domain (to reduce distrtion due to aliasing)

NFFT = 2^nextpow2(size(anm,1));
Anm = fft(anm, NFFT, 1);

% remove negative frequencies
Anm(NFFT/2+1:end,:)=[];

% frequency vector
f = (0 : (size(Anm,1) - 1))'*(fs/NFFT);

%% transformation to P
kr = r*2*pi*f/c;
b = bn(N, kr, "sphereType", sphereType);
Pnm = b.*Anm;
Yt = shmat(N, omega_q, isComplexSH, true);
P = Pnm*Yt;

%% IFFT

% pad negative frequencies with zeros (has no effect since we use ifft with
% "symmetric" flag
P(end+1:NFFT, :) = 0;

p = ifft(P, "symmetric");

% trim to size before power of 2 padding
p(size(anm,1)+1:end,:) = [];

end

