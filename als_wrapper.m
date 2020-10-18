function x = als_wrapper(p, fs, flim, doa, delay, opts)
arguments
    p (:,:) double
    fs (1,1) double
    flim (1,2) double
    doa (:,2) double
    delay (:,1) double
    opts.x_exp (:,1) double = []
    opts.s_exp (:,1) double = []
    opts.plot_flag (:,1) double = false
    opts.window = "none"
    opts.array_type (1,1) string = "em32"
    opts.real_flag = 1
    opts.output_all_iterations = false
    opts.verbose = true
end

if ~strcmp(opts.window, "none")
    p = p.*opts.window(size(p,1));
end

P = fft(p, [], 1).';
nfft = size(P, 2);
S_exp = fft(opts.s_exp, nfft);
f = freq_vec(nfft, fs);
I = f >= flim(1) & f < flim(2);
f = f(I);
J = size(f, 1);
P = P(:,I);

S_exp = S_exp(I);
H = doa_delay_to_A(doa, delay, f, opts.array_type, sqrt(size(P,1))-1);
x = als(H, P, "plot_flag", opts.plot_flag,...
    "real_flag", opts.real_flag, "s_exp", S_exp, "x_exp", opts.x_exp, "verbose", opts.verbose);
if ~opts.output_all_iterations
    x = x(:,end);
end

end

