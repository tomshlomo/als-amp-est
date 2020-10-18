function mse = scale_invariant_mse(x_hat, x_ref, dim)
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here
arguments
    x_hat
    x_ref
    dim = 1
end
% assert(iscolumn(x_hat));
% assert(iscolumn(x_ref));
assert(isequal(size(x_hat), size(x_ref)));

x_hat = sort_dims(x_hat);
x_ref = sort_dims(x_ref);

x_hat = x_hat./vecnorm(x_hat, 2, 1);
x_ref = x_ref./vecnorm(x_ref, 2, 1);
inner_prod = sum(conj(x_hat) .* x_ref, 1);
mse = 1 - abssq( inner_prod );
mse = shiftdim(mse, 1);

    function x = sort_dims(x)
        if strcmp(dim, "all")
            x = x(:);
            return
        end
        rest = setdiff(1:ndims(x), dim);
        final_size = [prod(size(x, dim)), size(x, rest)];
        x = permute(x, [dim, rest]);
        x = reshape(x, final_size);
    end
end

