function [features, varargout] = jh_vs_featureCalculation( ...
    im, featureNames, parameters, parameterNames, listedWS, listedSeeds, labMin, labWS, ...
    anisotropic, prefType, outputDefinition, waitbarHandle, scriptPath)

%%
features = [];
varout = [];

fprintf('    Feature calculation:\n');

global F calcBasics

calcBasics.labMin = labMin;
calcBasics.labWS = labWS;

for i = 1:length(featureNames)

    fprintf(['        ' featureNames{i} '... ']);
    tic
    
    if ~strcmp(featureNames{i}, 'WS size');
        
        %% Calculate features

        % Get feature and script names
        featureName = ['F_' featureNames{i}];
        scriptName = [scriptPath, featureName, '.m'];

        % Store parameters in temporary field
        F.out = [];
        F.parameters = parameters{i};
        F.mult = 3;
        F.anisotropic = anisotropic;
        F.in = im;
        % Run selected script
        run(scriptName);
                
        %% Determine sub features and flagged features
        
        % Iterate over sub features (e.g. the eigenvalues of the hessian)
        for j = 1:length(F.out)
            
            % Find flag parameters which are set to 1
            flags = cellfun(@(x) strcmp(x(1:3), 'F: '), parameterNames{i}) & cell2mat(parameters{i});
            flagsWOIntAtSeed = flags & ~cellfun(@(x) strcmp(x, 'F: Intensity at seed'), parameterNames{i});
            
            % Intensity values of the WS regions need to be determined if
            % at least one flag other than 'Intensity at seed' is one
            if max(flagsWOIntAtSeed)
                values = cellfun(@(x) {F.out{j}(x)}, listedWS.positions);
            end
            
            % Iterate over the flags and create each feature
            for k = 1:length(flags)
                
                if flags(k)
                    
                    switch parameterNames{i}{k}
                        case 'F: Intensity at seed'
                            features = [features, F.out{j}(listedSeeds.positions)];
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
                progress = ((i-1)*length(F.out) + j) / (length(featureNames) * length(F.out));
                waitbar(progress, waitbarHandle);
            end
                
            
        end        
        
        %% Check for output
        if ~isempty(outputDefinition)
            for j = 1:length(outputDefinition)
                if strcmp(outputDefinition{j}, 'features')
                    varout = [varout, F.out];
                end
            end
        end

        %%
        
        F = rmfield(F, 'out');

    else
        
        features = [features, listedWS.sizes];
        
    end
    
    elapsedTime = toc;
    fprintf('Done in %.2G seconds.\n', elapsedTime);
    
end

clear -global F

varargout{1} = varout;

end
