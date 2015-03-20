function s = jh_buildString(varargin)
%jh_buildString builds a concatenated string of supplied strings or numbers
%   
% SYNOPSIS 
%   s = jh_buildString(...)
%
% INPUT
%   Strings or numbers of type 'double', 'integer' or 'float'
%   1x2 vector containing two numbers:
%       E.g.: [3 4] is interpreted as '0003'
%
% OUTPUT
%   s: concatenated string containing all supplied values
%
% EXAMPLE
%   >> jh_buildString('value', [2 3], ': ', 25)
%
%   ans =
%
%   value002: 25

s = '';

for i = 1:length(varargin)
    si = varargin{i};
    % Check for type
    if ischar(si)
        s = [s si];
    elseif isa(si, 'double') || isa(si, 'integer') || isa(si, 'float')
        if size(si) == 1
            s = [s num2str(si)];
        elseif size(si, 2) == 2
            % Pad the first number according to the second
            no = sprintf(['%0' num2str(si(2)) 'd'], si(1));
            s = [s no];
        end
    end
end


end

