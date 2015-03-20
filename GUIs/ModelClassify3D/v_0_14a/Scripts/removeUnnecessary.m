% load([pwd '\project.mat']);
global WS features postProcessing fixedModel
saveStuff.WS = WS;
saveStuff.features = features;
saveStuff.fixedModel = fixedModel;
saveStuff.postProcessing = postProcessing;

if isfield(saveStuff, 'data')
    saveStuff = rmfield(saveStuff, 'data');
end
if isfield(saveStuff, 'parameters')
    saveStuff = rmfield(saveStuff, 'parameters');
end
if isfield(saveStuff.WS, 'calculated')
    saveStuff.WS = rmfield(saveStuff.WS, 'calculated');
end
if isfield(saveStuff.WS, 'results')
    saveStuff.WS = rmfield(saveStuff.WS, 'results');
end
if isfield(saveStuff.WS, 'listedWS')
    saveStuff.WS = rmfield(saveStuff.WS, 'listedWS');
end
if isfield(saveStuff.WS, 'listedSeeds')
    saveStuff.WS = rmfield(saveStuff.WS, 'listedSeeds');
end
if isfield(saveStuff.features, 'classification')
    saveStuff.features = rmfield(saveStuff.features, 'classification');
end
if isfield(saveStuff.features, 'stringList')
    saveStuff.features = rmfield(saveStuff.features, 'stringList');
end
if isfield(saveStuff.features, 'listed')
    saveStuff.features = rmfield(saveStuff.features, 'listed');
end
if isfield(saveStuff.features, 'output')
    saveStuff.features = rmfield(saveStuff.features, 'output');
end
if isfield(saveStuff.features, 'matrixed')
    saveStuff.features = rmfield(saveStuff.features, 'matrixed');
end
if isfield(saveStuff.fixedModel, 'indices')
    saveStuff.fixedModel = rmfield(saveStuff.fixedModel, 'indices');
end
if isfield(saveStuff.fixedModel, 'image')
    saveStuff.fixedModel = rmfield(saveStuff.fixedModel, 'image');
end
if isfield(saveStuff.fixedModel, 'overlayVesicleClouds')
    saveStuff.fixedModel = rmfield(saveStuff.fixedModel, 'overlayVesicleClouds');
end
if isfield(saveStuff.fixedModel, 'classification')
    saveStuff.fixedModel = rmfield(saveStuff.fixedModel, 'classification');
end
if isfield(saveStuff.fixedModel, 'vesicles')
    saveStuff.fixedModel = rmfield(saveStuff.fixedModel, 'vesicles');
end
if isfield(saveStuff.fixedModel, 'postProcessing')
    saveStuff.fixedModel = rmfield(saveStuff.fixedModel, 'postProcessing');
end
if isfield(saveStuff.fixedModel, 'result')
    saveStuff.fixedModel = rmfield(saveStuff.fixedModel, 'result');
end
if isfield(saveStuff.postProcessing, 'result')
    saveStuff.postProcessing = rmfield(saveStuff.postProcessing, 'result');
end


[fileName, pathName, ~] = uiputfile('*.mat');
save([pathName fileName], 'saveStuff');