function [ z ] = abssq( z )
% calculates the sqaured absolute value of a complex array z.
% for complex numbers, this way is faster than abs(z).^2 or z.*conj(z).
% Run the following line to see for yourself:
% z = randn(1e4)+1i*randn(1e4); tic; abssq(z); toc; tic; abs(z).^2; toc; tic; z.*conj(z); toc;

z = real(z).^2 + imag(z).^2;

end

