function [result, diffSimVes, intensities] = jh_vs_simVes(varargin)
%
% [result, diffSimVes, intensities] = jh_vs_simVes(im, param, pGF, pDiv)
% [result, diffSimVes, intensities] = jh_vs_simVes(im, param, 'GF', GF, pDiv)
% [result, diffSimVes, intensities] = jh_vs_simVes(im, param, 'div', div)
% [result, diffSimVes, intensities] = jh_vs_simVes(___, 'WS', labMin, labWS)
% [result, diffSimVes, intensities] = jh_vs_simVes(___, 'performWS', pWS)
% [result, diffSimVes, intensities] = jh_vs_simVes(___, 'save', nameRun, nameParam)
% [result, diffSimVes, intensities] = jh_vs_simVes(___, 'anisotropic', anisotropic)
% [result, diffSimVes, intensities] = jh_vs_simVes(___, 'prefType', prefType)
% [result, diffSimVes, intensities] = jh_vs_simVes(___, 'normalize', normalize)
% [~, diffSimVes, ~] = jh_vs_simVes(___, 'onlyResultImage')
%
%
% STRUCTS
%   param   .thresh
%           .sMex
%           .sGauss
%
%   pGF     .sigma
%           .mult
%           
%   pDiv    .sigma
%           .mult
%
%   pWS     .conn
%           .maxDepth
%           .maxSize
%
% NEEDED FUNCTIONS
%   jh_dip_imageGradient3D
%   jh_dip_divergenceFromGradient3D
%   jh_waterseeds3D
%   jh_dip_mexicanHat3D
%   jh_dip_gaussianFilter3D
%   jh_normalizeMatrix
%   jh_buildString
%   saveImageAsTiff3D
%
% NEEDED LIBRARIES
%   DIPlib

%% Check input

% Defaults
anisotropic = [1 1 1];
bGF = true;
bDiv = true;
bWS = true;
saveResults = false;
normalize = false;
bOnlyResultImage = false;
% Check input

if ~isempty(varargin)
    if length(varargin) == 1
        result = [];
        disp('jh_vs_simVes: Missing parameters')
        return
    end
    
    % First input: the image
    im = varargin{1};
    prefType = class(im);
    % Second input: parameters
    param = varargin{2};
    
    i = 2;
    while i < length(varargin)
        i = i+1;
        
        if strcmp(varargin{i}, 'GF')
            bGF = false;
            GF = varargin{i+1};
            pDiv = varargin{i+2};
            i = i+2;
        elseif strcmp(varargin{i}, 'div')
            bDiv = false;
            bGF = false;
            div = varargin{i+1};
            i = i+1;
        elseif strcmp(varargin{i}, 'WS')
            bWS = false;
            labMin = varargin{i+1};
            labWS = varargin{i+2};
            i = i+2;
        elseif strcmp(varargin{i}, 'performWS')
            pWS = varargin{i+1};
            i = i+1;
        elseif strcmp(varargin{i}, 'save')
            nameRun = varargin{i+1};
            nameParam = varargin{i+2};
            saveResults = true;
            i = i+2;
        elseif strcmp(varargin{i}, 'anisotropic')
            anisotropic = varargin{i+1};
            i = i+1;
        elseif strcmp(varargin{i}, 'prefType')
            prefType = varargin{i+1};
            i = i+1;
        elseif strcmp(varargin{i}, 'normalize')
            normalize = true;
        elseif strcmp(varargin{i}, 'onlyResultImage')
            bWS = false;
            bOnlyResultImage = true;
        else
            if i == 3
                pGF = varargin{i};
                pDiv = varargin{i+1};
                i = i+1;
            else
                % error
            end
        end
                    
    end
    
else
    
    result = [];
    disp('jh_vs_simVes: No image or parameters found')
    return

end
    

%%

%{

Versuch: künstliche Vesikel sollen, wenn unbeeinflusst durch benachbarte,
die Größe ihres Pendants bekommen. Wenn sie beeinflusst werden, sollen sie
entsprechend größer sein.

%}
%% Basics

[n1,n2,n3] = size(im);
n = n1*n2*n3;

%% Image gradient

if bGF
    [GF, magGF] = jh_dip_imageGradient3D(im, pGF.sigma, pGF.mult, anisotropic);

    if normalize
        magGF = jh_normalizeMatrix(magGF);
    end
    if saveResults
        fn = jh_buildString(nameRun, '_', nameParam, '_1magGF', '.TIFF');
        saveImageAsTiff3D(magGF, fn);
    end
    clear magGF pGF
end


%% Divergence

if bDiv
    div = jh_dip_divergenceFromGradient3D(GF, pDiv.sigma, pDiv.mult, anisotropic);
    clear GF pDiv
    
    if saveResults
        fn = jh_buildString(nameRun, '_', nameParam, '_2div', '.TIFF');
        saveImageAsTiff3D(jh_normalizeMatrix(div), fn);
    end
end

%% Watershed of the divergence

if bWS
    [labWS,labMin] = jh_waterseeds3D(div, 'lab', pWS.conn, pWS.maxDepth, pWS.maxSize);
%     labMinWSNotCleared = labMinWS;
%     % Clear everything near the borders
%     labMinWS = jh_clearNearBorder(labMinWS, 3, 3, 1);
end


%% Create artificial vesicles

simVes = zeros(n1,n2,n3, prefType);
% Add ones at centers of potential vesicles
simVes(labMin > 0) = div(labMin > 0);

% smooth
simVes = jh_dip_mexicanHat3D(simVes, param.sMex, 3, anisotropic, 1);

saveSimVes = jh_normalizeMatrix(simVes);

if saveResults
    fn = jh_buildString(nameRun, '_', nameParam, '_3simVes', '.TIFF');
    saveImageAsTiff3D(saveSimVes, fn);
end
clear saveSimVes

%% Create difference to divergence

imDiffDiv = abs(div - simVes);
clear simVes div

if normalize
    imDiffDiv = jh_normalizeMatrix(imDiffDiv);
end
if saveResults
    fn = jh_buildString(nameRun, '_', nameParam, '_4diff', '.TIFF');
    saveImageAsTiff3D(imDiffDiv, fn);
end

diffSimVes = jh_dip_gaussianFilter3D(imDiffDiv, param.sGauss, 3, anisotropic, 'normalizeKernel');
clear imDiffDiv

if normalize
    diffSimVes = jh_normalizeMatrix(diffSimVes);
end

if saveResults
    fn = jh_buildString(nameRun, '_', nameParam, '_5gDiff', '.TIFF');
    saveImageAsTiff3D(diffSimVes, fn);
end

%% Evaluation

if ~bOnlyResultImage
    [result, intensities] = jh_vs_createResult(diffSimVes, labMin, labWS, param.thresh, ...
        'prefType', 'single', 'smaller');
end

end

