taumax = 20e-3;
T = 5;
N = 3;
restore_rir.setup();
load("+restore_rir/metu_sparg_data.mat");
extra = 20*0.042/soundspeed();
[~,t0] = max(abs(h(:,1)));
h(t0 + round((extra + taumax)*fs) : end, :) = [];
figure;
plot((0:size(h,1)-1)/fs, h(:,1:5), '.-');

%% generare p
s = randn(round(T*fs), 1);
p = fftfilt(h, s);

%% convert to anm
fprintf("converting to anm...\n");
anm = p2anm(p, fs, [], [], "em32", 40, N);

%% calculate STFT
fprintf("STFT...\n");
windowLength_sec = 150e-3;
window = hann( round(windowLength_sec*fs) );
hop = floor(length(window)/4);
[anm_stft, f_vec, t_vec] = stft(anm, window, hop, [], fs);
anm_stft = anm_stft(1:size(anm_stft,1)/2+1,:,:); % discard negative frequencies

%% apply PHALCOR
fprintf("PHALCOR...\n");
[estimates_global, estimates_local, expected, phalcor_intermediate_variables, hyperparams] = ...
    phalcor.wrapper(anm_stft, f_vec, t_vec, windowLength_sec,...
    "expected", expected, "taumax", taumax, "densityThresh", 0.05, ...
    "fine_delay_flag", 1, ...
    "plotFlag", 1, "intermediate_variables", struct());

%% apply PHALCOR from clustering
load("+restore_rir/phalcor_intermediate_variables.mat");
[estimates_global, estimates_local, expected, phalcor_intermediate_variables, hyperparams] = ...
    phalcor.wrapper(anm_stft, f_vec, t_vec, windowLength_sec,...
    "expected", expected, "taumax", taumax, "densityThresh", 0.2, ...
    "fine_delay_flag", 1, ...
    "plotFlag", 1, "intermediate_variables", rmfield(intermediate_variables, "T3"));