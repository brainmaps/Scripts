function optGF = jh_optimizeGradient3D(GF, sigma)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

Fx = GF(:,:,:,2);
Fy = GF(:,:,:,1);
Fz = GF(:,:,:,3);

n1 = size(GF, 1);
n2 = size(GF, 2);
n3 = size(GF, 3);
n = n1 * n2 * n3;

% Make Kernel 
mult = 3;
[x, y, z] = ndgrid(-round(mult*sigma) : round(mult*sigma));

sizeKernel = size(x, 1)^3;

% Normalize the gradient field
mag = sqrt(GF(:,:,:,1).^2 + GF(:,:,:,2).^2 + GF(:,:,:,3).^2);
nFx = Fx ./ mag;
nFx(isnan(nFx)) = 0;
nFy = Fy ./ mag;
nFy(isnan(nFy)) = 0;
nFz = Fz ./ mag;
nFz(isnan(nFz)) = 0;

clear mag;
clear GF;

% Manipulate the gradient field that x and y component add up to 1
% This has to be true: value * (x_i + y_i) = 1
% value = 1 / (Fx + Fy + Fz);
% mFx = Fx .* value;
% mFy = Fy .* value;
% mFz = Fz .* value;

% Create matrix for x
xLin = reshape(x, sizeKernel, 1);
xG = xLin(:, ones(n1,1), ones(n2,1), ones(n3,1));
xG = permute(xG, [2,3,4,1]);
clear xLin;

% Create matrix for y
yLin = reshape(y, size(y, 1)^3, 1);
yG = yLin(:, ones(n1,1), ones(n2,1), ones(n3,1));
yG = permute(yG, [2,3,4,1]);
clear yLin;

% Create matrix for z
zLin = reshape(z, size(z, 1)^3, 1);
zG = zLin(:, ones(n1,1), ones(n2,1), ones(n3,1));
zG = permute(zG, [2,3,4,1]);
clear zLin;
% Create matrix for Fx
FxG = nFx(:,:,:, ones(size(xG, 4), 1));
clear nFx;

% Create matrix for Fy
FyG = nFy(:,:,:, ones(size(yG, 4), 1));
clear nFy;

% Create matrix for Fz
FzG = nFz(:,:,:, ones(size(zG, 4), 1));
clear nFz;

% Calculate the Gaussians for each position
Gxyz = ((FxG.*xG-FyG.*yG+FzG.*zG).^2 / (sqrt(2*pi)*2*pi*sigma^3)) .* exp( - (xG.^2+yG.^2+zG.^2) / (2*sigma^2));

% t = Gxy(11,7,:);
% t = reshape(t, size(y,1),size(x,1));
% 
% % figure(1)
% % imagesc(Gxy);
% 
% figure(2)
% imagesc(t);

% t = Gxy(8,8,:);
% t = reshape(t, size(y,1),size(x,1));
% 
% figure(2)
% imagesc(t);


% Clear everything that is not needed anymore
clear xG yG zG FxG FyG FzG;

% Create neighborhood matrices
%   Create matrix containing its linear coordinates at each position
mLin = 1 : (n1 * n2 * n3);
mLin = reshape(mLin, n1,n2,n3);
%   Create matrix describing the neighborhood (equal to the subset of mLin
%   at the top left corner)
nh = mLin(1:size(x,1), 1:size(x,2), 1:size(x,3));
%   Now subtract the central pixel (this now describes a neighborhood of a
%   certain position using linear coordinates)
nh = nh - nh((size(nh, 1)+1)/2, (size(nh, 2)+1)/2, (size(nh, 2)+1)/2);
%   Linearize this
nhLin = reshape(nh, size(nh, 1) * size(nh, 2) * size(nh, 3), 1);
clear nh;
%   Use Tony's trick to create matrix of size equal to Fx and Fy with
%   addititional 3rd dimension to store the neighborhood positions
nhLin = nhLin(:, ones(n1, 1), ones(n2, 1), ones(n3, 1));
nhLin = permute(nhLin, [2,3,4,1]);
%   Tony's trick on the mLin matrix
mLin = mLin(:,:,:, ones(sizeKernel, 1));
%   Add to mLin
NHLinTotal = nhLin + mLin;
clear mLin nhLin;
%   Set everything to 1 or max position that is not a possible position
NHLinTotal(NHLinTotal < 1) = 1;
NHLinTotal(NHLinTotal > (n1 * n2 * n3)) = (n1 * n2 * n3);
%   Use this to get the actual neighborhood matrices
FxNH = Fx(NHLinTotal);
FyNH = Fy(NHLinTotal);
FzNH = Fz(NHLinTotal);
clear NHLinTotal Fx Fy Fz;

% Smooth the gradient field
%   Compute with the Gaussian
optFx = FxNH .* Gxyz;
optFy = FyNH .* Gxyz;
optFz = FzNH .* Gxyz;
clear Gxyz FxNH FyNH FzNH;
%   Add up the fourth dimension
optFx = sum(optFx, 4) / 2;
optFy = sum(optFy, 4) / 2;
optFz = sum(optFz, 4) / 2;

% % Normalize
% magOpt = sqrt(optFx.^2 + optFy.^2);
% normOptFx = optFx ./ magOpt;
% normOptFx(isnan(normOptFx)) = 0;
% normOptFy = optFy ./ magOpt;
% normOptFy(isnan(normOptFy)) = 0;
% 
% optFx = normOptFx .* mag;
% optFy = normOptFy .* mag;




optGF(:,:,:,2) = optFx;
optGF(:,:,:,1) = optFy;
optGF(:,:,:,3) = optFz;



end

