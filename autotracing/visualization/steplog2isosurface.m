function steplog2isosurface(skelfile, b, basepath)
%STEPLOG2ISOSURFACE Isosurface plot of data in skelfile
%   WARNING: Do not run on a netbook.

%defaults
if ~exist('basepath', 'var')
    basepath = '/Users/nasimrahaman/Documents/MATLAB/MPI/mbrain/data/mbrain-convnet';
end

cubesize = 128;

%fetch dataset size
[numY, numX, numZ] = fetchSupercubeDimensions(basepath); 

%calculate dataset size 
sizY = numY*cubesize;
sizX = numX*cubesize;
sizZ = numZ*cubesize;

%initialize a logical segmentation matrix
segmat = true(sizY, sizX, sizZ); 

%fetch data from skelfile
branchlog = loadfromskelfile(skelfile, b, 'all', false); 

%convert to global coordinates
for step = 1:size(branchlog)
    currcontcoord = branchlog{step, 7}; 
    parserfun = @(x) context2globalcoordinates(currcontcoord, x);
    gcc = cellfun(parserfun, branchlog{step, 3});
    for k = [gcc(:)]'
        
    end
end

end

