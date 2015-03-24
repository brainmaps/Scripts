function [s, sind] = findindinbranchseg(skelfile, b, bind)
%FINDINDINBRANCHSEG Finds the segment (& corresponding index) where the 
%node indexed bind (resp b) is located in.

%load fileindex to RAM
fileindex = skelfile.fileindex; 

%take measurements
sizelist = measureskelfile(skelfile); 

%trim sizelist
sizelist = sizelist(fileindex(:,1) == b, :);

%cumulate 
csl = cumsum(sizelist); 

%check for boundary cases
s = find((csl - bind) >= 0, 1); 
if s ~= 1
    sind = bind - csl(s-1);
else
    sind = bind; 
end

end

