function [lambda1,lambda2,lambda3] = jh_hessianEigenvalues(Icc, Icr, Icd, Irr, Ird, Idd)
% Reference: O.K. Smith (1961), "Eigenvalues of a symmetric 3 x 3 matrix.",
%   Communications of the ACM 4(4):164


[n1, n2, n3] = size(Icc);


cc = double(Icc(:));
cr = double(Icr(:));
cd = double(Icd(:));
rr = double(Irr(:));
rd = double(Ird(:));
dd = double(Idd(:));

n = length(cc);

H = [permute(cc, [3 2 1]), permute(cr, [3 2 1]), permute(cd, [3 2 1]); ...
     permute(cr, [3 2 1]), permute(rr, [3 2 1]), permute(rd, [3 2 1]); ...
     permute(cd, [3 2 1]), permute(rd, [3 2 1]), permute(dd, [3 2 1])];

p1 = cr.^2 + cd.^2 + rd.^2;


q = (cc + rr + dd) / 3;
p2 = (cc - q).^2 + (rr - q).^2 + (dd - q).^2 + 2*p1;
p = sqrt(p2 / 6);
clear p1 p2

I = [1, 0, 0; ...
     0, 1, 0; ...
     0, 0, 1];
I = I(:, :, ones(n, 1));
p = permute(p, [3 2 1]);
pf = p(ones(3, 1), ones(3, 1), :);
q = permute(q, [3 2 1]);
qf = q(ones(3, 1), ones(3, 1), :);

B = (1./pf) .* (H - qf.*I);
clear pf qf

r = determinante(B) / 2;

phi = zeros(size(r));
phi(r <= -1) = pi/3;
phi(r >= 1) = 0;
phi(r > -1 & r < 1) = acos(r(r > -1 & r < 1)) / 3;

lambda1 = q + 2 * p .* cos(phi);
lambda3 = q + 2 * p .* cos(phi + (2*pi/3));
lambda2 = 3 * q - lambda1 - lambda3;

lambda1 = reshape(lambda1, n1,n2,n3);
lambda2 = reshape(lambda2, n1,n2,n3);
lambda3 = reshape(lambda3, n1,n2,n3);

end


function det = determinante(B)
    
det = B(1,1,:) .* B(2,2,:) .* B(3,3,:) ...
    + B(1,2,:) .* B(2,3,:) .* B(3,1,:) ...
    + B(1,3,:) .* B(2,1,:) .* B(3,2,:) ...
    - B(1,3,:) .* B(2,2,:) .* B(3,1,:) ...
    - B(1,2,:) .* B(2,1,:) .* B(3,3,:) ...
    - B(1,1,:) .* B(2,3,:) .* B(3,2,:);

end









