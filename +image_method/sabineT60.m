function [T60, A, V, S] = sabineT60(roomDim,R, c)
% Author: Noam Shabtai 27.8.2008
% Last updated: Dec 2019 by Tom Shlomo

%%
if isscalar(R)
    R = repmat(R, 6, 1);
end
assert(isvector(R) && length(R)==6, 'R must be a scalar or a vector of length 6');

if nargin<3 || isempty(c)
    c = soundspeed();
end
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

% Volume of the room.
V = Lx*Ly*Lz;

% Surface of the room.
S = 2*Ly*Lz + 2*Lx*Lz + 2*Lx*Ly;

% Absorbing Surface of the room.
A = ((1-Rx0^2)+(1-Rx1^2))*Ly*Lz + ((1-Ry0^2)+(1-Ry1^2))*Lx*Lz + ...
    ((1-Rz0^2)+(1-Rz1^2))*Lx*Ly;

% Reverberation time acording to Sabine formula
T60 = 24*log(10)/c * V/A;

end

