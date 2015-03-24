function [newsteplog] = steplog2smartcontext(steplog, targcontcoord)
%STEPLOG2SMARTCONTEXT Converts coordinates in steplog to valid coordinates
%in contcoord.

%copy steplog to newsteplog
newsteplog = steplog; 

%main loop
for k = 1:size(steplog, 1)
    %check if target context is compatible
    %fetch current context
    currcont = steplog{k, 7}; 
    if max(abs(currcont - targcontcoord)) <= 1
        %compatible
        %convert source
        currsource = steplog{k, 1}; 
        newsource = contextcoordinatetransition(currsource, currcont, targcontcoord);
        %convert target
        currtarg = steplog{k, 4}; 
        newtarget = contextcoordinatetransition(currtarg, currcont, targcontcoord); 
        %convert controlpoints
        cps = steplog{k, 6};
        cplen = size(cps, 1);
        ncontpnts = {};
        for m = 1:cplen
            contpnt = cps(m);
            ncontpnts = [ncontpnts; {contextcoordinatetransition(contpnt, currcont, targcontcoord)}];
        end
        
        %move to gsl
        newsteplog{k, 1} = newsource;
        newsteplog{k, 4} = newtarget;
        newsteplog{k, 6} = ncontpnts;
        newsteplog{k, 7} = targcontcoord; 
    else
        %incompatible
        continue
    end
end


end

