function [b]= imenhance(a)
b=a;

PSF0 = fspecial('gaussian',1,3);
PSF = fspecial('gaussian',2,5);
PSF2 = fspecial('gaussian',3,5);
PSF3 = fspecial('gaussian',7,10);
PSF4 = fspecial('gaussian',3,3);

%b=adapthisteq(b,'Distribution' ,'exponential','ClipLimit',0.005); %'exponential' 'uniform' 'rayleigh'
%b=imresize(b,2,'nearest');
%b=imresize(b,2,'Method','bicubic','Antialiasing',false); 

%b= deconvlucy(b,PSF2,4) ;
%b=gaussianbpf(b,100,15120);
%b = deconvblind(b,PSF);

%H = padarray(2,[2 2]) - fspecial('gaussian' ,[5 5],2); % create unsharp mask


%b= deconvlucy(b,PSF2,3) ;


 
%b=imresize(b,.5,'nearest');

%b=imresize(deconvlucy(imresize(a,2),PSF,4),.5);
%b= deconvlucy(a,PSF,3) ;
%b=medfilt2( b,[2 2]);
%b=medfilt2(  deconvlucy(b,PSF2,5)  ,[2 2]);
%b=imfilter(b,PSF4,'symmetric','same');



H = padarray(2,[1 1]) - fspecial('gaussian' ,[3 3],2);
H = padarray(2,[2 2]) - fspecial('gaussian' ,[5 5],3); % create unsharp mask
b=imfilter(b,H,'symmetric','same');
 
%b=deconvlucy(b,PSF4,4);

%b=imfilter(b,PSF4,'symmetric','same');
%b=deconvlucy(b,PSF,2);

%b = deconvblind(b,PSF);

%b=imfilter(b,PSF4,'symmetric','same');

%b=gaussianbpf(b,100,512);
%b=gaussianbpf(b,100,15120);
%b=imadjust(b,stretchlim(b, [0.002 0.99]));
%b=adapthisteq(b,'Distribution' ,'rayleigh','ClipLimit',0.005); %'exponential' 'uniform' 'rayleigh'

%b=medfilt2( b,[2 2]);
%b=imresize(b,.5,'Method','bicubic','Antialiasing',false); %'lanczos2' 

%b=medfilt2( b,[2 2]);

%b=imfilter(b,H,'symmetric','same');
b=imadjust(b,stretchlim(b, [0.002 0.994]));
%b=adapthisteq(b);

%bpfilter=im2double(imread('bpfilter.tif'));
%bpfilter=bpfilter-mean(bpfilter(:));
%b=filter2(fftshift(fft2(double(a))),bpfilter,'same');

%figure(456),imshow(a), figure(457),imshow(b)


