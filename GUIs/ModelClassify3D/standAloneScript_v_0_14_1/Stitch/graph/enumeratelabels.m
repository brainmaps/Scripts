function enumeratelabels(frompath, topath, limiter)
%ENUMERATELABELS Enumerates labels over an entire knossos directory such
%that no 2 labels are repeated. Like enumeratebwconncomplabel, but without
%using cubeprocessor
%   Not to be used with cubeprocessor
%   See cubeprocessor for more on limiter

[numY, numX, numZ] = fetchSupercubeDimensions(frompath);

%default argument for limiter
if ~exist('limiter', 'var')
    limiter = [1 1 1; numY, numX, numZ];
end

%default for topath
if ~exist('topath', 'var')
    topath = [frompath '-enumlabeled'];
end

%initialize a global enumerator
glc = 0;


for J = 1:numY
    for I = 1:numX
        for K = 1:numZ
            %skip all processing if not requested
            if any(~(([J I K] >= limiter(1,:)) & ([J I K] <= limiter(2, :))))
                continue
            end
        
            %load cube
            cube = loadcube([J I K], frompath);
            
            %label cube
            cube_output = conncomplabel(cube);
            
            %enumerate labels: add glc to every nonzero element in labcube
            cube_output(~(cube_output == 0)) = cube_output(~(cube_output == 0)) + glc;
            
            %update glc, but only when the cube isn't empty
            if ~(max(cube_output(:)) == 0)
                glc = max(cube_output(:));            
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

