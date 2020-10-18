function d_c = critical_distance_diffuse(roomDim, R)
arguments
    roomDim (1,3) double
    R (:,1) double
end
%%
if isscalar(R)
    R = repmat(R, 6, 1);
end
assert(length(R)==6, 'R must be a scalar or a vector of length 6');

%%
% Dimensions of room in meters
Lx=roomDim(1);  % length
Ly=roomDim(2);  % width
Lz=roomDim(3);  % height

% Reflection coefficients of 6 walls
Rx0=R(1);    % wall on y-z plane at x=0
Rx1=R(4);    % wall on y-z plane at x=Lx
Ry0=R(2);    % wall on x-z plane at y=0
Ry1=R(5);    % wall on x-z plane at y=Ly
Rz0=R(3);    % floor on x-y plane at z=0
Rz1=R(6);    % ceiling on x-y plane at z=Lz

% Absorbing Surface of the room.
A = ((1-Rx0^2)+(1-Rx1^2))*Ly*Lz + ((1-Ry0^2)+(1-Ry1^2))*Lx*Lz + ...
    ((1-Rz0^2)+(1-Rz1^2))*Lx*Ly;

d_c = sqrt(A/pi)/4;


end

