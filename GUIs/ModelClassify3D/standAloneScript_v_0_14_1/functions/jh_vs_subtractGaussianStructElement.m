function cim = jh_vs_subtractGaussianStructElement(im, sigma, diffCutOff, debug, nameRun, nameParam)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

fprintf('    Calculation: Difference to gaussian structural element... ');
tic;

im = im - min(min(min(im)));
im = im / max(max(max(im)));
% imRef = im;
% imRef(im < vesicleMin) = vesicleMin;
% imRef(im > vesicleMax) = vesicleMax;
im = 1 - im;
% imRef = 1-imRef;
% offset = 1-offset;

[n1,n2,n3] = size(im);
n = n1*n2*n3;

% Make kernel coordinates
mult = 2;
radius = round(mult*sigma);
%radius = 1;
[X,Y,Z] = ndgrid(-radius:radius);

mask = ((2*pi)^(1/2))/(4*pi^2*sigma^3) * exp( -(X.^2+Y.^2+Z.^2)/(2*sigma^2) );
mask = mask / max(max(max(mask)));

%cim = imfilter(im, mask, 'corr', 'symmetric');

fprintf('\n     - Kernel complete! \n');

% Get the neighborhood from 0 to radius
[nh,~,nhEachPos] = jh_getNeighborhood3D(0,radius,size(im),'extended',[],'random',0.6);

fprintf('     - Neighborhood found! \n');

% Linearize the Gaussian kernel using the neighborhood as mask
maskLin = mask(nh == 1);
clear mask;
sizeKernel = size(maskLin, 1);

% To avoid the border problen all impossible indices are set to 1
nhEachPos(nhEachPos <= 0) = 1;
nhEachPos(nhEachPos > n) = 1;
% Create a matrix with the image intensities at each position
nhImValues = im(nhEachPos);
clear im;
% % Normalize each position with the central pixel intensity
% for i = 1:sizeKernel
%     if i ~= round(sizeKernel/2)
%         nhImValues(:,:,:,i) = nhImValues(:,:,:,i) ./ nhImValues(:,:,:,round(sizeKernel/2));
%     end
% end
% nhImValues(:,:,:,round(sizeKernel/2)) = 1;
% % Correct Inf
% nhImValues(nhImValues == Inf) = 0;
minNhImValues = min(nhImValues,[],4);
minNhImValues = minNhImValues(:,:,:,ones(sizeKernel,1));
nhImValues = nhImValues - minNhImValues;
clear minNhImValues;
maxNhImValues = max(nhImValues,[],4);
maxNhImValues = maxNhImValues(:,:,:,ones(sizeKernel,1));
nhImValues = nhImValues ./ maxNhImValues;
clear maxNhImValues;
clear nhEachPos;
fprintf('     - Image values normalized! \n');

% Create a matrix with the linearized gaussian kernel as fourth dimension
%   Use Tony's trick to doublicate the nhLin vector to three dimensions    
maskEachPos = maskLin(:, ones(n1,1), ones(n2,1), ones(n3,1));
clear maskLin;
%   Re-arrange the 4D array to set the nhLin vectors to the fourth
%   dimension
maskEachPos = permute(maskEachPos, [2,3,4,1]);
% Multiply each Gaussian kernel value with the intensity of its
% corresponding position
% for i = 1:size(maskEachPos,4)
%     maskEachPos(:,:,:,i) = maskEachPos(:,:,:,i) .* (imRef-offset) + offset;
% end
% clear imRef;
fprintf('     - Kernel extended! \n');

diffImKernel = nhImValues - maskEachPos;
clear nhImValues maskEachPos;
% cim = zeros(n1,n2,n3);
% for i = 1:sizeKernel;
%     cim = cim + abs(diffImKernel(:,:,:,i));
% end
cim = sum(abs(diffImKernel), 4);
clear diffImKernel;

%cim(cim > diffCutOff) = diffCutOff;
cim = cim-min(min(min(cim)));
cim = cim/max(max(max(cim)));

fprintf('     - Kernel subtracted! \n');

% Debug
if debug
    saveImageAsTiff3D(cim, [nameRun '_' nameParam '.TIFF']);
end

fprintf('        ...');

elapsedTime = toc;
fprintf('Done in %.2G seconds!\n', elapsedTime);

end

