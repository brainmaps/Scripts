function [nh, nhLin, nhEachPos] = jh_getNeighborhood2D(dmin, dmax, varargin)
%jh_getNeighborhood gets a defined neighborhood around a pixel as mask or
%linear coordinates
%
% SYNOPSIS
%   [nh, nhLin] = jh_getNeighborhood2D(dmin, dmax)
%   [nh, nhLin] = jh_getNeighborhood2D(dmin, dmax, imgSize)
%   [nh, nhLin, nhEachPos] = jh_getNeighborhood2D(dmin, dmax, imgSize, type)
%   [nh, nhLin, nhEachPos] = jh_getNeighborhood2D(dmin, dmax, imgSize, type, anisotropic)
%   
% INPUT
%   dmin: Minimum distance of the neighborhood from the considered pixel
%   dmax: Maximum distance of the neighborhood from the considered pixel
%   imgSize: Size of the used image (needed to compute the linear
%       coordinates of the neighborhood pixels); if not supplied the linear
%       coordinates are computed for an image of the size of the returned
%       mask
%   type: When type is set to 'extended', the nhEachPos matrix is
%       calculated (see below)
%   anisotropic: When supplied it defines anisotropic pixels; e.g.,
%       anisotropic = [1, 3] means that the pixels are three times as
%       long in y-direction (anisotropic = [row, column])
%
% OUTPUT
%   nh: Mask
%   nhLin: Array containing linear coordinates
%   nhEachPos: A matrix which containes a vector at each position which
%       describes its neighborhood in linear coordinates; note that this
%       matrix containes negative values near the borders

%% Check input

% Defaults
extended = false;
anisotropic = [1,1];
% Check input
if ~isempty(varargin)
    % varargin is not empty
    % The first position defines the image size
    imgSize = varargin{1};
    % The second position defines the type
    if length(varargin) >= 2
        if strcmp(varargin{2}, 'extended');
            extended = true;
        end
    end
    % The third position specifies anisotropic voxels
    if length(varargin) == 3
        anisotropic = varargin{3} / min(varargin{3});
    end
else
    imgSize = [dmax*2+1, dmax*2+1];
end

%% General initializations

% The image size
n1 = imgSize(1);
n2 = imgSize(2);
n = n1*n2;

% For anisotropic voxels
dmax1 = round(dmax / anisotropic(1));
dmax2 = round(dmax / anisotropic(2));
%{ 
--- Not needed ---
dmin1 = round(dmin / anisotropic(1));
dmin2 = round(dmin / anisotropic(2));
dmin3 = round(dmin / anisotropic(3));
---
%}

%% Determine mask

% Initialize mask
maskDiameter = [dmax1*2+1, dmax2*2+1];
nh = zeros(maskDiameter);
% Determine mask
for r = -dmax1:dmax1
    for c = -dmax2:dmax2
        radius = round( ( (r*anisotropic(1))^2 + (c*anisotropic(2))^2 ) ^(1/2) );
        if radius >= dmin && radius <= dmax
            nh(r+dmax1+1,c+dmax2+1) = 1;
        end
    end
end

%% Determine offset of the mask pixels (using linear coordinates)

% Create matrix containing its linear coordinates at each position
mLin = 1:n;
mLin = reshape(mLin, n1,n2);

% Extract any part of this matrix with the total size of the neighborhood
% matrix
mLinSub = mLin(1:maskDiameter(1), 1:maskDiameter(2));
% Subtract the central pixel
mLinSub = mLinSub - mLinSub(dmax1+1, dmax2+1);

% Linearize the matrix using only the pixels of the neighborhood
nhLin = mLinSub(nh == 1);

%% Create nhEachPos (when type is set to 'extended')

if extended

    % Use Tony's trick to doublicate the nhLin vector to two dimensions    
    nhEachPos = nhLin(:, ones(n1,1), ones(n2,1));
    % Re-arrange the 4D array to set the nhLin vectors to the fourth
    % dimension
    nhEachPos = permute(nhEachPos, [2,3,1]);
    
    % Extend the previously calculated mLin matrix to the 3rd dimension
    mLinExt = mLin(:,:,ones(size(nhEachPos,3), 1));

    % Now just add both matrices, and voila!
    nhEachPos = mLinExt + nhEachPos;
    
else
    nhEachPos = 0;
end

end























