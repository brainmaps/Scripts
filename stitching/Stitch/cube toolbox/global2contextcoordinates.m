function [contextcoordinates, coordinatesincontext] = global2contextcoordinates(globcoord, basepath)
%GLOBAL2CONTEXTCOORDINATES Converts global coordinates to
%contextcoordinates and coordinates in context.

%default for basepath (change if required!)
if ~exist('basepath', 'var')
    basepath = '/Users/nasimrahaman/Documents/MATLAB/MPI/mbrain/data/BRAX-striatum-20nm-isotropic-deconvolved_mag1';
end

%provision for a single context cube
if strcmpi(basepath, 'single')
    dirsize = [3 3 3];
else
    [numY, numX, numZ] = fetchSupercubeDimensions(basepath);
    dirsize = [numY, numX, numZ];
end

%convert to matrix if globcoord a cell
if iscell(globcoord)
    globcoord = globcoord{1}; 
end

%determine cube coordinates and coordinates in cube
[cubecoord, cicube] = global2cubecoordinates(globcoord); 
contextcoordinates = cubecoord;


%make sure that the center cube isn't at dataset edge

shift = [0 0 0];
for k = 1:3
    if contextcoordinates(k) == dirsize(k)
        contextcoordinates(k) = dirsize(k) - 1; 
        shift(k) = 1; 
    elseif contextcoordinates(k) == 1
        contextcoordinates(k) = 2; 
        shift(k) = -1; 
    end
end
cshift = shift + 1; 

%determine coordinates in context from cicube
coordinatesincontext = cicube + 128*cshift;


end

