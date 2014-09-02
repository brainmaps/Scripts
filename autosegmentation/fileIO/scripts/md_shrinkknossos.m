% PLEASE READ THE FOLLOWING INFO BEFORE RUNNING THE SCRIPT:
%
% Scale down a big KNOSSOS volume and write the resized data to the disk as
%  a flat numbered TIF stack (readable by md_volread) and/or a directory structure
%  similar to KNOSSOS (not compatible with KNOSSOS itself, but with
%  some programs expecting a similar data structure).
%
% If you need a fully KNOSSOS compatible output, use the program available at
%  http://www.knossostool.org/downloads/KNOSSOSmaker_gaussfilter.zip
%  on the produced TIF stack (only works with MS Windows in this form).
%
% v1.0
%
% Dependencies:
%  You can easily satisfy all dependencies by adding the content of ...
%   https://github.com/brainmaps/Scripts/archive/8f7aa686457bea809cb354a4da2316e0d0c1cb9a.zip ...
%   to the Matlab path.
%  Exact depencencies:
%  - https://github.com/brainmaps/Scripts/blob/511372c514e4484694bab6a4351e2b99dd8b68e8/autosegmentation/fileIO/jh_openCubeRange.m
%  - https://github.com/brainmaps/Scripts/blob/53e7a3c02ec9ce8c42cbc432fccfaeb1930b1bb8/autosegmentation/fileIO/md_checkdir.m
%  - https://github.com/brainmaps/Scripts/blob/6bfa29c7369e77734d682b85377351e1318dc85f/autosegmentation/fileIO/md_volwrite.m
%  - https://github.com/brainmaps/Scripts/blob/8f7aa686457bea809cb354a4da2316e0d0c1cb9a/autosegmentation/fileIO/jh_saveImageAsTiff3D.m
%
% WARNING:
% - This usually needs at least 9 GiB free RAM (depending on the dataset)
%    and can take a few minutes to run.

%% Variables. You will most likely need to change them, at least the paths.

inputPath = '~/mpi/20130318.membrane.ctx.40nm/'; % location of the input KNOSSOS root
name = '20130318.membrane.ctx.40nm'; % dataset name (see knossos.conf file)
tifPath = '/tmp/ctx40-small-0.125/'; % where to write the numbered TIF stack
knossosPath = '/tmp/ctx40-small-0.125-knossos/'; % where to write the root ...
% ... of the KNOSSOS-like cubes (has to end with a path seperator).

cleanWorkspace = true; % if true: clear all temporary variables ...
% ... of the script after finishing.

scale = 0.125; % the image volume will be resized by this factor
filePrefix = [num2str(scale), '_']; % file names in the TIF stack start ...
% ... with the scaling factor, while preserving file order.

writeTifs = true; % if false, no tif stack is written.
writeKnossos = true; % if false, no knossos-like structure is written

%% Check variable validity

md_checkdir(inputPath);
if ceil(1 / scale) ~= floor(1 / scale)
    disp('(1 / scale) should be an integer. Output might be broken.');
end

%% Scale data

tic % start timer
disp(['Loading dataset from "', inputPath, '"...']);
vol = jh_openCubeRange(inputPath, name, 'range', 'complete', 'dataType', 'uint8'); % load original dataset
disp('Scaling in X and Y direction...');
scaledVolXY = imresize(vol, scale); % imresize only resizes X and Y dimensions for some reason
disp('Scaling in Z direction...');
zValues = floor(1: (1 / scale) : size(vol, 3)); % get every (1 / scale)th Z plane ...
clear vol; % free some RAM, just in case
scaledVol = scaledVolXY(:, :, zValues);         % ... effectively scaling the volume in Z direction by the defined scale value.
clear scaledVolXY;
disp('Scaling finished.');
toc % stop timer

%% Write TIF stack to disk

if writeTifs

    disp(['Writing TIFs into directory ', tifPath, ' ...']);
    md_volwrite(scaledVol, tifPath, 'none', false, filePrefix, '%04u', '', 'tif');

end

%% Write KNOSSOS-like data structure to disk (not compatible with KNOSSOS itself)
% For full KNOSSOS compatibility see the notice at the top of the script.

% This code section is derived from
%  https://github.com/brainmaps/Scripts/blob/4cc61b43e9579f262a8f60777f1c274a45a113e4/autosegmentation/fileIO/jh_createCubedTiff.m

if writeKnossos
    
    disp(['Writing KNOSSOS-like structure into "', knossosPath, name, '/"...']);
    
    scaledVolDouble = mat2gray(scaledVol);

    cubeSize = [128 128 128]; % [r c d]
    padValue = 0;
    padOrientation = [0 0 0]; % [r c d]

    n = size(scaledVolDouble);

    nc = [ceil(n(1)/cubeSize(1)), ceil(n(2)/cubeSize(2)), ceil(n(3)/cubeSize(3))];

    % Pad image
    paddedImage = ones(nc .* cubeSize) * padValue;
    np = size(paddedImage);
    from = zeros(3,1);
    to = zeros(3,1);
    for i = 1:3

        switch padOrientation(i)
            case -1
                from(i) = np(i) - n(i) + 1;
            case 0
                from(i) = round(np(i)/2) - round(n(i)/2) + 1;
            case 1
                from(i) = 1;
        end
        to(i) = from(i) + n(i) - 1;

    end
    clear i
    paddedImage(from(1):to(1), from(2):to(2), from(3):to(3)) = scaledVolDouble;

    clear n imageName padValue padOrientation np from to

    % Divide image into cubes
    for x = 1:nc(2)

        px = ['x' sprintf('%04d', x-1)];
        mkdir([knossosPath name], px);
        cx = 1+cubeSize(2)*(x-1);

        for y = 1:nc(1)

            py = ['y' sprintf('%04d', y-1)];
            mkdir([knossosPath name filesep px], py);
            cy = 1+cubeSize(1)*(y-1);

            for z = 1:nc(3)

                pz = ['z' sprintf('%04d', z-1)];
                mkdir([knossosPath name filesep px filesep py], pz);
                cz = 1+cubeSize(3)*(z-1);

                saveImage =  paddedImage(cy:cy+cubeSize(2)-1, cx:cx+cubeSize(1)-1, cz:cz+cubeSize(3)-1);
                saveImageAsTiff3D(saveImage, [knossosPath name filesep px filesep py filesep pz filesep name '_' px '_' py '_' pz '.TIFF'], 'gray');
                clear saveImage;
            end
        end
    end

end

%% Tidy up workspace (if "cleanWorkspace" is true)

if cleanWorkspace

    clear x y z cx cy cz px py pz
    clear name cubeSize nc
    clear inputPath knossosPath tifPath
    clear scale zValues writeTifs writeKnossos padOrientation padValue
    clear scaledVol scaledVolDouble paddedImage

end

disp('Done.');
