function [girth, diamvw, smallgirth, largegirth] = girthfinder(vw, axisvec, varargin)
%GIRTHFINDER Calculates the lower bound to the diameter of a cell at a node
%with a given view vw. Not tested for resolutions smaller/larger than
%180*360.
%Methods: Apex Angle Search with OTSU (AASOTSU)
%         Extracts vw info within a certain window perpendicular to the
%         skeleton axis -> classifies regions with OTSU.
%         Axial Search Perpendicular to Skeleton Axis (ASPSA)
%         similar to axial search.
%defaults
window = 0.2; %apex angle approx 25 degrees
method = 'AASOTSU'; %girthfinder method
ol = 4; %otsu cutoff level
angres = 360; 

%parse
for k = 1:2:length(varargin)
    switch varargin{k}
        case 'method'
            method = varargin{k+1};
        case 'window'
            window = varargin{k+1};
        case {'second axis vector', 'axisvec2'}
            axisvec2 = varargin{k+1};
        case 'otsu levels'
            ol = varargin{k+1};
        case {'angular resolution', 'angres'}
            angres = varargin{k+1}; 
    end
end

%validate
if ~exist('axisvec2', 'var') && strcmpi(method, 'ASPSA')
    warning('axisvec2 not provided, using AASOTSU instead...')
    method = 'AASOTSU';
end

switch method
    case 'AASOTSU'
        %calculate resolution (not tested for arbitrary resolutions)
        res = size(vw, 2);
        
        %initialize
        diamvw = NaN(size(vw));
        diffdiamvw = diamvw;
        
        %main loop over all angles theta and phi on S^2
        for yindtheta = 1:(res/2)
            for xindphi = 1:res
                %calculate antipodal coordinates
                ayindtheta = (res/2) - yindtheta;
                axindphi = mod(xindphi + (res/2), res);
                %correct out of bound indices
                if ayindtheta == 0
                    ayindtheta = 1;
                end
                if axindphi == 0
                    axindphi = res;
                end
                
                %extract dist value of the corresponding antipodal point
                pdist = vw(yindtheta, xindphi);
                apdist = vw(ayindtheta, axindphi);
                
                %register in diamvw
                diamvw(yindtheta, xindphi) = pdist + apdist;
                diffdiamvw(yindtheta, xindphi) = abs(pdist - apdist);
            end
        end
        
        %average by a small neighborhood
        diamvw = avgnhood(diamvw, 3);
        
        %if no axisvec given, proceed by thresholding with otsu
        if ~exist('axisvec', 'var')
            %run ol level otsu and calculate the mean excluding the ol-th level (to take
            %care of outliers)
            otdvw = otsu(diamvw, ol);
            
            %calculate mean and return
            girth = mean(diamvw(otdvw < ol));
            return
        end
        
        %otherwise, accquire orientation chart
        orientchart = orientationfinder(axisvec, res);
        %filter by window
        orientmap = orientchart > -window & orientchart < window;
        %Mask and calculate mean girth
        girth = mean(diamvw(orientmap(:)));
        %calculate smaller (average) girth with a 2-level OTSU
        %linearize and filter diamvw
        lindvw = diamvw(orientmap(:));
        %run otsu
        olindvw = otsu(lindvw, 2);
        %calculate smaller and larger estimates
        smallgirth = mean(lindvw(olindvw == 1));
        largegirth = mean(lindvw(olindvw == 2));
    
    case 'ASPSA'
        %prepare quaternion rotation of a unit circle on the xy plane
        %centered at the origin (see axial search)
        %normalize axial vector
        n = axisvec/norm(axisvec);
        
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
        
        %find vector perpendicular to span{axisvec, axisvec2}
        skelperpvec = cross(axisvec, axisvec2); 
        
        %formulate rotation quaternion
        rotquat; %CONTINUE
        
        
end

end

