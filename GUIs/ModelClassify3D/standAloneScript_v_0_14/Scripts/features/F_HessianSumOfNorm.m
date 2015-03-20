global gF

p = gF.parameters;
mult = gF.mult;
anisotropic = gF.anisotropic;
im = gF.in;

[L1, L2, L3, ~, ~, ~] = jh_dip_hessian3D(im, p{1}, mult, anisotropic);
gF.out{1} = jh_normalizeMatrix(L1) + jh_normalizeMatrix(L2) + jh_normalizeMatrix(L3);