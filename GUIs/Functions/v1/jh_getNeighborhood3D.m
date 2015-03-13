function [nh, nhLin, nhEachPos] = jh_getNeighborhood3D(dmin, dmax, varargin)
%jh_getNeighborhood gets a defined neighborhood around a pixel as mask or
%linear coordinates
%
% SYNOPSIS
%   [nh, nhLin, ~] = jh_getNeighborhood3D(dmin, dmax)
%   [nh, nhLin, ~] = jh_getNeighborhood3D(___, 'imgSize', imgSize)
%   [nh, nhLin, ~] = jh_getNeighborhood3D(___, 'anisotropic', anisotropic)
%   [nh, nhLin, ~] = jh_getNeighborhood3D(___, 'reduceSize', reduceSize, amount)
%   [nh, nhLin, nhEachPos] = jh_getNeighborhood3D(___, 'extended')
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
%   anisotropic: When supplied it defines anisotropic voxels; e.g.,
%       anisotropic = [1, 1, 3] means that the voxels are three times as
%       long in z-direction (anisotropic = [row, column, depth]);
%       can be set to [] for default of [1,1,1]
%   reduceSize: Determines how the number of pixels in the neighborhood is
%       reduced
%       'none': Default value, no reduction is performed
%       'random': A random set of n*total positions is excluded
%       'orderly': A uniformly distributed set of n*total positions is
%           excluded
%   amount: Defines the relative amount of positions that are excluded
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
anisotropic = [1,1,1];
reduceSize = 'none';
amount = 0.5;
imgSize = [dmax*2+1, dmax*2+1, dmax*2+1];
% Check input
if ~isempty(varargin)
    i = 0;
    while i < length(varargin)
        i = i+1;
        
        if strcmp(varargin{i}, 'imgSize')
            imgSize = varargin{i+1};
            i = i+1;
        elseif strcmp(varargin{i}, 'anisotropic')
            anisotropic = varargin{i+1};
            i = i+1;
        elseif strcmp(varargin{i}, 'reduceSize')
            reduceSize = varargin{i+1};
            amount = varargin{i+2};
            i = i+2;
        elseif strcmp(varargin{i}, 'extended')
            extended = true;
        end

        
    end
    
end

%% General initializations

% The image size
n1 = imgSize(1);
n2 = imgSize(2);
n3 = imgSize(3);
n = n1*n2*n3;

% For anisotropic voxels
dmax1 = round(dmax / anisotropic(1));
dmax2 = round(dmax / anisotropic(2));
dmax3 = round(dmax / anisotropic(3));
%{ 
--- Not needed ---
dmin1 = round(dmin / anisotropic(1));
dmin2 = round(dmin / anisotropic(2));
dmin3 = round(dmin / anisotropic(3));
---
%}

%% Determine mask

% Initialize mask
maskDiameter = [dmax1*2+1, dmax2*2+1, dmax3*2+1];
nh = zeros(maskDiameter);
% Determine mask
for r = -dmax1:dmax1
    for c = -dmax2:dmax2
        for d = -dmax3:dmax3
            radius = round( ( (r*anisotropic(1))^2 + (c*anisotropic(2))^2 + (d*anisotropic(3))^2 ) ^(1/2) );
            if radius >= dmin && radius <= dmax
                nh(r+dmax1+1,c+dmax2+1,d+dmax3+1) = 1;
            end
        end
    end
end

%% If desired clear parts of the neighborhood

% Randomly
if strcmp(reduceSize, 'random')
    % Determine total number of positions
    numPos = sum(nh(nh == 1));
    % Get the linear coordinates of all positions
    linCoord = find(nh == 1);
    % Determine the number of positions which will be excluded
    amount = round(amount*numPos);
    % Create random array of those positions which will be excluded
    p = randperm(numPos, amount);
    % Get the corresponding coordinates
    exclude = linCoord(p);
    % Exclude them
    nh(exclude) = 0;
end
% Orderly
if strcmp(reduceSize, 'orderly')

end

%% Determine offset of the mask pixels (using linear coordinates)

% Create matrix containing its linear coordinates at each position
mLin = 1:n;
mLin = reshape(mLin, n1,n2,n3);

% Extract any part of this matrix with the total size of the neighborhood
% matrix
mLinSub = mLin(1:maskDiameter(1), 1:maskDiameter(2), 1:maskDiameter(3));
% Subtract the central pixel
mLinSub = mLinSub - mLinSub(dmax1+1, dmax2+1, dmax3+1);

% Linearize the matrix using only the pixels of the neighborhood
nhLin = mLinSub(nh == 1);

%% Create nhEachPos (when type is set to 'extended')

if extended

    % Use Tony's trick to doublicate the nhLin vector to three dimensions    
    nhEachPos = nhLin(:, ones(n1,1), ones(n2,1), ones(n3,1));
    % Re-arrange the 4D array to set the nhLin vectors to the fourth
    % dimension
    nhEachPos = permute(nhEachPos, [2,3,4,1]);
    
    % Extend the previously calculated mLin matrix to the 4th dimension
    mLinExt = mLin(:,:,:,ones(size(nhEachPos,4), 1));

    % Now just add both matrices, and voila!
    nhEachPos = mLinExt + nhEachPos;
    
else
    nhEachPos = 0;
end

end























