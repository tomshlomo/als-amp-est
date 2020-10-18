function [ v ] = rand_between( lim, s )
%rand_between genrates random numbers at a given range.
%   inputs:
%      lim - a two element array. lim(1) is the minimal possible value to be generated, lim(2) is the maximal. default is [0 1].
%      s - the size of the output array. default is [1 1].

if nargin<1;
    lim = [0,1];
end

if nargin<2;
    s = [1,1];
end

v = rand(s);
v = lim(1)+diff(lim)*v;

end

