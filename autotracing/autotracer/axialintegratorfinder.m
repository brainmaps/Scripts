function [vw, pxr, nonanvw] = axialintegratorfinder(startpnt, endpnt, cube, intthresh, angres, linres, step)
%AXIALINTEGRATORFINDER Given a line segment (charachterised by startpnt and
%endpnt), the function integrates along rays in a cylindrical raycluster
%untill a given threshold (intthresh) is crossed. The coordinate system of
%the ray cluster is (phi, x) where phi (x) is the angular (linear) coordinate.
%The angular (linear) resolution can be specified as optional arguments.
%   Arguments:
%       
%       
%   Output:
%       
%       
%       

%defaults
if ~exist('intthresh', 'var') || isequal(intthresh, '~')
    intthresh = 1;
end

if ~exist('angres', 'var') || isequal(angres, '~')
    angres = 360;
end

if ~exist('linres', 'var') || isequal(linres, '~')
    linres = ceil(norm(startpnt - endpnt));
end

if ~exist('step', 'var') || isequal(step, '~')
    step = 1;
end

%take measurements
[sizy, sizx, sizz] = size(cube); 

%initialize outputs
vw = nan(angres, linres);
pxr = cell(angres, linres);
nonanvw = zeros(angres, linres);

%normalize axial vector
n = (endpnt - startpnt)/norm(endpnt - startpnt);

%determine axial vector orientation
%calculate normal to span{n, z}
b = cross(n, [0 0 1]);

%determine the angle between z and n
theta = acos(dot(n, [0 0 1]));

%calculate rotation quaternion
q = [cos(theta/2), sin(theta/2)*b(1), sin(theta/2)*b(2), sin(theta/2)*b(3)];

%determine coordinates of points in a unit circle about the z axis
s = [cos(deg2rad([linspace(1, 360, angres)]')), sin(deg2rad([linspace(1, 360, angres)]')), zeros(angres,1)];

%transform coordinates such that the new z axis is parallel to n
sp = quatrotate(q, s);

%calculate the locus of x
%initialize lambda
alllambda = linspace(0, 1, linres);

%loop
for xindx = 1:linres
    for yindtheta = 1:angres
        %accquire angular unit vector
        e = sp(yindtheta, :);
        
        %generate numerical coordinates of a point in the axial line
        %segment
        lambda = alllambda(xindx);
        p = (1-lambda)*startpnt + lambda*endpnt;
        
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
                nonanvw(yindtheta, xindx) = nstep*step;
                currcoord = round(currcoord');
                for k = 1:3
                    if currcoord(k) > sizx
                        currcoord(k) = sizx;
                    end
                    
                    if currcoord(k) < 1
                        currcoord(k) = 1;
                    end
                end
                pxr{yindtheta, xindx} = currcoord;
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
                vw(yindtheta, xindx) = lambda0(indmins);
                nonanvw(yindtheta, xindx) = lambda0(indmins);
                pxr{yindtheta, xindx} = pixcoordlist(indmins, :);
                break
            end            
            nstep = nstep + 1;
        end                
    end
end
end


function [retlambda0, rets] = calculateperilinea(p0, shortlist, e)
%Calculates the ray parameter of the point in ray lambda*e + p closest to
%coordinates (yxz) in shortlist. e and p assumed in yxz format. 

%initialize return variables
lambda0 = nan(size(shortlist, 1), 1);
s = nan(size(shortlist, 1), 1);

%reshape for dot product
p0 = p0';

%loop over all shortlisted entries
for k = 1:size(shortlist, 1)
    p = shortlist(k,:); 
    p = p'; 
    lambda0(k) = e*(p - p0);
    s(k) = norm(p - p0);
end

retlambda0 = lambda0;
rets = s;

end

