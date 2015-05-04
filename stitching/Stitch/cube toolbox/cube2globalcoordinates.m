function [globalcoordinates] = cube2globalcoordinates(cubecoordinates, coordinatesincube, format, cubesize)
%CUBE2GLOBALCOORDINATES Inverse to global2cubecoordinates. Cubesize and
%format defaults to 128 and yxz (resp.) when omitted and.

if ~exist('format', 'var')
    format = 'yxz';
end

if ~exist('cubesize', 'var')
    cubesize = 128;
end

%convert to double, just to be sure
cubecoordinates = double(cubecoordinates);
coordinatesincube = double(coordinatesincube);


%make global coordinates (yxz) from cubecoordinates and coordinates in cube
%preallocate globcoord for speed
globcoord = NaN([size(cubecoordinates,1), 3]);
for k = 1:size(cubecoordinates,1)
    globcoord(k, :) = [(cubecoordinates(k, 1) - 1)*cubesize + coordinatesincube(k, 1), (cubecoordinates(k, 2) - 1)*cubesize + coordinatesincube(k, 2), (cubecoordinates(k, 3) - 1)*cubesize + coordinatesincube(k, 3)];
end

%swap columns if requested
if strcmp(format, 'xyz')
    globcoord(:,[1 2]) = globcoord(:, [2 1]);
end

globalcoordinates = globcoord;

end

