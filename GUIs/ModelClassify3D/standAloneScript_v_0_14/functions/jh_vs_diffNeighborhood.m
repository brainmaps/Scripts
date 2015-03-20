function dn = jh_vs_diffNeighborhood(im, radius, range, debug, nameRun, nameParam)
% 
% INPUT
%   im: image used to calculate the gradient
%   radius: Radius of the neighborhood
%   range: The range of difference which is allowed
%
% OUTPUT
%   mdn: the magnitude of the gradient field

fprintf('    Calculation: Maximum difference in neighborhood... \n');
tic;

[n1,n2,n3] = size(im);
n = n1*n2*n3;

% Get the neighborhood from 0 to radius
[~,~,nhEachPos] = jh_getNeighborhood3D(0,radius,size(im),'extended',[]);
fprintf('     - Neighborhood found! \n');

% To avoid the border problen all impossible indices are set to 1
nhEachPos(nhEachPos <= 0) = 1;
nhEachPos(nhEachPos > n) = 1;
% Create a matrix with the image intensities at each position
nhImValues = im(nhEachPos);
clear im;

minNhImValues = min(nhImValues,[],4);
maxNhImValues = max(nhImValues,[],4);
diffNhImValues = maxNhImValues - minNhImValues;
clear maxNhImValues minNhImValues;
dn = jh_getValues(diffNhImValues, range);

fprintf('     - Difference determined! \n');

% Debug
if debug
    saveImageAsTiff3D(dn, [nameRun '_' nameParam '.TIFF']);
end

fprintf('        ...');

elapsedTime = toc;
fprintf('Done in %.2G seconds!\n', elapsedTime);

end
