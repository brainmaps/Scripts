function Idiv = jh_divergenceFromGradient2D(gradient, sigma)
%divergenceFromGradient calculates the divergence of a gradient field
%
% SYNOPSIS
%   Idiv = divergenceFromGradient(gradient, sigma)
%
% INPUT
%   gradient: gradient field for calculation of the divergence
%   sigma: Gaussian sigma used for calculation of the derivatives
%
% OUTPUT
%   Idiv: divergence

% Make kernel coordinates
mult = 1;
[X,Y] = ndgrid(-round(mult*sigma):round(mult*sigma));

Dx = -(X.*exp(-(X.^2 + Y.^2)/(2*sigma^2))) / (2*pi*sigma^4);
Dy = -(Y.*exp(-(X.^2 + Y.^2)/(2*sigma^2))) / (2*pi*sigma^4);

Gx = imfilter(gradient(:,:,1),Dx,'conv','symmetric' );
Gy = imfilter(gradient(:,:,2),Dy,'conv','symmetric' );

% Calculate the divergence
Idiv = Gx + Gy;

end
