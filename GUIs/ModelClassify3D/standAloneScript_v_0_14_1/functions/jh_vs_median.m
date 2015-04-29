function med = jh_vs_median(im, diameter, debug, nameRun, nameParam)
% 
% INPUT
%   im: image
%   diameter: Diameter of the structural element used to calculate the median
%
% OUTPUT
%   med: the median

fprintf(['    Calculation: Median, d = ' num2str(diameter) '... ']);
tic;

% med = zeros(size(im));
% for i = 1:size(im,3)
%     med(:,:,i) = medfilt2(im(:,:,i),[radius radius]);
% end
% med = medfilt3(im,[diameter diameter diameter]);
med = medif(im, diameter, 'elliptic');
med = im2mat(med);

% Debug
if debug
    saveImageAsTiff3D(med, [nameRun '_' nameParam '.TIFF']);
end

elapsedTime = toc;
fprintf('Done in %.2G seconds!\n', elapsedTime);

end


