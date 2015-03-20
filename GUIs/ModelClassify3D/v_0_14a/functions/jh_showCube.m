function jh_showCube(cube, dimension, cubesize, figurehandle, speed, cm)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if nargin<2
    dimension = 3;
end

if nargin<3
    cubesize = 128;
end

if nargin<4
    figurehandle = 430;
end

if nargin<5
    speed = 0.1;
end

if nargin<6
    cm = 'gray';
end

if dimension == 2
    cube = permute(cube, [1,3,2]);
elseif dimension == 1
    cube = permute(cube, [2,3,1]);
end    

if size(cube,4) == 1
    % For black & white image
    for i=1:cubesize
        figure(figurehandle), 
        imagesc(cube(:,:,i)),
        colormap(cm);
        pause(speed);
    end
elseif size(cube,4) == 3 
    % For color image
    cube = permute(cube, [1,2,4,3]);
    for i=1:cubesize
        figure(figurehandle),
        imagesc(cube(:,:,:,i));
        pause(speed);
    end
    
end

end

