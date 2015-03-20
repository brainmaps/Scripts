global visualization

p = visualization.this.parameters;
mult = visualization.this.mult;
anisotropic = visualization.this.anisotropic;
im = visualization.this.image;

visualization.MexicanHat = jh_dip_mexicanHat3D(im, p{1}, mult, anisotropic, 0);
