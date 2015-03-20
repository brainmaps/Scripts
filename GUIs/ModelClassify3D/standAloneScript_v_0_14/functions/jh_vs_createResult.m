function [result, intensities] = jh_vs_createResult(feature, labMin, labWS, thresh, varargin)
%
%   [result, intensities] = jh_vs_createResult(feature, labMin, labWS, thresh)
%   [result, intensities] = jh_vs_createResult(___, 'save', nameRun, nameParam)
%   [result, intensities] = jh_vs_createResult(___, 'prefType', prefType)
%   [result, intensities] = jh_vs_createResult(___, 'smaller')
%   [result, intensities] = jh_vs_createResult(___, 'larger')

%% Check input

% Defaults
saveResults = false;
prefType = class(labMin);
smaller = false;
%
if ~isempty(varargin)
    
    i = 0;
    while i < length(varargin)
        i = i+1;

        if strcmp(varargin{i}, 'save')
            nameRun = varargin{i+1};
            nameParam = varargin{i+2};
            saveResults = true;
            i = i+2;
        elseif strcmp(varargin{i}, 'prefType')
            prefType = varargin{i+1};
            i = i+1;
        elseif strcmp(varargin{i}, 'smaller')
            smaller = true;
        elseif strcmp(varargin{i}, 'larger')
            smaller = false;
        end
        
    end
end

[n1,n2,n3] = size(labMin);
n = n1*n2*n3;

%% Create result

% If negative values are present (do not work for dilation)
minFeature = min(min(min(feature)));
if minFeature < 0
    feature = feature - minFeature + .01;
end

values = zeros(n1, n2, n3, prefType);
values(labMin > 0) = feature(labMin > 0);
clear feature
intensities = values;
clear values
tValues = zeros(n1, n2, n3, prefType);
while ~isequal(intensities,tValues)
    
    tValues = intensities;
    [nh, ~] = jh_getNeighborhood2D(0, 1);
    intensities = imdilate(intensities, nh);
    intensities(labWS == 0) = 0;
    
end
clear tValues

if minFeature < 0
    intensities(intensities > 0) = intensities(intensities > 0) + minFeature - 0.01;
end

result = zeros(n1, n2, n3, prefType);
if smaller 
    result(intensities <= thresh) = 1;
else
    result(intensities >= thresh) = 1;
end
result(labWS == 0) = 0;
clear WSValues

if smaller
    intensities = 1-intensities;
    intensities(labWS == 0) = 0;
end

if saveResults
    fn = jh_buildString(nameRun, '_', nameParam, '_overlayHessResult', '.TIFF');
    saveImageAsTiff3D(jh_overlayMask(im,result), fn, 'rgb');
end

end