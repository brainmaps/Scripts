function [sec, boundsRangeIdx] = loadCurrentImageSection(x, y, z, settings)

%% Determine the image which needs to be loaded (old)
%{
    % For shorter variable names
    cr = settings.range;
    noS = settings.noOfSections;
    olp = settings.overlap;
    coord = [x+1;y+1;z+1];

    % Size of the section [in cubes] w/o overlap
    s = ( cr(:,2) - cr(:,1) + 1 ) ./ noS';
    % Total section size including overlap (max one cube)
    ts = s+(sign(olp)')*2;
    % Position of the first cube for each dimension w/o considering overlap
    p = (coord-1).*s + cr(:,1);
    % And now with overlap
    tp = p-(sign(olp)');

    sectionToLoad = [tp, tp+ts-1];

    % sectionToLoad

    % Border correction
    bc1 = find(sectionToLoad(:,1) < cr(:,1));
    bc2 = find(sectionToLoad(:,2) > cr(:,2));
    sectionToLoad(bc1) = cr(bc1);
    sectionToLoad(bc2, 2) = cr(bc2, 2);

    % bc1
    % bc2
    % 
    % sectionToLoad
%}
%% Determine the image which needs to be loaded

boundsVx = getBoundsVx([x,y,z], settings.secSize, settings.overlap, settings.offset);
[bounds, vxInBounds] = getBoundsCube(boundsVx, settings.cubeSize, settings.range);
[bounds, vxInBounds, boundsRangeIdx] = boundsOutOfRange(bounds, vxInBounds, settings.range', settings.cubeSize);


%% Load this image

im = jh_openCubeRange([settings.dataFolder, filesep], '', ...                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 openCubeRange([settings.dataFolder, filesep], '', ...
    'range', bounds(:,1), bounds(:,2), bounds(:,3), ...
    'cubeSize', settings.cubeSize, ...
    'dataType', 'single', ...
    'outputType', 'one');

%% Create image for calculation

sec = createSection(im, ...
    settings.secSize, ...
    bounds, vxInBounds, boundsRangeIdx);

%% Crop everything not necessary for calculation

%{
im_size = jh_size(im)';

start = (settings.cubeSize') - (olp') + 1;
start(bc1) = 1;
stop = (im_size + 1) - (settings.cubeSize') + (olp');
stop(bc2) = im_size(bc2)+1;

sec = im(start(2):stop(2),start(1):stop(1),start(3):stop(3));
% 
% start
% stop
%}

end

function sec = createSection(im, secSize, bounds, vxInBounds, boundsRangeIdx)

% [vib_p, vib_n] = splitSign(vxInBounds);
% vib_p = vib_p+1;
% vib_n = vib_n+1;
% sec = zerosXYZ(secSize);
% sec(vib_n(1,2):end-vib_n(2,2), vib_n(1,1):end-vib_n(2,1), vib_n(1,3):end-vib_n(2,3)) ...
%     = im(vib_p(1,2):end-vib_p(2,2), vib_p(1,1):end-vib_p(2,1), vib_p(1,3):end-vib_p(2,3));

[vib_p, vib_n] = splitSign(vxInBounds);
vib_p = vib_p+1;
vib_n = vib_n-1;
sec = im(vib_p(1,2):end-vib_n(2,2), vib_p(1,1):end-vib_n(2,1), vib_p(1,3):end-vib_n(2,3));


end

function [p, n] = splitSign(M)

p = M;
p(p < 0) = 0;
n = -M;
n(n < 1) = 1;

end

function bvx = getBoundsVx(pos, secSize, overlap, offset)

bvx = [ pos .* (secSize-overlap) + offset; ...
        pos .* (secSize-overlap) + secSize - 1 + offset ];

end

function [bc, vx] = getBoundsCube(bvx, cubeSize, range)

bc = floor( [ bvx(1,:) ./ cubeSize + (range(:,1))' ; ...
              bvx(2,:) ./ cubeSize + (range(:,1))' ] );
vx = [  mod(bvx(1,:), cubeSize); ...
        mod(bvx(2,:), cubeSize) - cubeSize ];

end

function [b, vx, idx] = boundsOutOfRange(b, vx, range, cubeSize)

idx = [ b(1,:) < range(1,:) ; ...
        b(2,:) > range(2,:) ];
b(idx) = range(idx);
vx(1,idx(1,:)) = vx(1,idx(1,:)) - cubeSize(idx(1,:));
vx(2,idx(2,:)) = vx(2,idx(2,:)) + cubeSize(idx(2,:));

end

function M = zerosXYZ(xyz)

M = zeros(xyz(2), xyz(1), xyz(3));

end
