function [steplog] = stacy(varargin)
%STACY Controller function for STEVE. 
%Tasks:
%   [ ] Feed STEVE with correct context cubes
%   [ ] Convert steplog from STEVE to global coordinates and archive
%   [ ] Detect branchpoints
%   [ ] Trace through detected branchpoints
%Arguments: 
%   masterseed
%   basepath
%Helper functions: 
%   cube2globalSL: convert cube coordinates to global coordinates (on steplog)
%   global2cubeSL: convert global coordinates to cube coordinates (on steplog)
%   branchfinder: finds branchpoints with controlpoints
%   deepbranchfinder: finds branchpoints with axial search


%---DEFAULTS---
%parameters
steveparams = {};
maxlooppass = 500;
basepath = '/Users/nasimrahaman/Documents/MATLAB/MPI/mbrain/data/BRAX-striatum-20nm-isotropic-deconvolved_mag1';
basepathin = false;
defskelfilepath = '/Users/nasimrahaman/Documents/MATLAB/MPI/mbrain/data'; %change this
echo = true;
msl = 60; %maximum segment length
segcache = 5; %cache size while switching segments.
stevecubemargin = [32 32 32; 32 32 32]; %default cube margins for steve
brancholt = 0.5; %branch overlap threshold: the fraction of all nodes in a new branch segment contained in the parent branch. 
findbranches = true;
doretrotrace = true;
%--------------

%-INPUT PARSER-
%parse input

if echo
    disp('Initializing Stacy...')
end

inpsiz = size(varargin, 2);
for k = 1:inpsiz
    %skip if k odd (since it should contain data content and not tags)
    if mod(k, 2) == 0
        continue
    end
    %stacy
    if strcmpi(varargin{k}, 'masterseed')
        masterseed = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'basepath')
        basepath = varargin{k + 1};
        basepathin = true;
    end
    
    if strcmpi(varargin{k}, 'echo')
        echo = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'maximum loop passes')
        maxlooppass = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'basepath')
        basepath = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'maximum segment length')
        msl = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'segment cache')
        segcache = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'skeleton file path') | strcmpi(varargin{k}, 'skelfilepath')
        skelfilepath = varargin{k + 1};
        skelfile = matfile(skelfilepath, 'Writable', true); 
    end
    
    if strcmpi(varargin{k}, 'skeleton file') | strcmpi(varargin{k}, 'skelfile')
        skelfile = varargin{k + 1};
        if ~isa(skelfile, 'matlab.io.MatFile')
            error('Skelfile error: check skelfile class')
        end
        skelfile.Properties.Writable = true; 
    end
    
    if strcmpi(varargin{k}, 'default skelfile path')
        defskelfilepath = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'find branches')
        findbranches = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'branch selection')
        branchselection = varargin{k + 1};
    end
    
    if strcmpi(varargin{k}, 'retrotrace')
        doretrotrace = varargin{k + 1};
    end
    
    %dev
    if strcmpi(varargin{k}, 'evalcode')
        evalcode = varargin{k + 1};
        eval(evalcode);
    end
    
    
    %????????????????????????????????????
    %steve
    if strcmpi(varargin{k}, 'steve tolerance')
        stevetolerance = varargin{k + 1};
        steveparams = [steveparams, {'tolerance', stevetolerance}];
    end
    
    if strcmpi(varargin{k}, 'steve detect bouncebacks')
        stevedetectbb = varargin{k + 1};
        steveparams = [steveparams, {'detect bouncebacks', stevedetectbb}];
    end
    
    if strcmpi(varargin{k}, 'steve resolution')
        steveres = varargin{k + 1};
        steveparams = [steveparams, {'resolution', steveres}];
    end
    
    if strcmpi(varargin{k}, 'steve cube margin')
        stevecubemargin = varargin{k + 1};
        %cubemargin is dynamically handled by cubefeeder, skip passing this
        %parameter to steve
    end
    
    if strcmpi(varargin{k}, 'steve clearance threshold')
        steveclearancethresh = varargin{k + 1};
        steveparams = [steveparams, {'clearance threshold', steveclearancethresh}];
    end
    
    if strcmpi(varargin{k}, 'steve wall clearance')
        stevewallclearance = varargin{k + 1};
        steveparams = [steveparams, {'wall clearance', stevewallclearance}];
    end
    
    if strcmpi(varargin{k}, 'steve edge clearance')
        steveedgeclearance = varargin{k + 1};
        steveparams = [steveparams, {'edge clearance', steveedgeclearance}];
    end
    
    if strcmpi(varargin{k}, 'steve echo')
        steveecho = varargin{k + 1};
        steveparams = [steveparams, {'echo', steveecho}];
    end
    
    if strcmpi(varargin{k}, 'steve method')
        stevemethod = varargin{k + 1};
        steveparams = [steveparams, {'method', stevemethod}];
    end
    
    if strcmpi(varargin{k}, 'steve integrater threshold')
        steveintthresh = varargin{k + 1};
        steveparams = [steveparams, {'integrater threshold', steveintthresh}];
    end
    
    if strcmpi(varargin{k}, 'steve minimum step size') | strcmpi(varargin{k}, 'steve minstepforward')
        steveminstepforward = varargin{k + 1};
        steveparams = [steveparams, {'minimum step size', steveminstepforward}];
    end
    
    if strcmpi(varargin{k}, 'steve minimum allowed obstacle distance') | strcmpi(varargin{k}, 'steve minobsdist')
        steveminobsdist = varargin{k + 1};
        steveparams = [steveparams, {'minobstdist', steveminobsdist}];
    end
end

if ~exist('masterseed', 'var') && ~exist('skelfile', 'var')
    error('No masterseed or skeleton file detected. Aborting...');
end

if ~basepathin
    warning(['No basepath detected. Using default: ', basepath]);
end

%--------------

%---INITIALIZATION---
%initialize loop pass counter
passcount = 0; 

%initialize a flag to indicate if the first pass in skel/branch was repeated
repeatfirstpassinskel = false; 
repeatfirstpassinbranch = false; 

%measure dataset dimensions
[numY, numX, numZ] = fetchSupercubeDimensions(basepath); 

%initialize the first pass flag
if ~exist('skelfile', 'var')
    firstpass = true;  
else
    firstpass = false; 
end

%initialize flag to indicate if branchselection given
if exist('branchselection', 'var')
    branchselectiongiven =  true; 
else
    branchselectiongiven = false;
end

%initialize branch and segment counter
if firstpass
    %initialize branch and segment counter
    b = 1; s = 1; 
    %create a fileindex variable to initialize a mat file
    fileindex = [0 0];   %#ok<NASGU>
    save(defskelfilepath, 'fileindex', '-v7'); 
    %initialize skelfile as a matfile
    skelfile = matfile(defskelfilepath, 'Writable', true);
    %save firstpassinbranch flag in skelfile
    skelfile.firstpassinbranch = true; 
    %initialize a retrotraced flag in skelfile
    skelfile.retrotraced = false;
else
    %load fileindex from skelfile and assign [b, s] to the last row in
    %(latest addition to) fileindex
    b = skelfile.fileindex(size(skelfile.fileindex, 1), 1); 
    s = skelfile.fileindex(size(skelfile.fileindex, 1), 2); 
    %if branch selection given,...
    if branchselectiongiven
        %update branch and segment count
        b = b + 1; s = 1; 
        %inject new branchlog in skelfile
        save2skel(branchselection, b, s, skelfile);
        %set firstpassinbranch flag in skelfile
        skelfile.firstpassinbranch = true; 
    end
end

%initialize steplog
if firstpass
    %new steplog if firstpass
    steplog = {};
else
    %start a new segment or a branch?
    if ~skelfile.firstpassinbranch
        %start a new segment. Initialize steplog as steplogcache and
        %increment segment counter. Note that this step cound be avoided
        %(as in the else case), but that would result in steve
        %unnecessarily tracing segcache previously traced nodes.
        %load cache from skelfile to continue tracing
        steplog = skelfile.steplogcache;
        %reset/overwrite segcache
        segcache = size(steplog, 1);
        %increment segment count
        s = s + 1;
    else
        %do nothing and load steplog as it was saved in skelfile in the
        %previous pass. steve should immediately detect cell termination
        %and report back to stacy for branch selection. Note that there's
        %no cache before a new branch, so no unnecessary work for steve. 
        %load BbSs and carry on
        steplog = loadfromskelfile(skelfile, b, s); 
    end     
end

%initialize a current context coordinate
if firstpass
    %initialize mscontcoord if firstpass. parse masterseed
    if numel(masterseed) == 3
        [mscontcoord, mscoordincont] = global2contextcoordinates(masterseed, basepath); 
    else
        mscontcoord = masterseed(4:6);
        mscoordincont = masterseed(1:3); 
    end
    %initialize a current context coordinate
    currcontcoord = mscontcoord;
else
    %initialize current context coordinate from steplog if not first pass
    currcontcoord = steplog{end, 7}; 
end

%initialize a flag to indicate if the present run is a new run
newrun = true; 

%initialize a flag to indicate if steve is to run in optimal coordinates of
%the last placed node
optimalcontextrequest = false;

%initialize stacy's internal cubemargin flag (= 0 => cube request
%rejected)
cubemargin = stevecubemargin; %FIXME cube margin is a default in steve, make default in stacy

%initialize a variable to archive visited contexts
contexthistory = currcontcoord; 
%--------------------

%----PRIMARY LOOP----
%break if bps (branchpoint stack) empty
while true
    %---cubefeeder---    
    if firstpass && skelfile.firstpassinbranch
        if echo
            disp('Configuring Steve for first pass in skeleton...')
        end
        %prepare for first pass in skeleton (ONE TIME EXECUTION)
        if ~repeatfirstpassinskel
            newcontcoord = currcontcoord; 
        end
        cube = loadcontext(newcontcoord, basepath);
        seed = mscoordincont;
        [steplog, breakdiagnosis, cuberequest] = steve([steveparams, {'cube', cube, 'seed', seed, 'maxsteps', msl, 'cube margin', cubemargin, 'context coordinates', newcontcoord}]);
        %check if first pass successful
        if ~isempty(steplog)
            firstpass = false;
            skelfile.firstpassinbranch = false;
            repeatfirstpassinskel = false; 
        else
            if echo
                disp('First pass failed, reconfiguring...')
            end
            repeatfirstpassinskel = true; 
        end
        newrun = false;
    elseif skelfile.firstpassinbranch && ~firstpass
        if echo
            disp(['Configuring Steve for first pass in branch ', num2str(b) ,'...'])
        end
        %prepare for first pass in branch
        currcontcoord = steplog{1, 7};
        if ~repeatfirstpassinbranch
            newcontcoord = currcontcoord;
        end
        cube = loadcontext(newcontcoord, basepath);         
        [steplog, breakdiagnosis, cuberequest] = steve([steveparams, {'cube', cube, 'steplog', steplog, 'maxsteps', msl, 'cube margin', cubemargin, 'context coordinates', newcontcoord}]);
        if ~(size(steplog, 1) == 1)
            skelfile.firstpassinbranch = false;
        else
            repeatfirstpassinbranch = true; 
        end
        newrun = false;
    else
        if echo
            disp(['Configuring Steve for branch ', num2str(b), ', Segment', num2str(s), '...'])
        end
        %cube request decision
        if newrun
            currcontcoord = steplog{1,7};
            newcontcoord = currcontcoord;
            newrun = false;
        end 
        cube = loadcontext(newcontcoord, basepath);
        [steplog, breakdiagnosis, cuberequest] = steve([steveparams, {'cube', cube, 'steplog', steplog, 'maxsteps', msl, 'cube margin', cubemargin, 'context coordinates', newcontcoord}]);
        currcontcoord = newcontcoord; 
    end
    
    %handle cube request
    if strcmpi(breakdiagnosis, 'Cube request')
        %check if at dataset boundary
        newcontcoord = currcontcoord + cuberequest;
        for k = 1:3
            datasetdim = [numY numX numZ];
            if newcontcoord(k) <= 1 || newcontcoord(k) >= datasetdim(k)
                %mend cuberequest
                cuberequest(k) = 0;
                if newcontcoord(k) <= 1
                    cubemargin(1, k) = 0;
                end
                if newcontcoord(k) >= datasetdim(k)
                    cubemargin(2, k) = 0; 
                end
                newcontcoord(k) = currcontcoord(k);
            else
                %reset cube margin
                cubemargin(:, k) = stevecubemargin(:, k);
                optimalcontextrequest = false; 
            end
        end
        %convert all coordinates in steplog to (valid) coordinates in
        %newcontcoord if possible
        if ~isequal(currcontcoord, newcontcoord) && ~isempty(steplog)
            steplog = steplog2smartcontext(steplog, newcontcoord); 
        elseif ~isequal(currcontcoord, newcontcoord) && isempty(steplog)
            seed = contextcoordinatetransition(seed, currcontcoord, newcontcoord);
        elseif isequal(currcontcoord, newcontcoord) && optimalcontextrequest
            optimalcontextrequest = true; 
        end
        if echo
            disp(['Old context: ', num2str(currcontcoord), '; New context: ', num2str(newcontcoord), '...'])
        end
        contexthistory = [contexthistory; newcontcoord]; 
    end
    
    if strcmpi(breakdiagnosis, 'Allowed number of steps taken')
        %having traced the first segment in new branch, check if it has been traced
        %redundantly to the parent branch
        %skip if first branch in skeleton
        if s ~= 1 && exist('parentbranch', 'var')
            %check if segment in branch (sib)
            [~, overlap] = issegmentinbranch(skelfile, parentbranch, steplog); 
            if overlap >= brancholt
                %redundant tracing detected. Not written to skelfile yet, ergo proceed by:
                %1. popping branch entry from abps
                %2. reselecting branch (with the same target branch)
                %3. terminating if steplog empty
                %4. reset flags
                
                %1. 
                %pop
                skelfile.abps = skelfile.abps(1:end-1, :);                
                %2. 
                %select branch
                [steplog, parentbranch] = branchselector(skelfile, b);              
                %3. 
                %terminate if empty
                if isempty(steplog)
                    %echo
                    if echo
                        disp('Terminating Stacy...')
                    end
                    break
                else
                    %prepare for a new pass in branch
                    cubemargin = stevecubemargin;
                end
                %4.
                %set flag
                skelfile.firstpassinbranch = true;
                continue
            end
        end
        
        if echo
            disp('Saving steplog to segment...')
        end
        %start new segment
        %save all but the last 'cache' steps in skelfile
        save2skel(steplog(1:(end-segcache), :), b, s, skelfile);
        %increment segment count
        s = s + 1; 
        %trim steplog
        steplog = steplog((end-segcache+1):end, :); 
        %save steplog as cache in skelfile for later reference 
        skelfile.steplogcache = steplog; 
        %steplog now ready for next pass
    end
    
    if strcmpi(breakdiagnosis, 'Cell termination detected') || strcmpi(breakdiagnosis, 'No targets in sight') %FIXME: CROSSCHECK WITH STEVE
        %if steve complains that no targets are in sight, 
        %check if new targets can be found by switching to a better context
        
        %but first check for periodic context change
        %initialize cube request oscillation flag
        
        %////DEBUG////
        %cro = false;
        cro = true;
        %//END DEBUG//
        %get context history sequence
        [~,~, chs] = unique(contexthistory, 'rows', 'legacy'); 
        if size(chs,1) > 6
            if all(chs(end-1:end) == chs(end-3:end-2)) && all(chs(end-5:end-4) == chs(end-3:end-2))
                %cube request oscillation detected
                cro = true; 
            end
        end
        
        %determine optimal context 
        if ~optimalcontextrequest && ~cro
            %set cubemargin to 128 to land in the context centered at the
            %parent cube of the target
            cubemargin(cubemargin ~= 0) = 128; 
            %set corresponding flag
            optimalcontextrequest = true;
            if echo
                disp('Switching to optimal context...')
            end
            continue
        end
        
        if echo
            disp('Saving to branch...')
        end
        %save entire steplog as a segment
        save2skel(steplog, b, s, skelfile);
        %set flag
        skelfile.firstpassinbranch = true;
        %look for branches?
        if findbranches
            %echo
            if echo
                disp('Calculating cell diamenters at all nodes in branch...')
            end
            %calculate girths for the entire branch
            branch2girth(skelfile, b);
            %echo
            if echo
                disp('Updating branchpoint stack...')
            end
            %update branch point stack (bps)
            updatebps(skelfile, b);
            %increment branch counter
            b = b + 1; s = 1;
            %echo
            if echo
                disp('Selecting branch...')
            end
            %select branch
            [steplog, parentbranch] = branchselector(skelfile, b);
            %check if steplog empty
            if isempty(steplog)
                %echo
                if echo
                    disp('Terminating Stacy...')
                end
                break
            else
                %prepare for a new pass in branch
                cubemargin = stevecubemargin;
            end
        elseif doretrotrace
            if ~skelfile.retrotraced
                if echo
                    disp('Branch detection skipped. Initializing retrotracing...')
                end
                %trace in the other direction from firstnode
                %increment branch counter
                b = b + 1; s = 1;
                %load steplog for retro tracing
                steplog = initializeretrotrace(skelfile);
                %set flag to true
                skelfile.retrotraced = true;
                if isempty(steplog)
                    if echo
                        disp('Terminating Stacy...')
                    end
                    break
                end
            end
        else
            if echo
                disp('Terminating Stacy...')
            end
            break
        end
        
    end
    passcount = passcount + 1;
    
    if passcount > maxlooppass
        break
    end
end





end





