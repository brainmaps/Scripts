global gPP

parameters = gPP.parameters;
mult = gPP.mult;
anisotropic = gPP.anisotropic;
im = gPP.image;
WS = gPP.WS;
features = gPP.features;

gPP.result = cell(1,4);
gPP.resultNames = { ...
    'PP: Vesicle clouds', ...
    'PP: Vesicles', ...
    'PP: Vc score', ...
    'PP: Nh score'};


p.excludeSolitary.enable = gPP.parameters{1};
p.WS.dimensions = gPP.WS.pWS.parameters.dimensions;
p.excludeSolitary.conn = gPP.parameters{2};
p.excludeSolitary.nhRadius = gPP.parameters{3}; % 12
p.excludeSolitary.thresh = gPP.parameters{4}; % 7
p.vesicleClouds.classThresh = gPP.parameters{5};
p.vesicleClouds.conn = gPP.parameters{6};
p.vesicleClouds.dimensions = gPP.parameters{7};
p.vesicleClouds.sizeExclusion = gPP.parameters{8};
p.vesicleClouds.smoothing = gPP.parameters{9};

vesiclePrediction = zeros(size(gPP.data.image), gPP.data.prefType);
vesiclePrediction(gPP.classification.result.matrixed{3} > p.vesicleClouds.classThresh) = 1;
vesiclePrediction(gPP.WS.result.matrixed{1} == 0) = 0;
[gPP.result{1}, gPP.result{2}, gPP.result{3}, gPP.result{4}] = ...
    jh_vs_calculateVesicleClouds_v5( ...
    im, vesiclePrediction, gPP.WS.result.matrixed, ...
    'parameters', p, ...
    'prefType', 'single', ...
    'vesicleScores', gPP.classification.result.matrixed{3}, 0, ...
    'anisotropic', anisotropic);
