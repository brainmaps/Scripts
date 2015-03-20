global gF

p = gF.parameters;
mult = gF.mult;
anisotropic = gF.anisotropic;
im = gF.in;

[GF, ~] = jh_dip_imageGradient3D(im, p{1}, mult, anisotropic);
gF.out{1} = jh_dip_divergenceFromGradient3D(GF, p{2}, mult, anisotropic);