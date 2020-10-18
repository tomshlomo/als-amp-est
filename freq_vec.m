function f = freq_vec( n, fs, fftshift_flag, negative_freqs_flag )
arguments
    n (1,1) double
    fs (1,1)
    fftshift_flag (1,1) logical = false
    negative_freqs_flag (1,1) logical = true
end

f = (0:n-1)'*fs/n;
if negative_freqs_flag
    f = mod2(f, fs);
end
if fftshift_flag
    f = fftshift(f);
end

end