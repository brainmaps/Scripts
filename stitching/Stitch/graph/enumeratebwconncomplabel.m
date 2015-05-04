function enumlabcube = enumeratebwconncomplabel(cube)
%ENUMERATEBWCONNCOMPLABEL Labels cubes, but no two labels (in an entire
%Knossos directory) are repeated. May require the path to a doc directory
%   Ready for use with cubeprocessor.
%(CC) Nasim Rahaman. Github: github.com/nasimrahaman

%call global variable
global glc;

%when called for the first time, glc = []. Initialize if that's the case:
if isempty(glc)
    glc = 0; 
end

%relabel cubes to fit Julian's format
%take measurements
sizc = size(cube); 
%calculate unique indices for relabelling
[~,~,cube] = unique(cube); cube = reshape(cube - 1, sizc);  

%update labels
cube(~(cube == 0)) = cube(~(cube == 0)) + glc; 

%calculate new glc, but only when labcube isn't empty (the counter gets
%resetted to 0 otherwise)
if max(cube(:)) ~= 0
    glc = max(cube(:));
end

enumlabcube = cube;

end

