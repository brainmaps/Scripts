function calculateCurrentSection(x, y, z, settings)
%
% INPUT
%   x, y, z: Coordinates of the current section (1-based)
%   settings: structure
%       .range
%       .noOfSections
%       .overlap
%       .cubeSize
%       .data
%       .pWS
%       .pFeatures
%       .pClassification
%       .pPP
%       .saveFolder
%       .nameRun
%       .dataFolder
%       .saveAlso


%% Load necessary cubes and create image

fprintf('\nLoading current image section...')

data = settings.data;
[data.image, boundsRangeIdx] = loadCurrentImageSection(x, y, z, settings);

fprintf(' Done!\n');


%% Calculate result for current section

fprintf('Calculating result for current section...\n')

path = jh_buildString( ...
    settings.saveFolder, filesep, ...
    settings.nameRun, filesep, ...
    'x', [x,4], filesep, ...
    'y', [y,4], filesep, ...
    'z', [z,4], filesep); 

if exist([path, settings.nameRun], 'dir') ~= 7
    mkdir([path, settings.nameRun]);
end

% result = zeros(size(data.image));
result = jh_synapseSeg3D( ...
    data, settings.pWS, settings.pFeatures, settings.pClassification, settings.pPP, ...
    'save', settings.saveAlso, path, settings.nameRun, ...
    'prefType', 'single', ...
    'anisotropic', data.anisotropic);


%% Crop result

fprintf('Cropping result...')
resultC = cropResult(result, settings, boundsRangeIdx);
fprintf(' Done!\n')
% im = jh_normalizeMatrix(data.image);
% figure, imshow(im(:,:,100));
% figure, imagesc(result(:,:,100));


%% Save result for current section

fprintf('Saving results for current section...')
if settings.saveOverlays
    saveResult(x, y, z, settings, resultC, result, data.image);
else
    saveResult(x, y, z, settings, resultC, [], []);
end
fprintf(' Done!\n')

end