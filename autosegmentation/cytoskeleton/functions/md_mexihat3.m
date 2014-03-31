function mexihat3 = md_mexihat3(xSize,ySize,zSize,xScale,yScale,zScale)
%MD_MEXIHAT3 "Mexican hat" convolution kernel for 3D blob detection
%
% v1.0
%
% This function makes a 4-dimensional "mexican hat",
% intended for being used as a convolution kernel for 3D image processing.
%
% It can be helpful in the detection of blob-like image features.
%
% This function is inspired by the second derivative of the gaussian
% function (a.k.a. "Mexican Hat" or "Ricker Wavelet"), but it adds and
% removes some parameters from it, making it suitable for image processing.
%
%
% SYNOPSIS
%   mexihat3 = md_mexihat3(xSize,ySize,zSize,xScale,yScale,zScale)
%   mexihat3 = md_mexihat3(xSize,ySize,zSize)
%   mexihat3 = md_mexihat3()
%
%
% INPUT
%   xSize (uint8): Determines the size of the kernel in X direction.
%       The produced grid will have the length "2 * xSize + 1" in X
%       direction. Default value is "5".
%   ySize (uint8): Determines the size of the kernel in Y direction.
%       The produced grid will have the length "2 * ySize + 1" in Y
%       direction. Default value is "xSize".
%   zSize (uint8): Determines the size of the kernel in Z direction.
%       The produced grid will have the length "2 * zSize + 1" in Z
%       direction. Default value is "xSize".
%   xScale (double): Scales the function in X direction.
%       Default value is "xSize/2".
%   yScale (double): Scales the function in Y direction.
%       Default value is "ySize/2".
%   zScale (double): Scales the function in Y direction.
%       Default value is "zSize/2".
%
%
% OUTPUT
%   mexihat3: the "mexican hat" that was created


if ~exist('xSize','var'), xSize = 5; end
if ~exist('ySize','var'), ySize = xSize; end
if ~exist('zSize','var'), zSize = xSize; end
if ~exist('xScale','var'), xScale = xSize/2; end
if ~exist('yScale','var'), yScale = ySize/2; end
if ~exist('zScale','var'), zScale = zSize/2; end

% create a grid on which the function is calculated
[X,Y,Z] = ndgrid(-xSize:xSize,-ySize:ySize,-zSize:zSize);

% T is the distance from the center of the coordinate system,
% if the scale factors are all "1".
T = sqrt((X/xScale).^2+(Y/yScale).^2+(Z/zScale).^2);

% calculate the modified mexican hat function.
mexihat3 = (1-T.^2).*exp(-T.^2);

end
