function [resultMin, resultWS, mdl] = GUI_KNNanalysis(data, features, WS, numNeighbors, waitbarHandle)

%% Classification

usedFeatures = features.listed;

c_all = data.listedGT;

nonzero = find(c_all(:, ones(size(usedFeatures, 2),1)) > 0);
nonzero = reshape(nonzero, size(find(c_all > 0), 1), size(usedFeatures, 2));

f_all = usedFeatures(nonzero);
c_all = c_all(nonzero(:,1)) - 1;

clear mdl
mdl = ClassificationKNN.fit(f_all, c_all, 'NumNeighbors', numNeighbors, 'Distance', 'Euclidean');

waitbar(.5, waitbarHandle);

%% Analysis

KNNresult = predict(mdl, usedFeatures);

resultMin = zeros(size(data.image), features.prefType);
% score1 = zeros(size(data.image), features.prefType);
% score2 = zeros(size(data.image), features.prefType);

resultMin(WS.listedSeeds.positions) = KNNresult;
resultWS = jh_vs_createResult(resultMin, WS.results{2}, WS.results{1}, .1, 'larger', 'prefType', features.prefType);

end
