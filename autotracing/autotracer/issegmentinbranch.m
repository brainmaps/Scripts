function [overlap, seginbranch] = issegmentinbranch(skelfile, b, seglog)
%ISSEGMENTINBRANCH Checks if segment seglog is redundantly traced along
%branch b in skelfile. 

%integrity check on seglog
if size(seglog,1) < 2
    error('Seglog must have 2 or more entries. Consider using ispointinbranch() instead.')
end

%load branch from skelfile
branchlog = loadfromskelfile(skelfile, b); 

%load girthcell from skelfile. {} indexing is not allowed for matfiles.
cellgirtharray = skelfile.girthcell(b, 1);
girtharray = cellgirtharray{1};

%extract nodes in seglog
nodecoord = cell2mat(seglog(2:end,4));

%check if nodes in branch
nodeinbranch = ispointinbranch(nodecoord, branchlog, girtharray); 

%calculate the ratio of the number of nodes found in branch b to the total
%number of nodes
overlap = numel(find(nodeinbranch))/numel(nodeinbranch); 

if overlap > 0.5
    seginbranch = true; 
end

end

