function stack = raystackxy(incube, p, resolution)
%RAYSTACK Polar sweep on the xy-plane. 
%   Returns a 2D matrix with increasing x => increasing r. 
%   Resolution in degrees. 

if ~exist('resolution', 'var')
    resolution = 1;
end

limr1 = max([128 128 128] - p);
limr2 = min(p);
limr = min(limr1, limr2);

n = 1;
for phi = 0:resolution:360
    stack(n, :) =  fetchray(incube, p, limr, deg2rad(phi), pi/2);
    n = n + 1;
end

end

function stack = raystackxy(incube, p, resolution)
%RAYSTACK Polar sweep on the xy-plane. 
%   Returns a 2D matrix with increasing x => increasing r. 
%   Resolution in degrees. 

if ~exist('resolution', 'var')
    resolution = 1;
end

limr1 = max([128 128 128] - p);
limr2 = min(p);
limr = min(limr1, limr2);

rstack = [double(fetchray(incube, p, limr, deg2rad(1), pi/2))]';
for phi = 1:resolution:360
    ray = [double(fetchray(incube, p, limr, deg2rad(phi), pi/2))]';
    rstack = robustvertcat(rstack, ray, NaN);
end
rstack(1,:) = [];

stack = rstack;

end

