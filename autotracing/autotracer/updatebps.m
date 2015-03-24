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
        
        %check if controlpoint in branch. ensure debugswitch is set to
        %'A' in ispointinbranch.m
        [cpinbranch, extendbranch, minind1, ~, pinbconf] = ispointinbranch(currcp, branchlog, girtharray, loadnodes, nodeind); 
        
        %do nothing if cp in branch and no branch extension
        %\\\\DEBUG\\\\
        %dev
        if cpinbranch || extendbranch
        %nodev
        %if cpinbranch && ~extendbranch
        %\\END DEBUG\\
            %reject
            continue
        else
            %report a candidate branch to bps
            skelfile.bps = [skelfile.bps; {b, loadnodes(minind1), {nodeind, cpind}, pinbconf}];
        end        
        
    end
end

end

