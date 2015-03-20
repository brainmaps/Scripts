function gauss = jh_vs_gaussianFeature(im, sigma, varargin)
%
%   gauss = jh_vs_gaussianFeature(im, sigma)
%   gauss = jh_vs_gaussianFeature(___, 'save', nameRun, nameParam)
%   gauss = jh_vs_gaussianFeature(___, 'anisotropic', anisotropic)
%   gauss = jh_vs_gaussianFeature(___, 'prefType', prefType)
%   gauss = jh_vs_gaussianFeature(___, 'normalize')

%% Check input

% Defaults
anisotropic = [1 1 1];
bGauss = true;
saveResults = false;
prefType = class(im);
normalize = false;
% Check input
if ~isempty(varargin)
    
    i = 0;
    while i < length(varargin)
        i = i+1;
        
        if strcmp(varargin{i}, 'save')
            nameRun = varargin{i+1};
            nameParam = varargin{i+2};
            saveResults = true;
            i = i+2;
        elseif strcmp(varargin{i}, 'anisotropic')
            anisotropic = varargin{i+1};
            i = i+1;
        elseif strcmp(varargin{i}, 'prefType')
            prefType = varargin{i+1};
            i = i+1;
        elseif strcmp(varargin{i}, 'normalize')
            normalize = true;
        end
        
    end
    
else
    
    disp('jh_vs_hessianFeature: Parameters missing')
    return
    
end

[n1,n2,n3] = size(im);
n = n1*n2*n3;

%% Gaussian

if bGauss
    gauss = jh_dip_gaussianFilter3D(im, sigma, 3, anisotropic, 'normalizeKernel');
    if normalize
        gauss = jh_normalizeMatrix(gauss);
    end
    if saveResults
        if ~normalize
            saveGauss = jh_normalizeMatrix(gauss);
        else
            saveGauss = gauss;
        end
        fn = jh_buildString(nameRun, '_', nameParam, '_gauss', '.TIFF');
        saveImageAsTiff3D(saveGauss, fn);
        clear saveGauss;
    end
end

end