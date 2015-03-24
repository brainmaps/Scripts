function [steplog] = fetchfromskelfile(skelfile, b, s, ind) %#ok<INUSL>
%FETCHFROMSKELFILE Fetches the steplog for BbSs in skelfile when ind is omitted.
%Otherwise, the ind-th node in BbSs.

if ~exist('ind', 'var') || isequal(ind, '~') || isequal(ind, 'none')
    steplog = eval(['skelfile.B', num2str(b), 'S', num2str(s)]);
else
    steplog = eval(['skelfile.B', num2str(b), 'S', num2str(s), '(ind, :)']);
end

end

