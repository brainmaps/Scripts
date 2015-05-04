function conngraph = graphmaker(basepath, enumpath, limiter)
%GRAPHMAKER Generates a sparse connectivity graph of labeled connected
%components. Generates a directory of globally enumerated labels at basepath.
%   [ARGUMENTS] basepath: path to binary knossos cube directory.
%               limiter: a matrix of the following format: [a,b; c,d; e,f].
%                        This would cause the function to process all cubes
%                        with y coordinates between a & b, x coordinates
%                        between c & d and z coordinates between e & f. 
%(CC) Nasim Rahaman. Github: github.com/nasimrahaman


%retrieve dataset size
[numY, numX, numZ] = fetchSupercubeDimensions(basepath);

%default argument for limiter
if ~exist('limiter', 'var')
    limiter = [1 1 1; numY, numX, numZ];
end

%clear global variables named glc
clearvars -global glc

disp('Enumerating Labels...')
%label and globally enumerate labels
cubeprocessor(basepath, enumpath, @enumeratebwconncomplabel, {}, 'cube', limiter);

disp('Analyzing Boundaries...')
%run boundary analysis
conntup = boundaryanalysis(enumpath, limiter);

%call global label counter (from enumeratebwconncomplabel)
global glc; 

%write to graph
conngraph = sparse(conntup(:,1)', conntup(:, 2)', ones(size(conntup, 1), 1), glc, glc);
%and make it undirected
conngraph = logical(conngraph + conngraph');

end

