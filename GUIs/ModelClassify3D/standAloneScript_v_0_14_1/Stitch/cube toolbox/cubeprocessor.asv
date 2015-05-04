function cubeprocessor(frompath, topath, applyfunction, extrarguments, onwhat, limiter)
%CUBEMAKER Processes a Knossos cube directory at frompath. Makes a new
%directory at topath and saves the processed cubes there as cube_output.
%onwhat is a string specifying if the function acts on the onwhat = 'cube' or just the
%onwhat = 'coordinates'. onwhat defaults to 'cube' when omitted. Limiter
%specifies the range of the cubes to be processed. limiter = [a b c; e f g]
%would cause the function to process all cubes with MATLAB coordinates 
%between (a, b, c) and (e, f, g). extrarguments is a cell array of
%extra arguments applyfunction might require.  
%   [NOTE] The function applyfunction must be of the following format:
%          [cube_output] = applyfunction(cube_input, ...)
%   [NOT TESTED] Cuboid ready
%   [WARNING] Ignoring limiter would cause the function to process the
%             entire dataset. For larger datasets, this might take a while.
%(CC) Nasim Rahaman. Github: github.com/nasimrahaman


%default arguments
if ~exist('extrarguments', 'var') || isequal(onwhat, '~')
    extrarguments = {};
end

if ~exist('onwhat', 'var') || isequal(onwhat, '~')
    onwhat = 'cube';
end

%Fetch supercube dimensions
[numY, numX, numZ] = fetchSupercubeDimensions(frompath);

%default argument for limiter
if ~exist('limiter', 'var')
    limiter = [1 1 1; numY, numX, numZ];
end

%calculate the number of cubes to process
cubesremaining = (limiter(2,1) - limiter(1,1))*(limiter(2,2) - limiter(1,2))*(limiter(2,3) - limiter(1,3));

%initialize mainloop
for J = 1:numY
    for I = 1:numX
        for K = 1:numZ
            %skip all processing if not requested
            if any(~(([J I K] >= limiter(1,:)) & ([J I K] <= limiter(2, :))))
                continue
            end
            
            %echo
            disp(['Processing ', onwhat, ': ', num2str([J I K])]);
            
            cube_output = [];
            %load in a cube only when onwhat is set to cubes
            if ~strcmpi(onwhat, 'coordinates')
                if strcmpi(onwhat, 'context')
                    %try loading a .mat
                    try
                        cube_output = loadcontext([J I K], frompath);
                    catch
                        %load tiff
                        cube_output = loadtiffcontext([J I K], frompath);
                    end
                elseif strcmpi(onwhat, 'cube')
                    %try loading a .mat
                    try
                        cube_output = loadcube([J I K], frompath);
                    catch
                        %load tiff
                        cube_output = loadtiff2mat([J, I, K], frompath);
                    end
                end
            end
            
            %if a function is given, get processing
            tic;
            if exist('applyfunction', 'var')
                if strcmpi('cube', onwhat)
                    cube_output = applyfunction(cube_output, extrarguments{:});
                elseif strcmpi('coordinates', onwhat)
                    cube_output = applyfunction([J I K], frompath, extrarguments{:});
                elseif strcmpi('context', onwhat)
                    cube_output = applyfunction(cube_output, extrarguments{:}); 
                    %strip excess cubes around cube_output
                    cube_output = cube_output(129:256, 129:256, 129:256, :);
                else
                    warning('onwhat string not recognized, function will not be applied.');
                end
            end
            proct = toc; 
            
            tic;
            %make directory and write to file
            access_string = [filesep, 'x', num2str(I-1, '%04d'), filesep, 'y', num2str(J-1, '%04d'), filesep, 'z', num2str(K-1, '%04d')];
            mkdir([topath, access_string])
            wherewasi = pwd;
            cd([topath, access_string]);
            save mitomap_output cube_output
            jh_saveImageAsTiff3D(uint16(cube_output), 'cube_output.tiff', 'gray', 'bitsPerSample', 16);
            cd(wherewasi)
            savt = toc;
            
            %estimate time remaining
            cubesremaining = cubesremaining - 1; 
            eta = (savt + proct)*cubesremaining; 
            
            disp(['Estimated Time Remaining: ', num2str(eta/60), ' minutes @ ', num2str(savt + proct), ' minutes/cube...'])
        end
    end
end

end


