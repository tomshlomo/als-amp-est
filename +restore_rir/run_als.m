restore_rir.setup();

%% parameters
rng("default"); % for reproducibility
T = 1; % sample length
dnr = 30; % direct to noise ratio (dB)
array_type = "em32"; % eigenmike with 32 microphones
bw = 1000; % bandwidth (Hz)
f_c = 530:100:10e3;

%%
load("+restore_rir/phalcor_results.mat", "estimates_global", "p", "h");
estimates_global = sortrows(estimates_global, "tau");
doa = estimates_global.omega;
delay = estimates_global.tau;

%% Figure 2: SIMSE vs. frequency, with noisy DOA and delays
fprintf("Generating figure 2\n");
rng("default"); % for reproducibility
K = size(doa, 1);
sigma_doa   = [0, 5, 10, 0, 0 ]*pi/180;
sigma_delay = [0, 0, 0,  5, 10]*1e-6;
x_hat = zeros(K, length(f_c));
for i=1:length(f_c)
    x_hat(:,i) = als_wrapper(p, fs, f_c(i) + bw/2*[-1, 1], doa, delay, "verbose", true, "output_all_iterations", false, "real_flag", 1, "plot_flag", mod(i, 10)==1);
    drawnow();
end

