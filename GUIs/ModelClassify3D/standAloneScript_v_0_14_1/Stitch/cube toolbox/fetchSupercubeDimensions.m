function [numY, numX, numZ] = fetchSupercubeDimensions(basepath)
%FETCHSUPERCUBEDIMENSIONS Calculates the size of a Knossos supercube in path basepath.
%   Returns dimensions in [Y, X, Z] format, as would size(...). 

%Fetch supercube dimensions
wherewasi = pwd;
cd(basepath)

%load file names
flistX=dir(basepath);
filenameX = flistX(end).name;
flistY=dir([basepath filesep filenameX]);
filenameY = flistY(end).name;
flistZ=dir([basepath filesep filenameX filesep filenameY]);
filenameZ = flistZ(end).name;

%parse file names
numX = str2num(filenameX(2:end)) + 1;
numY = str2num(filenameY(2:end)) + 1;
numZ = str2num(filenameZ(2:end)) + 1;

cd(wherewasi)

end

