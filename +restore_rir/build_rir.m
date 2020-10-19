function build_rir(delay, doa, amp, f_c, fs, h_exp)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
arguments
    delay (:,1)
    doa (:,2)
    amp (:,:)
    f_c (1,:)
    fs (1,1) double
    h_exp (:,:) double
end
assert(size(f_c, 2)==size(amp, 2));
assert(size(delay, 1) == size(doa, 1));
assert(size(delay, 1) == size(amp, 1));


N = ceil(0.042*2*pi*fs/2/soundspeed)+1;
extra = 10e-3;
min_delay = 50e-3;
delay = delay - min(delay) + min_delay;
n = round((max(delay) + extra)*fs);
Yh = shmat(N, doa)';
K = size(delay, 1);
amp = [zeros(K, 1), amp, zeros(K, 1)];
f = [0; f_c.' / fs; 1];
hnm = zeros(n+1+ceil(max(delay)*fs), K);
for k=1:K
    b = fir2(n, f, amp(k, :).').'; % .* exp(-1i * 2*pi * f * (delay(k) * fs))).';
    pad = round(delay(k)*fs);
    b = [zeros(pad, 1); b];
    hnm(1:size(b, 1), k) = b;
    
end
hnm = hnm*Yh.';
h = anm2p(hnm, fs, [], [], "em32", true);
T = size(h, 1) + size(h_exp, 1) - 1;
h(end+1:T, :) = 0;
h_exp(end+1:T, :) = 0;
Q = size(h, 2);
c = 0;
for q=1:Q
    [c1, lag] = xcorr(h_exp(:, q), h(:, q), "normalized");
    c = c + c1;
end
figure; plot(lag, abs(c));
[~, i] = max(abs(c));
if lag(i) >= 0
    h = [zeros(lag(i), Q); h];
    h_exp(size(h_exp, 1)+1:size(h, 1), :) = 0;
else
    error();
end
scaling = h\h_exp;
h = h*scaling;
for q=1:Q
    figure("name","q="+q);
    plot((0:size(h, 1)-1)'/fs, h(:,q));
    hold on;
    plot((0:size(h, 1)-1)'/fs, h_exp(:,q));
    title("q="+q);
    mylegend("est","exp");
end


[S, f, t] = stft(h-h_exp, hann(1024), 256, 2048, fs);
[S1, f, t] = stft(h_exp, hann(1024), 256, 2048, fs);
e = mean(abssq(S), [2, 3]);
p = mean(abssq(S1), [2, 3]);
figure; plot(f, e./p);

end
