function cube = at_openCube(path,cubesize)

if nargin < 2
    cubesize = 128;
end

if nargin <1
    [file getpath] = uigetfile;
    path = fullfile(getpath,file);
end

fid=fopen(path,'r');
cube=fread(fid,cubesize^3);
fclose(fid);
cube = permute(reshape(cube, cubesize, cubesize, cubesize), [2 1 3]);
