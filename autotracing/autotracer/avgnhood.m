function [avim] = avgnhood(im, fieldsize)
%AVGNHOOD Averages im over fieldsize with convolution. 

%default for fieldsize
if ~exist('fieldsize', 'var')
    fieldsize = 19; 
end

avim = unpad(imfilter(smartpad(im, fieldsize), ones(fieldsize, fieldsize)/(fieldsize*fieldsize)), fieldsize);

end

