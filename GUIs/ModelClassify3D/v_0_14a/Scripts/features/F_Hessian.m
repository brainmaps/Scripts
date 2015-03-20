global gF

p = gF.parameters;
mult = gF.mult;
anisotropic = gF.anisotropic;
im = gF.in;

[gF.out{1}, gF.out{2}, gF.out{3}, ~, ~, ~] = jh_dip_hessian3D(im, p{1}, mult, anisotropic);
