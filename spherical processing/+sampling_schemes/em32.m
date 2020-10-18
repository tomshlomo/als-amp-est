function [th_mic, ph_mic, weights, r_mic] = em32()
% sampling schemes used by the 32-microphones array Eigenmike.
% data was taken from the LOCATA challenge.

load('+sampling_schemes/EM32_parameters.mat', 'th_mic', 'ph_mic', 'r_mic');
th_mic = th_mic.';
ph_mic = ph_mic.';
weights = repmat( 4*pi/length(th_mic) , size(th_mic) );

if nargout==1
    th_mic = [th_mic ph_mic];
end

end