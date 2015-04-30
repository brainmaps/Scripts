function enumlabcube = enumeratebwconncomplabel(cube)
%ENUMERATEBWCONNCOMPLABEL Labels cubes, but no two labels (in an entire
%Knossos directory) are repeated. May require the path to a doc directory
%   Ready for use with cubeprocessor.


%check if glc is loaded. If not, initialize. 
if ~exist('glc', 'var')
    global glc; %#ok<TLEV>
    glc = 0;
end

%update labels
cube(~(cube == 0)) = cube(~(cube == 0)) + glc; 

%calculate new glc, but only when labcube isn't empty (the counter gets
%resetted to 0 otherwise)
if max(cube(:)) ~= 0
    glc = max(cube(:));
end

enumlabcube = cube;

end

