function [steplog] = spoofsteplog(skelfile, b, s, nodeind, targcoord, sepprop, basepath)
%SPOOFSTEPLOG Spoofs a steplog to make steve (stacy) trace along a given
%direction (towards (global coordinates) targcoord). skelfile, b and nodeind are required for vw
%and pxr in the new steplog. Omitting s would result in the function
%assuming that nodeind is the node index in branch (and not a segment). 
%basepath is required for converting global to context coordinates.
%sepprop tells the seperation proportion (see code). Omit with '~' or
%'none'. 
%   To omit s, use '~' or 'none' as placeholders. 

%defaults
if ~exist('basepath', 'var')
    basepath = '/Users/nasimrahaman/Documents/MATLAB/MPI/mbrain/data/mbrain-convnet';
end

if ~exist('sepprop', 'var') || isequal('sepprop', '~') || isequal('sepprop', 'none')
    sepprop = 0.5; 
end 

%hardwired parameters
%context size
contsize = 384;

%parse arguments
if isequal(s, '~') || isequal(s, 'none')
    isbranchind = true; 
end

%mend seg- and nodeind
if isbranchind
    [s, nodeind] = findindinbranchseg(skelfile, b, nodeind);
end

%fetch node from BbSs in skelfile
steplog = global2steplogcoordinates(steplog2globalcoordinates(fetchfromskelfile(skelfile, b, s, nodeind))); 

%convert targcoord to context coordinates
[targcont, targcoord] = global2contextcoordinates(targcoord, basepath);

%transition to node context in steplog
targcoord = contextcoordinatetransition(targcoord, targcont, steplog{1, 7}); 

%make sure steplogtarget is within bounds
while true
    steplogtarg = round(((1 - sepprop)*steplog{1} + sepprop*targcoord));    
    if all(steplogtarg > [0 0 0]) && all(steplogtarg <= [contsize contsize contsize]);
        steplog{4} = steplogtarg;
        steplog{5} = targcoord - steplog{1};
        break
    else
        sepprop = 0.5*sepprop; 
    end
end


end