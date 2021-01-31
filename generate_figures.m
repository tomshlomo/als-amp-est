function [h, simse] = generate_figures(h, simse)

setup();

%% parameters
rng("default"); % for reproducibility
M = 50; % Monte Carlo Repetitions
T = 1; % sample length
dnr = 30; % direct to noise ratio (dB)
array_type = "em32"; % eigenmike with 32 microphones
bw = 1000; % bandwidth (Hz)
f_c = 1e3:100:10e3;

%% create clean microphone signals
[p_clean, fs, reflectionsInfo, s, sceneInfo, h_exp] = ...
    simulator("seed", "default", "T", T,...
    "arrayType", array_type, "maxWaves", inf, "source_type", "speech");
x = reflectionsInfo.amp;
doa = reflectionsInfo.omega;
tau0 = reflectionsInfo.delay(1);
delay = reflectionsInfo.delay - tau0;

%% Figure 1: RIR recostruction
fprintf("Generating figure 1\n");
rng("default"); % for reproducibility
K = 20;
p = add_sensor_noise(p_clean);
doa_noisy = add_doa_noise(doa(1:K+1,:), 10*pi/180);
delay_noisy = add_delay_noise(delay(1:K+1,:), 10e-6);
if nargin==0 || isempty(h)
    h = 0;
    for i = 1:length(f_c)
        passband = f_c(i) + bw * [-0.5, 0.5];
        x_est = als_wrapper(p, fs, passband, doa_noisy, delay_noisy, "x_exp", x(1:K + 1), "s_exp", s);
        x_est = x_est / x_est(1);
        h_f = image_method.rir_from_parametric(fs, delay_noisy + tau0, x_est, doa_noisy, "array_type", array_type, "bpfFlag", false);
        h = h + bandpass(h_f, passband, fs);
    end
end
passband = [1000, 5000];
q = 1;
h_exp_f = bandpass(h_exp, passband, fs);
h_exp_f = h_exp_f/max(h_exp_f(:,q));
h_exp_f_early = h_exp_f(1:size(h, 1), :);
h_f = bandpass(h, passband, fs);
scale = h_f(:, q) \ h_exp_f_early(:, q);
tvec = (0:size(h_exp_f) - 1)' / fs - tau0 + 200e-6;

fig1a = new_figure("rir", 2.5);
yl = [-0.8, 1];
lw = 0.5;
plot(tvec, h_exp_f(:, q), "LineWidth", lw);
xlim([0, 0.4]);
ylim(yl);
set_font_sizes(fig1a);
fig2file(fig1a, "fig_1a");

fig1b = new_figure("rir_zoom", 3);
plot(tvec, h_exp_f(:, q), "LineWidth", lw);
hold on
plot(tvec(1:size(h_f, 1)), h_f(:, q) * scale, '-', "LineWidth", lw);
xlabel("Time [sec]");
xlim([0, 0.02]);
ylim(yl);
set_font_sizes(fig1b);
fig2file(fig1b, "fig_1b");

%% Figure 2: SIMSE vs. frequency, with noisy DOA and delays
fprintf("Generating figure 2\n");
rng("default"); % for reproducibility
K = 20;
sigma_doa   = [0, 5, 10, 0, 0 ]*pi/180;
sigma_delay = [0, 0, 0,  10, 20]*1e-6;
if nargin==0
    simse = zeros(length(f_c), length(sigma_doa), M);
    for i=1:length(f_c)
        for j=1:length(sigma_doa)
            for m=1:M
                p = add_sensor_noise(p_clean);
                doa_noisy = add_doa_noise(doa(1:K+1,:), sigma_doa(j));
                delay_noisy = add_delay_noise(delay(1:K+1,:), sigma_delay(j));
                x_hat = als_wrapper(p, fs, f_c(i) + bw/2*[-1, 1], doa_noisy, delay_noisy, "x_exp", x(1:K+1), "s_exp", s, "verbose", false);
                simse(i, j, m) = scale_invariant_mse(x_hat, x(1:K+1));
                fprintf("\ti = %3d/%3d, j = %3d/%3d, m = %3d/%3d\n", i, length(f_c), j, length(sigma_doa), m, M);
            end
        end
    end
    simse = mean(simse, 3);
end
fig2 = new_figure("simse", 5);
plot(f_c, 10*log10(simse), "LineWidth", 1);
xlabel("$f_c$ [Hz]")
ylabel("SIMSE [dB]");
leg = legend("$\sigma_\Omega=" + round(sigma_doa'*(180/pi)) + "^\circ, \, \sigma_\tau=" + round(sigma_delay'*1e6) + "\mu s$", "Location", "southoutside", "NumColumns", 2);
leg.ItemTokenSize(1) = 20;
xlim([f_c(1), f_c(end)]);
ylim([-25, 0]);
set_font_sizes(fig2);
fig2file(fig2, "fig_2");

%% nested
    function p = add_sensor_noise(p)
        snr = RoomParams.dnr_drr_to_snr(dnr, sceneInfo.DRR);
        noise = randn(size(p))* 10^(-snr/20);
        p = p+noise;
    end
    function doa = add_doa_noise(doa, sigma_doa)
        doa = randn_on_sphere(size(doa,1), doa, sigma_doa, "sphere");
    end
    function delay = add_delay_noise(delay, sigma_delay)
        delay = delay + [0; randn(size(delay,1)-1,1)*sigma_delay];
    end
    function fig = new_figure(name, height)
        fig = figure("Units", "centimeters", "WindowStyle", "normal", "Name", name);
        fig.Position(3) = 8.5;
        fig.Position(4) = height;
        fig.PaperUnits = fig.Units;
        fig.PaperPosition = fig.Position;
    end
    function fig = set_font_sizes(fig)
        set(findall(fig,'-property','FontSize'),'FontSize', 8)
    end
    function fig2file(fig, filename)
        resolution = '-r1200';
        type = '-depsc';
        if ~isfolder("figures")
            mkdir("figures");
        end
        print(fig, resolution, fullfile("figures", filename), type )
    end
end

