function [steplog, breakdiagnosis, cuberequest] = steve(varargin)
%STEVE Given a seedpoint (yxz), Steve tries to autotrace through a neuron. 
%   TSWs (Target Selection Workflows): 
%   Target Extraction with Area Classifier (TEAC): 
%       1. Select level 2 from 3 level otsu on viewfinder output (view)
%       2. Mask (original) result with orientation map
%       3. Connected component analysis on both original and masked
%          binaries
%       4. Calculate region areas from both original and masked labeled images
%       5. If 3 or more regions in original labeled image, classify regions
%          by OTSU. 
%       6. Pick the class of areawise largest patches in original image and
%          compare with its (corresponding) area in the masked labeled
%          image. Pick the patch with the largest ratio between areas in 
%          masked vs. original images. 
%       7. Pick maxima from this patch, assign as target. 
%
%   Obstacle Aware TEAC (TEAC+)
%       1. Try to ensure that selected TEAC target is within some distance
%          from an obstacle. 


%---DEFAULTS---
%parameters: 

%General
res = 360;
maxpasslim = 100;
maxsteplim = 50;
echo = true;
cubemargin = [0 0 0; 0 0 0];
method = 'VOTSU';
contextcoord = [NaN NaN NaN];

%viewfinder/integratorfinder
intthresh = 1; %threshold for integraterfinder

%bounceback detector
bbpoint = NaN;
detectbb = true;
trailsize = 6;
maxcelldiameter = 100;

%TEAC + TEAC+
clearancethresh = 20; %maximum distance the pointer is allowed to traverse
wallclearance = 5; %minimum clearance to be held before walls
edgeclearance = round(0.7*(res*res/4)); %almost irrelevant when detectbb on
minstepforward = 2;

%TEAC+
obsavrad = 5; %scan radius for obstacle avoidance
minobsdist = 3; %minimum allowable obstacle distance

%NBFCM + TEAC + VOTSU + TEAC+
tolerance = 0; %foresight solid angle; 0 => hemisphere

%VOTSU + NBFCM
srr = 0.125; %ratio of scan radius to propagation distance

%VOTSU
meanpropdist = 20; %mean propagation distance

%NBFCM
maxnhoodsize = 9;
nclust = 2; 
fcmopt = [nan, nan, nan, 0];
features = {@iden; @imgradient; @stdfilt5x5};

%global logs
steplog = {};
targetveclog = {};
bbdrecord = {};
%--------------

%---INPUT PARSER---

%unpack varargin if required
if isequal(size(varargin), [1, 1]) && iscell(varargin{1})
    varargin = varargin{1}; 
end

%custom input parser. To activate, replace input arguments with varargin and uncomment.
%length of input cell
inpsiz = size(varargin, 2);
for k = 1:inpsiz
    %skip if k odd (since it should contain data content and not tags)
    if mod(k, 2) == 0
        continue
    end
    %parse
    if strcmpi(varargin{k}, 'seed')
        seed = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'cube')
        cube = varargin{k + 1};
        if islogical(cube)
            distcube = bwdist(cube);
        elseif max(cube(:)) == 1
            distcube = bwdist(cube>0.2); %hardwired thresholding parameter for Sven's data
        end
    end
    
    if strcmpi(varargin{k}, 'tolerance')
        tolerance = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'bounceback detector trail size')
        trailsize = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'bounceback detector maximum cell diameter')
        maxcelldiameter = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'detect bouncebacks')
        detectbb = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'resolution')
        res = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'context coordinates')
        contextcoord = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'cube margin')
        cubemargin = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'steplog')
        steplog = varargin{k + 1};
        targetveclog = steplog(:,5); 
    end
    
    if strcmpi(varargin{k}, 'clearance threshold')
        clearancethresh = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'wall clearance')
        wallclearance = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'edge clearance')
        edgeclearance = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'number of passes') | strcmpi(varargin{k}, 'maxpasses')
        maxpasslim = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'number of steps') | strcmpi(varargin{k}, 'maxsteps')
        maxsteplim = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'echo')
        echo = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'method')
        method = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'minimum step size') | strcmpi(varargin{k}, 'minstepforward')
        minstepforward = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'minimum allowed obstacle distance') | strcmpi(varargin{k}, 'minobsdist')
        minobsdist = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'scan radius to propagation distance') | strcmpi(varargin{k}, 'srr')
        srr = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'maximum nhood size')
        maxnhoodsize = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'fcm options')
        fcmopt = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'features')
        features = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'mean propagation distance')
        meanpropdist = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'integrater threshold')
        intthresh = varargin{k + 1};
    end
end

%issue errors or warnings
if ~exist('cube', 'var')
    error('No cube found...')
end
%assign first target
if isempty(steplog) && ~exist('seed', 'var')
    error('Steplog/Seed not found...')
elseif isempty(steplog) && exist('seed', 'var')
    target = seed;
elseif ~isempty(steplog) && ~exist('seed', 'var')
    target = steplog{end, 4};
elseif isempty(steplog) && exist('seed', 'var')
    warning('Discarding provided seed and fetching target from steplog instead...');
    target = steplog{end, 4};
end

%------------------

%---INITIALIZATION---
%step counter
passcount = 1;
%control points
controlpnts = {};
%local logs; will be removed in a future version
targetcoordlog = {target};
vwlog = {};
pxrlog = {};
bouncebacklog = [];
%diagnosis strings
breakdiagnosis = '';
%cube request
cuberequest = [0 0 0];
%tolerance reset switch
resettolerancein = 0;
inptolerance = tolerance;
maxtolerance = inptolerance; 
%take measurements
[sizy, sizx, sizz] = size(cube);
%--------------------

%---PRIMARY LOOP---
while true
    %---validate---
    %validate loop pass/step
    if passcount > maxpasslim
        breakdiagnosis = 'Allowed number of passes taken';
        break
    end
    
    if size(steplog, 1) > maxsteplim
        breakdiagnosis = 'Allowed number of steps taken';
        break
    end
    
    %echo
    if echo
        disp(['Processing: Step ', num2str(size(steplog, 1)), ', Pass ', num2str(passcount),'...']);  
    end
    
    %---initialization---
    %pick current point and delete from queue
    currcoord = target;
    
    %---cube check---
    %decide if more context is required
    
    y = currcoord(1);
    x = currcoord(2);
    z = currcoord(3);
    
    %Looking top down at a cube:
    %go left
    if x <= cubemargin(1, 2)
        cuberequest(2) = -1;
    end
    
    %go right
    if x + cubemargin(2, 2) >= sizx
        cuberequest(2)= 1;
    end
    
    %forwards
    if y <= cubemargin(1, 1)
        cuberequest(1) = -1;
    end
    
    %backwards
    if y + cubemargin(2, 1) >= sizy
        cuberequest(1) = 1;
    end
    
    %go up
    if z <= cubemargin(1, 3)
        cuberequest(3) = -1;
    end
    
    %go down
    if z + cubemargin(2, 3) >= sizz
        cuberequest(3) = 1;
    end
    
    %return if cuberequest isn't all zeros. Note that cuberequest is always
    %[0 0 0] if cubemargin = [0 0 0], so a cuberequest is never actually
    %placed. Smooth.  
    if ~isequal(cuberequest, [0 0 0])
        breakdiagnosis = 'Cube request';    
        %echo
        if echo
            disp(breakdiagnosis)
        end      
        return
    end
    
    %clean up
    clear('x', 'y', 'z');
    
    %---viewfinding---
    %echo
    if echo
        disp(['Viewfinder on ', num2str(currcoord), '...']);
    end
    
    %look around
    [vw, pxr, nonanvw] = integraterfinder(currcoord, cube, intthresh);
    %save to log
    vwlog = [vwlog; {vw}];
    pxrlog = [pxrlog; {pxr}];
    
    %---target selection---
    %legend: 
    %   target: self explanatory
    %   dirvec: direction vector from currcoord
    
    %bounceback detector 
    if detectbb && size(steplog, 1) >= 3 && resettolerancein == 0
        if echo
            disp('Bounceback detection...');
        end
        [targtolerance, bbpoint, lspoint, pfp] = bouncebackdetector(steplog, trailsize, maxcelldiameter);
    end
    
    %echo
    if echo
        disp(['Target selection...']);
    end
    
    if resettolerancein > 0
        tolerance = maxtolerance; 
        resettolerancein = resettolerancein - 1; 
    else
        tolerance = inptolerance; 
    end
    
    %if no bounceback found: business as usual. Otherwise: delete from
    %steplog and reduce tolerance at bounceback point
    if isnan(bbpoint)
        if strcmpi(method, 'TEAC') || strcmpi(method, 'TEAC+')
            [target, dirvec, controlpntssel, breakloop, breakdiagnosis] = TEAC(method, currcoord, vw, pxr, targetveclog, clearancethresh, wallclearance, edgeclearance, minstepforward, tolerance, res, obsavrad, minobsdist, distcube);
        elseif strcmpi(method, 'NBFCM')
            [target, dirvec, controlpntssel, breakloop, breakdiagnosis] = NBFCM(currcoord, nonanvw, pxr, maxnhoodsize, features, nclust, fcmopt, targetveclog, tolerance, cube);
        elseif strcmpi(method, 'VOTSU')
            [target, dirvec, controlpntssel, breakloop, breakdiagnosis] = VOTSU(currcoord, nonanvw, pxr, targetveclog, tolerance, srr, meanpropdist, cube); 
        end
    else
        %record instance
        bouncebacklog = [bouncebacklog, bbpoint];
        if echo
            disp(['Bounceback detected at step ', num2str(bbpoint), '...'])
        end
        %Assume cell termination on repeated bouncebacks around the same
        %point
        if numel(find(bouncebacklog >= (bbpoint - 1) & bouncebacklog <= (bbpoint + 1))) >= 3
            breakdiagnosis = 'Cell termination detected';
            %delete from steplog
            steplog = steplog(1:(bbpoint-1), :);
            targetveclog = targetveclog(1:(bbpoint-1),:);
            break
        end
        
        if echo
            disp('Rolling back...');
        end
        
        %delete from steplog and continue
        steplogbackup = steplog;
        steplog = steplog(1:(bbpoint-1), :);
        targetveclogbackup = targetveclog;
        targetveclog = targetveclog(1:(bbpoint-1),:);
        bbptolerance = targtolerance - (1/res);
        if strcmpi(method, 'TEAC') || strcmpi(method, 'TEAC+')
            [target, dirvec, controlpntssel, breakloop, breakdiagnosis] = TEAC(method, currcoord, vw, pxr, targetveclog, clearancethresh, wallclearance, edgeclearance, minstepforward, bbptolerance, res, obsavrad, minobsdist, distcube);
        elseif strcmpi(method, 'NBFCM')
            [target, dirvec, controlpntssel, breakloop, breakdiagnosis] = NBFCM(currcoord, nonanvw, pxr, maxnhoodsize, features, nclust, fcmopt, targetveclog, bbptolerance, cube);
        elseif strcmpi(method, 'VOTSU')
            [target, dirvec, controlpntssel, breakloop, breakdiagnosis] = VOTSU(currcoord, nonanvw, pxr, targetveclog, bbptolerance, srr, meanpropdist, cube);
        end
        
        %check if TEAC or NBFCM fails due to bounceback detector issuing a false positive.
        if breakloop
            if strcmpi(breakdiagnosis, 'No targets in sight') & pfp > 0.5
                %increase tolerance, but make sure the 180 degree maneuver 
                %isn't possible within set constraints
                %calculate half loop size from lspoint
                halfloopsize = size(steplogbackup, 1) - lspoint + 1; 
                %calculate the min angle that makes a 180 turn possible 
                %within this half loop size 
                minang = pi/halfloopsize; 
                %calculate corresponding tolerance
                maxtolerance = -cos(minang); 
                %ensure that tolerance is set to maxtolerance for the next
                %halfloopsize steps
                resettolerancein = halfloopsize; 
                %reselect target
                if strcmpi(method, 'TEAC') || strcmpi(method, 'TEAC+')
                    [target, dirvec, controlpntssel, breakloop, breakdiagnosis] = TEAC(method, currcoord, vw, pxr, targetveclog, clearancethresh, wallclearance, edgeclearance, minstepforward, bbptolerance, res, obsavrad, minobsdist, distcube);
                elseif strcmpi(method, 'NBFCM')
                    [target, dirvec, controlpntssel, breakloop, breakdiagnosis] = NBFCM(currcoord, nonanvw, pxr, maxnhoodsize, features, nclust, fcmopt, targetveclog, bbptolerance, cube);
                elseif strcmpi(method, 'VOTSU')
                    [target, dirvec, controlpntssel, breakloop, breakdiagnosis] = VOTSU(currcoord, nonanvw, pxr, targetveclog, bbptolerance, srr, meanpropdist, cube);
                end
                resettolerancein = resettolerancein - 1;
            end
            
        end
        
        
    end
    
    %echo
    if echo
        disp(['Archiving...']);
    end
    
    %---step logger---
    %don't log and break if breakloop set to true
    if ~breakloop
        targetcoordlog = [targetcoordlog; {target}];
        targetveclog = [targetveclog; {dirvec}];
        controlpnts = [controlpnts; controlpntssel];
        stepinfo = {currcoord, nonanvw, pxr, target, dirvec, controlpntssel, contextcoord};
        steplog = [steplog; stepinfo];
    else
        break
    end
    
    
    passcount = passcount + 1;
    
    
    %---TODO:---
    %         [ ] script to assign the skeleton a confidence level with
    %               [ ] control points
    %               [x] first and second derivatives of propagation vectors
    %         [x] clean up archiver
    %         [ ] error handling
end

if echo
    disp(['Break diagnosis: ', breakdiagnosis]);
end
%------------------

end

%FIXME: TEAC outdated. 
function [target, dirvec, controlpnts, breakloop, breakdiagnosis] = TEAC(method, currcoord, vw, pxr, targetveclog, clearancethresh, wallclearance, edgeclearance, minstepforward, tolerance, res, obsavrad, minobsdist, distcube)
%TEAC Select target and control points from the supplied view
%matrix (vw) and pixel register (pxr).
%   Target Extraction with Area Classifier (TEAC): 
%       1. Select level 2 from 3 level otsu on viewfinder output (view)
%       2. Mask (original) result with orientation map
%       3. Connected component analysis on both original and masked
%          binaries
%       4. Calculate region areas from both original and masked labeled images
%       5. If 3 or more regions in original labeled image, classify regions
%          by OTSU. 
%       6. Pick the class of areawise largest patches in original image and
%          compare with its (corresponding) area in the masked labeled
%          image. Pick the patch with the largest ratio between areas in 
%          masked vs. original images. 
%       7. Pick maxima from this patch, assign as target. 
%
%   Obstacle Aware TEAC (TEAC+)
%       1. Try to ensure that selected TEAC target is within some distance
%          from an obstacle. 


if strcmpi(method, 'TEAC') || strcmpi(method, 'TEAC+')
    %initializations
    breakloop = false;
    controlpnts = {};
    breakdiagnosis = '';
    %build gradient and standard deviation of gradient
    vwgr = gradient(vw); vwgrstd = stdfilt(vwgr, ones(5,5,5));
    %3 level otsu on vw to extract interest regions
    vwotsu = otsu(vw, 3);
    %extract and label candidate target region (2/3)
    vwtarg = vwotsu == 2; labvwtarg = bwlabel(vwtarg);
    %extract and label control point region (3/3)
    vwcontp = vwotsu == 3; labvwcontp = bwlabel(vwcontp);
    
    %while loop to recalculate when target map isn't satisfactory
    targetmapvalid = false;
    while ~targetmapvalid
        %generate orientmap if possible
        if ~isempty(targetveclog)
            firststep = false;
            %fetch vector
            vec = targetveclog{end};
            %make orientation chart
            orientchart = orientationfinder(vec, res);
            %make orientation map
            orientmap = double(orientchart >= -tolerance);
        else
            firststep = true;
            orientmap = ones(res/2, res);
        end
        %intersect orientation with vw, target and control point otsu's
        orlabvwtarg = orientmap.*labvwtarg;
        orlabvwcontp = orientmap.*labvwcontp;
        orvw = orientmap.*vw;
        %check the number of NaNs in orlabvwtarg. Break if above a
        %threshold (edgeclearance)
        if numel(find(isnan(orvw))) >= edgeclearance && ~firststep
            target = NaN;
            dirvec = NaN;
            controlpnts = NaN;
            breakdiagnosis = 'Arrived at dataset edge';
            breakloop = true;
            return
        end
        
        
        %---target selection---
        %fetch region properties
        targprops = regionprops(labvwtarg, 'Area');
        ortargprops = regionprops(orlabvwtarg, 'Area');
        
        %pick largest regions in non oriented map
        %start by indexing areas
        targarea = [];
        ortargarea = [];
        for k = 1:size(targprops, 1)
            targarea = [targarea; targprops(k).Area];
            if k <= size(ortargprops, 1)
                ortargarea = [ortargarea; ortargprops(k).Area];
            else
                ortargarea = [ortargarea; 0];
            end
        end
        %ratio orarea:area
        ratarea = ortargarea./targarea;
        
        %classify 3 classes by patch area with otsu if k>=3
        if size(targprops, 1) >= 3
            targareaclass = otsu(targarea, 3);
            %---bug report---
            %for currcoord = [341,57,199], targarea = [23190 4 24 32 3
            %35 2]'. otsu(targarea, 3) returns [NaN NaN NaN NaN NaN NaN
            %NaN]', probably because some search-based optimization in
            %OTSU's method did not converge. See workaround below.
            %---workaround---
            %do a 2 class otsu instead. This appears to work.
            if all(isnan(targareaclass))
                warning('3 class OTSU failed; using 2 class instead');
                targareaclass = otsu(targarea, 2) + 1; %add one to keep things consistent
            end
            %ortargareaclass = otsu(ortargarea, 3);
        elseif size(targprops) == 2
            if targarea(1) > targarea(2)
                targareaclass = [3; 2];
            elseif targarea(1) == targarea(2)
                targareaclass = [3; 3];
            else
                targareaclass = [2; 3];
            end
        elseif size(targprops) == 1
            targareaclass = 3;
        else
            target = NaN;
            dirvec = NaN;
            controlpnts = NaN;
            breakdiagnosis = 'No targets found';
            breakloop = true;
            return %?
        end
        
        %pick largest classes in non oriented map and compare with area in
        %ortargarea + failsafe for when ratarea(c3elems) = 0
        patchfound = false;
        while ~patchfound %question to self: why's this while loop necessary again?
            c3elems = find(targareaclass == 3);
            %check if area ratios are all zeros
            if all(ratarea(c3elems) == 0)
                %well, shit
                %Plan B: sort targarea and ratarea, pick the largest
                %target which has a nonzero overlap with the
                %hind-hemisphere.
                warning('No class 3 patch intersects with fore-hemisphere. Selecting next largest patch with non-zero intersection.')
                indnzrat = find(ratarea ~= 0);
                [~, indmaxar] = max(targarea(indnzrat));
                k = indnzrat(indmaxar);
                patchfound = true;
            else
                %find maximum
                [~, ind] = max(ratarea(c3elems));
                %class 3 patch with largest area ratio
                k = c3elems(ind);
                patchfound = true;
            end
        end
        
        %break if k is empty, i.e. ratarea = 0, i.e. no targets in sight
        if isempty(k)
            target = NaN;
            dirvec = NaN;
            controlpnts = NaN;
            breakdiagnosis = 'No targets in sight';
            breakloop = true;
            return 
        end
        
        
        %isolate patch from view map
        targetmap = orlabvwtarg == k;
        
        %---target assignment---
        %linearize all variables
        lintargetmap = targetmap(:);
        linpxr = pxr(:);
        linvw = vw(:);
        
        %generate target view and pxr
        targvw = linvw(lintargetmap);
        targpxr = linpxr(lintargetmap);
        [clearance, ind] = max(targvw);
        
        %derive unit vector in chosen direction
        targetdir = targpxr{ind};
        dirvec = targetdir - currcoord;
        e = dirvec/norm(dirvec, 2);
        %calculate propagation distance
        if clearance >= clearancethresh
            propdist = clearancethresh;
        else
            propdist = clearance - wallclearance;
        end
        
        if propdist < minstepforward
            breakloop = true;
            target = NaN;
            dirvec = NaN;
            controlpnts = NaN;
            breakdiagnosis = 'Dead end';
            return
        end
        
        
        %Obstacle detection for TEAC+
        if strcmpi(method, 'TEAC+')
            
            %_______________________________________________
            %the plan: 
            %           MSR
            %|--|--------|-[---|---]
            %0 MSF        SR--RPD--PD
            %legend: 
            %0: zero (currcoord)
            %MSF: minstepforward
            %SR--RPD = RPD--PD = scanr (scan radius)
            %MSR: maxscanr (maximum scan radius)
            %RPD: redpropdist (reduced propagation distance)
            %PD: propdist (propagation distance; target)
            %_______________________________________________
            
            %check if scan radius larger than (propdist - minstepforward)/2. If so,
            %replace scan radius with (propdist - minstepforward)/2
            scanr = obsavrad;
            maxscanr = floor((propdist - minstepforward)/2);
            
            %ensure that max(scanr) = maxscanr and that maxscanr>=1.
            doscan = true;
            if scanr > maxscanr 
                if maxscanr>=1
                    scanr = maxscanr;
                else
                    doscan = false;
                    method = 'TEAC'; 
                    warning('Not enough room to scan for obstacles with TEAC+, reverting to TEAC...')
                end
            end
            
            %scan loop
            maxnotfound = true;
            while maxnotfound && doscan
                %initialize reduced propdist such that effective propdist
                %doesn't exceed propdist
                redpropdist = propdist - scanr;
                
                %start scan: accquire target shortlist
                targsl = [];
                for k = -scanr:scanr
                    targsl = [targsl; round(currcoord + (redpropdist + k).*e)];
                end
                %accquire linear indices
                targslind = sub2ind(size(distcube), targsl(:,1)', targsl(:,2)', targsl(:,3)');
                
                %list of distances from closest obstacles
                distlist = distcube(targslind);
                
                %compute maximum
                [maxdist, ind] = max(distlist);
                
                %case analysis
                if maxdist < minobsdist && scanr < maxscanr
                    scanr = scanr + 1;
                    continue
                elseif maxdist >= minobsdist
                    target = targsl(ind, :);
                    maxnotfound = false;
                elseif maxdist < minobsdist && scanr >= maxscanr
                   warning('Minimum obstacle distance cannot be held within the constraints set by minpropdist...')
                   target = targsl(ind, :);
                   maxnotfound = false;
                end 
            end          
        end
                
        %calculate target coordinate for TEAC
        if strcmpi(method, 'TEAC')
            targetcoord = currcoord + propdist.*e;
            for k = 1:3
                if ((targetcoord(k) - floor(targetcoord(k))) < 0.5)
                    target(k) = floor(targetcoord(k));
                else
                    target(k) = floor(targetcoord(k)) + 1;
                end
            end
        end
        
        targetmapvalid = true;
        %-------------------------------
    end
    %---control point placement---
    %find uniques
    uilvwcp = unique(labvwcontp); uilvwcp = uilvwcp'; uilvwcp(uilvwcp == 0) = [];
    %loop over uniques if not empty, extract regions and add to controlpnts
    if ~isempty(uilvwcp)
        for k = uilvwcp
            binvwcontp = double(labvwcontp == k);
            maskedvwcontp = binvwcontp.*vw;
            [~, ind] = max(maskedvwcontp(:));
            controlpnts = [controlpnts; {pxr{ind}}];
        end
    end
end

end

function [target, dirvec, controlpnts, breakloop, breakdiagnosis] = NBFCM(currcoord, nonanvw, pxr, maxnhoodsize, features, nclust, fcmopt, targetveclog, tolerance, cube)
%NBFCM select targets with Neighborhood-Based Fuzzy C-Means classifier. 
%   ARGUMENTS: 
%       nonanvw: vw without the nans (see viewfinder)
%       pxr: see Steve
%       maxnhoodsize: maximum size of sampling neighborhood. Must be a
%                     number which divides sizes in both dimensions. For
%                     instance: 9 or 15 for 180x360 fields.
%       features: a cell array of function handles. 
%       nclust: number of clusters for fcm (=2 atm)
%       fcmopt: options for fcm (see doc fcm)
%       targetveclog: log of target vectors
%       tolerance: see TEAC
%   OUTPUT: Standard
%   NOTES: NBFCM uses functional tolerance wherein propagation vector
%          candidates along the previous propvector are rewarded with
%          the cosine of the angle between it and the previous propvector. 

%initialize
breakloop = false;
breakdiagnosis = '';

%---hardwired parameters---
nclust = 2; %makes cluster selection easier atm
srr = 0.25; 
tolcoup = -0.1; %tolerance coupling

%---pad---
%smart pad view with exactly the width lost to convolution
padvw = smartpad(nonanvw, ((maxnhoodsize - 1)/2)); 

%---build convolution kernels---
%initialize
convkerns = {};
%calculate halfsize
hs = (maxnhoodsize + 1)/2;

for m = 1:hs
    %initialize
    ker = zeros(maxnhoodsize);
    for p = 1:maxnhoodsize
        for q = 1:maxnhoodsize
            if p == m || p == maxnhoodsize - m + 1
                ker(p, m:(maxnhoodsize - m + 1)) = 1; 
            end
            
            if q == m || q == maxnhoodsize - m + 1
                ker(m:(maxnhoodsize - m + 1), q) = 1;
            end
        end
    end
    
    %normalize kernel
    ker = ker/sum(ker(:));
    %save to cell array
    convkerns = [convkerns; ker]; 
end

%---build feature vectors---
%take measurements 
[sizy, sizx] = size(nonanvw);
%preallocate
fvec = nan([sizy*sizx size(convkerns, 1) size(features, 1)]);
for k = 1:size(features, 1)
    %extract function
    fun = features{k};
    %process vw with requested function
    prvw = fun(padvw); 
    %process convolutions    
    for l = 1:size(convkerns, 1)
        %convolve
        convim = imfilter(prvw, convkerns{l}, 'conv'); 
        %undo padding 
        unpadconvim = unpad(convim, ((maxnhoodsize - 1)/2));
        %archive
        fvec(:, l, k) = unpadconvim(:);
    end
end

%---run fcm---

%method 2: fcm(mean)
%flatten fvec2 to fvec
fvec2 = [];
for k = 1:size(features, 1)
    fvec2 = [fvec2, fvec(:, :, k)];
end

%evaluate fcm
[clustcent, U] = fcm(fvec2, nclust, fcmopt);

%parse results
clustcell = {};
for l = 1:nclust
    clustcell = [clustcell; reshape(U(l,:), [sizy sizx])];
end

%---cluster selection---
%for nclust = 2 only:
%average over a large field
avgclustcell = cellfun(@avgnhood, clustcell, 'UniformOutput', false); 
%pick a cluster image
clustim = avgclustcell{1};
%run 2 level otsu
otsucim = otsu(clustim, 2); 
%linearize otsu-ed cluster image and nonanvw
linotsucim = otsucim(:);
linnonanvw = nonanvw(:);
%if class 2 mean in nonanvw is less than that of class 1, select the other
%cluster; continue otherwise
if mean([linnonanvw(linotsucim == 2)]) < mean([linnonanvw(linotsucim == 1)])
    clustim = avgclustcell{2}; 
    %generate new otsucim and linotsucim
    otsucim = otsu(clustim, 2);
    linotsucim = otsucim(:);
end
%clustim should now be the correct cluster

%---prepare orientation map---
res = size(nonanvw, 2);
%generate orientmap if possible
if ~isempty(targetveclog)
    firststep = false;
    %fetch vector
    vec = targetveclog{end};
    %make orientation chart
    orientchart = orientationfinder(vec, res);
    %make orientation map
    %copy orientchart to orientmap
    orientmap = orientchart;
    %scale according to given coupling
    orientmap = tolcoup*orientmap; 
    %impose tolerance constraint
    orientmap(orientchart < -tolerance) = -1; 
    orientmask = double(orientchart >= -tolerance);
else
    firststep = true;
    orientmap = ones(res/2, res);
    orientmask = orientmap; 
end

%---mask with orientation and otsu class---
%linearize
linclustim = clustim(:); 
linotsuclass = linotsucim == 2; 
linorientmap = orientmap(:); 
linorientmask = orientmask(:);
%mask
lintargetmap = (linclustim + linorientmap).*linotsuclass.*linorientmask; 

%---target selection---
[maxtargval, targind] = max(lintargetmap); 
%check if no targets found
if maxtargval <= 0
    breakdiagnosis = 'No targets in sight';
    breakloop = true;
    target = NaN;
    dirvec = NaN;
    controlpnts = NaN;
    return
else
    targcoord = pxr{targind};   
    dirvec = targcoord - currcoord; 
    e = dirvec/norm(dirvec);
end

%---propdist selector---
%criteria:
%         -SR       +SR
%  |-------(----|----)--------|
%  0          NDV/2          NDV
%NDV: Norm(dirvec)
%SR: Scan radius (fixed parameter)
%SRR: Scan radius ratio = SR/NDV. Default: 0.25. 

%initialize
ndv = norm(dirvec); 
hndv = round(ndv/2); 
sr = round(ndv*srr);

%value extraction loop
%initialize
targsl = [];
%take measurements
[csiz, ~, ~] = size(cube); 
for pd = (hndv-sr):(hndv+sr)
    slcoord = round(currcoord + (hndv + pd).*e); 
    %check if slcoord within bounds
    if any(slcoord > csiz) || any(slcoord < 1)
       
        %===[DEBUGGER]===
        %slcoord(slcoord > csiz) = csiz; %SRSLY MATLAB?
        %slcoord(slcoord < 1) = 1;
        %================
        
        for k = 1:3
            if slcoord(k) > csiz
                try
                    slcoord(k) = csiz;
                catch
                    '';
                end
            end
            
            if slcoord(k) < 1
                try
                    slcoord(k) = 1;
                catch
                    '';
                end
            end
        end
    end
    %add slcoord to targsl
    targsl = [targsl; slcoord]; 
end

%accquire linear indices
targslind = sub2ind(size(cube), targsl(:,1)', targsl(:,2)', targsl(:,3)');

%accquire values
vallist = cube(targslind);

%find minimum in vallist
[~, minind] = min(vallist);
%select target gogogog
target = targsl(minind, :); 

%---controlpoint assignment---
%[CODE GOES HERE]
controlpnts = {};

end

function [target, dirvec, controlpnts, breakloop, breakdiagnosis] = VOTSU(currcoord, nonanvw, pxr, targetveclog, tolerance, srr, meanpropdist, cube)
%VOTSU runs a 3 level OTSU on the passed view (after convolving with a large aver-
%aging filter) and selects a target from level 3. 
%   "Simplicity is the ultimate sophistication" - Leonardo da Vinci

%---initialize---
breakloop = false; 
breakdiagnosis = '';

%---process nonanvw---
%average nonanvw over a 19 by 19 field
smnonanvw = avgnhood(nonanvw); 

%run 3 level otsu
otsuvw = otsu(smnonanvw, 3); 

%binarize
otsuvwl3 = double(otsuvw == 3); 

%---check orientation---
res = size(nonanvw, 2); 
%generate orientmap if possible
if ~isempty(targetveclog)
    firststep = false;
    %fetch vector
    vec = targetveclog{end};
    %make orientation chart
    orientchart = orientationfinder(vec, res);
    %make orientation map
    orientmap = double(orientchart >= -tolerance);
else
    firststep = true;
    orientmap = ones(res/2, res);
end

lintargetmap = smnonanvw(:).*otsuvwl3(:).*orientmap(:); 

%---target selection---
[maxtargval, targind] = max(lintargetmap); 
%check if no targets found
if maxtargval <= 0
    breakdiagnosis = 'No targets in sight';
    breakloop = true;
    target = NaN;
    dirvec = NaN;
    controlpnts = NaN;
    return
else
    targcoord = pxr{targind};   
    dirvec = targcoord - currcoord; 
    e = dirvec/norm(dirvec);
end

%---propdist selection---
%criteria:
%         -SR       +SR     2*MPD
%  |-------(----|----)--------|
%  0          NDV/2          NDV
%NDV: Norm(dirvec) OR
%     2*meanpropdist (MPD)
%SR: Scan radius (fixed parameter)
%SRR: Scan radius ratio = SR/NDV. Default: 0.25. 

%initialize
if isnan(meanpropdist) || 2*meanpropdist > norm(dirvec)
    ndv = norm(dirvec);
    hndv = round(ndv/2);
    sr = round(ndv*2*srr);
else
    ndv = 2*meanpropdist;
    hndv = round(ndv/2);
    sr = round(ndv*srr);
end
%value extraction loop
%initialize
targsl = [];
%take measurements
[csiz, ~, ~] = size(cube); 
for pd = (hndv-sr):(hndv+sr)
    slcoord = round(currcoord + (hndv + pd).*e); 
    %check if slcoord within bounds
    if any(slcoord > csiz) || any(slcoord < 1)
       
        %===[DEBUGGER]===
        %slcoord(slcoord > csiz) = csiz; %SRSLY MATLAB?
        %slcoord(slcoord < 1) = 1;
        %================
        
        for k = 1:3
            if slcoord(k) > csiz
                try
                    slcoord(k) = csiz;
                catch
                    '';
                end
            end
            
            if slcoord(k) < 1
                try
                    slcoord(k) = 1;
                catch
                    '';
                end
            end
        end
    end
    %add slcoord to targsl
    targsl = [targsl; slcoord]; 
end

%accquire linear indices
targslind = sub2ind(size(cube), targsl(:,1)', targsl(:,2)', targsl(:,3)');

%accquire values
vallist = cube(targslind);

%find minimum in vallist
[~, minind] = min(vallist);
%select target 
target = targsl(minind, :); 

%controlpoint selection

%the plan:
%   1. label level 3 otsu clusters
%   2. Assign as controlpoint the maximum smnonanvw masked by labeled l3 clusters.

%label l3 otsu
labotsuvwl3 = bwlabel(otsuvwl3);

%initialize
controlpnts = {}; 
uilo = unique(labotsuvwl3); uilo = uilo'; uilo(uilo == 0) = [];  
%loop over labels
for lab = uilo
    %create mask
    labbin = labotsuvwl3 == lab; 
    %mask smnonanvw
    lincpmap = smnonanvw(:).*labbin(:); 
    %pick maximum
    [~, maxind] = max(lincpmap); 
    %pull corresponding coordinates in pixel register
    cntp = pxr{maxind}; 
    %check if pulled controlpoint corresponds to targetcoord
    if ~isequal(cntp, targcoord)
    %save cntp to list
    controlpnts = [controlpnts; cntp]; 
    else
        continue
    end
end


end

function [targtolerance, bbpoint, lspoint, pfp] = bouncebackdetector(steplog, trailsize, celldiameter)
%Bounceback detector relying on geometric cues. The idea is to check if the
%norm of the vector connecting the last node to the previous n nodes are
%monotonously increasing with n. And if yes, what's the larges such norm
%(or the local maxima).
%Output: 
%   targtolerance: target tolerance for TEAC(+) when a bounceback is found
%   bbpoint: start retracing from (end - bbpoint) with targtolerance
%   pfp: probability of the decision being a false positive
%   lspoint: point where the 180 degree semi-"circle" starts

%fix coordinate compatibility issues (between cubes) by converting steplog 
%to global coordinates
if ~all(isnan(steplog{end, 7}))
    steplog = steplog2globalcoordinates(steplog); 
end

%determine total number of steps taken 
totsteps = size(steplog, 1); 

%return if no steps taken yet
if totsteps < 3
    targtolerance = NaN;
    bbpoint = NaN;
    lspoint = NaN;
    pfp = NaN;
    return
end

%obtain coordinate cell:
%admit max 10 trailing nodes (10 is a hard-wired parameter, change that)
if totsteps <= trailsize
    coordcell = steplog(:, 4);
else
    coordcell = steplog((totsteps - trailsize):end, 4);
end

%determine reference coordinate
refcoord = coordcell{end}; 

%center coordinate cell wrt refcoord
centcoordcell = cellfun(@(x)(x - refcoord), coordcell, 'UniformOutput', false); 

%calculate norms of these centered vectors for analysis
centvecnorms = cellfun(@norm, centcoordcell); 
%flip centvecnorms
centvecnorms = flipud(centvecnorms); 

%find maxima & minima
[maxnorms, locmaxs] = findpeaks(centvecnorms); 
[minnorms, locmins] = findpeaks(-centvecnorms); minnorms = -minnorms; 
%pick the first maximum & minimum (this can be done cleaner, but save that for another day)
if numel(maxnorms) > 1
    maxind = locmaxs(1);
    maxnorm = maxnorms(1);
else
    maxind = locmaxs;
    maxnorm = maxnorms;
end

if numel(minnorms) > 1
    minind = locmins(find(locmins > maxind, 1));
    minnorm = minnorms(minind);
else
    minind = locmins;
    minnorm = minnorms;
end

%decide if a bounceback is found: 
%1: check if a maximum is found
%2: when yes, check the dot product b/w corresponding and previous dirvec's
%3: check if minnorm is smaller than celldiameter
if ~isempty(maxnorms)
    %calculate bbpoint, i.e. the point to start deleting from 
    bbpoint = totsteps - maxind + 1;
    lspoint = totsteps - minind + 1; 
    %calculate the dirvec that would have brought the pointer to bbpoint
    %(remember that cellcoord comprises targets)
    bbvec = steplog{bbpoint, 5}/norm(steplog{bbpoint, 5});
    bbvecm1 = steplog{bbpoint - 1, 5}/norm(steplog{bbpoint - 1, 5});
    targtolerance = - dot(bbvec, bbvecm1);
    
    %estimate the probability of a false positive
    %define extrapolation function
    linext = @(a, b, x) (x./(b-a) - a./(b-a));
    %weigh 25-75 as follows:
    pfp = 0.25*linext(celldiameter/2, celldiameter, minnorm) + 0.75*linext(0.9, 1, abs(targtolerance));
else
    targtolerance = NaN; 
    bbpoint = NaN; 
    lspoint = NaN; 
    pfp = NaN;
end


end

function [bbdrecord, bbpoint] = bouncebackdetector_old(bbdrecord, targetveclog)
%BOUNCEBACKDETECTOR tries to detect bouncebacks in Steve's pointer.
%bbdpoint is where the bounce most likely happened. 


%validate target map:
%----------------------------
%[CODE TO DETECT BOUNCEBACKS]
%Flags to raise suspicion:
%   [x] check if the angle between dirvec and previous dirvec's
%       approaches 90 degrees (when tolerance is set to zero)
%   [x] check if the angle between dirvec and previous to
%       previous dirvec approaches 180 degrees
%   [x] check if considerable number of NaNs in foresight
%       (orvw)
%   [ ] generate a 'consensus' dirvec (normalized) and check if
%       the current dirvec within 1 sigma (say N = 5 moving avg)
%   [x] infer from the second derivative of the vector sequence
%TODO
%   [ ] better weight management (to work with arbitrary number of weights)
%   [ ] another function to find new target points

%------BOUNCEBACK DETECTOR------
%vote if bounceback true
%weightage:
%40% => dot product between dirvec & previous dirvec: [no vote, full
%       vote] = [1, 0] (A)
%20% => dot product between dirvec & previous to previous dirvec:
%       [no vote, full vote] = [1, -1] (B)
%20% => number of NaNs: [no vote, full vote] = [0, 5%] (C)
%20% => magnitude of the second vector derivative: [no vote, full
%       vote] = [0, 2] (D)

%initialize weights
wA = 0.20;
wB = 0.30;
wC = 0.30*(1 - (0.5)^(size(targetveclog, 1)-2));
wD = 0.20;

%intialize threshold
bbdt = 0.5;

%linear extrapolation function mapping [a, b] -> [0, 1]
linext = @(a, b, x) (x./(b-a) - a./(b-a));

%skip if bounceback detection if size(targetveclog) is smaller than 2.
if size(targetveclog, 1) > 2
    %accquire direction vectors and normalize
    dirvec = targetveclog{end}; e = dirvec/norm(dirvec);
    dirvecm1 = targetveclog{end - 1}; em1 = dirvecm1/norm(dirvecm1);
    dirvecm2 = targetveclog{end - 2}; em2 = dirvecm2/norm(dirvecm2);
    %(A)
    dpA = dot(e, em1);
    voteA = linext(1, -tolerance, dpA);
    if voteA > 1, voteA = 1; end
    
    %(B)
    dpB = dot(e, em2);
    voteB = linext(1, -1, dpB);
    if voteB > 1, voteB = 1; end
    
    %(C)
    numnan = numel(find(isnan(orvw)));
    totnumel = numel(orvw);
    nanfrac = (numnan/totnumel);
    voteC = linext(0, 0.05, nanfrac);
    if voteC > 1, voteC = 1; end
    
    %(D)
    D1p1 = e - em1;
    D1p2 = em1 - em2;
    D2 = D1p1 - D1p2;
    magD2 = norm(D2);
    voteD = linext(0, 2, magD2);
    if voteD > 1, voteD = 1; end
    
else
    voteA = -inf;
    voteB = -inf;
    voteC = -inf;
    voteD = -inf;
end



%calculate bounceback decision
bbd = wA*voteA + wB*voteB + wC*voteC + wD*voteD;

%archive bounceback decisions
weights = [wA, wB, wC, wD];
votes = [voteA, voteB, voteC, voteD];
bbdrecord = {weights, votes, bbd};



end


