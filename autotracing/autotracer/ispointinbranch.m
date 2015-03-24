function [pointinbranch, branchextension, minind1s, minind2s, pinbconf] = ispointinbranch(p, branchlog, girtharray, loadnodes, refnode)
%ISPOINTINBRANCH Checks if the point p (global coordinates) lies within
%branch represented branchlog & girtharray. p can also be a n-by-3 list of
%coordinates.
%   OUTPUT: 
%       pointinbranch: whether point p is in branch (specified by
%                      branchlog)
%       branchextension: whether point p is a branch extension
%       minind1s: n-by-1 array of node positions (in branchlog) of alpha
%                 points
%       minind2s: like minind1s, but for beta points
%       pinbconf: n-by-1 array of numbers quantifying the confidence in
%                 decision. Large pinbconf -> more confindent. 

%parameters
debugswitch = 'A';

%defaults
if ~exist('loadnodes', 'var')
    loadnodes = 1:size(branchlog, 1);
end

%extract coordinates
coordlist = branchlog(loadnodes, 1);
girthlist = girtharray(loadnodes);

%preallocate
pointinbranch = false(size(p,1), 1); 
branchextension = false(size(p,1), 1); 
minind1s = zeros(size(p, 1), 1);
minind2s = zeros(size(p, 1), 1); 
pinbconf = zeros(size(p, 1), 1); 

%vectorize
for k = 1:size(p, 1)
    %define anon function to calculate distance from CP
    calcdistfromcp = @(x) norm(x - p(k, :));
    
    %calculate distlist
    distlist = cellfun(calcdistfromcp, coordlist);
    
    %compute distance minima
    mininds = find(imregionalmin(distlist));
    
    %\\\\ DEBUG \\\\
    switch debugswitch
        case 'A'
            %more than 1 regional minima may appear, for cp is not a
            %node (but a control point, duh). Not to be confused with
            %bounceback detector in steve.
            %problem: which minima is the alpha point?
            if exist('refnode', 'var')
                %workaround: pick the minima closest to reference node (nodeind)
                if numel(mininds) > 1
                    %calculate distance from nodeind
                    distancefromnodeind = abs(mininds - refnode);
                    %find minimum
                    [~, minindinmininds] = min(distancefromnodeind);
                    %assign first minima
                    minind1 = mininds(minindinmininds);
                else
                    minind1 = mininds;
                end
            else
                %workaround: pick the smallest from distlist
                [~, minind1] = min(distlist);
            end
        case 'B'
            %something's fishy if more than 1 regional minimia appears
            minind1 = mininds;
            if numel(minind1) > 1
                warning('Possible bounceback detected. Skipping branch detection')
                pointinbranch(k) = false;
                continue
            end
    end
    %\\\\ END DEBUG \\\\
    
    %determine second minima
    if minind1 > 1 && minind1 < size(distlist,1)
        %minima within skeleton (i.e. not a branch extension)
        if distlist(minind1 - 1) > distlist(minind1 + 1)
            minind2 = minind1 + 1;
        else
            minind2 = minind1 - 1;
        end
        branchextension(k) = false;
    elseif minind1 == 1
        minind2 = minind1 + 1;
        branchextension(k) = true;
    else
        minind2 = minind1 - 1;
        branchextension(k) = true;
    end
    
    %assign return variable
    minind1s(k) = minind1; 
    minind2s(k) = minind2; 
    
    %extract relevant coordinates
    alphacoord = coordlist{minind1}; %alpha point
    betacoord = coordlist{minind2}; %beta point
    
    %extract relevant girths
    alphagirth = girthlist(minind1);
    betagirth = girthlist(minind2);
    
    %variable reassignment
    currcp = p; 
    
    %calculate perpendicular distance of currcp from the line
    %connecting alpha and beta points
    perpdist = norm(currcp - alphacoord) * sqrt(1 - (normdot((betacoord - alphacoord),(currcp - alphacoord)))^2);
    
    %calculate interpolated girth at where currcp is
    cpgirth = alphagirth*((norm(currcp - alphacoord)*normdot((betacoord - alphacoord),(currcp - alphacoord)))/(norm(alphacoord - betacoord))) ...
        + betagirth*((norm(currcp - betacoord)*normdot((alphacoord - betacoord),(currcp - betacoord)))/(norm(alphacoord - betacoord)));
    
    %decide if point in branch
    if cpgirth/2 > perpdist
        pointinbranch(k) = true;
    else
        pointinbranch(k) = false;
    end
    
    %quantify confidence in decision
    pinbconf(k) = 2*(perpdist/cpgirth);
    
end

end

