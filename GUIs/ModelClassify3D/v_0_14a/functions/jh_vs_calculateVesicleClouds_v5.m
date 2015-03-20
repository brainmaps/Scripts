function [vc, v, vcScore, nhScore] = jh_vs_calculateVesicleClouds_v5(im, vesiclePrediction, WS, varargin)
%
% SYNOPSIS
%   [vc, v, vcScore, nhScore] = jh_vs_calculateVesicleClouds(im, vesiclePrediction, WS)
%   [vc, v, vcScore, nhScore] = jh_vs_calculateVesicleClouds(___, 'parameters', p)
%   [vc, v, vcScore, nhScore] = jh_vs_calculateVesicleClouds(___, 'vesicleScores', vesicleScores, thresh)
%   [vc, v, vcScore, nhScore] = jh_vs_calculateVesicleClouds(___, 'prefType', prefType)
%   [vc, v, vcScore, nhScore] = jh_vs_calculateVesicleClouds(___, 'anisotropic', anisotropic)
%
% INPUT
%   im: image
%   vesiclePrediction: Vesicle prediction from previous calculations
%   WS: Cell array describing the WS which was used for calculations
%       WS{1}: labeled WS regions; WS{2}: labeled Seeds
%   p: parameter structure (see below)
%   vesicleScores: score matrix describing the probability of a vesicle for
%       each WS basin
%   thresh: vesicle clouds with lower total score will be excluded
%   prefType: preferred data type
%   anisotropic: specifies anisotropic voxels; e.g., anisotropic = [1 1 3]
%       default: anisotropic = [1 1 1]
%
% PARAMETERS
%     [parameter = defaultValue]
%     p.dimensions = 3;
%     p.excludeSolitary.conn = 2;
%     p.excludeSolitary.enable = true;
%     p.excludeSolitary.nhRadius = 12;
%     p.excludeSolitary.thresh = 7;
%     p.vesicleClouds.WS.conn = 2;
%     p.vesicleClouds.WS.maxDepth = 1;
%     p.vesicleClouds.WS.maxSize = 10;
%     p.vesicleClouds.WS.source = 'HessianL1';
%     p.vesicleClouds.WS.sourceParameters = {2};
%     p.vesicleClouds.WS.connect = true;
%     p.vesicleClouds.sizeExclusion = 1000;


%% Check input

% Defaults
bVesicleScores = false;
prefType = 'single';
anisotropic = [1 1 1];
p.excludeSolitary.enable = true;
p.dimensions = 2;
p.excludeSolitary.conn = 2;
p.excludeSolitary.nhRadius = 12; % 12
p.excludeSolitary.thresh = 0; % 7
p.vesicleClouds.conn = 2;
p.vesicleClouds.dimensions = 2;
p.vesicleClouds.sizeExclusion = 0;
% Check input
if ~isempty(varargin)
    
    i = 0;
    while i < length(varargin)
        i = i+1;
        
        if strcmp(varargin{i}, 'vesicleScores');
            bVesicleScores = true;
            vesicleScores = varargin{i+1};
            thresh = varargin{i+2};
            i = i+2;
        elseif strcmp(varargin{i}, 'prefType')
            prefType = varargin{i+1};
            i = i+1;
        elseif strcmp(varargin{i}, 'parameters')
            p = varargin{i+1};
            i = i+1;
        elseif strcmp(varargin{i}, 'anisotropic')
            anisotropic = varargin{i+1};
            i = i+1;
        end
        
    end
    
end

%% Exclude solitary vesicles

nhScore = [];
if p.excludeSolitary.enable
    % Get seeds of predicted vesicles
    classifiedMin = zeros(size(vesiclePrediction), prefType);
    classifiedMin(WS{2} > 0) = vesiclePrediction(WS{2} > 0);

    % Convolve with spherical neighborhood
    [kernel, ~] = jh_getNeighborhood3D(1, p.excludeSolitary.nhRadius, 'anisotropic', anisotropic);
    nhScore = im2mat(convolve(classifiedMin > 0, kernel));
    clear kernel;

    % Do the thresholding to get the solitary seeds
    tScore = zeros(size(nhScore), prefType);
    tScore(nhScore < p.excludeSolitary.thresh) = 1;
    solitaryMin = zeros(size(nhScore), prefType);
    solitaryMin(classifiedMin > 0) = tScore(classifiedMin > 0);
    clear tscore;

    % Grow the solitary seeds to get the WS basins of the solitary vesicles
    nh = jh_getNeighborhoodFromConnectivity(p.excludeSolitary.conn, p.WS.dimensions);
    solitaryWS = jh_regionGrowing3D(solitaryMin, WS{1}, nh, 0, 'l', 'prefType', 'single', 'iterations', 0);
    clear nh;

    % exclude the determined solitary vesicles
    vesiclePrediction(solitaryWS > 0) = 0;
    clear solitaryMin solitaryWS 
    v = vesiclePrediction;
    clear vesiclePrediction
    
else
    nhScore = [];
    v = vesiclePrediction;
    clear vesiclePrediction;
end

%% Calculate vesicle clouds

vc = vesicleCloudsFromVesicles(v, ...
    p.vesicleClouds.conn, ...
    p.vesicleClouds.dimensions, ...
    anisotropic, ...
    p.vesicleClouds.smoothing);

% %% Connect the vesicle Cloud WS basins
% 
% if p.vesicleClouds.WS.connect
%     [nh, ~, ~] = jh_getNeighborhood3D(0, 1);
%     vc = imerode(imdilate(vc, nh), nh);
%     clear nh
% end

%% Size exclusion 

STATS = regionprops(vc, 'PixelIdxList');
PixelIdxList = {STATS.PixelIdxList};
excludeSmall = find(cellfun(@length, PixelIdxList) > p.vesicleClouds.sizeExclusion);
CC.Connectivity = 18;
CC.ImageSize = size(im);
CC.NumObjects = length(excludeSmall);
CC.PixelIdxList = PixelIdxList(excludeSmall);
clear excludeSmall
vc = single(labelmatrix(CC));
clear CC PixelIdxList excludeSmall;


%% Exclude vesicle clouds with low score

vcScore = [];
if bVesicleScores
    
    vcScore = zeros(size(im), prefType);
    STATS = regionprops(vc, vesicleScores, 'PixelIdxList', 'MeanIntensity');
    meanInts = {STATS.MeanIntensity};
    PixelIdxList = {STATS.PixelIdxList};
    
    for i = 1:length(meanInts)
        
        vcScore(PixelIdxList{i}) = meanInts{i};
        
    end
    
end

%% Pre step (filling of holes)

if ~isempty(nhScore)
    
    nh = jh_getNeighborhoodFromConnectivity(p.excludeSolitary.conn, p.WS.dimensions);
    vc = jh_regionGrowing3D(vc, nhScore, nh, p.excludeSolitary.thresh, 'l', prefType, 'iterations', 5);
%     vc = jh_regionGrowing3D(vc, nhScore, nh, 1, 'l', prefType, 'iterations', 10);

    nhScore = jh_normalizeMatrix(single(nhScore));

end

%% For output

vc = jh_normalizeMatrix(vc);
vcScore = jh_normalizeMatrix(single(vcScore));
vcScore(vc == 0) = 0;

end


function vc = vesicleCloudsFromVesicles(vesicles, conn, dimensions, anisotropic, smoothing)
nh = jh_getNeighborhoodFromConnectivity(conn, dimensions);
vc = imerode(imdilate(vesicles, nh), nh);
clear vesicles

CC = bwconncomp(vc, jh_dip2MatConnectivity(conn, dimensions));
% excludeSmall = find(cellfun(@length, CC.PixelIdxList) > sizeEx);
% CC.NumObjects = length(excludeSmall);
% CC.PixelIdxList = CC.PixelIdxList(excludeSmall);
% clear excludeSmall

vc = single(labelmatrix(CC));

% For BRAX: 0, 1
[nh, ~, ~] = jh_getNeighborhood3D(0, smoothing, 'anisotropic', anisotropic);
vc = imerode(imdilate(vc, nh), nh);

end