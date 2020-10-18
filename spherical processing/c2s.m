function [theta,phi,r] = c2s(x,y,z)
%C2S converts Cartesian to spherical coordinates (non Matlab notation!).
% [theta,phi,r] = c2s(x,y,z);
% (x,y,z) are the conventional cartezian coordinates.
% theta is the angle going down from the z-axiz.
% phi is the azimuth angle from the poitive x-axis, towards the positive y-axis.
%  
% Fundmentals of Spherical Array Processing
% Boaz Rafaely, 2017.
%
% Modified by Tom Shlomo, Dec 2019

if nargin==1
    c = x;
    x = c(:,1);
    y = c(:,2);
    z = c(:,3);
end

theta = atan2(sqrt(x.^2+y.^2),z);
phi = atan2(y,x);
r = sqrt(x.^2+y.^2+z.^2);

if nargout==1
    theta = [theta(:), phi(:), r(:)];
end
