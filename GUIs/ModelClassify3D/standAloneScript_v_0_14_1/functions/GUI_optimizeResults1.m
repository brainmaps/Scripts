function [data, features, featureList] = GUI_optimizeResults1(data, features, WS)

features.overallResults = ones(size(data.image), features.prefType);
features.overallProbabilities = zeros(size(data.image), features.prefType);
findVesicles = data.WSVesicles > 0 & WS.results{2} > 0;


resultsList = {'Overall (Result)'};
probabilitiesList = {'Overall (Probabilities)'};

features.probabilities = [];
features.results = [];

for i = 1:length(features.parameters)
    
    if ~isa(features.intensities{i}, 'cell')

        values = features.intensities{i}(findVesicles);
        features.probabilities{i} = jh_vs_calculateScore(values, features.intensities{i});
        features.probabilities{i}(features.intensities{i} == 0) = 0;
        features.parameters{i}{1} = min(features.probabilities{i}(findVesicles));

        features.results{i} = zeros(size(data.image), features.prefType);
        features.results{i}(features.probabilities{i} >= features.parameters{i}{1}) = 1;

        features.overallResults = features.overallResults & features.results{i};
        features.overallProbabilities = (features.overallProbabilities + features.probabilities{i}) / 2;


        resultsList = [resultsList, {[features.available{features.inUse{i}}, ' (Result)']}];
        probabilitiesList = [probabilitiesList, {[features.available{features.inUse{i}}, ' (Probabilities)']}];
        
    else
        
        for j = 1:length(features.intensities{i})

            values = features.intensities{i}{j}(findVesicles);
            features.probabilities{i}{j} = jh_vs_calculateScore(values, features.intensities{i}{j});
            features.probabilities{i}{j}(features.intensities{i}{j} == 0) = 0;
            features.parameters{i}{1} = min(features.probabilities{i}{j}(findVesicles));

            features.results{i}{j} = zeros(size(data.image), features.prefType);
            features.results{i}{j}(features.probabilities{i}{j} >= features.parameters{i}{1}) = 1;

            features.overallResults = features.overallResults & features.results{i}{j};
            features.overallProbabilities = (features.overallProbabilities + features.probabilities{i}{j}) / 2;

            
        end
        
    end
    
end

featureList = [resultsList, probabilitiesList];
% parameters.S5.optimization1.Hessian.thresh = parameters.S4.Hessian.thresh;
% parameters.S5.optimization1.Gaussian.thresh = parameters.S4.Gaussian.thresh;
% parameters.S5.optimization1.divergence.thresh = parameters.S4.div.thresh;
% parameters.S5.optimization1.diffSimVes.thresh = parameters.S4.diffSimVes.thresh;



end