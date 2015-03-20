global F

p = F.parameters;
mult = F.mult;
anisotropic = F.anisotropic;
im = F.in;

[L1, L2, L3, ~, ~, ~] = jh_dip_hessian3D(im, p{1}, mult, anisotropic);
F.out{1} = jh_invertImage(jh_normalizeMatrix(L1)) + jh_normalizeMatrix(L2) + jh_normalizeMatrix(L3);