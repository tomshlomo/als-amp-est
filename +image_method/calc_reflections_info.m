function [reflectionPos, hits ] = calc_reflections_info( roomDim, sourcePos, R, maxReflectionOrder )

%% input validation
if isscalar(R)
    R = repmat(R, 6, 1);
end
assert(isvector(R) && length(R)==6, 'R must be a scalar or a vector of length 6');
R = R(:)'; % make row vector

if isscalar(maxReflectionOrder)
    maxReflectionOrder = repmat(maxReflectionOrder, 3, 1);
end
assert(isvector(maxReflectionOrder) && length(maxReflectionOrder)==3, 'maxReflectionOrder must be a scalar or a vector of length 3');

max_hits = ceil(maxReflectionOrder/2);
%% 
[i1, i2, i3] = ndgrid(-max_hits(1):max_hits(1),...
                      -max_hits(2):max_hits(2),...
                      -max_hits(3):max_hits(3));
reflectionIndex = [i1(:) i2(:) i3(:)];
clear i1 i2 i3

cornerIndex = floor( (reflectionIndex+1)/2 );
cornerPos = cornerIndex .* (2*roomDim);
clear cornerIndex

reflectionPos = (-1).^(reflectionIndex).*sourcePos + cornerPos;
clear cornerPos

hits = zeros(size(reflectionIndex));
I = reflectionIndex>0;
hits(I) = ceil(abs(reflectionIndex(I))/2);
hits(~I) = floor(abs(reflectionIndex(~I))/2);
hits = [hits, abs(reflectionIndex)-hits];

end