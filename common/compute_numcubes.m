function [xcubes ycubes zcubes] = compute_numcubes(dirname)


xcubes=size(dir([dirname filesep 'x*']),1);
ycubes=size(dir([dirname filesep 'x0001' filesep 'y*']),1);
zcubes=size(dir([dirname filesep 'x0001' filesep 'y0001' filesep 'z*']),1);
