function steplog2projection(steplog)
%STEPLOG2PROJECTION Converts all pxr's in steplog to projection (with
%isosurface in 3-space)

%concatenate all available pxr's in steplog
allpxr = cat(1, steplog{:,3}); 

%fetch projection cube
projcube = pxr2projection(allpxr); 

%smooth projcube
smprojcube = smooth3(projcube, 'gaussian', 5, 2); 

%plot isosurface
isosurface(smprojcube);


end

