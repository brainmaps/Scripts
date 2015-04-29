function [resultMin, resultWS, SVMStruct, resultScore] = GUI_SVManalysis(data, features, WS, classification, waitbarHandle)

%% Classification

usedFeatures = features.result.listed;

c_all = classification.groundTruth.listed;

nonzero = find(c_all(:, ones(size(usedFeatures, 2),1)) > 0);
nonzero = reshape(nonzero, size(find(c_all > 0), 1), size(usedFeatures, 2));

f_all = usedFeatures(nonzero);
c_all = c_all(nonzero(:,1)) - 1;

% SVMStruct = svmtrain(f_all, c_all, 'kernel_function', 'polynomial', 'polyorder', 2, 'kktviolationlevel', 0.5, 'showplot', true);

% SVMStruct = fitcsvm(f_all, c_all, 'kernelfunction', 'polynomial', 'PolynomialOrder', 2, 'KKTTolerance', 0.5, 'Solver', 'SMO');
SVMStruct = fitcsvm(f_all, c_all, 'kernelfunction', 'polynomial', 'PolynomialOrder', 2, 'Cost', [0, 100; 1, 0], 'Standardize',true);

waitbar(.5, waitbarHandle);

%% Analysis

% SVMresult = svmclassify(SVMStruct, usedFeatures);
[SVMresult, score] = predict(SVMStruct, usedFeatures);

resultMin = zeros(size(data.image), features.prefType);
% score1 = zeros(size(data.image), features.prefType);
% score2 = zeros(size(data.image), features.prefType);

resultMin(WS.result.listed.seeds.positions) = SVMresult;
nh = jh_getNeighborhoodFromConnectivity(WS.pWS.parameters.conn, WS.pWS.parameters.dimensions);
% resultWS = jh_vs_createResult(resultMin, WS.results{2}, WS.results{1}, .1, 'larger', 'prefType', features.prefType);
resultWS = jh_regionGrowing3D(resultMin, WS.result.matrixed{1}, nh, 0, 'l', ...
    'iterations', 0, ...
    'prefType', data.prefType);

% Score matrix
resultScore = zeros(size(data.image), data.prefType);
resultScore(WS.result.listed.seeds.positions) = score(:,2);
minResultScore = min(min(min(resultScore)));
resultScore(WS.result.listed.seeds.positions) ...
    = resultScore(WS.result.listed.seeds.positions) - minResultScore +1;
resultScore = jh_regionGrowing3D(resultScore, WS.result.matrixed{1}, nh, 0, 'l', 'prefType', data.prefType, 'iterations', 0);
resultScore(WS.result.matrixed{1} ~= 0) = resultScore(WS.result.matrixed{1} ~= 0) + minResultScore -1;


end
