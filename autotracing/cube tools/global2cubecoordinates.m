function [cubecoordinates, coordinatesincube] = global2cubecoordinates(coordinates, coordinatetype, basepath)
%GLOBAL2CUBECOORDINATES Converts global coordinates (over a supercube directory) 
%to cube coordinates + coordinates in cube. basepath specifies the
%directory the conversion is done for. coordinatetype (possible values 'xyz' and 'yxz' 
%specifies if coordinates are passed in MATLAB format 'yxz' or in cartesian 'xyz'. 
%It defaults to 'xyz' when omitted. The cube size defaults to 128 by 128 by 128 if basepath
%is omitted.
%   All outputs parsed for compatibility with MATLAB (i.e. in YXZ format) and
%   loadcube.m and loadcontext.m. 
%   [FUNCTION ARGUMENTS]
%   coordinates: n by 3 array of coordinates
%   basepath: path to the corresponding knossos dataset
%   coordinatetype: string, 'xyz' or 'yxz'. Defaults to 'xyz'
%   [FUNCTION RETURNS]
%   cubecoordinates: n by 3 array of cube coordinates relative to the
%                    knossos directory at basepath
%   coordinatesincube: n by 3 array of coordinates in the corresponding
%                      cube (of coordinates given by the n-th row of
%                      cubecoordinates). 
%   [WARNING] Not cuboid ready. 
%   [TESTED AND WORKING]


%parse input
%handle default values
if ~exist('coordinatetype', 'var')
    coordinatetype = 'yxz';
end
%check if a basepath is given and extract size. Set a default value otherwise.
if exist('basepath', 'var')
    try
        samplecube = loadtiff2mat([1 1 1], basepath);
    catch
        samplecube = loadcube([1 1 1], basepath);
    end
    [sizy, sizx, sizz] = size(samplecube);
    clear samplecube;
else
    sizy = 128;
    sizx = 128;
    sizz = 128;
end

%initialize variables to return
retcubecoordinates = [];
retcoordinatesincube = [];

%determine the length of the row list
[clistsize, ~] = size(coordinates);

for n = 1:clistsize
    %parse coordinates
    if strcmpi(coordinatetype, 'xyz')
        xcoordinate = coordinates(n, 1)-1;
        ycoordinate = coordinates(n, 2)-1;
        zcoordinate = coordinates(n, 3)-1;
    elseif strcmpi(coordinatetype, 'yxz')
        xcoordinate = coordinates(n, 2)-1;
        ycoordinate = coordinates(n, 1)-1;
        zcoordinate = coordinates(n, 3)-1;
    else
        warning('coordinatetype not recognized, will default to xyz');
        xcoordinate = coordinates(n, 1)-1;
        ycoordinate = coordinates(n, 2)-1;
        zcoordinate = coordinates(n, 3)-1;
    end


    %determine cubecoordinates. Divide by the cube size (in respective
    %dimension), take the floor and add one. For instance: global coordinate x = 120
    %and sizx = 128 --> x/sizx = 0.9375 --> floor(0.9375) = 0 -->
    %cubecoordinates(x) = 0 + 1 = 1. 
    ccordx = uint8(floor(xcoordinate/sizx)+1);
    ccordy = uint8(floor(ycoordinate/sizy)+1);
    ccordz = uint8(floor(zcoordinate/sizz)+1);

    %determine coordinates in cube. Take the decimal part, multiply by cubesize
    %and round to nearest integer. No need to add one, Knossos coordinates also
    %start at [1 1 1]. Right? Wrong. This works, don't ask why. 
    cicx = uint8(((xcoordinate/sizx) - floor(xcoordinate/sizx))*sizx + 1);
    cicy = uint8(((ycoordinate/sizy) - floor(ycoordinate/sizy))*sizy + 1);
    cicz = uint8(((zcoordinate/sizz) - floor(zcoordinate/sizz))*sizz + 1);

    %append results to return variables
    listcubecoordinates = [ccordy, ccordx, ccordz];
    listcoordinatesincube = [cicy, cicx, cicz];
    
    retcubecoordinates = [retcubecoordinates; listcubecoordinates];
    retcoordinatesincube = [retcoordinatesincube; listcoordinatesincube];
    
end

%return
cubecoordinates = double(retcubecoordinates);
coordinatesincube = double(retcoordinatesincube);

end

