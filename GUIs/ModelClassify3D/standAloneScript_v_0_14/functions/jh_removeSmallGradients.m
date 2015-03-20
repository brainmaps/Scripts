function [mGF, mMag] = jh_removeSmallGradients(GF, varargin)
%jh_removeSmallGradients removes gradients with a small magnitude from a
%gradient field
%
% SYNOPSIS
%   [mGF, mMag] = jh_removeSmallGradients(GF)
%   [mGF, mMag] = jh_removeSmallGradients(GF, thresh)
%   [mGF, mMag] = jh_removeSmallGradients(GF, thresh, type)
%
% INPUT
%   GF: the original gradient field
%   thresh: when supplied all gradients with a small magnitude than thresh
%       will be excluded, when not supplied or thresh == 0 an Otsu-based 
%       method is used
%   type: String which defines the calculation of the magnitude
%       'normal': default value, the general definition of the magnitude is
%           used
%       'quadratic': the quadratic magnitude is used (increased
%           computational efficiency)
%
% OUTPUT
%   mGF: the modified gradient field
%   mMag: the accordingly modified magnitude matrix

%% Check input

% Defaults
thresh = 0;
type = 'normal';
if ~isempty(varargin)
    % varargin is not empty
    % The first position defines the threshold
    thresh = varargin{1};
    % The second position defines the type
    if length(varargin) >= 2
        type = varargin{2};
    end
end

%% Main part of the function

% Calculate the magnitude
magnitude = GF(:,:,:,1).^2 + GF(:,:,:,2).^2 + GF(:,:,:,3).^2;
if strcmp(type, 'normal')
    magnitude = magnitude .^ (1/2);
end
% The magnitude matrix needs the same dimension as the gradient field
mMag = magnitude;
magnitude(:,:,:,2) = magnitude(:,:,:,1);
magnitude(:,:,:,3) = magnitude(:,:,:,1);

% Initialize the modified gradient field with the original
mGF = GF;

% Choose the method to exclude small gradients
if thresh > 0
	mGF(magnitude < thresh) = 0;
    mMag(magnitude(:,:,:,1) < thresh) = 0;
elseif thresh == 0
    level = graythresh(magnitude);
    mGF(magnitude < level) = 0;
    mMag(magnitude(:,:,:,1) < level) = 0;
end

end

