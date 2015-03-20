global gWS

p = gWS.this.parameters;
mult = gWS.this.mult;
anisotropic = gWS.this.anisotropic;
im = gWS.this.image;

[GF, ~] = jh_dip_imageGradient3D(im, p{1}, mult, anisotropic);
gWS.input = jh_dip_divergenceFromGradient3D(GF, p{2}, mult, anisotropic);