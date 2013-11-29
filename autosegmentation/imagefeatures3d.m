function [I0,Ix,Iy,Iz,Igrad,Ixx,Ixy,Ixz,Iyy,Iyz,Izz,Ihess,Lambda1a,Lambda2a,Lambda3a,Vx,Vy,Vz,FA] = imagefeatures3d(I,Sigma)
% syms X Y Z Sigma
% f=1/(  Sigma ) * exp(-(X^2 + Y^2 )/(2*Sigma^2))
% g=diff(diff(f,X),Y)

slice=34;

%if nargin < 2, Sigma = 1; end

% Make kernel coordinates
mult=1;
[X,Y,Z]   = ndgrid(-round(mult*Sigma):round(mult*Sigma));

I=double(I);

D0 = exp(-(X.^2 + Y.^2 + Z.^2)/(2*Sigma^2))/Sigma;

I0 = imfilter(I,D0,'conv','symmetric' );

%figure(79),imshow( I(:,:,slice),[])
%figure(80),imshow( I0(:,:,slice),[])


Dx = -(X.*exp(-(X.^2 + Y.^2 + Z.^2)/(2*Sigma^2)))/Sigma^3;
Dy = -(Y.*exp(-(X.^2 + Y.^2 + Z.^2)/(2*Sigma^2)))/Sigma^3;
Dz = -(Z.*exp(-(X.^2 + Y.^2 + Z.^2)/(2*Sigma^2)))/Sigma^3;

Ix = imfilter(I,Dx,'conv','symmetric' );
Iy = imfilter(I,Dy,'conv','symmetric' );
Iz = imfilter(I,Dz,'conv','symmetric' );

Igrad=(Ix.^2+Iy.^2+Iz.^2).^(.5);

%figure(81),imshow( Igrad(:,:,slice),[])

% Build the gaussian 2nd derivatives filters
Dxx = (X.^2.*exp(-(X.^2 + Y.^2 + Z.^2)/(2*Sigma^2)))/Sigma^5 - exp(-(X.^2 + Y.^2 + Z.^2)/(2*Sigma^2))/Sigma^3;
Dxy = (X.*Y.*exp(-(X.^2 + Y.^2 + Z.^2)/(2*Sigma^2)))/Sigma^5;
Dxz = (X.*Z.*exp(-(X.^2 + Y.^2 + Z.^2)/(2*Sigma^2)))/Sigma^5;
Dyy = (Y.^2.*exp(-(X.^2 + Y.^2 + Z.^2)/(2*Sigma^2)))/Sigma^5 - exp(-(X.^2 + Y.^2 + Z.^2)/(2*Sigma^2))/Sigma^3;
Dyz = (Y.*Z.*exp(-(X.^2 + Y.^2 + Z.^2)/(2*Sigma^2)))/Sigma^5;
Dzz = (Z.^2.*exp(-(X.^2 + Y.^2 + Z.^2)/(2*Sigma^2)))/Sigma^5 - exp(-(X.^2 + Y.^2 + Z.^2)/(2*Sigma^2))/Sigma^3;


Ixx = imfilter(I,Dxx,'conv','symmetric' );
Ixy = imfilter(I,Dxy,'conv','symmetric' );
Ixz = imfilter(I,Dxz,'conv','symmetric' );
Iyy = imfilter(I,Dyy,'conv','symmetric' );
Iyz = imfilter(I,Dyz,'conv','symmetric' );
Izz = imfilter(I,Dzz,'conv','symmetric' );
%figure(821), imagesc(Dxx)
%figure(822), imagesc(Dxy)


%[Lambda1,Lambda2,Vx,Vy]=eig2image(Ixx,Ixy,Iyy);
% [vec1eig,vec2eig,vec3eig,vec1x,vec1y,vec1z,vec2x,vec2y,vec2z,vec3x,vec3y,vec3z]=eig3image_sm(Ixx,Ixy,Ixz,Iyy,Iyz,Izz);
% Ihess=vec1eig;
% figure(82),imshow(-vec1eig(:,:,slice),[])
% figure(822),imshow(-vec2eig(:,:,slice),[])
% figure(823),imshow(-vec3eig(:,:,slice),[])

[Lambda1a,Lambda2a,Lambda3a,Vx,Vy,Vz]=eig3volume(Ixx,Ixy,Ixz,Iyy,Iyz,Izz);
Ihess=Lambda3a;
%figure(823),imshow(-Lambda1a(:,:,slice),[])
%figure(822),imshow(-Lambda2a(:,:,slice),[])
%figure(82),imshow(-Lambda3a(:,:,slice),[])

FA=.5*(( (Lambda1a-Lambda2a).^2 + (Lambda2a-Lambda3a).^2 + (Lambda3a-Lambda1a).^2).^(.5) )...
    ./(( (Lambda1a).^2 + (Lambda2a).^2 + (Lambda3a).^2).^(.5)  )   ;


%figure(891),num=3000,scatter(I0(1:num),Ihess(1:num));



% Dxxxx = (3*exp(-(X.^2 + Y.^2)/(2*Sigma^2)))/Sigma^5 - (6*X.^2.*exp(-(X.^2 + Y.^2)/(2*Sigma^2)))/Sigma^7 + (X.^4.*exp(-(X.^2 + Y.^2)/(2*Sigma^2)))/Sigma^9;
% Dyyyy = (3*exp(-(X.^2 + Y.^2)/(2*Sigma^2)))/Sigma^5 - (6*Y.^2.*exp(-(X.^2 + Y.^2)/(2*Sigma^2)))/Sigma^7 + (Y.^4.*exp(-(X.^2 + Y.^2)/(2*Sigma^2)))/Sigma^9;
% Dxyxy = exp(-(X.^2 + Y.^2)/(2*Sigma^2))/Sigma^5 - (X.^2.*exp(-(X.^2 + Y.^2)/(2*Sigma^2)))/Sigma^7 - (Y.^2.*exp(-(X.^2 + Y.^2)/(2*Sigma^2)))/Sigma^7 + (X.^2*Y.^2.*exp(-(X.^2 + Y.^2)/(2*Sigma^2)))/Sigma^9;
% 
% Ixxxx = imfilter(I,Dxxxx,'conv','symmetric' );
% Ixyxy = imfilter(I,Dxyxy,'conv','symmetric' );
% Iyyyy = imfilter(I,Dyyyy,'conv','symmetric' );
% figure, imagesc(Dxxxx)
% figure, imagesc(Dxyxy)
% 
% 
% [Lambda1a,Lambda2a,Vxa,Vya]=eig2image(Ixxxx,Ixyxy,Iyyyy);
% I4th=Lambda2a;
% figure(83),imshow(Lambda2a,[])
