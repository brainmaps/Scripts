function invIm = jh_invertImage(im, varargin)

maxIm = jh_globalMax(im);

invIm = maxIm - im;

end