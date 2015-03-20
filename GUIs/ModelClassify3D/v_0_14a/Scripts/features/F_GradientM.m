global gF

p = gF.parameters;
mult = gF.mult;
anisotropic = gF.anisotropic;
im = gF.in;

[~, gF.out{1}] = jh_dip_imageGradient3D(im, p{1}, mult, anisotropic);
