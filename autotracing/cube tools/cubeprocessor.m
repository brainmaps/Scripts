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



%default arguments
if ~exist('extrarguments', 'var')
    extrarguments = {};
end

if ~exist('onwhat', 'var')
    onwhat = 'cube';
end

%Fetch supercube dimensions
[numY, numX, numZ] = fetchSupercubeDimensions(frompath);

%default argument for limiter
if ~exist('limiter', 'var')
    limiter = [1 1 1; numY, numX, numZ];
end

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
                    cube_output = loadcontext([J I K], frompath);
                elseif strcmpi(onwhat, 'cube')
                    cube_output = loadcube([J I K], frompath);
                end
            end
            
            %if a function is given, get processing
            if exist('applyfunction', 'var')
                if strcmpi('cube', onwhat) || strcmpi('context', onwhat)
                    cube_output = applyfunction(cube_output, extrarguments{:});
                elseif strcmpi('coordinates', onwhat)
                    cube_output = applyfunction([J I K], frompath, extrarguments{:});
                elseif strcmpi('context', onwhat)
                    cube_output = applyfunction(cube_output, extrarguments{:}); 
                    %strip excess cubes around cube_output
                    cube_output = cube_output(129:256, 129:256, 129:256);
                else
                    warning('onwhat string not recognized, function will not be applied.');
                end
            end
            %make directory and write to file
            access_string = [filesep, 'x', num2str(I-1, '%04d'), filesep, 'y', num2str(J-1, '%04d'), filesep, 'z', num2str(K-1, '%04d')];
            mkdir([topath, access_string])
            wherewasi = pwd;
            cd([topath, access_string]);
            save mitomap_output cube_output
            cd(wherewasi)
        end
    end
end

end


