function [girtharray, smallgirtharray, largegirtharray] = steplog2girth(steplog)
%STEPLOG2GIRTH Calculates the cell diameter at each node in steplog and
%returns result as an array (which can eventually be horzcat'ed to
%steplog). 

%initialize
girtharray = zeros(size(steplog,1), 1); 
smallgirtharray = zeros(size(steplog,1), 1); 
largegirtharray = zeros(size(steplog,1), 1); 

%loop over steplog
for k = 1:size(steplog, 1)
    
    %calculate axis vector
    if k == 1
        axisvec = steplog{1, 5}; 
    else
        axisvec = normvecmean(steplog{k, 5}, steplog{k - 1, 5}); 
    end
    
    %calculate diameter
    [girtharray(k), ~, smallgirtharray(k), largegirtharray(k)] = girthfinder(steplog{k, 2}, axisvec); 
end


end

