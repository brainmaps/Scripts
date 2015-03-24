function [projcube] = pxr2projection(pxr)
%PXR2PROJECTION Constructs a 3D projection of Steve's view from pxr
%   Assumes 384^3 working context size

%initialize projcube with zeros
projcube = zeros(384, 384, 384);

%fill projcube
for k = [pxr(:)]'
    try
        projcube(k{1}(2), k{1}(1), k{1}(3)) = 1;
    catch
        '';
    end
end


end

