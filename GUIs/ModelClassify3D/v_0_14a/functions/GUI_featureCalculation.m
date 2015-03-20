function [features, varargout] = GUI_featureCalculation(im, pFeatures, WS, data, ...
    anisotropic, outputDefinition, waitbarHandle)
%
%   .pFeatures
%       .methods
%       .parameters
%       .parameterNames
%       .scriptPath

%%
features = [];
varout = [];

fprintf('    Feature calculation:\n');

% global F calcBasics
% 
% calcBasics.labMin = labMin;
% calcBasics.labWS = labWS;

global gF
gF.WS = WS;
gF.data = data;

for i = 1:length(pFeatures.methods)

    fprintf(['        ' pFeatures.methods{i} '... ']);
    tic
    
    if ~strcmp(pFeatures.methods{i}, 'WS size');
        
        %% Calculate features

        % Get feature and script names
        featureName = ['F_' pFeatures.methods{i}];
        scriptName = [pFeatures.scriptPath, featureName, '.m'];

        % Store parameters in temporary field
        gF.out = [];
        gF.parameters = pFeatures.parameters{i};
        gF.mult = 3;
        gF.anisotropic = anisotropic;
        gF.in = im;
        % Run selected script
        run(scriptName);
                
        %% Determine sub features and flagged features
        
        % Iterate over sub features (e.g. the eigenvalues of the hessian)
        for j = 1:length(gF.out)
            
            % Find flag parameters which are set to 1
            flags = cellfun(@(x) strcmp(x(1:3), 'F: '), pFeatures.parameterNames{i}) & cell2mat(pFeatures.parameters{i});
            flagsWOIntAtSeed = flags & ~cellfun(@(x) strcmp(x, 'F: Intensity at seed'), pFeatures.parameterNames{i});
            
            % Intensity values of the WS regions need to be determined if
            % at least one flag other than 'Intensity at seed' is one
            if max(flagsWOIntAtSeed)
                values = cellfun(@(x) {gF.out{j}(x)}, WS.result.listed.WS.positions);
            end
            
            % Iterate over the flags and create each feature
            for k = 1:length(flags)
                
                if flags(k)
                    
                    switch pFeatures.parameterNames{i}{k}
                        case 'F: Intensity at seed'
                            features = [features, gF.out{j}(WS.result.listed.seeds.positions)];
                        case 'F: Mean'
                            features = [features, cellfun(@mean, values)];
                        case 'F: Standard derivation'
                            features = [features, cellfun(@std, values)];
                        case 'F: Minimum'
                            features = [features, cellfun(@min, values)];
                        case 'F: Maximum'
                            features = [features, cellfun(@max, values)];
                    end
                    
                end
                
            end
            
            if ~isempty(waitbarHandle)
                progress = ((i-1)*length(gF.out) + j) / (length(pFeatures.methods) * length(gF.out));
                waitbar(progress, waitbarHandle);
            end
                
            
        end        
        
        %% Check for output
        if ~isempty(outputDefinition)
            for j = 1:length(outputDefinition)
                if strcmp(outputDefinition{j}, 'features')
                    varout = [varout, gF.out];
                end
            end
        end

        %%
        
        gF = rmfield(gF, 'out');

    else
        
        features = [features, WS.result.listed.WS.sizes];
        
    end
    
    elapsedTime = toc;
    fprintf('Done in %.2G seconds.\n', elapsedTime);
    
end

clear -global gF

varargout{1} = varout;

end
