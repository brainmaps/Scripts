function [cpinbranch] = iscontpntinbranch(skelfile, currcp, b, refaddress, cptrail)
%ISCONTPNTINBRANCH Checks if the given controlpoint currcp lies within a
%branch (branchlog). cptrail is a parameter.
%[DECOMISSIONED]

%load stripped branch and convert to global
branchlog = loadfromskelfile(skelfile, b);
branchlog = steplog2globalcoordinates(branchlog);

%load girthcell
girtharray = skelfile.girthcell{b, 1};
sgirtharray = skelfile.girthcell{b, 2};
lgirtharray = skelfile.girthcell{b, 3};

%take measurements
bloglen = size(branchlog, 1);

%NOTE steplog looks like:
%     1      2    3     4       5           6             7
%{currcoord, vw, pxr, target, dirvec, controlpntssel, cubecoord;    n = 1
%   ...                                                             n = 2
%   ... }                                                           n = 3
%and branchlog like:
%{currcoord, [], {}, target, dirvec, controlpntssel, cubecoord; ...}

if exist('refaddress', 'var') && exist('cptrail', 'var')
    %current coordinates
    refcoord = branchlog(refaddress, 1);
    dirvec = branchlog(refaddress, 5);
    %cp direction vector
    cpdirvec = currcp - refcoord;
    
    %check if controlpoint prograde or retrograde to steplog
    if normdot(dirvec, cpdirvec) > 0
        cporient = 'pro';
    elseif normdot(dirvec, cpdirvec) < 0
        cporient = 'retro';
    else
        cporient = 'perp';
    end
    
    %switch
    switch cporient
        case 'pro'
            %load the next cptrail entries (if possible)
            if cptrail + refaddress > bloglen
                loadnodes = refaddress:bloglen;
            else
                loadnodes = refaddress:(cptrail + refaddress);
            end
            
        case 'retro'
            if refaddress - cptrail < 1
                loadnodes = 1:refaddress;
            else
                loadnodes = (refaddress - cptrail):refaddress;
            end
            
        case 'perp'
            %unusual special case where cpdirvec is perpendicular to
            loadnodes = 1:bloglen; 
    end
else
    loadnodes = 1:bloglen; 
end

%extract coordinates
coordlist = branchlog(loadnodes, 1);
girthlist = girtharray(loadnodes);
%define anon function to calculate distance from CP
calcdistfromcp = @(x) norm(x - currcp);

%calculate distlist
distlist = cellfun(calcdistfromcp, coordlist);

%compute distance minima
minind1 = find(imregionalmin(distlist));

%something's fishy if more than 1 regional minimia appears
if numel(minind1) > 1
    warning('Possible bounceback detected. Skipping branch detection')
    cpinbranch = false;
    return
end

%determine second minima
if minind1 > 1 && minind1 < size(distlist,1)
    if distlist(minind1 - 1) > distlist(minind1 + 1)
        minind2 = minind1 + 1;
    else
        minind2 = minind - 1;
    end
elseif minind1 == 1
    minind2 = minind1 + 1;
else
    minind2 = minind1 - 1;
end

%extract relevant coordinates
alphacoord = coordlist(minind1); %alpha point
betacoord = coordlist(minind2); %beta point

%extract relevant girths
alphagirth = girthlist(minind1);
betagirth = girthlist(minind2);

%calculate perpendicular distance of currcp from the line
%connecting alpha and beta points
perpdist = norm(currcp - alphacoord) * sqrt(1 - (normdot((betacoord - alphacoord),(currcp - alphacoord)))^2);

%calculate interpolated girth at where currcp is
cpgirth = alphagirth*((norm(currcp - alphacoord)*normdot((betacoord - alphacoord),(currcp - alphacoord)))/(norm(alphacoord - betacoord))) ...
    + betagirth*((norm(currcp - betacoord)*normdot((alphacoord - betacoord),(currcp - betacoord)))/(norm(alphacoord - betacoord)));

%compare perpdist with cpgirth
if perpdist < cpgirth/2
    cpinbranch = true;
else
    cpinbranch = false; 
end


end



