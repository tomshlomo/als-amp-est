function generate_figures()

setup();

%% parameters
rng("default"); % for reproducibility
M = 1; % Monte Carlo Repetitions
T = 1; % sample length
dnr = 30; % direct to noise ratio (dB)
array_type = "em32"; % eigenmike with 32 microphones
bw = 1000; % bandwidth (Hz)
f_c = 1e3:2000:10e3;

%% create clean microphone signals
[p_clean, fs, reflectionsInfo, s, sceneInfo] = ...
    simulator("seed", "default", "T", T,...
    "arrayType", array_type, "maxWaves", inf, "source_type", "speech");
x = reflectionsInfo.amp;
doa = reflectionsInfo.omega;
delay = reflectionsInfo.delay;

%% Figure 1: estimates vs. iteration
fprintf("Generating figure 1\n");
rng("default"); % for reproducibility
K = 5;
p = add_sensor_noise(p_clean);
x_hat = als_wrapper(p, fs, [3500 4500], doa(1:K+1,:), delay(1:K+1), "output_all_iterations", true, "x_exp", x(1:K+1), "s_exp", s);

fig1 = new_figure("iterations");
h = plot(0:10, x_hat.');
scaling = x(1:K+1)\x_hat(:,end);
for k=1:K+1
    yline(scaling*x(k), "Color", h(k).Color, "LineStyle", "--", "LineWidth", 1, "HandleVisibility", "off");
    h(k).DisplayName = "$k="+(k-1)+"$";
end
legend("Location", "southoutside", "NumColumns", 3);
xlabel("Iteration Num.");
ylabel("$\hat{x}_k$");

set_font_sizes(fig1);
fig2file(fig1, "fig_1");

%% Figure 2: SIMSE vs. frequency, with noisy DOA
fprintf("Generating figure 2\n");
rng("default"); % for reproducibility
K = 20;
sigma_doa = [0, 5, 10]*pi/180;
simse1 = zeros(length(f_c), length(sigma_doa), M);
for i=1:length(f_c)
    for j=1:length(sigma_doa)
        for m=1:M
            p = add_sensor_noise(p_clean);
            doa_noisy = add_doa_noise(doa(1:K+1,:), sigma_doa(j));
            x_hat = als_wrapper(p, fs, f_c(i) + bw/2*[-1, 1], doa_noisy, delay(1:K+1), "x_exp", x(1:K+1), "s_exp", s, "verbose", false);
            simse1(i, j, m) = scale_invariant_mse(x_hat, x(1:K+1));
            fprintf("\ti = %3d/%3d, j = %3d/%3d, m = %3d/%3d\n", i, length(f_c), j, length(sigma_doa), m, M);
        end
    end
end
simse1 = mean(simse1, 3);
fig2 = new_figure("doa noise");
plot(f_c, 10*log10(simse1));
xlabel("$f_c$ [Hz]")
ylabel("SIMSE [dB]");
legend("$\sigma_\Omega=" + round(sigma_doa'*(180/pi)) + "^\circ$");

set_font_sizes(fig2);
fig2file(fig2, "fig_2");

%% Figure 3: SIMSE vs. frequency, with noisy delay
fprintf("Generating figure 3\n");
rng("default"); % for reproducibility
K = 20;
sigma_delay = [0, 5, 10]*1e-6;
simse2 = zeros(length(f_c), length(sigma_delay), M);
for i=1:length(f_c)
    for j=1:length(sigma_delay)
        for m=1:M
            p = add_sensor_noise(p_clean);
            delay_noisy = add_delay_noise(delay(1:K+1,:), sigma_delay(j));
            x_hat = als_wrapper(p, fs, f_c(i) + bw/2*[-1, 1], doa(1:K+1,:), delay_noisy, "x_exp", x(1:K+1), "s_exp", s, "verbose", false);
            simse2(i, j, m) = scale_invariant_mse(x_hat, x(1:K+1));
            fprintf("\ti = %3d/%3d, j = %3d/%3d, m = %3d/%3d\n", i, length(f_c), j, length(sigma_delay), m, M);
        end
    end
end
simse2 = mean(simse2, 3);
fig3 = new_figure("delay noise");
plot(f_c, 10*log10(simse2));
xlabel("$f_c$ [Hz]")
ylabel("SIMSE [dB]");
legend("$\sigma_\tau=" + round(sigma_delay'*1e6) + "\mu s$");

set_font_sizes(fig3);
fig2file(fig3, "fig_3");

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
    function fig = new_figure(name)
        fig = figure("Units", "centimeters", "WindowStyle", "normal", "Name", name);
        fig.Position(3) = 8.5;
        fig.Position(4) = 6;
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
