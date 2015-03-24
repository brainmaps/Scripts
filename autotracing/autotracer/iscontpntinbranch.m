function [cpntinbranch] = iscontpntinbranch(skelfile, cp, targbranch)
%ISCONTPNTINBRANCH Checks if a given control point cp lies within a given
%branch (targbranch) in skelfile. Use as feeder function for ispointinbranch. 
%   Replacement for iscontpntinbranch2, using ispointinbranch's vectorized
%   engine. 

%load branchlog
branchlog = loadfromskelfile(skelfile, targbranch); 

%convert to global coordinates
branchlog = steplog2globalcoordinates(branchlog); 


%load girthcell from skelfile. {} indexing is not allowed for matfiles.
cellgirtharray = skelfile.girthcell(b, 1);
girtharray = cellgirtharray{1};

%check if cp in targbranch
cpntinbranch = ispointinbranch(cp, branchlog, girtharray);


end

