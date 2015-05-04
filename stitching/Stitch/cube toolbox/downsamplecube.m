function dscube = downsamplecube(cube, factor)
%DOWNSAMPLE Downsamples a cube by a factor 'factor'.
%   Cube processor ready

%defaults
if ~exist('factor', 'var')
    factor = 4;
end

%dirty but functional: 
dc = downsample(cube, factor);
dcp = permute(dc, [2 1 3]);
dc2 = downsample(dcp, factor);
dcp2 = permute(dc2, [3 1 2]);
dc3 = downsample(dcp2, factor);
dcp3 = permute(dc3, [3, 2, 1]);

%return
dscube = dcp3;

end

