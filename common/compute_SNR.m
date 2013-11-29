%function [snr]=compute_SNR(im)
%compute SNR using method of Thong 2001
im='D:\Dropbox\mSEM\2013-09-24T0937459008891_beam_1.png';
im='/Users/Shawn/Dropbox/mSEM/2013-09-24T0937459008891_beam_1.png';
im='D:\for mSEM\ZEISS-scan\130925_PT1_Denk_12_5muFoV_50ns_6_1\beam_ (1).bmp';
im='C:\Users\smikula\Downloads\substack0000.tif';

window_size=30;  
a=double(imread(im));

%% using circshift

b=a(:,floor(end/2));

c=[];
for i=-window_size:window_size
    c=[c,circshift(b,i)];
end
        
b2=(b-mean(b(:,1)) )/std(b(:,1)) ;
c2=(c-mean(b(:,1)) )/std(b(:,1)) ;

r2=b2'*c2;
r2=r2/max(r2);

y_est=( r2(ceil(end/2)-1)-r2(ceil(end/2)-2) ) + r2(ceil(end/2)-1);

snr = (y_est)/(1-y_est)

figure,plot(-window_size:window_size,r2), hold on, scatter(0,y_est) %,xlim([0,size(r,1)])




%% using normxcorr2

%b=a(:,floor(end/2));
c=normxcorr2(a,a);
r=c(:,ceil(end/2));
r2=r(ceil(end/2)-window_size:ceil(end/2)+window_size);
y_est=( r2(ceil(end/2)-1)-r2(ceil(end/2)-2) ) + r2(ceil(end/2)-1);

snr = (y_est)/(1-y_est)

figure,plot(-window_size:window_size,r2), hold on, scatter(0,y_est) %,xlim([0,size(r,1)])














