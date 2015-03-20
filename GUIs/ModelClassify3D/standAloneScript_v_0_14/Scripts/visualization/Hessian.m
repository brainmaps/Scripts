global visualization

p = visualization.this.parameters;
mult = visualization.this.mult;
anisotropic = visualization.this.anisotropic;
im = visualization.this.image;

[L1, L2, L3, ~, ~, ~] = jh_dip_hessian3D(im, p{1}, mult, anisotropic);

visualization.Hessian.L1 = L1;
visualization.Hessian.L2 = L2;
visualization.Hessian.L3 = L3;

visualization.Hessian.Sum = L1 + L2 + L3;
visualization.Hessian.SumOfNormalized = jh_normalizeMatrix(L1) + jh_normalizeMatrix(L2) + jh_normalizeMatrix(L3);
visualization.Hessian.Product = L1 .* L2 .* L3;
visualization.Hessian.ProductOfNormalized = jh_normalizeMatrix(L1) .* jh_normalizeMatrix(L2) .* jh_normalizeMatrix(L3);
visualization.Hessian.GeometricMean = (L1 .* L2 .* L3) .^ (1/3);
visualization.Hessian.GeometricMeanOfNormalized = (jh_normalizeMatrix(L1) .* jh_normalizeMatrix(L2) .* jh_normalizeMatrix(L3)) .^ (1/3);

visualization.Hessian.SumOfNormiL1L2L3 = 1-jh_normalizeMatrix(L1) + jh_normalizeMatrix(L2) + jh_normalizeMatrix(L3);
visualization.Hessian.SumOfNormL1iL2L3 = jh_normalizeMatrix(L1) + (1-jh_normalizeMatrix(L2)) + jh_normalizeMatrix(L3);
visualization.Hessian.SumOfNormL1L2iL3 = jh_normalizeMatrix(L1) + jh_normalizeMatrix(L2) + (1-jh_normalizeMatrix(L3));

visualization.Hessian.ProductOfNormiL1L2L3 = (1-jh_normalizeMatrix(L1)) .* jh_normalizeMatrix(L2) .* jh_normalizeMatrix(L3);
visualization.Hessian.ProductOfNormL1iL2L3 = jh_normalizeMatrix(L1) .* (1-jh_normalizeMatrix(L2)) .* jh_normalizeMatrix(L3);
visualization.Hessian.ProductOfNormL1L2iL3 = jh_normalizeMatrix(L1) .* jh_normalizeMatrix(L2) .* (1-jh_normalizeMatrix(L3));