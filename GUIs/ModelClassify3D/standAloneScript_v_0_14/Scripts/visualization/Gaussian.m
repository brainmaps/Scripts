global visualization

p = visualization.this.parameters;
mult = visualization.this.mult;
anisotropic = visualization.this.anisotropic;
im = visualization.this.image;

visualization.Gaussian = jh_dip_gaussianFilter3D(im, p{1}, mult, anisotropic);
