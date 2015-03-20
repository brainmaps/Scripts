global WS data

%{
WS structure
    .result
        .matrixed {labWS, labSeeds, labSeedsNotCleared, calculated}
        .listed
            .positions
            .labels
            .sizes
        .seeds
            .positions
            .labels
    .pWS
        .preStep
            .method
            .bInvert
            .bInvertRaw
            .parameters
        .parameters
            .conn
            .maxDepth
            .maxSize
            .dimensions
        .scriptPath
    --- in GUI use only ---
    .available
    .defaults
    .parameterNames
    .inUse
    ---
%}


WS.prefType = 'single';

WS.available = { ...
    'Image', ...
    'Divergence', ...
    'Gaussian', ...
    'GradientMagnitude', ...
    'Hessian_L1', ...
    'Hessian_L2', ...
    'Hessian_L3'};
WS.defaults = { ...
    [], ...
    {0.5, 1.0}, ...
    {1.5}, ...
    {1.5}, ...
    {1.5}, ...
    {1.5}, ...
    {1.5}};
WS.parameterNames = { ...
    [], ...
    {'Sigma (GF)', 'Sigma (divergence)'}, ...
    {'Sigma'}, ...
    {'Sigma'}, ...
    {'Sigma'}, ...
    {'Sigma'}, ...
    {'Sigma'}};

WS.inUse = 3;

WS.pWS.preStep.method = WS.available{WS.inUse};
WS.pWS.preStep.bInvert = 0;
WS.pWS.preStep.bInvertRaw = 0;
WS.pWS.preStep.parameters = {1.5};
WS.pWS.parameters.conn = 2;
WS.pWS.parameters.maxDepth = 0;
WS.pWS.parameters.maxSize = 0;
WS.pWS.parameters.dimensions = 2;
WS.pWS.scriptPath = [data.folders.main, data.folders.watershed];
