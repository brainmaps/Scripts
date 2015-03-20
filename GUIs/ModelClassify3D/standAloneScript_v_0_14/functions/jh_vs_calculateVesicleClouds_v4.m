function [vc, v, vcScore, nhScore] = jh_vs_calculateVesicleClouds_v4(im, vesiclePrediction, WS, varargin)
%
% SYNOPSIS
%   [vc, v, vcScore, nhScore] = jh_vs_calculateVesicleClouds(im, vesiclePrediction, WS)
%   [vc, v, vcScore, nhScore] = jh_vs_calculateVesicleClouds(___, 'parameters', p)
%   [vc, v, vcScore, nhScore] = jh_vs_calculateVesicleClouds(___, 'vesicleScores', vesicleScores, thresh)
%   [vc, v, vcScore, nhScore] = jh_vs_calculateVesicleClouds(___, 'prefType', prefType)
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
%
% PARAMETERS
%     [parameter = defaultValue]
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
p.excludeSolitary.enable = true;
p.excludeSolitary.nhRadius = 12;
p.excludeSolitary.thresh = 7;
p.vesicleClouds.WS.conn = 2;
p.vesicleClouds.WS.maxDepth = 1;
p.vesicleClouds.WS.maxSize = 10;
p.vesicleClouds.WS.source = 'HessianL1';
p.vesicleClouds.WS.sourceInvert = 'true';
p.vesicleClouds.WS.sourceParameters = {2};
p.vesicleClouds.WS.connect = true;
p.vesicleClouds.sizeExclusion = 1000;
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
        end
        
    end
    
end

%% Exclude solitary vesicles

if p.excludeSolitary.enable
    % Get seeds of predicted vesicles
    classifiedMin = zeros(size(vesiclePrediction), prefType);
    classifiedMin(WS{2} > 0) = vesiclePrediction(WS{2} > 0);

    % Convolve with spherical neighborhood
    [kernel, ~] = jh_getNeighborhood3D(1, p.excludeSolitary.nhRadius, 'anisotropic', [1 1 3]);
    nhScore = im2mat(convolve(classifiedMin > 0, kernel));
    clear kernel;

    % Do the thresholding to get the solitary seeds
    tScore = zeros(size(nhScore), prefType);
    tScore(nhScore < p.excludeSolitary.thresh) = 1;
    solitaryMin = zeros(size(nhScore), prefType);
    solitaryMin(classifiedMin > 0) = tScore(classifiedMin > 0);
    clear tscore;

    % Grow the solitary seeds to get the WS basins of the solitary vesicles
    nh = [1, 1, 1; 1, 1, 1; 1, 1, 1];
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

vc = vesicleCloudsFromVesicles(im, v, prefType, ...
    p.vesicleClouds.WS.conn, ...
    p.vesicleClouds.WS.maxDepth, ...
    p.vesicleClouds.WS.maxSize, ...
    p.vesicleClouds.WS.source, ...
    p.vesicleClouds.WS.sourceParameters, ...
    p.vesicleClouds.WS.sourceInvert);

%% Connect the vesicle Cloud WS basins

if p.vesicleClouds.WS.connect
    [nh, ~, ~] = jh_getNeighborhood3D(0, 1);
    vc = imerode(imdilate(vc, nh), nh);
    clear nh
end

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

%% For output

vc = jh_normalizeMatrix(vc);
vcScore = jh_normalizeMatrix(single(vcScore));
vcScore(vc == 0) = 0;
nhScore = jh_normalizeMatrix(single(nhScore));

end


function vc = vesicleCloudsFromVesicles(im, vesicles, prefType, conn, maxDepth, maxSize, source, sParam, invertSource)

vc = imerode(vesicles, [1,1,1; 1,1,1; 1,1,1]);
clear vesicles

switch source
    case 'HessianL1'
        [s, ~, ~] = jh_dip_hessian3D(im, sParam{1}, 3, [1 1 3]); 
    case 'HessianL2'
        [~, s, ~] = jh_dip_hessian3D(im, sParam{1}, 3, [1 1 3]); 
    case 'HessianL3'
        [~, ~, s] = jh_dip_hessian3D(im, sParam{1}, 3, [1 1 3]); 
    case 'HessianL1_2Sigmas'
        [s1, ~, ~] = jh_dip_hessian3D(im, sParam{1}, 3, [1 1 3]); 
        [s2, ~, ~] = jh_dip_hessian3D(im, sParam{2}, 3, [1 1 3]); 
        s = s1 .* s2;
        clear s1 s2
    case 'Gaussian'
        s = jh_dip_gaussianFilter3D(im, sParam{1}, 3, [1 1 3], 'normalizeKernel');
    case 'Divergence'
        [GF, ~] = jh_dip_imageGradient3D(im, sParam{1}, 3, [1 1 3]);
        s = jh_dip_divergenceFromGradient3D(GF, sParam{2}, 3, [1 1 3]);
        clear GF
    case 'Magnitude'
        [~, s] = jh_dip_imageGradient3D(im, sParam{1}, 3, [1 1 3]);
end

if invertSource
    s = jh_invertImage(s);
end

dipSeeds = minima(s, conn, 0);
WS_hess = im2mat(jh_dip_waterseed(dipSeeds, s, conn, maxDepth, maxSize));
clear s conn maxDepth maxSize dipSeeds

[nh, ~] = jh_getNeighborhood3D(0, 1); 
vc = jh_regionGrowing3D(vc, WS_hess, nh, 0, 'l', 'prefType', prefType, 'iterations', 0);

CC = bwconncomp(vc, 18);
% excludeSmall = find(cellfun(@length, CC.PixelIdxList) > sizeEx);
% CC.NumObjects = length(excludeSmall);
% CC.PixelIdxList = CC.PixelIdxList(excludeSmall);
% clear excludeSmall

vc = single(labelmatrix(CC));

vc(WS_hess == 0) = 0;
clear WS_hess

end