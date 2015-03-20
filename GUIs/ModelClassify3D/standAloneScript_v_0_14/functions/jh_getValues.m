function v = jh_getValues(im, range, varargin)
%jh_getValues returnes the areas from a matrix where it is within a certain
%range.
%
% SYNOPSIS
%   v = jh_getValues(im, range)
%   v = jh_getValues(im, p, type)
%
% INPUT
%   im: the image or matrix
%   range: the specific range: [min max]
%   p: A percentage when type is set
%   type: has to be set when the second input is of scalaric value
%       'fromMin': Default value
%       'fromMax'
%
% OUTPUT
%   v: the resulting matrix

%% Check input

% Defaults
if size(range,2) > 1
    type = 'range';
else
    type = 'fromMin';
end
% Check input
if ~isempty(varargin)
    % varargin is not empty
    % The first position defines the type
    type = varargin{1};
    % ...
    if length(varargin) >= 2

    end
else
end

%%

if strcmp(type, 'fromMin')
    minIm = min(min(min(im)));
    maxIm = max(max(max(im)));
    range = [minIm, range*maxIm];
elseif strcmp(type, 'fromMax')
    maxIm = max(max(max(im)));
    range = [range*maxIm, maxIm];
end

v = zeros(size(im));
v(im >= range(1)) = 1;
v(im > range(2)) = 0;


end

