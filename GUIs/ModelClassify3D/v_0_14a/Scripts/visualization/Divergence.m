global visualization

p = visualization.this.parameters;
mult = visualization.this.mult;
anisotropic = visualization.this.anisotropic;
im = visualization.this.image;

[GF, mag] = jh_dip_imageGradient3D(im, p{1}, mult, anisotropic);
visualization.Divergence = jh_dip_divergenceFromGradient3D(GF, p{2}, mult, anisotropic);
