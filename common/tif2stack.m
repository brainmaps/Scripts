function b=tif2stack(a)
%b=tif2stack('D:\Dropbox\SCRIPTS\MATLAB\autosegmentation\I0.tif');
info = imfinfo(a);
num_images = numel(info);
for k = 1:num_images
    A = imread(a, k, 'Info', info);
    b(:,:,k)=A;
end
