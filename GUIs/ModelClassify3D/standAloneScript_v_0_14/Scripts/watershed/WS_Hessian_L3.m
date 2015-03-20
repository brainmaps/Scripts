global gWS

p = gWS.this.parameters;
mult = gWS.this.mult;
anisotropic = gWS.this.anisotropic;
im = gWS.this.image;

[~, ~, gWS.input, ~, ~, ~] = jh_dip_hessian3D_2(im, p{1}, mult, anisotropic);

