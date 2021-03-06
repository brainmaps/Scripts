global visualization

%{
visualization structure
    .output
        .image
        .overlay {}
        .overlayMethod {}
    .currentImage % replaced by output
    .currentSlice
    .pImage
        .parameters
        .bInvert
        .bInvertRaw
    .pOverlay
        .bWS
        .bGT
        .bAdditional
    .available
    .subAvailable
    .defaults
    .parameterNames
%}

% visualization.pOverlay.bWS = false;
% visualization.pOverlay.bGT = false;
% visualization.pOverlay.bAdditional = false;

visualization.output.image = [];
visualization.output.overlay = cell(0,0);
visualization.currentSlice = 1;

visualization.available = { ...
    'Image', ...
    'Gaussian', ...
    'Gradient', ...
    'Divergence', ...
    'Hessian', ...
    'MexicanHat'};
visualization.subAvailable = { ...
    {''}, ...
    {''}, ...
    {'Magnitude'}, ...
    {''}, ...
    {'L1', 'L2', 'L3', 'Sum', 'Product', 'GeometricMean', 'SumOfNormalized', 'ProductOfNormalized', 'GeometricMeanOfNormalized', 'SumOfNormiL1L2L3', 'SumOfNormL1iL2L3', 'SumOfNormL1L2iL3', 'ProductOfNormiL1L2L3', 'ProductOfNormL1iL2L3', 'ProductOfNormL1L2iL3'}, ...
    {''}};
visualization.defaults = { ...
    [], ...
    {0.6}, ...
    {1.5}, ...
    {1.0, 1.0}, ...
    {1.5}, ...
    {1.5}};
visualization.parameterNames = { ...
    [], ...
    {'Sigma'}, ...
    {'Sigma'}, ...
    {'Sigma (GF)', 'Sigma (divergence)'}, ...
    {'Sigma'}, ...
    {'Sigma'}};

visualization.pImage.parameters = visualization.defaults;

visualization.pImage.bInvert = 0;
visualization.pImage.bInvertRaw = 0;
