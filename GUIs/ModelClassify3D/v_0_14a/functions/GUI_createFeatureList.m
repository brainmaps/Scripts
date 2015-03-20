function featureList = GUI_createFeatureList(parameters)

featureList = [];
for i = 1:length(parameters.available)
    
    
    for j = 1:length(parameters.subAvailable{i})
        featureName = [];
        if ~strcmp(parameters.subAvailable{i}{j}, '')
            featureName = [parameters.available{i} ': ' parameters.subAvailable{i}{j}];
        else 
            featureName = parameters.available{i};
        end
        featureList = [featureList, {featureName}];
    end
    
end

end