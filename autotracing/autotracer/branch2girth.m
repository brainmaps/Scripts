function branch2girth(skelfile, b)
%BRANCH2GIRTH Calculates the cell girth at every node in an entire branch
%(b) in matfile (skelfile) and saves to skelfile (in girthcell). 
%   OUTPUT (in matfile): 
%       girthcell: cell array where girthcell{b} returns a cell containing
%       girtharray, smallgirtharray, largegirtharray

%load fileindex
fileindex = skelfile.fileindex; 

%find segments in branch
seginbranch = fileindex(fileindex(:, 1) == b, 2); 

%initialize containers
bgirtharray = []; 
bsmallgirtharray = [];
blargegirtharray = []; 

%loop over 
for seg = [seginbranch]'
    %load from skelfile
    steplog = loadfromskelfile(skelfile, b, seg, false); 
    %run steplog2girth on steplog
    [girtharray, smallgirtharray, largegirtharray] = steplog2girth(steplog);  
    %save to container
    bgirtharray = [bgirtharray; girtharray]; 
    bsmallgirtharray = [bsmallgirtharray; smallgirtharray];
    blargegirtharray = [blargegirtharray; largegirtharray];
end

%check if girthcell exists in skelfile; create one if it doesn't
var = whos(skelfile);  
if ~ismember('girthcell', {var.name})
    %initialize
    girthcell = cell(b, 3); 
    girthcell(b, :) = {bgirtharray, bsmallgirtharray, blargegirtharray}; 
    skelfile.girthcell = girthcell; 
elseif size(skelfile.girthhcell, 1) + 1 == b
    skelfile.girthcell = [skelfile.girthcell; {bgirtharray, bsmallgirtharray, blargegirtharray}]; 
elseif size(skelfile.girthcell, 1) < b - 1
    catcell = cell(b - size(skelfile.girthcell,1), 3); 
    catcell(end, :) = {bgirtharray, bsmallgirtharray, blargegirtharray}; 
    skelfile.girthcell = [skelfile.girthcell; catcell]; 
elseif size(skelfile.girthcell, 1) >= b
    skelfile.girthcell(b, :) = {bgirtharray, bsmallgirtharray, blargegirtharray}; 
end


end