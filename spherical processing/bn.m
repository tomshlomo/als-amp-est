function b = bn(N, kr, options)
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here
arguments
    N (1,1) double
    kr (:,1) double 
%     options.ka (:,1) double = kr
    options.sphereType (1,1) string {mustBeMember(options.sphereType, ["rigid", "open"])} = "rigid"
    options.outputForm (1,1) string {mustBeMember(options.outputForm, ["vec", "vecduplicated", "mat", "matduplicated"])} = "vecduplicated";
    options.directionInterpertation (1,1) string {mustBeMember(options.directionInterpertation, ["doa", "propagation"])} = "doa"
end


n = 0:N;
n_mat = repmat(n, size(kr, 1), 1);
kr_mat = repmat(kr, 1, N+1);
% if isempty(options.ka)
%     ka_mat = kr_mat;
% elseif isscalar(ka)
%     ka_mat = repmat(ka, size(kr_mat));
% else
%     assert(isequal(size(ka), size(kr)), "ka must be empty, scalar, or the same size as kr");
%     ka_mat = repmat(options.ka, 1, N+1);
% end

switch options.directionInterpertation
    case "doa"
        factor = 4*pi*1j.^n_mat;
    case "propagation"
        factor = 4*pi*(-1j).^n_mat;
end

switch options.sphereType
    case "open"
        b = sBessel(n_mat,kr_mat);
    case "rigid"
        b = sBessel(n_mat,kr_mat)-(sBesseld(n_mat,kr_mat)./sHankeld(n_mat,kr_mat,2)).*sHankel(n_mat,kr_mat,2);
end
b = factor.*b;

switch options.outputForm
    case {"vecduplicated","matduplicated"}
        n = i2nm(1:(N+1)^2, true);
        b = b(:, n+1);
end

switch options.outputForm
    case {"mat","matduplicated"}
        B = zeros(size(b,2), size(b,2), size(kr,1));
        for i=1:size(kr,1)
            B(:,:,i) = diag(b(i,:));
        end
        b = B;        
end

b(isnan(b))=0;

end

function y = sBessel(n,x)
  y = sqrt(pi./(2*x)) .* besselj(n+0.5,x);
end

function y = sBesseld(n,x)
  y = (n./x) .* sBessel(n,x) - sBessel(n+1,x);
end

function y = sHankel(n,x,kind)  % kind is 1 or 2
  y = sqrt(pi./(2*x)) .* besselh(n+0.5,kind,x);
end

function y = sHankeld(n,x,kind)  % kind is 1 or 2
  y = (n./x) .* sHankel(n,x,kind) - sHankel(n+1,x,kind);
end