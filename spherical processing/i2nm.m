function [n,m] = i2nm(i, isComplex)
if nargin<2 || isComplex
    n = floor(sqrt(i-1));
    m = i-1-n.*(n+1);
else
    error("Real SH are supported yet");
end

end

