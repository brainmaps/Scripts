function [pathcube] = visualizepath(steplog, cube)
%VISUALIZEPATH Annotates cube with the path traced by Steve (as contained
%in steplog). 

%take measurements on steplog
numnodes = size(steplog, 1);

%copy cube to pathcube
pathcube = cube; 

%loop over all nodes
for n = 1:numnodes
    %extract current and target coordinates
    currcoord = steplog{n, 1}; 
    targcoord = steplog{n, 4};
    pathcube = connectpoints(targcoord, currcoord, cube);
end


end


function [outcube] = connectpoints(p1, p2, cube)

%generate direction vector and calc. appx norm
dirvec = p2 - p1; 
veclen = norm(dirvec, 2);
e = dirvec/veclen;

%copy cube to outcube
outcube = cube;


for k = linspace(0,1,round(veclen) + 20)
    paintercoord = round(p1 + k.*veclen.*e);
    outcube(paintercoord(1), paintercoord(2), paintercoord(3)) = true;
end

end