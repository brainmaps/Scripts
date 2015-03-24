function [steplog] = global2steplogcoordinates(globsteplog)
%GLOBAL2STEPLOGCOORDINATES Converts all global coordinates in globsteplog to
%local context coordinates.
%   steplog2globalcoordinates doesn't delete the column in steplog with context
%   coordinates. 

%take measurements
gsloglen = size(globsteplog, 1); 

%copy globsteplog to an intermediate variable
sl = globsteplog; 

%loop over steplog entries
for k = 1:gsloglen   
    
    %convert target
    [targetcontcoord, targetcoord] = global2contextcoordinates(globsteplog{k, 4});   
    
    %convert source
    [sourcecontcoord, sourcecoord] = global2contextcoordinates(globsteplog{k, 1}); 
    %check if source and target contcoord agree; if not, calculate
    %equivalent sourcecoord in targetcontcoord
    if ~isequal(sourcecontcoord, targetcontcoord)
        sourcecoord = contextcoordinatetransition(sourcecoord, sourcecontcoord, targetcontcoord);
    end
    
    %convert control points
    cps = globsteplog{k, 6};
    cplen = size(cps, 1);
    gcontpnts = {};
    for m = 1:cplen
        gcontpnt = cps(m); 
        [cpcontcoord, contpoint] = global2contextcoordinates(gcontpnt); 
        %check if the context coordinates match; if they don't, calculate
        %the corresponding contpoint coordinates in contcoord.
        if ~isequal(cpcontcoord, targetcontcoord)
            contpoint = contextcoordinatetransition(contpoint, cpcontcoord, targetcontcoord); 
        end
        gcontpnts = [gcontpnts; {contpoint}]; 
    end
    
    %move to sl
    sl{k, 1} = sourcecoord; 
    sl{k, 4} = targetcoord; 
    sl{k, 6} = gcontpnts; 
    sl{k, 7} = targetcontcoord;
    
end

%return
steplog = sl; 

end