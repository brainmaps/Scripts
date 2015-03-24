function [targetcoord] = contextcoordinatetransition(sourcecoord, sourcecontext, targetcontext, cubesize)
%COORDINATETRANSITION Converts given coordinates (sourcecoordinates) in
%source context to the corresponding coordinate in target context. Note that the 
%returned targcoord may be out of bounds wrt targetcontext, so handle with care.  

%default for cubesize
if ~exist('cubesize', 'var')
    cubesize = 128;
end

%unpack if required
if iscell(sourcecoord)
    sourcecoord = sourcecoord{1}; 
end

%consider difference between source and target context coordinates
diffcoord = sourcecontext - targetcontext; 

%calculate targetcoord
targetcoord = sourcecoord + cubesize*diffcoord; 

end

