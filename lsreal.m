function x = lsreal(A,b)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

x = [real(A); imag(A)]\[real(b); imag(b)];

end