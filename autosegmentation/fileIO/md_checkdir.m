function md_checkdir(pathname)
%MD_CHECKDIR Check validity of a path. No output means that the path is valid!
%
% v1.0
%
% This simple function is helpful in scripts that rely on a path's validity
% and have to stop if a path is not accessible.
%
% SYNOPSIS
%   md_checkdir(pathname)
%
% INPUT
%   pathname: Path of the directory that should be checked.
%
% OUTPUT
%   None (just produces an error and aborts the script if the path is invalid).

if exist(pathname,'dir') ~= 7
    error(strcat('"', pathname, ...
        '" not found. Please make sure that this directory is accessible.'));
end

end
