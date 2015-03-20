function evaluation = GUI_evaluate(WS, classification)

evaluation = sprintf('________________________________________\n');
evaluation = sprintf([evaluation 'Ground truth statistics:\n\n']);

totalClass1 = WS.result.matrixed{2};
totalClass1(classification.groundTruth.matrixed.class1 == 0) = 0;
totalClass1 = length(find(totalClass1 > 0));
evaluation = sprintf([evaluation 'Total class 1: ' num2str(totalClass1) '\n']);

totalClass2 = WS.result.matrixed{2};
totalClass2(classification.groundTruth.matrixed.class2 == 0) = 0;
totalClass2 = length(find(totalClass2 > 0));
evaluation = sprintf([evaluation 'Total class 2: ' num2str(totalClass2) '\n\n']);

truePos = classification.groundTruth.matrixed.class1 ...
    & classification.result.matrixed{2} & WS.result.matrixed{2};
truePos = length(find(truePos > 0));
evaluation = sprintf([evaluation 'True positives:  ' num2str(truePos) '\n']);
falseNeg = classification.groundTruth.matrixed.class1 ...
    & ~classification.result.matrixed{2} & WS.result.matrixed{2};
falseNeg = length(find(falseNeg > 0));
evaluation = sprintf([evaluation 'False negatives: ' num2str(falseNeg) '\n']);
trueNeg = classification.groundTruth.matrixed.class2 ...
    & ~classification.result.matrixed{2} & WS.result.matrixed{2};
trueNeg = length(find(trueNeg > 0));
evaluation = sprintf([evaluation 'True negatives:  ' num2str(trueNeg) '\n']);
falsePos = classification.groundTruth.matrixed.class2 ...
    & classification.result.matrixed{2} & WS.result.matrixed{2};
falsePos = length(find(falsePos > 0));
evaluation = sprintf([evaluation 'False positives: ' num2str(falsePos) '\n']);

end

% 
% %% Watershed regions
% 
% evaluation = sprintf('________________________________________\n');
% evaluation = sprintf([evaluation 'Watershed regions:\n\n']);
% 
% % Determine values
% totalClass1 = data.S3.labMin;
% totalClass1(data.WSVesicles == 0) = 0;
% totalClass1 = length(find(totalClass1 > 0));
% 
% totalClass2 = data.S3.labMin;
% totalClass2(data.WSNoVesicles == 0) = 0;
% totalClass2 = length(find(totalClass2 > 0));
% 
% totalWS = totalClass1 + totalClass2;
% %%%
% 
% evaluation = sprintf([evaluation 'total = ' num2str(totalWS) '\n']);
% evaluation = sprintf([evaluation 'class1 = ' num2str(totalClass1) '\n']);
% evaluation = sprintf([evaluation 'class2 = ' num2str(totalClass2) '\n\n']);
% 
% % Determine values
% labeledClass1 = data.S3.labWS;
% labeledClass1(data.WSVesicles == 0) = 0;
% labels = unique(labeledClass1);
% sizes = zeros(length(labels)-1, 1);
% for i = 2:length(labels)
%     sizes(i-1) = length(find(data.S3.labWS == labels(i)));
% end
% maxSize = max(sizes);
% minSize = min(sizes);
% meanSize = length(find(data.WSVesicles > 0)) / totalClass1;
% %%%
% 
% evaluation = sprintf([evaluation 'CLASS 1\n\n']);
% evaluation = sprintf([evaluation '    minSize = ' num2str(minSize) '\n']);
% evaluation = sprintf([evaluation '    maxSize = ' num2str(maxSize) '\n']);
% evaluation = sprintf([evaluation '    meanSize = ' num2str(meanSize) '\n\n']);
% 
% % Determine values
% labeledClass2 = data.S3.labWS;
% labeledClass2(data.WSNoVesicles == 0) = 0;
% labels = unique(labeledClass2);
% sizes = zeros(length(labels)-1, 1);
% for i = 2:length(labels)
%     sizes(i-1) = length(find(data.S3.labWS == labels(i)));
% end
% maxSize = max(sizes);
% minSize = min(sizes);
% meanSize = length(find(data.WSNoVesicles > 0)) / totalClass2;
% %%%
% 
% evaluation = sprintf([evaluation 'CLASS 2\n\n']);
% evaluation = sprintf([evaluation '    minSize = ' num2str(minSize) '\n']);
% evaluation = sprintf([evaluation '    maxSize = ' num2str(maxSize) '\n']);
% evaluation = sprintf([evaluation '    meanSize = ' num2str(meanSize) '\n\n']);
% 
% %% Minima
% 
% evaluation = sprintf([evaluation '________________________________________\n']);
% evaluation = sprintf([evaluation 'Minima (of WS regions):\n\n']);
% 
% evaluation = sprintf([evaluation 'CLASS 1\n\n']);
% 
% % Determine values
% minGauss = 0;
% maxGauss = 0;
% meanGauss = 0;
% %%%
% 
% evaluation = sprintf([evaluation '    minGaussian = ' num2str(minGauss) '\n']);
% evaluation = sprintf([evaluation '    maxGaussian = ' num2str(maxGauss) '\n']);
% evaluation = sprintf([evaluation '    meanGaussian = ' num2str(meanGauss) '\n\n']);
% 
% % Determine values
% minDiv = 0;
% maxDiv = 0;
% meanDiv = 0;
% %%%
% 
% evaluation = sprintf([evaluation '    minDivergence = ' num2str(minDiv) '\n']);
% evaluation = sprintf([evaluation '    maxDivergence = ' num2str(maxDiv) '\n']);
% evaluation = sprintf([evaluation '    meanDivergence = ' num2str(meanDiv) '\n\n']);
% 
% % Determine values
% values = data.features.hess.iL1L2L3(data.features.hess.iL1L2L3 > 0 & data.WSVesicles > 0);
% minIL1L2L3 = min(values);
% maxIL1L2L3 = max(values);
% meanIL1L2L3 = mean(values);
% %%%
% evaluation = sprintf([evaluation '    minIL1L2L3 = ' num2str(minIL1L2L3) '\n']);
% evaluation = sprintf([evaluation '    maxIL1L2L3 = ' num2str(maxIL1L2L3) '\n']);
% evaluation = sprintf([evaluation '    meanIL1L2L3 = ' num2str(meanIL1L2L3) '\n\n']);
% 
% % Determine values
% minDiffSimVes = 0;
% maxDiffSimVes = 0;
% meanDiffSimVes = 0;
% %%%
% 
% evaluation = sprintf([evaluation '    minDiffSimVes = ' num2str(minDiffSimVes) '\n']);
% evaluation = sprintf([evaluation '    maxDiffSimVes = ' num2str(maxDiffSimVes) '\n']);
% evaluation = sprintf([evaluation '    meanDiffSimVes = ' num2str(meanDiffSimVes) '\n\n']);
% 
% % ----------------------------------------------
% 
% evaluation = sprintf([evaluation 'CLASS 2\n\n']);
% 
% % Determine values
% minGauss = 0;
% maxGauss = 0;
% meanGauss = 0;
% %%%
% 
% evaluation = sprintf([evaluation '    minGaussian = ' num2str(minGauss) '\n']);
% evaluation = sprintf([evaluation '    maxGaussian = ' num2str(maxGauss) '\n']);
% evaluation = sprintf([evaluation '    meanGaussian = ' num2str(meanGauss) '\n\n']);
% 
% % Determine values
% minDiv = 0;
% maxDiv = 0;
% meanDiv = 0;
% %%%
% 
% evaluation = sprintf([evaluation '    minDivergence = ' num2str(minDiv) '\n']);
% evaluation = sprintf([evaluation '    maxDivergence = ' num2str(maxDiv) '\n']);
% evaluation = sprintf([evaluation '    meanDivergence = ' num2str(meanDiv) '\n\n']);
% 
% % Determine values
% values = data.features.hess.iL1L2L3(data.features.hess.iL1L2L3 > 0 & data.WSNoVesicles > 0);
% minIL1L2L3 = min(values);
% maxIL1L2L3 = max(values);
% meanIL1L2L3 = mean(values);
% %%%
% evaluation = sprintf([evaluation '    minIL1L2L3 = ' num2str(minIL1L2L3) '\n']);
% evaluation = sprintf([evaluation '    maxIL1L2L3 = ' num2str(maxIL1L2L3) '\n']);
% evaluation = sprintf([evaluation '    meanIL1L2L3 = ' num2str(meanIL1L2L3) '\n\n']);
% 
% % Determine values
% minDiffSimVes = 0;
% maxDiffSimVes = 0;
% meanDiffSimVes = 0;
% %%%
% 
% evaluation = sprintf([evaluation '    minDiffSimVes = ' num2str(minDiffSimVes) '\n']);
% evaluation = sprintf([evaluation '    maxDiffSimVes = ' num2str(maxDiffSimVes) '\n']);
% evaluation = sprintf([evaluation '    meanDiffSimVes = ' num2str(meanDiffSimVes) '\n\n']);
% 
% 
% %% Proposed thresholds
% 
% evaluation = sprintf([evaluation '________________________________________\n']);
% evaluation = sprintf([evaluation 'Proposed thresholds:\n\n']);
% 
% % Gaussian
% 
% propGaussT = 0;
% propGaussTMin = 0;
% propGaussTMax = 0;
% 
% evaluation = sprintf([evaluation 'GAUSSIAN\n']);
% evaluation = sprintf([evaluation '    t = ' num2str(propGaussT) '\n']);
% evaluation = sprintf([evaluation '    t_min = ' num2str(propGaussTMin) '\n']);
% evaluation = sprintf([evaluation '    t_max = ' num2str(propGaussTMax) '\n']);
% 
% % message = sprintf(1, 'Now reading: %s\n', fullfile(file{n}))
% % sprintf
% end