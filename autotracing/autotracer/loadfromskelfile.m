function [steplog] = loadfromskelfile(skelfile, b, s, fastload)
%LOADFROMSKELFILE Loads BbSs from matfile (skelfile). 
%   ARGUMENTS:
%       skelfile: handle to matfile
%       b: branch
%       s: segment (optional). Omitting s results in all segments in branch
%          being loaded to RAM, to be used cautiosly with fastload. Use
%          s = 'all' if omission not possible. 
%       fastload: strips vw and pxr from steplog when set to true. Defaults
%                 to true if s is omitted or set to 'all', false otherwise. 

%parse overloaded arguments
if ~isa(skelfile, 'matlab.io.MatFile')
    skelfile = matfile(skelfile);
end

%default assignments
if ~exist('s', 'var') || strcmpi(s, 'all')
    loadallsegments = true; 
    if ~exist('fastload', 'var')
        fastload = true;
    end
else
    loadallsegments = false; 
    if ~exist('fastload', 'var')
        fastload = false; 
    end
end

%load fileindex to RAM
fileindex = skelfile.fileindex;

%check if skelfile empty
if isequal(fileindex, [0 0])
    warning('skelfile empty.')
    steplog = {}; 
    return
end

if ~loadallsegments
    if fastload
        %load everything except vw and pxr
        %NOTE: skelfile.BbSs(:, [1, 4:end]) doesn't work because [1, 4:end]
        %isn't equally spaced. Workaround: Load individually and concatenate.
        %steplog part 1
        steplog1 = eval(['skelfile.B', num2str(b), 'S', num2str(s), '(:, 1)']);
        %part 2
        steplog2 = eval(['skelfile.B', num2str(b), 'S', num2str(s), '(:, 4:end)']);
        %concatenate
        steplog = [steplog1, steplog2];
        %use [] & {} as placeholders for vw and pxr respectively
        steplog = [steplog(:, 1), repmat({[] {}}, size(steplog, 1), 1), steplog(:, 2:end)]; 
    else
        %load everything
        steplog = eval(['skelfile.B', num2str(b), 'S', num2str(s)]);
    end
else
    %load all segments
    %obtain all segments in branch b
    seginbranchind = fileindex(:,1) == b;
    seginbranch = fileindex(seginbranchind, 2);
    
    %calculate size to preallocate
    [sizeindex, wid] = measureskelfile(skelfile); 
    presize = sum(sizeindex(seginbranchind)); 
    %preallocate
    steplog = cell(presize, wid); 
    slogpointer = 1; 
    
    for seg = [seginbranch]'
        seglog = loadfromskelfile(skelfile, b, seg, fastload); 
        segsize = size(seglog, 1); 
        steplog(slogpointer:(slogpointer+segsize-1), :) = seglog; 
        slogpointer = slogpointer + segsize; 
    end
end

end