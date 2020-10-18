function val = DRR(h_all, h_dir, opts)
arguments
    h_all (:,1) double
    h_dir (:,1) double
    opts.directDelay (:,1) double
    opts.outputType (1,1) string {mustBeMember(opts.outputType, ["dB", "linear"])} = "dB"
    opts.source
end

if isfield(opts,  "directDelay")
    assert(isempty(h_dir), "to use the directDelay option, h_dir must be empty");
    h_dir = zeros(size(h_all));
    h_dir(opts.directDelay) = h_all(opts.directDelay);
end

h_rev = h_all-h_dir;
if isfield(opts, "source")
    h_dir = fftfilt(h_dir, opts.source, 2^15); % 2^15 seems to be fastest in my mac
    h_rev = fftfilt(h_rev, opts.source, 2^15);    
end
val = (h_dir'*h_dir) / (h_rev'*h_rev);


switch opts.outputType
    case "dB"
        val = 10*log10(val);
end

end

