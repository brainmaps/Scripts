function [cube] = contextincoordinates2cube(coordinates, basepath)
%CONTEXT2CUBE Strips context's stored in (coordinates, basepath) to cubes.
%   For use with cubeprocessor (coordinates)

%load context as cube
cntx = loadcube(coordinates, basepath); 

%strip and return
cube = cntx(129:256, 129:256, 129:256); 


end

