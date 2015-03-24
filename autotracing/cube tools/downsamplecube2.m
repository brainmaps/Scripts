function dscube = downsamplecube2(cube, factor)
%DOWNSAMPLE Downsamples a cube by a factor 'factor'.
%   Cube processor ready

%defaults
if ~exist('factor', 'var')
    factor = 2;
end

%return
dscube = cube(1:factor:end,1:factor:end,1:factor:end);

end

