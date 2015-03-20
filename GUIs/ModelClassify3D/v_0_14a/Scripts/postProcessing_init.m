global postProcessing data

%{ 
postProcessing structure
    .prefType
    .result
        .matrixed {}
    .pPP
        .method
        .parameters
        .parameterNames
        .scriptPath
    --- in GUI use only ---
    .available
    .defaults
    .parameterNames
    .inUse
    ---
%}

postProcessing.prefType = 'single';
postProcessing.pPP.scriptPath = [data.folders.main data.folders.postProcessing];

files = dir([postProcessing.pPP.scriptPath '*_init.m']);
fileNames = {files.name};

global gPP
gPP.defaults = {};
gPP.parameterNames = {};

postProcessing.available = cell(1, 3);
for i = 1:length(fileNames)
    
    run([postProcessing.pPP.scriptPath fileNames{i}]);
    
    postProcessing.available{i} = fileNames{i}(4:end-7);
    postProcessing.defaults{i} = gPP.defaults;
    postProcessing.parameterNames{i} = gPP.parameterNames;
    
end

clear -global gPP

postProcessing.inUse = 2;
postProcessing.pPP.parameters = postProcessing.defaults{postProcessing.inUse};
postProcessing.pPP.parameterNames = postProcessing.parameterNames{postProcessing.inUse};
postProcessing.pPP.method = postProcessing.available{postProcessing.inUse};

% postProcessing.result{1} -> vesicle clouds
% postProcessing.result{2} -> vesicles (WS)

