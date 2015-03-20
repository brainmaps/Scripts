function [result, varargout] = jh_synapseSeg3D(data, pWS, pFeatures, pClassification, pPostProcessing, varargin)
%
% SYNOPSIS
%   [result] = jh_synapseSeg3D(im, data, pWS, pFeatures, pClassification, pPP)
%   [result, calculated] = jh_synapseSeg3D(___, 'output', outputDefinition)
%   [result, calculated] = jh_synapseSeg3D(___, 'prefType', prefType)
%   [result, calculated] = jh_synapseSeg3D(___, 'anisotropic', anisotropic)
%   [result, calculated] = jh_synapseSeg3D(___, 'save', toSave, folder, nameRun)
%
% INPUT
%   data: Structure
%       .image
%       .anisotropic
%       .prefType
%   pWS: Structure
%       .preStep
%           .type
%           .bInvert
%           .bInvertRaw
%           .parameters
%       .parameters
%           .conn
%           .maxDepth
%           .maxSize
%       .scriptPath
%   .pFeatures
%       .methods
%       .parameters
%       .parameterNames
%       .scriptPath
%   pClassification: Structure
%       .type
%       .model
%   pPP: Structure (postProcessing)
%       .method
%       .parameters
%   outputDefinition: Cell array defining which calculated steps are
%       returned
%       possible values: 'WS', 'features', 'classification', and
%           'postProcessing'
%       e.g.: {'WS', 'postProcessing'} returnes 1x2 cell array containing
%           {1} watershed basins and seeds, and
%           {2} postProcessing
%       Note: Returning the sub-steps prevents clearing of according 
%           matrices which leads to increased memory usage
%   toSave: Cell array defining which matrices are saved
%       possible values: 'result', 'WS', 'features', 'classification', and
%           'postProcessing'
%   folder: String defining the target folder
%   nameRun: String which is included into the file name
%
% OUTPUT
%   result: Labeled vesicle clouds
%   calculated:
%

%% Check input

overallElapsedTimerValue = tic;

fprintf('\n>> START >>\n\n')
fprintf('    Checking input... ')

% Defaults
outputDefinition = [];
prefType = 'double';
anisotropic = [1 1 1];
toSave = [];
% Check input
i = 0;
while i < length(varargin)
    i = i+1;
    
    if strcmp(varargin{i}, 'output')
        outputDefinition = varargin{i+1};
        i = i+1;
    elseif strcmp(varargin{i}, 'prefType')
        prefType = varargin{i+1};
        i = i+1;
    elseif strcmp(varargin{i}, 'anisotropic')
        anisotropic = varargin{i+1};
        i = i+1;
    elseif strcmp(varargin{i}, 'save')
        toSave = varargin{i+1};
        folder = varargin{i+2};
        nameRun = varargin{i+3};
        i = i+3;

    end
    
end

fprintf('Input feasible.\n\n');

%%

idRunning = 1;
padID = 2;
if ~isempty(outputDefinition)
    varargout = cell(1, length(outputDefinition));
end

%%

WS.pWS = pWS;
features.pFeatures = pFeatures;


%% Calculate the desired input image and watershed

fprintf('    Calculating watershed basins... ');
tic

WS.result.matrixed = GUI_watershedFromScript( ...
    data.image, pWS, ...
    'prefType', prefType, ...
    'dimensions', pWS.parameters.dimensions, ...
    'anisotropic', anisotropic);

[WS.result.listed.WS, WS.result.listed.seeds] = GUI_labeledWS2Listed( ...
    WS.result.matrixed{1}, WS.result.matrixed{2}, ...
    jh_dip2MatConnectivity(pWS.parameters.conn, pWS.parameters.dimensions));

% Check for output
if ~isempty(outputDefinition)
    for i = 1:length(outputDefinition)
        if strcmp(outputDefinition{i}, 'WS')
            varargout{i} = WS.result;
        end
    end
end
% For saving
if ~isempty(toSave)
    for i = 1:length(toSave)
        if strcmp(toSave{i}, 'WS')
            save([folder filesep nameRun filesep 'WS'], 'WS');
        end
    end
end

% The calculated matrix is not needed anymore
WS.result.matrixed{4} = [];

elapsedTime = toc;
fprintf('Done in %.2G seconds.\n\n', elapsedTime);


%% Calculate necessary features

fprintf('    Calculating necessary features: \n')
tmrValue = tic;
% 
% features = [];

features.pFeatures = pFeatures;
[~, features] = GUI_createFeatureIntensities(data, features, WS, []);
% [features.result.listed, features.result.matrixed] = GUI_featureCalculation(data.image, pFeatures, WS, data, anisotropic, outputDefinition, []);

% Check for output
if ~isempty(outputDefinition)
    for j = 1:length(outputDefinition)
        if strcmp(outputDefinition{j}, 'features')
            varargout{j} = features.result;
        end
    end
end
% For saving
if ~isempty(toSave)
    for i = 1:length(toSave)
        if strcmp(toSave{i}, 'features')
            save([folder filesep nameRun filesep 'features'], 'features');
        end
    end
end

clear output

elapsedTime = toc(tmrValue);
fprintf('    Features done in %.2G seconds.\n\n', elapsedTime);

%% Classification

fprintf('    Classification... ')
tic

if strcmp(pClassification.method, 'SVM')
%     classResult = svmclassify(pClassification.model, features);
    [classResult, score] = predict(pClassification.model, features.result.listed);

elseif strcmp(pClassification.method, 'KNN')
    classResult = predict(pClassification.model, features.result.listed);
end

classifiedMin = zeros(size(data.image), prefType);
classifiedMin(WS.result.listed.seeds.positions) = classResult;
% classified = jh_vs_createResult(classifiedMin, labMin, labWS, .1, 'larger', 'prefType', prefType);
nh = jh_getNeighborhoodFromConnectivity(pWS.parameters.conn, pWS.parameters.dimensions);
classification.result.matrixed{2} = jh_regionGrowing3D(classifiedMin, WS.result.matrixed{1}, nh, 0, 'l', 'prefType', 'single', 'iterations', 0);

if ~isempty(outputDefinition)
    for i = 1:length(outputDefinition)
        if strcmp(outputDefinition{i}, 'classification')
            classification.result.matrixed{1} = classifiedMin;
        end
    end
end

clear resultMin classResult

% Score matrix
resultScore = zeros(size(data.image), prefType);
resultScore(WS.result.listed.seeds.positions) = score(:,2);
minResultScore = min(min(min(resultScore)));
resultScore(WS.result.listed.seeds.positions) = resultScore(WS.result.listed.seeds.positions) - minResultScore +1;
resultScore = jh_regionGrowing3D(resultScore, WS.result.matrixed{1}, nh, 0, 'l', 'prefType', prefType, 'iterations', 0);
resultScore(WS.result.matrixed{1} ~= 0) = resultScore(WS.result.matrixed{1} ~= 0) + minResultScore -1;
classification.result.matrixed{3} = resultScore;
clear minResultScore resultScore

classification.result.names = { ...
    'Classification: Minima', ...
    'Classification: WS', ...
    'Classification: Score', ...
    'Classification: Score (cut off)'};


% Check for output
if ~isempty(outputDefinition)
    for i = 1:length(outputDefinition)
        if strcmp(outputDefinition{i}, 'classification')
            
            outScore = classification.result.matrixed{3};
            outScore(outScore < -5) = -5;
            outScore(WS.result.matrixed{1} == 0) = -6;
            outScore = jh_normalizeMatrix(outScore);
            classification.result.matrixed{4} = outScore;
            clear outScore
            varargout{i} = classification.result;
        end
    end
end
% For saving
if ~isempty(toSave)
    for i = 1:length(toSave)
        if strcmp(toSave{i}, 'classification')
            save([folder filesep nameRun filesep 'classification'], 'classification');
        end
    end
end

elapsedTime = toc;
fprintf('Done in %.2G seconds.\n\n', elapsedTime);

%% postProcessing

fprintf('    Calculating vesicle Clouds... ');
tmrValue = tic;

% [postProcessing, classified] = jh_vs_calculateVesicleClouds(im, resultScore, classified, labWS, labMin, prefType);
% [postProcessing, classified] = jh_vs_calculateVesicleClouds_v2(im, resultScore, classified, labWS, prefType);
% [postProcessing, classified] = jh_vs_calculateVesicleClouds_v3(im, resultScore, classified, labWS, labMin, prefType);
%     pPostProcessing.dimensions = dimensions;
%     [postProcessing, classified, ...
%      vcScore, nhScore] = ...
%         jh_vs_calculateVesicleClouds_v5( ...
%         im, classified, {labWS, labMin}, ...
%         'parameters', pPostProcessing, ...
%         'prefType', prefType, ...
%         'vesicleScores', resultScore, 0, ...
%         'anisotropic', anisotropic);

% pPP.method = pPostProcessing.method;
% pPP.parameters = pPostProcessing.parameters;
% pPP.dimensions = dimensions;
% pPP.WS = WS;
% pPP.data = data;
% pPP.features = features;
% pPP.scriptPath = [data.folders.main postProcessing.folder];

[postProcessing.result.matrixed, postProcessing.result.names] = GUI_postProcessingFromScript( ...
    data.image, pPostProcessing, ...
    WS, data, features, classification, ...
    'anisotropic', anisotropic);

    
% fprintf('        Excluding solitary vesicles... ');
% tic
% 
% [kernel, ~] = jh_getNeighborhood3D(1, 12, 'anisotropic', [1 1 3]);
% 
% score = im2mat(convolve(classifiedMin > 0, kernel));
% clear kernel;
% tScore = zeros(size(score), prefType);
% tScore(score < 5) = 1;
% solitaryMin = zeros(size(score), prefType);
% solitaryMin(classifiedMin > 0) = tScore(classifiedMin > 0);
% clear score tscore;
% 
% % solitaryWS = jh_vs_createResult(solitary, WS.results{2}, WS.results{1}, .1, 'larger', 'prefType', data.prefType);
% nh = [1, 1, 1; 1, 1, 1; 1, 1, 1];
% solitaryWS = jh_regionGrowing3D(solitaryMin, labWS, nh, 0, 'l', 'prefType', 'single', 'iterations', 0);
% clear nh;
% 
% classified(solitaryWS > 0) = 0;
% % classifiedMin(solitaryMin > 0) = 0;
% clear solitaryMin solitaryWS
% 
% elapsedTime = toc;
% fprintf('Done in %.2G seconds.\n', elapsedTime);
% 
% fprintf('        Calculating vesicle clouds... ');
% tic
% 
% postProcessing = jh_vs_vesicleCloudsFromVesicles2(im, classified, labMin, prefType);

% Check for output
if ~isempty(outputDefinition)
    for i = 1:length(outputDefinition)
        if strcmp(outputDefinition{i}, 'postProcessing')
            varargout{i} = postProcessing.result;
        end
    end
end
% For saving
if ~isempty(toSave)
    for i = 1:length(toSave)
        if strcmp(toSave{i}, 'postProcessing')
            save([folder filesep nameRun filesep 'postProcessing'], 'postProcessing');
        end
    end
end

result = postProcessing.result.matrixed{1};
clear postProcessing


elapsedTime = toc;
fprintf('Done in %.2G seconds.\n', elapsedTime);


elapsedTime = toc(tmrValue);
fprintf('Done in %.2G seconds.\n\n', elapsedTime);

%% The algorithm ends here 

overallElapsedTime = toc(overallElapsedTimerValue);
fprintf('    Overall elapsed time: %.2G seconds\n\n', overallElapsedTime);
fprintf('<<< DONE <<<\n\n');

end

