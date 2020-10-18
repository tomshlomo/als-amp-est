function [x,y,z] = s2c(theta,phi,r)
%S2C converts spherical to Cartesian coordinates (non Matlab notation!).
% [x,y,z] = s2c(theta,phi,r);
% (x,y,z) is the conventional cartezian coordinates.
% theta is the angle going down from the z-axiz.
% phi is the azimuth angle from the poitive x-axis, towards the positive y-axis.
%
% Fundmentals of Spherical Array Processing
% Boaz Rafaely, 2017.
%
% Modified by Tom Shlomo, Dec 2019

if nargin==1
    s = theta;
    theta = s(:,1);
    phi = s(:,2);
    if size(s,2)>=3
        r = s(:,3);
    else
        r = ones(size(s,1),1);
    end
elseif nargin==2
    r = ones(size(theta));
end
x = r.*sin(theta).*cos(phi);
y = r.*sin(theta).*sin(phi);
z = r.*cos(theta);

if nargout<=1
    x = [x(:), y(:), z(:)];
end

