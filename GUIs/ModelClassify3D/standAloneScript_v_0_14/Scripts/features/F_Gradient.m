global gF

p = gF.parameters;
mult = gF.mult;
anisotropic = gF.anisotropic;
im = gF.in;

[GF, ~] = jh_dip_imageGradient3D(im, p{1}, mult, anisotropic);

gF.out{1} = GF(:,:,:,2);
gF.out{2} = GF(:,:,:,1);
gF.out{3} = GF(:,:,:,3);