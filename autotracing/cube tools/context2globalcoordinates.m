function [globcoord] = context2globalcoordinates(contextcenter, coordinatesincontext, contextsize)
%CONTEXT2GLOBALCOORDINATES converts coordinates in a given context cube to
%global coordinates. 
%   Arguments: 
%   contextcenter: coordinates of the center cube in context
%   coordinatesincontext: self-explanatory

%defaults
if ~exist('contextsize', 'var')
    contextsize = 384;
end

%unpack coordinatesincontext if required
if iscell(coordinatesincontext)
    coordinatesincontext = coordinatesincontext{1}; 
end

%vectorize
globcoord = []; 
for k = 1:size(contextcenter, 1)
    x = coordinatesincontext(k, 2);
    y = coordinatesincontext(k, 1);
    z = coordinatesincontext(k, 3);
    
    %calculate cubesize
    cubesize = round(contextsize/3);
    
    %determine in which cube the coordinate lies
    shift = [0 0 0];
    %Looking top down at a cube:
    %go left
    if x <= cubesize
        shift(2) = -1;
    end
    
    %go right
    if x > 2*cubesize
        shift(2) = 1;
    end
    
    %forwards
    if y <= cubesize
        shift(1) = -1;
    end
    
    %backwards
    if y > 2*cubesize
        shift(1) = 1;
    end
    
    %go up
    if z <= cubesize
        shift(3) = -1;
    end
    
    %go down
    if z > 2*cubesize
        shift(3) = 1;
    end
    
    %calculate cubecoordinate
    cubecoordinates = contextcenter(k,:) + shift;
    
    %calculate coordinates
    %calculate shift in cubecoordinates
    cshift = shift + 1;
    coordinatesincube = coordinatesincontext(k,:) - 128*cshift;
    
    %calculate global coordinates
    globcoord = [globcoord; cube2globalcoordinates(cubecoordinates, coordinatesincube)];
end

end

