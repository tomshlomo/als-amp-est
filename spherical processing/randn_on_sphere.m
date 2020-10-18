function out = randn_on_sphere(len, omega_mu, sigma, output_type)
arguments
    len (1,1) double
    omega_mu (:,2) double
    sigma (:,1) double
    output_type (1,1) string {mustBeMember(output_type,["cart", "sphere"])} = "sphere"
end
if size(omega_mu, 1) == 1
    omega_mu = repmat(omega_mu, len, 1);
end

if size(sigma, 1) == 1
    sigma = repmat(sigma, len, 1);
end

rotation_from_axis = randn(len,1).*sigma;
rotation_around_axis = rand(len,1)*2*pi;
omega = omega_mu;
omega(:,1) = omega(:,1) - rotation_from_axis;
x_mu = s2c(omega_mu);
x = s2c(omega);
for i=1:len
    R = axang2rotm([x_mu(i,:) rotation_around_axis(i)]);
    x(i,:) = x(i,:)*R;
end

switch output_type
    case "cart"
        out = x;
    case "sphere"
        out = c2s(x);
        out = out(:,1:2);
    otherwise
        error("Unknown option: %s", output_type);
end

end

