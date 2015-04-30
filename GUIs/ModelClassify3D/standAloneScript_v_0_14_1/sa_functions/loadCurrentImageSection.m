function [sec, bc1, bc2] = loadCurrentImageSection(x, y, z, settings)

%% Determine the image which needs to be loaded

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

%% Load this image

im = jh_openCubeRange([settings.dataFolder, filesep], '', ...                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 openCubeRange([settings.dataFolder, filesep], '', ...
    'range', sectionToLoad(1,:), sectionToLoad(2,:), sectionToLoad(3,:), ...
    'cubeSize', settings.cubeSize, ...
    'dataType', 'single', ...
    'outputType', 'one');


%% Crop everything not necessary 

im_size = jh_size(im)';

start = (settings.cubeSize') - (olp') + 1;
start(bc1) = 1;
stop = (im_size + 1) - (settings.cubeSize') + (olp');
stop(bc2) = im_size(bc2)+1;

sec = im(start(2):stop(2),start(1):stop(1),start(3):stop(3));
% 
% start
% stop


end