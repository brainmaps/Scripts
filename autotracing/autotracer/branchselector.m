function [bpsteplog, bpcb] = branchselector(skelfile, targbranch)
%BRANCHSELECTOR Selects a branchpoint from the stack of candidate
%branchpoints (bps) and saves selection to abps (archived branchpoint
%stack)
%OUTPUT: 
% bpsteplog : steplog for next pass
%      bpcb : parent branch
%NOTE:  bps = {branch, alphapoint, {parentnode, cpind}, conf}
%      abps = {sourcebranch, alphapoint, {parentnode, cpind}, conf, targetbranch}

%parameter for alpha point search width
apscan = 50;

%check if abps exists. Create one if not.
var = whos(skelfile);
if ~ismember('abps', {var.name})
    skelfile.abps = {};
    newabps = true;
else
    if isequal(size(skelfile.abps), [0 0])
        newabps = true;
    else
        newabps = false;
    end
end

%repeat until a legit branch is found
while true
    %load abps to RAM
    abps = skelfile.abps;
    bps = skelfile.bps;
    
    %check if bps empty
    if isempty(bps)
        bpsteplog = {}; 
        bpcb = NaN; 
        return
    end
    
    %sort bps to pick only the best branches first
    [~, bpssortind] = sortrows(cell2mat(bps(:, 4)), [1]);
    %move nans to the top
    %find nans
    naninbpsind = find(isnan(cell2mat(bps(:, 4)))); 
    %get rid of nans in bpssortind
    bpssortnonanind = bpssortind(~ismember(bpssortind, naninbpsind)); 
    %move nans to top
    bpssortnantopind = [naninbpsind; bpssortnonanind];
    bps = bps(bpssortnantopind, :);
    
    %select candidate from bps
    bpcand = bps(end, :);
    
    %check if there has been a branch in vicinity of the alpha point of bpcand
    %extract parent branch (bpcb: branch point candidate branch)
    bpcb = bpcand{1};
    %load trimmed branchlog to RAM
    branchlog = loadfromskelfile(skelfile, bpcb);
    %convert to global
    branchlog = steplog2globalcoordinates(branchlog); 
    %extract alpha point index of the control point (bpcap: branch point
    %candidate alpha point)
    bpcap = bpcand{2};
    %extract parentnode (NOTE: parnode and bpcap live in the same branch - bpcb)
    parnode = bpcand{3}{1};
    %extract index of the relevant control point of parnode
    cpind = bpcand{3}{2}; 
    %extract controlpoint coordinates from parent node
    currcp = branchlog{bpcand{3}{1}, 6}{cpind};
    
    
    %if abps exists:
    if ~newabps
        %STEP 1: Check if currcp lies within any of the previously traced
        %        branches. 
        %find all entries in abps with matching parent branch index...
        findbind = cellfun(@(x) x == bpcb, abps(:,1));
        %... and alpha points
        findapind = cellfun(@(x) x > (bpcap - apscan) & x < (bpcap + apscan), abps(:,2));
        findsearchind = findbind & findapind;
        cpinb = [];
        for k = [find(findsearchind)]'
            %k corresponds to branch indices in abps. Extract target branch and
            %check if currcp lies within it
            targb = abps{k, 4};
            cpinb = [cpinb; iscontpntinbranch(skelfile, currcp, targb)]; %#ok<AGROW>
        end
        %check if controlpoint was found within any of the previously
        %traced branches
        if any(cpinb)
            %pop from bps without doing anything
            bps = bps(1:(end-1), :);
            skelfile.bps = bps;
            continue
        else
            %STEP 2: branch legit, find steplog entry
            %find segment in which parent node point resides
            [s, sind] = findindinbranchseg(skelfile, bpcb, parnode);
            %load from skelfile
            seglog = steplog2globalcoordinates(fetchfromskelfile(skelfile, bpcb, s));
            parnodelog = seglog(sind, :);
            %rectify and return
            %NOTE: parnode and currcp lie within the
            %same context, so no cube business to take care of
            %set steve's target to the midpoint of the line connecting the
            %parent node coordinates parnodecoord and its controlpoint currcp
            parnodecoord = parnodelog{1};
            targvec = round((currcp + parnodecoord)/2);
            dirvec = targvec - parnodecoord;
            %assign to bsteplog
            bpsteplog = parnodelog;
            bpsteplog{4} = targvec;
            bpsteplog{5} = dirvec;
            bpsteplog{6} = {};
            bpsteplog = global2steplogcoordinates(bpsteplog); 
            %pop from bps and append to abps
            bps = bps(1:(end-1), :);
            skelfile.bps = bps;
            abps = [abps; [bpcand, {targbranch}]];
            skelfile.abps = abps;
            %get the hell out of the loop
            return
        end
    else
        %STEP 2: branch legit, find steplog entry
        %find segment in which parent node point resides
        [s, sind] = findindinbranchseg(skelfile, bpcb, parnode);
        %load from skelfile
        seglog = steplog2globalcoordinates(fetchfromskelfile(skelfile, bpcb, s));
        parnodelog = seglog(sind, :);
        %rectify and return
        %NOTE: parnode and currcp lie within the
        %same context, so no cube business to take care of
        %set steve's target to the midpoint of the line connecting the
        %parent node coordinates parnodecoord and its controlpoint currcp
        parnodecoord = parnodelog{1};
        targvec = round((currcp + parnodecoord)/2);
        dirvec = targvec - parnodecoord;
        %assign to bsteplog
        bpsteplog = parnodelog;
        bpsteplog{4} = targvec;
        bpsteplog{5} = dirvec;
        bpsteplog{6} = {};
        bpsteplog = global2steplogcoordinates(bpsteplog);
        %pop from bps and append to abps
        bps = bps(1:(end-1), :);
        skelfile.bps = bps;
        abps = [abps; [bpcand, {targbranch}]];
        skelfile.abps = abps;
        %get the hell out of the loop
        return
    end
end

end

