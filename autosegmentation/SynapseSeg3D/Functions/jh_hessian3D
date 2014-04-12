function [lambda1,lambda2,lambda3,V1,V2,V3] = jh_hessian3D(im, sigma, varargin)
%
% SYNOPSIS
%   [lambda1,lambda2,lambda3,V1,V2,V3] = jh_hessian3D(im, sigma)
%   [lambda1,lambda2,lambda3,V1,V2,V3] = jh_hessian3D(im, sigma, mult)
%   [lambda1,lambda2,lambda3,V1,V2,V3] = jh_hessian3D(im, sigma, mult, anisotropic)
%
% INPUT
%   im: the original image
%   sigma: Gaussian sigma
%   mult: Factor to determine the kernel side for the Gaussian; the kernel
%       side is calculated by mult*sigma+1
%       default: mult = 1
%   anisotropic: specifies anisotropic voxels; e.g., anisotropic = [1 1 3]
%       default: anisotropic = [1 1 1]
%
% OUTPUT
%   lambda1, lambda2, lambda3: Eigenvalues of the hessian matrix
%   Vr, Vc, Vd: Eigenvectors of the hessian matrix
%
% NOTE
%   jh_hessian3D(im, 0.5, 3, [1 1 3]) works fine, but the function produces
%   artifacts for a larger sigma. I am using a previous gaussian smoothing 
%   to simulate a larger sigma. This works, but I do not get why it doesn't 
%   work here.

%% Check input

% Defaults
mult = 1;
anisotropic = [1 1 1];
% Check input
if ~isempty(varargin)
    % varargin is not empty
    % First input: mult
    mult = varargin{1};
    % Second input: for anisotropic voxels
    if length(varargin) == 2
        anisotropic = varargin{2};
    end
end

%% 

% Make kernel coordinates
r_1 = floor(-mult*sigma/anisotropic(1)); r_end = ceil(mult*sigma/anisotropic(1));
c_1 = floor(-mult*sigma/anisotropic(2)); c_end = ceil(mult*sigma/anisotropic(2));
d_1 = floor(-mult*sigma/anisotropic(3)); d_end = ceil(mult*sigma/anisotropic(3));
[r,c,d] = ndgrid(r_1:r_end, c_1:c_end, d_1:d_end);
r = r * anisotropic(1);
c = c * anisotropic(2);
d = d * anisotropic(3);

% Gauss and its derivatives:
% G = 1/((2*pi*sigma^2)^(1/2))^3 * exp(-(c^2+r^2+d^2)/(2*sigma^2))
% Gc = -c/((2*pi)^(3/2)*sigma^5) * exp(-(c^2+r^2+d^2)/(2*sigma^2))
% Gcc = (c^2-sigma^2) / ((2*pi)^(3/2)*sigma^7) * exp(-(c^2+r^2+d^2)/(2*sigma^2))
% Gcr = (c*r) / ((2*pi)^(3/2)*sigma^7) * exp(-(c^2+r^2+d^2)/(2*sigma^2))

% Build the gaussian 2nd derivatives filters
Drr = (r.^2-sigma^2) / ((2*pi)^(3/2)*sigma^7) .* exp(-(r.^2+c.^2+d.^2)/(2*sigma^2));
Drd = (r.*d) / ((2*pi)^(3/2)*sigma^7) .* exp(-(r.^2+c.^2+d.^2)/(2*sigma^2));
Dcc = (c.^2-sigma^2) / ((2*pi)^(3/2)*sigma^7) .* exp(-(r.^2+c.^2+d.^2)/(2*sigma^2));
Dcr = (c.*r) / ((2*pi)^(3/2)*sigma^7) .* exp(-(r.^2+c.^2+d.^2)/(2*sigma^2));
Dcd = (c.*d) / ((2*pi)^(3/2)*sigma^7) .* exp(-(r.^2+c.^2+d.^2)/(2*sigma^2));
Ddd = (d.^2-sigma^2) / ((2*pi)^(3/2)*sigma^7) .* exp(-(r.^2+c.^2+d.^2)/(2*sigma^2));

Irr = imfilter(im,Drr,'conv','symmetric');
Ird = imfilter(im,Drd,'conv','symmetric');
Icc = imfilter(im,Dcc,'conv','symmetric');
Icr = imfilter(im,Dcr,'conv','symmetric');
Icd = imfilter(im,Dcd,'conv','symmetric');
Idd = imfilter(im,Ddd,'conv','symmetric');

[lambda1,lambda2,lambda3,V1,V2,V3] = eig3volume(Icc,Icr,Icd,Irr,Ird,Idd);

