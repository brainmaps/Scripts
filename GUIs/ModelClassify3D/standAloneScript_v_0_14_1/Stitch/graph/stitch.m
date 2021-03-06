function stitch(frompath, topath, enumpath, limiter)
%STITCH Global relabelling of connected component ID's. 
%A given connected component in a given cube is represented by a node in a
%graph, where an edge between two given nodes represents if the two connected
%components are connected (over the corresponding cube edge). A connected
%component analysis (graph theoretical) is run and the results
%consolidated to a globally labeled directory of cubes. 
%   Arguments: 
%       frompath: path to cubewise labeled directory (input directory, should exist!)
%                 The algorithm expects bwlabeln'd cubes. 
%       topath: (optional) path to globally labeled directory (output directory, must
%               not exist)
%       enumpath: (optional) path to an intermediate directory with globally
%                 enumerated label ID's (like frompath, but without 2
%                 labels repeating over the entire dataset).
%       limiter: (optional) limits the processing scope. Example: limiter = [2 2 2; 6
%                6 6] would tell the program to only process cubes with
%                coordinates [2 2 2] <= [i j k] <= [6 6 6]. 
%(CC) Nasim Rahaman. Github: github.com/nasimrahaman

%defaults
if ~exist('enumpath', 'var') || isequal(enumpath, '~')
    enumpath = [frompath, '-enumlabeled'];
end 

if ~exist('topath', 'var') || isequal(topath, '~')
    topath = [frompath, '-stitched'];
end 

if ~exist('limiter', 'var')
    [numY, numX, numZ] = fetchSupercubeDimensions(frompath); 
    limiter = [1, 1, 1; numY, numX, numZ];
end

%generate connectivity graph
cg = graphmaker(frompath, enumpath, limiter);

disp('Computing Connected Components...')
%connected component analysis
[~, cgcc] = graphconncomp(cg, 'Directed', false); 

disp('Consolidating Labels...')
%consolidate labels
cubeprocessor(enumpath, topath, @consolidatelabels, {cgcc}, 'cube', limiter);

disp('Done.')

end

