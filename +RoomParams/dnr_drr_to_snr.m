function snr_db = dnr_drr_to_snr(dnr_db,drr_db)
% calculate the signal to noise ratio, based on the direct sound to noise
% ratio (DNR), and the direct to reverberant ratio (DRR).
% in SNR, "signal" means direct + reverberant.
%
% This calculation assumes the energy of the signal is the sum of the
% energies of the direct and reverberant parts. This might not be true for
% input signals with sufficiently long autocorrelation.


dnr = 10^(dnr_db/10);
drr = 10^(drr_db/10);

snr = dnr*(1+drr)/drr;
snr_db = 10*log10(snr);

end

