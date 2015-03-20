function nm = jh_vs_neighborhoodMean(im, minDist, maxDist, anisotropic, debug, nameRun, nameParam)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

fprintf(['    Mean value of ' num2str(minDist) ' to ' num2str(maxDist) ' neighborhood... ']);
tic;

[n1,n2,n3] = size(im);
n = n1*n2*n3;

% Get the neighborhood indices
[~, ~, nhEachPos] = jh_getNeighborhood(minDist, maxDist, [n1,n2,n3], 'extended', anisotropic);

% To avoid the border problem the index matrix is cut accordingly
% nhEachPosCut = nhEachPos(2:end-1, 2:end-1, 2:end-1, :);

% To avoid the border problen all impossible indices are set to 1
% Later on the pixels near the borders are set to 0
nhEachPosCorr = nhEachPos;
nhEachPosCorr(nhEachPos <= 0) = 1;
nhEachPosCorr(nhEachPos > n) = 1;

% Get the neighborhood values
nhValues = im(nhEachPosCorr);

% Calculate the mean at every position
nm = mean(nhValues, 4);

% Debug
if debug
    saveImageAsTiff3D(nm, [nameRun '_' nameParam '.TIFF']);
end

elapsedTime = toc;
fprintf('Done in %.2G seconds!\n', elapsedTime);

end

