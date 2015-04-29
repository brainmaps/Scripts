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

%% Load necessary cubes and create image

data = settings.data;
data.image = loadCurrentImageSection(x, y, z, settings);


%% Calculate result for current section

result.result = jh_synapseSeg3D( ...
    data, settings.pWS, settings.pFeatures, settings.pClassification, settings.pPP, ...
    'save', {'WS', 'features', 'classification', 'postProcessing'}, ...
    settings.saveFolder, settings.nameRun, ...
    'prefType', 'single', ...
    'anisotropic', data.anisotropic);

% im = jh_normalizeMatrix(data.image);
% figure, imshow(im(:,:,100));
% figure, imagesc(result.result(:,:,100));


%% Save result for current section

% result.modelFile = modelFile;
% result.loadFolder = loadFolder;
% result.saveFolder = saveFolder;
% result.nameRun = nameRun;
% save([saveFolder filesep nameRun filesep 'result'], 'result');
% 
% saveImageAsTiff3D( ...
%     jh_overlayLabels( ...
%         jh_normalizeMatrix(data.image), ...
%         result.result, ...
%         'type', 'colorize', ...
%         'range', [0 .33], ...
%         'gray', 'randomizeColors'), ...
%     [saveFolder filesep nameRun filesep 'result_Overlay.TIFF'], ...
%     'rgb');

end