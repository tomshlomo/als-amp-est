function dnr_db = snr_drr_to_dnr(snr_db,drr_db)
% calculated the direct sound to noise ratio, based on the signal to noise
% ratio (SNR), and the direct to reverberant ratio (DRR).
% in SNR, "signal" means direct + reverberant.
%
% This calculation assumes the energy of the signal is the sum of the
% energies of the direct and reverberant parts. This might not be true for
% input signals with sufficiently long autocorrelation.


snr = 10^(snr_db/10);
drr = 10^(drr_db/10);

dnr = drr*snr/(1+drr);
dnr_db = 10*log10(dnr);

end

