global visualization

p = visualization.this.parameters;
mult = visualization.this.mult;
anisotropic = visualization.this.anisotropic;
im = visualization.this.image;

[~, visualization.Gradient.Magnitude] = jh_dip_imageGradient3D(im, p{1}, mult, anisotropic);
