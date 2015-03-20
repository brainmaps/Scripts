function [lambda1,lambda2,lambda3] = jh_hessianEigenvalues(Icc, Icr, Icd, Irr, Ird, Idd)
% Reference: O.K. Smith (1961), "Eigenvalues of a symmetric 3 x 3 matrix.",
%   Communications of the ACM 4(4):164


[n1, n2, n3] = size(Icc);


Icc = Icc(:);
Icr = Icr(:);
Icd = Icd(:);
Irr = Irr(:);
Ird = Ird(:);
Idd = Idd(:);

n = length(Icc);


p1 = Icr.^2 + Icd.^2 + Ird.^2;
% H = [permute(Icc, [3 2 1]), permute(Icr, [3 2 1]), permute(Icd, [3 2 1]); ...
%      permute(Icr, [3 2 1]), permute(Irr, [3 2 1]), permute(Ird, [3 2 1]); ...
%      permute(Icd, [3 2 1]), permute(Ird, [3 2 1]), permute(Idd, [3 2 1])];
% clear Icr Icd

q = (Icc + Irr + Idd) / 3;
p2 = (Icc - q).^2 + (Irr - q).^2 + (Idd - q).^2 + 2*p1;
% clear Icc Irr Idd p1

p = sqrt(p2 / 6);
clear p2

p = permute(p, [3 2 1]);
q = permute(q, [3 2 1]);

B = [(1/p).*(permute(Icc, [3 2 1])-q), (1/p).*(permute(Icr, [3 2 1])), (1/p).*(permute(Icd, [3 2 1])); ...
           (1/p).*(permute(Icr, [3 2 1])), (1/p).*(permute(Irr, [3 2 1])-q), (1/p).*(permute(Ird, [3 2 1])); ...
           (1/p).*(permute(Icd, [3 2 1])), (1/p).*(permute(Ird, [3 2 1])), (1/p).*(permute(Idd, [3 2 1])-q)];
clear Icc Icr Icd Irr Ird Idd
% B = (1./p(ones(3, 1), ones(3, 1), :)) .* (HminusI);
% clear HminusI


r = (B(1,1,:) .* B(2,2,:) .* B(3,3,:) ...
    + B(1,2,:) .* B(2,3,:) .* B(3,1,:) ...
    + B(1,3,:) .* B(2,1,:) .* B(3,2,:) ...
    - B(1,3,:) .* B(2,2,:) .* B(3,1,:) ...
    - B(1,2,:) .* B(2,1,:) .* B(3,3,:) ...
    - B(1,1,:) .* B(2,3,:) .* B(3,2,:)) /2;
clear B

phi = zeros(size(r));
phi(r <= -1) = pi/3;
phi(r >= 1) = 0;
phi(r > -1 & r < 1) = acos(r(r > -1 & r < 1)) / 3;
clear r;

lambda1 = q + 2 * p .* cos(phi);
lambda3 = q + 2 * p .* cos(phi + (2*pi/3));
clear p phi
lambda2 = 3 * q - lambda1 - lambda3;
clear q

lambda1 = reshape(lambda1, n1,n2,n3);
lambda2 = reshape(lambda2, n1,n2,n3);
lambda3 = reshape(lambda3, n1,n2,n3);
% 
% lambdas(:,:,:,1) = lambda1;
% lambdas(:,:,:,2) = lambda2;
% lambdas(:,:,:,3) = lambda3;
% 
% % [~, I] = sort(abs(lambdas), 4);
% % lambda1 = lambdas(:, :, :, I(:, :, :, 1));
% 
% 
% A = abs(lambdas);
% 
% B = A; %// Start with same values so we can programmatically check result
% 
% [~, ix4] = sort(A,4);
% %// ix4 is the index along dimension 4, and we want dimension 1, 2, and 3 to remain unchanged
% ix1 = repmat((1:size(A, 1))', [1, size(A, 2), size(A, 3), size(A, 4)]); %//'
% ix2 = repmat(1:size(A, 1), [size(A, 1), 1, size(A, 3), size(A, 4)]);
% ix3 = repmat(permute(1:size(A, 1), [1, 3, 2]), [size(A, 1), size(A, 2), 1, size(A, 4)]);
% 
% % ix1 = sub2ind([size(A, 1), size(A, 2), size(A, 3)], ix1, ix2, ix3, ix4(:,:,:,1));
% 
% %// Convert to linear index equivalent of the reordering of the sort() call
% ix = ix1 + size(A, 1)*(ix2-1) + size(A, 1)*size(A, 2)*(ix3-1) + size(A, 1)*size(A, 2)*size(A, 3)*(ix4-1);
% 
% %// And apply it
% B2 = B(ix);
% % ok = isequal(A2, B2) %// confirm reordering% 
% 
% lambda1 = B2(:,:,:,1);
% lambda2 = B2(:,:,:,2);
% lambda3 = B2(:,:,:,3);
% % 
% % lambda1 = lambdas(:,:,:,1);
% % lambda2 = lambdas(:,:,:,2);
% % lambda3 = lambdas(:,:,:,3);

end


function det = determinante(B)
    
det = B(1,1,:) .* B(2,2,:) .* B(3,3,:) ...
    + B(1,2,:) .* B(2,3,:) .* B(3,1,:) ...
    + B(1,3,:) .* B(2,1,:) .* B(3,2,:) ...
    - B(1,3,:) .* B(2,2,:) .* B(3,1,:) ...
    - B(1,2,:) .* B(2,1,:) .* B(3,3,:) ...
    - B(1,1,:) .* B(2,3,:) .* B(3,2,:);

end









