function [retorientmat] = orientationfinder(vec, res)
%ORIENTATIONFINDER Given a vector vec (yxz), retorient (y,x) = (theta, phi) contains
%the dot product of the unit vector along vec with that of the unit vector
%along (theta, phi). 
%   ARGUMENTS:
%   vec: vector. Must not be normalized. 
%   res: scan resolution. 360 by default.

%default for res
if ~exist('res', 'var')
    res = 360;
elseif mod(res, 2) == 1
    res = res + 1;
end

%initialize orientation matrix and index variables
orientmat = NaN(res/2, res);
yindtheta = 1;
xindphi = 1;

%normalize vec
e0 = vec/norm(vec, 2);

%loop over theta and phi
for phi = linspace(0, 2*pi, res)
    yindtheta = 1;
    for theta = linspace(0, pi, res/2)
        %define unit vector
        e = [sin(theta) * sin(phi); sin(theta) * cos(phi); cos(theta)];
        orientmat(yindtheta, xindphi) = dot(e0, e);
        yindtheta = yindtheta + 1;
    end
    xindphi = xindphi + 1;
end

%return
retorientmat = orientmat;

end

