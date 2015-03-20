global gF

p = gF.parameters;
mult = gF.mult;
anisotropic = gF.anisotropic;
im = gF.in;

[L1, L2, L3, ~, ~, ~] = jh_dip_hessian3D(im, p{1}, mult, anisotropic);

gF.out{1} = L1 + L2 + L3;
gF.out{2} = jh_normalizeMatrix(L1) + jh_normalizeMatrix(L2) + jh_normalizeMatrix(L3);
gF.out{3} = (1-jh_normalizeMatrix(L1)) + jh_normalizeMatrix(L2) + jh_normalizeMatrix(L3);
gF.out{4} = jh_normalizeMatrix(L1) + (1-jh_normalizeMatrix(L2)) + jh_normalizeMatrix(L3);
gF.out{5} = jh_normalizeMatrix(L1) + jh_normalizeMatrix(L2) + (1-jh_normalizeMatrix(L3));