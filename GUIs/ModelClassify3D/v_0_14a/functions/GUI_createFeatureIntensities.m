function [data, features] = GUI_createFeatureIntensities(data, features, WS, waitbarHandle)

% if isfield(features, 'listed')
%     features = rmfield(features, 'listed');
%     features = rmfield(features, 'output');
% end

% featureNames = cellfun(@(x) features.available(x), features.inUse);
% parameterNames = cellfun(@(x) features.parameterNames(x), features.inUse);
featureNames = features.pFeatures.methods;
parameterNames = features.pFeatures.parameterNames;

%% Get the feature list and calculated matrices
% [features.result.listed, features.result.matrixed] = jh_vs_featureCalculation(data.image, featureNames, ...
%     features.pFeatures.parameters, parameterNames, WS.listedWS, WS.listedSeeds, WS.results{2}, WS.results{1}, ...
%     data.anisotropic, features.prefType, {'features'}, waitbarHandle, scriptPath);

[features.result.listed, features.result.matrixed] = GUI_featureCalculation(data.image, features.pFeatures, WS, data, data.anisotropic, {'features'}, waitbarHandle);

%% Create empty cell array for matrices for visualization
% The final computation is performed on demand to increase speed and
% decrease memory usage

% if isfield(features, 'matrixed')
%     features = rmfield(features, 'matrixed');
% end
% features.matrixed.atPositions = cell(1, size(features.listed, 2));

%% Determine the string list for the popup box
features.result.names = [];
features.result.namesCalculated = [];

for i = 1:length(featureNames)
    
    if ~strcmp(featureNames{i}, 'WS size')

        len = length(features.pFeatures.subFeatures{i});
        
        for j = 1:len
            
            if strcmp(features.pFeatures.subFeatures{i}{1}, '');
                features.result.namesCalculated = [features.result.namesCalculated, ...
                    featureNames(i)];
            else
                features.result.namesCalculated = [features.result.namesCalculated, ...
                    {[featureNames{i}, '; ' features.pFeatures.subFeatures{i}{j}]}];
            end

            % Find flag parameters which are set to 1
            flags = cellfun(@(x) strcmp(x(1:3), 'F: '), parameterNames{i}) & cell2mat(features.pFeatures.parameters{i});

            for k = 1:length(flags)
                if flags(k)
                    switch parameterNames{i}{k}
                        case 'F: Intensity at seed'
                            features.result.names = [features.result.names, ...
                                {[featureNames{i} '; ' features.pFeatures.subFeatures{i}{j}, ...
                                '@seed']}];
                        case 'F: Mean'
                            features.result.names = [features.result.names, ...
                                {[featureNames{i} '; ' features.pFeatures.subFeatures{i}{j}, ...
                                '@mean']}];
                        case 'F: Standard derivation'
                            features.result.names = [features.result.names, ...
                                {[featureNames{i} '; ' features.pFeatures.subFeatures{i}{j}, ...
                                '@std']}];
                        case 'F: Minimum'
                            features.result.names = [features.result.names, ...
                                {[featureNames{i} '; ' features.pFeatures.subFeatures{i}{j}, ...
                                '@min']}];
                        case 'F: Maximum'
                            features.result.names = [features.result.names, ...
                                {[featureNames{i} '; ' features.pFeatures.subFeatures{i}{j}, ...
                                '@max']}];
                    end
                end
            end
            

        end
    
    else
        
        features.result.names = [features.result.names, ...
            featureNames{i}];
    
    end
    
end

end