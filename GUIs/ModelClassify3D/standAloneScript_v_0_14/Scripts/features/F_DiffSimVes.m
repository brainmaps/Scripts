global gF

p = gF.parameters;
mult = gF.mult;
anisotropic = gF.anisotropic;
im = gF.in;

pa.thresh = 0;
pa.sMex = p{4};
pa.sGauss = p{3};
pGF.sigma = p{1};
pGF.mult = mult;
pDiv.sigma = p{2};
pDiv.mult = 3;
[~,gF.out{1},~] = jh_vs_simVes( ...
    im, pa, pGF, pDiv, ...
    'WS', gF.WS.result.matrixed{2}, gF.WS.result.matrixed{1}, ...
    'anisotropic', anisotropic, 'prefType', 'single');
