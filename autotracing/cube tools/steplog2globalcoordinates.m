function [globsteplog] = steplog2globalcoordinates(steplog)
%STEPLOG2GLOBALCOORDINATES Converts all local context coordinates in steplog to
%global coordinates and saves results in globsteplog. 

%take measurements
sloglen = size(steplog, 1); 

%copy steplog to an intermediate variable
gsl = steplog; 

%loop over steplog entries
for k = 1:sloglen
    %convert source
    gsourcecoord = context2globalcoordinates(steplog{k, 7}, steplog{k, 1}); 
    %convert target
    gtargetcoord = context2globalcoordinates(steplog{k, 7}, steplog{k, 4});
    %convert control points
    cps = steplog{k, 6};
    cplen = size(cps, 1);
    gcontpnts = {};
    for m = 1:cplen
        contpnt = cps(m); 
        gcontpnts = [gcontpnts; {context2globalcoordinates(steplog{k, 7}, contpnt)}]; 
    end
    
    %move to gsl
    gsl{k, 1} = gsourcecoord; 
    gsl{k, 4} = gtargetcoord; 
    gsl{k, 6} = gcontpnts; 
    
end

%return
globsteplog = gsl; 

end

