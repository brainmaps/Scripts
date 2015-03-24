function [sizelist, wid] = measureskelfile(skelfile)
%MEASURESKELFILE Calculates the size of all segments in skelfile. 
%   Indexing compatible with fileindex. 

%load fileindex to ram
fileindex = skelfile.fileindex; 

if isequal(fileindex, [0 0])
    sizelist = 0; 
    return
end

%initialize size
sizelist = zeros(size(fileindex, 1),1); 

%evaulate width
wid = size(eval(['skelfile.B', num2str(fileindex(2, 1)), 'S', num2str(fileindex(2, 2))]), 2); 

%loop over fileindex and calculate size
for k = 2:size(fileindex, 1)
    %parse b and s
    b = fileindex(k, 1); 
    s = fileindex(k, 2); 
    %evaluate size
    sizelist(k) = size(eval(['skelfile.B', num2str(b), 'S', num2str(s)]), 1);
end


end

