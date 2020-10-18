function [i, isZeroIndex] = nm2i(n,m, isComplex)

if nargin<3 || isComplex
    i = n.*(n+1) + m+1;
    if nargout>=2
        isZeroIndex = abs(m)>n;
    end
else
    error("Real SH are not supported yet");
end


end

