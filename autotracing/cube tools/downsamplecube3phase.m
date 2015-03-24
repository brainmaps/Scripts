function dscube = downsamplecube3phase(cube, factor)
%DOWNSAMPLE Downsamples a cube by a factor 'factor'.
%   Cube processor ready

%defaults
if ~exist('factor', 'var')
    factor = 4;
end

storecell = cell(factor, 1);

%dirty but functional: 
for phase = 0:factor-1
    dc = downsample(cube, factor, phase);
    dcp = permute(dc, [2 1 3]);
    dc2 = downsample(dcp, factor, phase);
    dcp2 = permute(dc2, [3 1 2]);
    dc3 = downsample(dcp2, factor, phase);
    dcp3 = permute(dc3, [3, 2, 1]);
    storecell{phase + 1} = dcp3;
end

%expand storecell
storecell{end+1} = storecell{end};

%add up cell values
for p = 1:factor-1
    storecell{end} = storecell{end} | storecell{p};
end

%return
dscube = storecell{end};

end

