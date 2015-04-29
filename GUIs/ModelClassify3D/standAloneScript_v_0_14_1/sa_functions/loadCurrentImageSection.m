function sec = loadCurrentImageSection(x, y, z, settings)

%% Determine the image which needs to be loaded

% For shorter variable names
cr = settings.range;
noS = settings.noOfSections;
olp = settings.overlap;
coord = [x;y;z];

% Size of the section [in cubes] w/o overlap
s = ( cr(:,2) - cr(:,1) + 1 ) ./ noS';
% Total section size including overlap (max one cube)
ts = s+(sign(olp)');
% Position of the first cube for each dimension w/o considering overlap
p = (coord-1).*s + cr(:,1);
% And now with overlap
tp = p-(sign(olp)');

sectionToLoad = [tp, tp+ts-1];

% Border correction
bc = find(sectionToLoad(:,1) < cr(:,1));
sectionToLoad(bc) = cr(bc);

%% Load this image

im = jh_openCubeRange([settings.dataFolder, filesep], '', ...                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 openCubeRange([settings.dataFolder, filesep], '', ...
    'range', sectionToLoad(1,:), sectionToLoad(2,:), sectionToLoad(3,:), ...
    'cubeSize', settings.cubeSize, ...
    'dataType', 'single', ...
    'outputType', 'one');


%% Crop everything not necessary 

start = (settings.cubeSize') - (olp') + 1;
start(bc) = 1;

sec = im(start(2):end,start(1):end,start(3):end);


end