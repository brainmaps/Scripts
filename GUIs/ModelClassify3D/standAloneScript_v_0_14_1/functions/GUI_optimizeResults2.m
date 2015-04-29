function [data, parameters] = GUI_optimizeResults2(data, parameters)

[n1, n2, n3] = size(data.im);
n = n1*n2*n3;

%% Extract the selected vesicles and create smaller matrix
optimize.Hessian.sigma.min = 0.5;
optimize.Hessian.sigma.max = 4;

im = data.im;
labWSVesicles = data.S3.labMin;
labWSNoVesicles = data.S3.labMin;
labWSVesicles(data.WSVesicles == 0) = 0;
labWSNoVesicles(data.WSNoVesicles == 0) = 0;

posVesicles = find(labWSVesicles > 0);
posNoVesicles = find(labWSNoVesicles > 0);

sigmas = 0.5:0.1:3.5;
vesicles = cell(length(sigmas), 1);
noVesicles = vesicles;
maskVes = vesicles;
maskNoVes = vesicles;

for i = 1:length(sigmas)
    
    sizeR = (ceil(sigmas(i)*3)*2+1)+2;
    sizeC = sizeR;
    sizeD = sizeR;
    
    M = ceil(sizeR / 2);
    
    vesicles{i} = zeros(sizeR * length(posVesicles), sizeC, sizeD);
    noVesicles{i} = zeros(sizeR * length(posNoVesicles), sizeC, sizeD);
    maskVes{i} = vesicles{i};
    maskNoVes{i} = noVesicles{i};
    
    for j = 1:length(posVesicles)
%         d = ceil(positions(j) / (n1*n2));
%         c = ceil((positions(j) - (d-1)*(n1*n2)) / n1);
%         r = positions(j) - (d-1)*(n1*n2) - (c-1)*n1;
        maskVes{i}(M + (j-1)*sizeR, M, M) = 1;

        [r, c, d] = jh_getCoordinatesFromLinear(posVesicles(j), [n1, n2, n3]);
        r1 = 1 + (j-1)*sizeR;
        r2 = (j-1)*sizeR + sizeR;
        c2 = sizeR;
        d2 = sizeR;
        vesicles{i}(r1:r2, 1:c2, 1:d2) ...
            = data.im(r-M+1:r+M-1, c-M+1:c+M-1, d-M+1:d+M-1);


    end
    
    for j = 1:length(posNoVesicles)
        
        maskNoVes{i}(M + (j-1)*sizeR, M, M) = 1;

        [r, c, d] = jh_getCoordinatesFromLinear(posNoVesicles(j), [n1, n2, n3]);
        r1 = 1 + (j-1)*sizeR;
        r2 = (j-1)*sizeR + sizeR;
        c2 = sizeR;
        d2 = sizeR;
        try
            noVesicles{i}(r1:r2, 1:c2, 1:d2) ...
                = data.im(r-M+1:r+M-1, c-M+1:c+M-1, d-M+1:d+M-1);
        catch
        end
        
    end
    
end

%% Iterate through possible settings


for i = 1:length(sigmas)

    
    [~, ~, ~, ~, hessVes] = jh_vs_hessianFeature( ...
        vesicles{i}, parameters{1}{2}, sigmas(i), ...
        'anisotropic', [1 1 3], 'prefType', 'single');
    [~, ~, ~, ~, hessNoVes] = jh_vs_hessianFeature( ...
        noVesicles{i}, parameters{1}{2}, sigmas(i), ...
        'anisotropic', [1 1 3], 'prefType', 'single');
    
    hessVes(maskVes{i} == 0) = 0;
    meanHessVes = mean(hessVes(hessVes > 0));
    hessNoVes(maskNoVes{i} == 0) = 0;
    hessNoVes = hessNoVes(hessNoVes > 0);
    
    meanDiff(i) = mean(abs(hessNoVes - meanHessVes));
    
    
end

figure, plot(sigmas, meanDiff);


end