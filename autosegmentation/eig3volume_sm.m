function [Lambda1a,Lambda2a,Ihess,Vx,Vy,Vz]=eig3volume_sm(Ixx,Ixy,Ixz,Iyy,Iyz,Izz)

% if matlabpool('size') == 0 % checking to see if my pool is already open
%     matlabpool open 4
% end

Lambda1a = zeros(size(Ixx,1),size(Ixx,2),size(Ixx,3));
Lambda2a = zeros(size(Ixx,1),size(Ixx,2),size(Ixx,3));
Ihess = zeros(size(Ixx,1),size(Ixx,2),size(Ixx,3));
Vx = zeros(size(Ixx,1),size(Ixx,2),size(Ixx,3));
Vy = zeros(size(Ixx,1),size(Ixx,2),size(Ixx,3));
Vz = zeros(size(Ixx,1),size(Ixx,2),size(Ixx,3));


xx=Ixx(:);
xy=Ixy(:);
xz=Ixz(:);
yy=Iyy(:);
yz=Iyz(:);
zz=Izz(:);

Ihess=xx./3 + yy./3 + zz./3 - ((xx + yy + zz).^2./9 - (xx.*yy)./3 - (xx.*zz)./3 - (yy.*zz)./3 + xy.^2./3 + xz.^2./3 + yz.^2./3)./(2.*(((((xx + yy + zz).*(xx.*yy + xx.*zz + yy.*zz - xy.^2 - xz.^2 - yz.^2))./6 - (xx + yy + zz).^3./27 + (xx.*yz.^2)./2 + (xz.^2.*yy)./2 + (xy.^2.*zz)./2 - xy.*xz.*yz - (xx.*yy.*zz)./2).^2 - ((xx + yy + zz).^2./9 - (xx.*yy)./3 - (xx.*zz)./3 - (yy.*zz)./3 + xy.^2./3 + xz.^2./3 + yz.^2./3).^3).^(1./2) - ((xx + yy + zz).*(xx.*yy + xx.*zz + yy.*zz - xy.^2 - xz.^2 - yz.^2))./6 + (xx + yy + zz).^3./27 - (xx.*yz.^2)./2 - (xz.^2.*yy)./2 - (xy.^2.*zz)./2 + xy.*xz.*yz + (xx.*yy.*zz)./2).^(1./3)) - (((((xx + yy + zz).*(xx.*yy - xz.^2 - yz.^2 - xy.^2 + xx.*zz + yy.*zz))./6 - (xx + yy + zz).^3./27 + (xx.*yz.^2)./2 + (xz.^2.*yy)./2 + (xy.^2.*zz)./2 - xy.*xz.*yz - (xx.*yy.*zz)./2).^2 - ((xx + yy + zz).^2./9 - (xx.*yy)./3 - (xx.*zz)./3 - (yy.*zz)./3 + xy.^2./3 + xz.^2./3 + yz.^2./3).^3).^(1./2) - ((xx + yy + zz).*(xx.*yy - xz.^2 - yz.^2 - xy.^2 + xx.*zz + yy.*zz))./6 + (xx + yy + zz).^3./27 - (xx.*yz.^2)./2 - (xz.^2.*yy)./2 - (xy.^2.*zz)./2 + xy.*xz.*yz + (xx.*yy.*zz)./2).^(1./3)./2 + (3.^(1./2).*(((xx + yy + zz).^2./9 - (xx.*yy)./3 - (xx.*zz)./3 - (yy.*zz)./3 + xy.^2./3 + xz.^2./3 + yz.^2./3)./(((((xx + yy + zz).*(xx.*yy + xx.*zz + yy.*zz - xy.^2 - xz.^2 - yz.^2))./6 - (xx + yy + zz).^3./27 + (xx.*yz.^2)./2 + (xz.^2.*yy)./2 + (xy.^2.*zz)./2 - xy.*xz.*yz - (xx.*yy.*zz)./2).^2 - ((xx + yy + zz).^2./9 - (xx.*yy)./3 - (xx.*zz)./3 - (yy.*zz)./3 + xy.^2./3 + xz.^2./3 + yz.^2./3).^3).^(1./2) - ((xx + yy + zz).*(xx.*yy + xx.*zz + yy.*zz - xy.^2 - xz.^2 - yz.^2))./6 + (xx + yy + zz).^3./27 - (xx.*yz.^2)./2 - (xz.^2.*yy)./2 - (xy.^2.*zz)./2 + xy.*xz.*yz + (xx.*yy.*zz)./2).^(1./3) - (((((xx + yy + zz).*(xx.*yy - xz.^2 - yz.^2 - xy.^2 + xx.*zz + yy.*zz))./6 - (xx + yy + zz).^3./27 + (xx.*yz.^2)./2 + (xz.^2.*yy)./2 + (xy.^2.*zz)./2 - xy.*xz.*yz - (xx.*yy.*zz)./2).^2 - ((xx + yy + zz).^2./9 - (xx.*yy)./3 - (xx.*zz)./3 - (yy.*zz)./3 + xy.^2./3 + xz.^2./3 + yz.^2./3).^3).^(1./2) - ((xx + yy + zz).*(xx.*yy - xz.^2 - yz.^2 - xy.^2 + xx.*zz + yy.*zz))./6 + (xx + yy + zz).^3./27 - (xx.*yz.^2)./2 - (xz.^2.*yy)./2 - (xy.^2.*zz)./2 + xy.*xz.*yz + (xx.*yy.*zz)./2).^(1./3)).*i)./2;

Ihess=reshape(Ihess,[size(Ixx,1),size(Ixx,2),size(Ixx,3)]);




% for i=1:size(Ixx,1)
%     for j=1:size(Ixx,2)
%         parfor k=1:size(Ixx,3)
%              [V,D] = eig( [ Ixx(i,j,k) Ixy(i,j,k) Ixz(i,j,k) ; Ixy(i,j,k) Iyy(i,j,k) Iyz(i,j,k)  ; Ixz(i,j,k) Iyz(i,j,k) Izz(i,j,k) ] );
%              Lambda1a(i,j,k) = D(1,1);
%              Lambda2a(i,j,k) = D(2,2);
%              Ihess(i,j,k) = D(3,3);
%              %Vx(i,j,k) = V(:,1);
%         end
%     end
% end






























