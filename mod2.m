function [ output ] = mod2( value, base )
%just like the function mod, but the result ranges from -base/2 to base/2.

hb = base/2;
output = mod(value+hb, base)-hb;

end