function cube = loadtiff2mat(cubecoordinates, basepath, cubesize)
%LOADTIFF2MAT Fetches a .raw at cubecoordinates (MATLAB yxz) in a knossos directory at
%basepath, converts to and returns a MATLAB matrix. 

%default value for cubesize
if ~exist('cubesize', 'var')
    cubesize = 128;
end

%parse cubecoordinates
I = cubecoordinates(2);
J = cubecoordinates(1);
K = cubecoordinates(3);

%generate access string
access_string = [filesep, 'x', num2str(I-1, '%04d'), filesep, 'y', num2str(J-1, '%04d'), filesep, 'z', num2str(K-1, '%04d')];
%load RAW
%acquire filepath
filedir = dir([basepath, access_string]);
rawfilepath = [basepath, access_string, filesep, filedir(3).name];
%read in RAW
fid=fopen(rawfilepath,'r');
cube_output=reshape(uint8(fread(fid)),cubesize,cubesize,cubesize);
fclose(fid);
%permute and convert to double
cube_output = permute(cube_output, [2 1 3]);
cube_output = im2double(cube_output);

%return
cube = cube_output;

end

