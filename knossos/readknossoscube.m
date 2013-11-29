function cube = readknossoscube(path,cubesize)

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
cube=reshape(cube,cubesize,cubesize,cubesize);
