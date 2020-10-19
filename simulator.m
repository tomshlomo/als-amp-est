function [p, fs, reflectionsInfo, s, sceneInfo, h] = simulator(opts)
arguments
    opts.seed = "default"
    opts.maxWaves = inf;
    opts.arrayType = "em32"
    opts.dnr = inf;
    opts.T = 1;
    opts.angle_dependence = false;
    opts.source_type (1,1) string = "speech"
end

persistent cache
if ~isempty(cache)
    p = cache.p;
    fs = cache.fs;
    reflectionsInfo = cache.reflectionsInfo;
    s = cache.s;
    sceneInfo = cache.sceneInfo;
    h = cache.h;
    return 
end
rng(opts.seed);
roomDim = [7, 5, 3];

if opts.angle_dependence
    R = 0.95;
else
    R = 0.9;
end

rng(2)
switch opts.source_type
    case "speech"
        [s, fs] = audioread("female_speech.wav");
        s = s(1:round(opts.T*fs));
    case "noise"
        fs = 48e3;
        s = randn(round(fs*opts.T),1);
end
sourcePos = [roomDim(1)*2/3 roomDim(2)/2 1.5]+rand_between([-0.5, 0.5], [1, 3]);
arrayPos =  [roomDim(1)*1/4 roomDim(2)/2 1.5]+rand_between([-0.5, 0.5], [1, 3]);

%% get responce
[h, reflectionsInfo, roomParams] = image_method.calc_rir(fs, roomDim, sourcePos, arrayPos, R, ...
    {"maxwaves", opts.maxWaves, "zerofirstdelay", false, "angledependence", opts.angle_dependence}, ...
    {"array_type", opts.arrayType, "N", 4});% N is not really used here.
sceneInfo.T60 = roomParams.T60;
sceneInfo.DRR = roomParams.DRR;
sceneInfo.SNR = RoomParams.dnr_drr_to_snr(opts.dnr, roomParams.DRR);
fprintf("T60: %.2f sec\n", roomParams.T60);
fprintf("DRR: %.1f dB\n", roomParams.DRR);
fprintf("DNR: %.1f dB\n", opts.dnr);
sceneInfo.dist = norm(sourcePos-arrayPos);
fprintf("Distance: %.2f meters\n", sceneInfo.dist);

%% convolve with responce
if size(h,1)==1
    p = s*h;
else
    p = fftfilt(h, s); % 2^15 seems to be the fastest on my mac
end
p = p./std(p, [], "all");

%% add noise
% noise = randn(size(p))* 10^(-snr/20);
% p = p+noise;

% % decimate (discard high frequencies)
% [p, fs] = decimate_cols(p, fs, fmax*2*1.05);

%% cache
cache = struct();
cache.p = p;
cache.fs = fs;
cache.reflectionsInfo = reflectionsInfo;
cache.s = s;
cache.sceneInfo = sceneInfo;
cache.h = h;

end