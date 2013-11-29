function [I0,Ix,Iy,Igrad,Ixx,Ixy,Iyy,Ihess] = imagefeatures2d(I,Sigma,mult,power)
% syms X Y Z Sigma
% f=1/(  Sigma ) * exp(-(X^2 + Y^2 )/(2*Sigma^2))
% g=diff(diff(f,X),Y)

I=double(I);

if nargin < 2, Sigma = 1; end
if nargin < 3, mult = 3; end
if nargin < 4, power = .5; end

% Make kernel coordinates
%mult=2;
[X,Y]   = ndgrid(-round(mult*Sigma):round(mult*Sigma));

%the Gaussian raised to power 
%power=.5;
G0=(exp(-(sym('x')^2 + sym('y')^2)/(2*sym('sigma')^2))/sym('sigma'))^power;
D0 = subs(G0,{'x','y','sigma','power'},{X,Y,Sigma,power});      %exp(-(X.^2 + Y.^2)/(2*Sigma^2))/Sigma;

G0x=diff(G0,'x');
G0y=diff(G0,'y');
Dx=subs(G0x,{'x','y','sigma','power'},{X,Y,Sigma,power}); 
Dy=subs(G0y,{'x','y','sigma','power'},{X,Y,Sigma,power}); 

G0xx=diff(G0x,'x');
G0yy=diff(G0y,'y');
G0xy=diff(G0x,'y');
Dxx=subs(G0xx,{'x','y','sigma','power'},{X,Y,Sigma,power}); 
Dyy=subs(G0yy,{'x','y','sigma','power'},{X,Y,Sigma,power}); 
Dxy=subs(G0xy,{'x','y','sigma','power'},{X,Y,Sigma,power}); 

%normalization of filters
%Dxx=Dxx-sum(Dxx(:))/length(Dxx(:));
%Dyy=Dyy-sum(Dyy(:))/length(Dyy(:));
%Dxy=Dxy-sum(Dxy(:))/length(Dxy(:));

%figure(2917),subplot(231),imagesc(D0),subplot(232),imagesc(Dx),subplot(233),imagesc(Dy),
%subplot(234),imagesc(Dxx),subplot(235),imagesc(Dyy),subplot(236),imagesc(Dxy), 
%title(['power: ' num2str(power) ',  sigma: ' num2str(Sigma)])

%figure(1922),imagesc(D0)

I0 = imfilter(I,double(D0),'conv','symmetric' );

%figure(179),imshow( I,[])
%figure(180),imshow( I0,[])



%figure,imagesc(Dx)
%Dx = -(X.*exp(-(X.^2 + Y.^2)/(2*Sigma^2)))/Sigma^3;
%Dy = -(Y.*exp(-(X.^2 + Y.^2)/(2*Sigma^2)))/Sigma^3;

Ix = imfilter(I,double(Dx),'conv','symmetric' );
Iy = imfilter(I,double(Dy),'conv','symmetric' );

Igrad=(Ix.^2+Iy.^2).^(.5);

%figure(181),imshow( Igrad,[])

% Build the gaussian 2nd derivatives filters



%Dxx = (X.^2.*exp(-(X.^2 + Y.^2)/(2*Sigma^2)))/Sigma^5 - exp(-(X.^2 + Y.^2)/(2*Sigma^2))/Sigma^3;
%Dyy = (Y.^2.*exp(-(X.^2 + Y.^2)/(2*Sigma^2)))/Sigma^5 - exp(-(X.^2 + Y.^2)/(2*Sigma^2))/Sigma^3;
%Dxy = (X.*Y.*exp(-(X.^2 + Y.^2)/(2*Sigma^2)))/Sigma^5;


Ixx = imfilter(I,double(Dxx),'conv','symmetric' );
Ixy = imfilter(I,double(Dxy),'conv','symmetric' );
Iyy = imfilter(I,double(Dyy),'conv','symmetric' );
%figure(1821), imagesc(Dxx)
%figure(1822), imagesc(Dxy)


[Lambda1,Lambda2,Vx,Vy]=eig2image(Ixx,Ixy,Iyy);
%[Lambda1,Lambda2,Vx,Vy]=eig2image(Ix.*Ix,Ix.*Iy,Iy.*Iy);
Ihess=Lambda2;
figure(182),imshow(-Lambda2(1:512,1:512),[])
figure(1823),imshow(-sqrt(abs(Lambda2-Lambda1)),[])


%figure(1891),num=3000,scatter(I0(1:num),Ihess(1:num));



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











