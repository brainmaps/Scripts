function updatebps(skelfile, b)
%UPDATEBPS Prunes branch BbS* for false positive controlpoints and builds a
%stack of candidate branchpoints (bps). 

%dev & debug
debugswitch = 'A'; 

%parameters
%trail size to evaluate cpdist
cptrail = 20; 
%flag to indicate if a branch is to be extended
extendbranch = false; 

%load fileindex to RAM
fileindex = skelfile.fileindex; 

%check if branchpoint stack (bps) exists in skelfile
var = whos(skelfile); 
if ~ismember({'bps'}, {var.name})
    skelfile.bps = {};
end

%load stripped branch and convert to global
branchlog = loadfromskelfile(skelfile, b); 
branchlog = steplog2globalcoordinates(branchlog); 

%load girthcell from skelfile. {} indexing is not allowed for matfiles.
cellgirtharray = skelfile.girthcell(b, 1);
girtharray = cellgirtharray{1};
%small and large girtharrays are not required at the moment
%sgirtharray = skelfile.girthcell{b, 2}; 
%lgirtharray = skelfile.girthcell{b, 3}; 

%take measurements
bloglen = size(branchlog, 1);

%NOTE steplog looks like:
%     1      2    3     4       5           6             7
%{currcoord, vw, pxr, target, dirvec, controlpntssel, cubecoord;    n = 1
%   ...                                                             n = 2
%   ... }                                                           n = 3
%and branchlog like:
%{currcoord, [], {}, target, dirvec, controlpntssel, cubecoord; ...}


%loop over nodes
for nodeind = 1:bloglen
    %current coordinates
    currcoord = branchlog{nodeind, 1}; 
    dirvec = branchlog{nodeind, 5}; 
    %extract controlpoints
    cpcell = branchlog{nodeind, 6};
    %skip iteration if cpcell found empty
    if isempty(cpcell)
        continue
    end
    %loop over controlpoints in nodes
    for cpind = 1:size(cpcell, 1)
        %parse
        currcp = cpcell{cpind}; 
        cpdirvec = currcp - currcoord; 
        
        %\\\\ DEBUG \\\\
        switch debugswitch
            case 'A'
                loadnodes = 1:bloglen;
            case 'B'
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
                        if cptrail + nodeind > bloglen
                            loadnodes = nodeind:bloglen;
                        else
                            loadnodes = nodeind:(cptrail + nodeind);
                        end
                        
                    case 'retro'
                        if nodeind - cptrail < 1
                            loadnodes = 1:nodeind;
                        else
                            loadnodes = (nodeind - cptrail):nodeind;
                        end
                        
                    case 'perp'
                        %unusual special case where cpdirvec is perpendicular to
                        %dirvec
                        %yadda yadda
                end
        end
        %\\\\ END DEBUG \\\\
        
        %extract coordinates
        coordlist = branchlog(loadnodes, 1); 
        girthlist = girtharray(loadnodes); 
        %define anon function to calculate distance from CP
        calcdistfromcp = @(x) norm(x - currcp); 
        
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
                %workaround: pick the minima closest to nodeind
                
                if numel(mininds) > 1
                    %calculate distance from nodeind
                    distancefromnodeind = abs(mininds - nodeind);
                    %find minimum
                    [~, minindinmininds] = min(distancefromnodeind);
                    %assign first minima
                    minind1 = mininds(minindinmininds); 
                else
                    minind1 = mininds; 
                end
            case 'B'
                %something's fishy if more than 1 regional minimia appears
                minind1 = mininds; 
                if numel(minind1) > 1
                    warning('Possible bounceback detected. Skipping branch detection')
                    continue
                end
        end
        %\\\\ END DEBUG \\\\
        
        %determine second minima 
        if minind1 > 1 && minind1 < size(distlist,1)
            if distlist(minind1 - 1) > distlist(minind1 + 1)
                minind2 = minind1 + 1; 
            else
                minind2 = minind1 - 1;
            end
            extendbranch = false;
        elseif minind1 == 1
            minind2 = minind1 + 1;
            extendbranch = true;
        else
            minind2 = minind1 - 1;
            extendbranch = true; 
        end
        
        %extract relevant coordinates
        alphacoord = coordlist{minind1}; %alpha point
        betacoord = coordlist{minind2}; %beta point
        
        %extract relevant girths
        alphagirth = girthlist(minind1); 
        betagirth = girthlist(minind2); 
        
        %calculate perpendicular distance of currcp from the line
        %connecting alpha and beta points
        perpdist = norm(currcp - alphacoord) * sqrt(1 - (normdot((betacoord - alphacoord),(currcp - alphacoord)))^2); 
        
        %calculate interpolated girth at where currcp is
        cpgirth = alphagirth*((norm(currcp - alphacoord)*normdot((betacoord - alphacoord),(currcp - alphacoord)))/(norm(alphacoord - betacoord))) ...
            + betagirth*((norm(currcp - betacoord)*normdot((alphacoord - betacoord),(currcp - betacoord)))/(norm(alphacoord - betacoord)));
        
        %compare perpdist with cpgirth and make sure no branch extension
        if perpdist < cpgirth/2 && ~extendbranch
            %reject
            continue
        else
            %report a candidate branch to bps
            skelfile.bps = [skelfile.bps; {b, loadnodes(minind1), {nodeind, cpind}}];
        end        
        
    end
end

end

