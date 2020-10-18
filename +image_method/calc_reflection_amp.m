function a = calc_reflection_amp(r, hits, z0, angleDependence, r_norm)

arguments
    r (:,3) % relative position vector (between each image source and the array)
    hits (:,6) % number of wall hits for eatch reflection (for each wall)
    z0 % the ratio of impdenaces between the walls and the air. either a 6-vector, or a scalar.
       % In terms of R (the reflection coeffecient): z0 = (R+1)./(1-R)
    angleDependence (1,1) logical = true
    r_norm (:,1) = [] % relative distance (between each image source and the array) [optional]
end

if isempty(r_norm)
    r_norm = vecnorm(r,2,2);
end

if isscalar(z0)
    z0 = repmat(z0, 1, 6);
end

%%
z0 = reshape(z0, 1, 3, 2);
hits = reshape(hits, [], 3, 2);

if angleDependence
    cos_th = abs(r./r_norm);
else
    cos_th = ones(size(r));
end

z0_cos_th = cos_th .* reshape(z0,1,3,2);
a = ( z0_cos_th - 1 )./( z0_cos_th + 1 );
a = prod(a.^hits, [2 3]);

a = a./r_norm;

end

