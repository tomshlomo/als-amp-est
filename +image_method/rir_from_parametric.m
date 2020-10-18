% function [hnm, delay] = rir_from_parametric(fs, N, delay, amp, doa, varargin)
function [h, delay, roomParams] = rir_from_parametric(fs, delay, amp, doa, opts)
arguments
    fs (1,1) double % Hz
    delay (:,1) double % sec
    amp (:,1) double
    doa (:,2) double
    opts.array_type (1,1) string {mustBeMember(opts.array_type, ["anm","rigid","open", "em32"])} = "anm"
    opts.array_radius (1,1) double
    opts.array_omega (:,2) double
    opts.N (1,1) double

    opts.isComplexSH (1,1) logical = true
    opts.bpfFlag (1,1) logical = true % default is true.
    opts.bpfLimits (1,2) double = [10 fs/2*0.95]; % Hz
    
    opts.buffer_size = 1e7 % optimize this number for performance. as this number is larger, the code is more "vectorized". 1e7 seems to be optimal in my experience.
end

%% input validation
assert( size(delay,1) == size(amp,1), 'length of delay and amp must be the same' );
assert(size(doa,1)==size(delay,1), 'length of doa and delay must me the same');

%% set some parameters according to array type
switch opts.array_type
    case "anm"
        N = opts.N;
    otherwise
        % get parameters of em32
        if opts.array_type == "em32"
            [opts.array_omega(:,1), opts.array_omega(:,2), ~, r] = sampling_schemes.em32();
            opts.array_radius = r(1);
            opts.array_type = "rigid";
        end
        
        % get maximal order required for simulation (and increase by 2 to
        % increase accuracy)
        N = ceil(fs/2 *2*pi/soundspeed() * opts.array_radius)+2;
end
%% 
% todo: implement a buffer loop for cases where Yh is very big.

%% delay to samples
delay = round(delay*fs);

%% accumulate reflections with the same delay
% the following 2 lines are a vectorized implementation of the following
% loop:
% for i=1:length(delau)
%   hnm( delay(i)+1 , : ) = Yh_am(:,i).';
% end
nref = size(doa,1);
q = 1:(N+1)^2;
sz = [max(delay)+1, q(end)];
hnm = zeros(sz);
buffer_size = round(opts.buffer_size/q(end));
I0 = 0:(buffer_size-1);
for i=1:buffer_size:nref
    I = I0+i;
    if I(end)>nref
        I(I>nref)=[];
    end
    Yh = conj(shmat(N, doa(I,:), opts.isComplexSH, false));
    Yh_amp = Yh .* amp(I); 
    [xx, yy] = ndgrid(delay(I)+1,q);
    hnm = hnm + accumarray([xx(:) yy(:)], reshape(Yh_amp, 1, []), sz); 
end
if nargout>=3
    roomParams.T60 = RoomParams.T60(hnm(:,1), fs);
    roomParams.DRR = RoomParams.DRR(hnm(:,1), [], "directDelay", delay(1)+1, "outputType", "dB");
end

%% convert to h (if needed)
switch opts.array_type
    case "anm"
        h = hnm;
    otherwise
        % add some delay to compensate for the non causality of the system
        % from anm to p.
        pad = ceil(opts.array_radius/soundspeed() * fs)+1;
        firstnonzero = find(any(hnm,2),1);
        if firstnonzero<=pad
            pad = pad-firstnonzero+1;
            hnm = [zeros(pad, size(hnm,2)); hnm];
        end
        h = anm2p(hnm, fs, opts.array_radius, opts.array_omega, opts.array_type);
end

%% BPF to make IR more realistic
if ~isempty(opts.bpfLimits) && opts.bpfFlag
    [b,a] = butter(4,opts.bpfLimits/(fs/2));
    h = filter(b,a,h,[],1); 
end

if nargout>=2
    delay = delay/fs;
end

end

