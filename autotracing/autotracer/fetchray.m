function [ray, manl] = fetchray(incube, p, r, phi, theta)
%FETCHRAY Given a point p within incube, the function returns a list of
%pixel intensities along a ray directed along (phi, theta).
%   [INPUT] 
%   incube: input cube
%   p: point (yxz)
%   r: maximum scan radius
%   phi, theta: spherical coordinates (phi: azimuthal) (assumed in radians) 
%   [WARNINGS]
%   MATLAB's yx format must be dealt with by swapping x and y in unit
%   vector coordinates. 

%define dr as the number of pixels to step by. Optimally 1, can vary. 
dr = 1;

%define unit vector
e = [sin(theta) * sin(phi); sin(theta) * cos(phi); cos(theta)];

%compile a list of euclidean coordinates. Set first entry to p and trace
%along the ray
eucl = nan(r + 1, 3);
eucl(1,:) = p;
for n = 1:r
    newp = p + (n*dr).*e';
    eucl(n + 1, :) = newp;
end

%convert from euclidian to manhattan coordinates
manl = p;
for n = 1:r
    currcoord = floor(eucl(n + 1, :));
    %take care of repititons
    if isequal(currcoord, manl(n))
        continue
    end
    manl = [manl; currcoord];
end

%eliminate duplicates
manl = unique(manl, 'rows', 'stable');

%fetch from cube
%take measurements
siz = size(incube, 1);
%initialize pixel list
pixl = nan(size(manl, 1), 1);
%loop over
for n = 1:size(pixl, 1)
    currcoord = manl(n, :);
    %check if currcoord is accessible
    try 
        pixl(n) = incube(currcoord(1), currcoord(2), currcoord(3));
    catch
        manl(n, :) = [NaN NaN NaN];
        continue
    end
end

ray = pixl;

end

