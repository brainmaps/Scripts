function [data features] = GUI_optimizeFeature(data, features, index, featureName, parametersToOptimize, range, steps)

%{
% IDs of parameters
parametersToOptimize = {p1, p2, ..., pn} 

% as in parametersToOptimize
range = {{min1, max1}, {min2, max2}, ..., {minn, maxn}}
steps = {s1, s2, ..., sn}
%}

%%
[n1, n2, n3] = size(data.im);
n = n1*n2*n3;

%%

% Prepare the parameters which are to be tested for recursive function call
parametersToTry = [];
for i = 1:length(parametersToOptimize)
    parametersToTry = [parametersToTry, {range{i}{1}:steps{i}:range{i}{2}}];
end

% Prepare whole set of parameters
allParameters = features.parameters{index};
for i = 1:length(parametersToOptimize)
    allParameters{parametersToOptimize{i}} = parametersToTry{i};
end

% Find the annotated vesicles
labWSVesicles = data.S3.labMin;
labWSNoVesicles = data.S3.labMin;
labWSVesicles(data.WSVesicles == 0) = 0;
labWSNoVesicles(data.WSNoVesicles == 0) = 0;

posVesicles = find(labWSVesicles > 0);
posNoVesicles = find(labWSNoVesicles > 0);

% Variables for the analysis results
meanDeviations = [];
stdDeviationsVes = [];
stdDeviationsNoVes = [];


%% Recursive function calls to get a variable amount of stacked for-loops
recursiveParameterIteration(1, []);

function recursiveParameterIteration(I, indices)

    if I <= length(allParameters)
        % These are the for-loops...
        for j = 1:length(allParameters{I})
            recursiveParameterIteration(I+1, [indices, {j}]);
        end
    else
        % ... and this is what happens in the inner for-loop
        % indices contains the current index of each dimension, thus
        % length(indices) being the number of stacked for-loops
        str = num2str(indices{1});
        for j = 2:length(indices)
            str = [str ',' num2str(indices{j})];
        end
        disp(str);

        innerForLoop(indices);

    end

end

%% This is what happens within the inner for-loop
function innerForLoop(indices)
    
    switch featureName
        case 'Divergence'
            
        case 'Gaussian'
            
        case 'Hessian: iL1L2L3'
            
            [~, ~, ~, ~, output] = jh_vs_hessianFeature( ...
                data.im, allParameters{3}(indices{3}), allParameters{2}(indices{2}), ...
                'anisotropic', [1 1 3], 'prefType', features.prefType);
  
        case 'DiffSimVes'
            
    end
    
    valuesVesicles = output(posVesicles);
    valuesNoVesicles = output(posNoVesicles);
    
    meanDeviations = [meanDeviations, mean(abs(mean(valuesVesicles) - valuesNoVesicles))];
    stdDeviationsVes = [stdDeviationsVes, std(valuesVesicles)];
    stdDeviationsNoVes = [stdDeviationsNoVes, std(valuesNoVesicles)];
    
end



figure, plot(meanDeviations, 'color', 'red');
hold on
plot(stdDeviationsVes, 'color', 'green');
plot(meanDeviations ./ stdDeviationsVes, 'color', 'blue');
hold off

figure, plot(meanDeviations, 'color', 'red');
hold on
plot(stdDeviationsVes + stdDeviationsNoVes, 'color', 'green');
plot(meanDeviations - stdDeviationsVes - stdDeviationsNoVes, 'color', 'blue');
hold off

end