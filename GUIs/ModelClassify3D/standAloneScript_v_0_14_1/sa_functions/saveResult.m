function saveResult(x, y, z, settings, resultC, result, im)

%% Create folder

path = jh_buildString( ...
    settings.saveFolder, filesep, ...
    settings.nameRun, filesep, ...
    'x', [x,4], filesep, ...
    'y', [y,4], filesep, ...
    'z', [z,4], filesep); 

% Create path if it does not exist
if exist(path, 'dir') ~= 7
    mkdir(path);
end

%% Save result as mat-file

currentPath = pwd;
cd(path);

cube_output = resultC;

% if ~isempty(result)
%     save('mitomap_output', 'cube_output', 'result');
% else
    save('mitomap_output', 'cube_output');
% end

cd(currentPath);

%% Save result as overlay-Tiff

if ~isempty(im) && ~isempty(result)
    
    try
        jh_saveImageAsTiff3D( ...
            jh_overlayLabels( ...
                jh_normalizeMatrix(im), ...
                result, ...
                'type', 'colorize', ...
                'range', [0 .33], ...
                'gray', 'randomizeColors' ...            
            ), ...
            [path, settings.nameRun, '.tiff'], ...
            'rgb');
    catch
        disp('ERROR: Overlay image was not saved');
    end
        
    
end

end