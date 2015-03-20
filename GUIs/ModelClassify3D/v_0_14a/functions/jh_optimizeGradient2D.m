function optGF = jh_optimizeGradient2D(GF, sigma)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

Fx = GF(:,:,2);
Fy = GF(:,:,1);

% Make Kernel 
mult = 3;
[x, y] = ndgrid(-round(mult*sigma) : round(mult*sigma));

% Normalize the gradient field
mag = sqrt(GF(:,:,1).^2 + GF(:,:,2).^2);
nFx = Fx ./ mag;
nFx(isnan(nFx)) = 0;
nFy = Fy ./ mag;
nFy(isnan(nFy)) = 0;

% Manipulate the gradient field that x and y component add up to 1
% This has to be true: value * (x_i + y_i) = 1
% value = (Fx + Fy).^(-1);
% mFx = Fx * value;
% mFy = Fy * value;

% Create matrix for x
xLin = reshape(x, size(x, 1)^2, 1);
xG = xLin(:, ones(size(GF, 1), 1));
xG = xG(:,:, ones(size(GF, 2), 1));
xG = permute(xG, [2,3,1]);

% Create matrix for y
yLin = reshape(y, size(y, 1)^2, 1);
yG = yLin(:, ones(size(GF, 1), 1));
yG = yG(:,:, ones(size(GF, 2), 1));
yG = permute(yG, [2,3,1]);

% Create matrix for Fx
FxG = nFx(:,:, ones(size(xG, 3), 1));

% Create matrix for Fy
FyG = nFy(:,:, ones(size(yG, 3), 1));

% Calculate the Gaussians for each position
% This function is something like x^2 * G, where the x^2-part is rotated
% according to the vector of each position
Gxy = (((FxG.*xG-FyG.*yG).^2) / (2*pi*sigma^2)) .* exp( - (xG.^2+yG.^2) / (2*sigma^2));
% Gxy = ((xG.^2 - sigma^2) / (sqrt(2*pi)*sigma^(9/2))) .* exp( - (xG.^2+yG.^2) / (2*sigma^2));

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
clear nFx nFy xG yG FxG FyG;

% Create neighborhood matrices
%   Create matrix containing its linear coordinates at each position
mLin = 1 : (size(Fx,1)*size(Fx,2));
mLin = reshape(mLin, size(Fx,1),size(Fx,2));
%   Create matrix describing the neighborhood (equal to the subset of mLin
%   at the top left corner)
nh = mLin(1:size(x,1), 1:size(x,2));
%   Now subtract the central pixel (this now describes a neighborhood of a
%   certain position using linear coordinates)
nh = nh - nh((size(nh, 1)+1)/2, (size(nh, 2)+1)/2);
%   Linearize this
nhLin = reshape(nh, size(nh, 1) * size(nh, 2), 1);
%   Use Tony's trick to create matrix of size equal to Fx and Fy with
%   addititional 3rd dimension to store the neighborhood positions
nhLin = nhLin(:, ones(size(Fx,1), 1), ones(size(Fx,2), 1));
nhLin = permute(nhLin, [2,3,1]);
%   Tony's trick on the mLin matrix
mLin = mLin(:,:, ones(size(xLin, 1), 1));
%   Add to mLin
NHLinTotal = nhLin + mLin;
%   Set everything to 1 or max position that is not a possible position
NHLinTotal(NHLinTotal < 1) = 1;
NHLinTotal(NHLinTotal > (size(Fx, 1) * size(Fx, 2))) = (size(Fx, 1) * size(Fx, 2));
%   Use this to get the actual neighborhood matrices
FxNH = Fx(NHLinTotal);
FyNH = Fy(NHLinTotal);

% Smooth the gradient field
%   Compute with the Gaussian
optFx = FxNH .* Gxy;
optFy = FyNH .* Gxy;
%   Add up the third dimension
optFx = sum(optFx, 3) / 2;
optFy = sum(optFy, 3) / 2;

% % Normalize
% magOpt = sqrt(optFx.^2 + optFy.^2);
% normOptFx = optFx ./ magOpt;
% normOptFx(isnan(normOptFx)) = 0;
% normOptFy = optFy ./ magOpt;
% normOptFy(isnan(normOptFy)) = 0;
% 
% optFx = normOptFx .* mag;
% optFy = normOptFy .* mag;




optGF(:,:,2) = optFx;
optGF(:,:,1) = optFy;



end

