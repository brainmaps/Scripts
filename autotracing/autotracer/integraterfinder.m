function [retview, retpixview, retnonanvw] = integraterfinder(p, cube, intthresh, res, step)
%WALLVIEW Given a point p in cube, the function integrates along a ray (ch-
%aracterized by solid angles theta and phi) until a given threshold
%(intthresh) is crossed. The ray is then assigned this distance (retview)
%and pixel coordinates registered. 
%   ARGUMENTS: 
%   p: point in data (yxz)
%   cube: data
%   res: scan resolution (360 by default)
%   step: step resolution (1 by default)
%   intthresh: integral threshold
%   OUTPUT:
%   view: A res by res matrix with (y, x) = (theta, phi)
%   pixview: A cell array of points associated with the corresponding entry
%   in view
%   nonanvw: Like vw, but without the NaNs to make things conv friendly


%echo switch
echo = false;

%default for res
if ~exist('res', 'var')
    res = 360;
else
    if mod(res, 2) == 1
        res = res + 1;
    end
end

%default for intthresh
if ~exist('intthresh', 'var')
    intthresh = 0.5;
end

%default for step
if ~exist('step', 'var')
    step = 1;
end

%take measurements
[sizy, sizx, sizz] = size(cube);

%transpose p
p = p';

%initialize res/2-by-res view matrix
viewf = nan(res/2, res);
%initialize res/2-by-res NaN-less view matrix
nonanvw = nan(res/2, res);
%intialize res/2-by-res pixel coordinate register
pixviewf = cell(res/2, res);

%initialize theta and phi indices
yindtheta = 1;
xindphi = 1;

if echo
    %intialize waitbar
    wbx = 0;
    h = waitbar(wbx, 'Progress');
    wbmax = res*res;
end

%loop over theta and phi
for phi = linspace(0, 2*pi, res)
    yindtheta = 1;
    for theta = linspace(0, pi, res/2)
        
        %if echo
%             %waitbar variables
%             wbx = wbx + 1/wbmax;
%             %progress string
%             progstring = ['theta = ', num2str(theta, 4), '; phi = ', num2str(phi, 4)];
%             waitbar(wbx, h, progstring)
        %end
        
        %define unit vector
        e = [sin(theta) * sin(phi); sin(theta) * cos(phi); cos(theta)];
        
        %initialize condition for step-forward
        stepf = true;
        %initialize step counter
        nstep = 1;
        %initialize a integral
        integ = 0;
        %step loop
        while stepf
            %locate viewfinder
            currcoord = p + nstep*step.*e;
            yrangemin = floor(currcoord(1)); yrangemax = yrangemin + 1;
            xrangemin = floor(currcoord(2)); xrangemax = xrangemin + 1;
            zrangemin = floor(currcoord(3)); zrangemax = zrangemin + 1;
            
            %out of bound: 
            if yrangemax > sizy || xrangemax > sizx || zrangemax > sizz || yrangemin < 1 || xrangemin < 1 || zrangemin < 1
                stepf = false;
                nonanvw(yindtheta, xindphi) = nstep*step;
                currcoord = round(currcoord');
                for k = 1:3
                    if currcoord(k) > sizx
                        currcoord(k) = sizx;
                    end
                    
                    if currcoord(k) < 1
                        currcoord(k) = 1; 
                    end
                end                
                pixviewf{yindtheta, xindphi} = currcoord;
                break
            end
            
            %fetch all pixels in vicinity (values)
            %notation: ffc: y = floor, x= floor,
            %z = ceiling; v: value; p: pixel coordinates
            vfff = cube(yrangemin, xrangemin, zrangemin);
            vffc = cube(yrangemin, xrangemin, zrangemax);
            vfcf = cube(yrangemin, xrangemax, zrangemin);
            vfcc = cube(yrangemin, xrangemax, zrangemax);
            vcff = cube(yrangemax, xrangemin, zrangemin);
            vcfc = cube(yrangemax, xrangemin, zrangemax);
            vccf = cube(yrangemax, xrangemax, zrangemin);
            vccc = cube(yrangemax, xrangemax, zrangemax);
            
            %assemble to lists
            pixvallist = [vfff; vffc; vfcf; vfcc; vcff; vcfc; vccf; vccc];
            
            %add to integral
            integ = integ + mean(pixvallist); 
            
            %keep going if integral below threshold; otherwise:
            if integ > intthresh
                
                %assemble coordinate list
                pfff = [yrangemin, xrangemin, zrangemin];
                pffc = [yrangemin, xrangemin, zrangemax];
                pfcf = [yrangemin, xrangemax, zrangemin];
                pfcc = [yrangemin, xrangemax, zrangemax];
                pcff = [yrangemax, xrangemin, zrangemin];
                pcfc = [yrangemax, xrangemin, zrangemax];
                pccf = [yrangemax, xrangemax, zrangemin];
                pccc = [yrangemax, xrangemax, zrangemax];
                
                pixcoordlist = [pfff; pffc; pfcf; pfcc; pcff; pcfc; pccf; pccc];
            
                %calculate all displacements from ray 
                [lambda0, s] = calculateperilinea(p, pixcoordlist, e);
                %find smallest s
                [~, indmins] = min(s);
                %assign to view matrix (& pixel coordinate register)
                viewf(yindtheta, xindphi) = lambda0(indmins);
                nonanvw(yindtheta, xindphi) = lambda0(indmins);
                pixviewf{yindtheta, xindphi} = pixcoordlist(indmins, :);
                break
            end
            
            nstep = nstep + 1;
        end
        yindtheta = yindtheta + 1;
    end
    xindphi = xindphi + 1;
end
if echo
    delete(h)
end
retview = viewf;
retpixview = pixviewf;
retnonanvw = nonanvw;

end

function [retlambda0, rets] = calculateperilinea(p0, shortlist, e)
%Calculates the ray parameter of the point in ray lambda*e + p closest to
%coordinates (yxz) in shortlist. e and p assumed in yxz format. 

%initialize return variables
lambda0 = nan(size(shortlist, 1), 1);
s = nan(size(shortlist, 1), 1);

%loop over all shortlisted entries
for k = 1:size(shortlist, 1)
    p = shortlist(k,:); p = p';
    lambda0(k) = e'*(p - p0);
    s(k) = norm(p - p0);
end

retlambda0 = lambda0;
rets = s;

end