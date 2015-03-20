function gauss = GUI_gaussian(im, p)

gauss = jh_vs_gaussianFeature(im, p{2}, ...
    'anisotropic', [1 1 3], ...
    'prefType', 'single');

end