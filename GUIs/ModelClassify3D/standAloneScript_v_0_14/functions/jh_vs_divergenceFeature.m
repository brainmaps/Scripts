function [div, GF, magGF] = jh_vs_divergenceFeature(im, sigmaDiv, varargin)
%
%   result = jh_vs_divergenceFeature(im, sigmaDiv, sigmaGF)
%   result = jh_vs_divergenceFeature(im, sigmaDiv, 'GF', GF)
%   result = jh_vs_divergenceFeature(___, 'save', nameRun, nameParam)
%   result = jh_vs_divergenceFeature(___, 'anisotropic', anisotropic)
%   result = jh_vs_divergenceFeature(___, 'prefType', prefType)
%   result = jh_vs_divergenceFeature(___, 'normalize')

%% Check input

% Defaults
anisotropic = [1 1 1];
bGF = true;
saveResults = false;
prefType = class(im);
normalize = false;
% Check input
if ~isempty(varargin)
    
    i = 0;
    while i < length(varargin)
        i = i+1;
        
        if i == 1
            if strcmp(varargin{i}, 'GF')
                GF = varargin{i+1};
                bGF = false;
                i = i+1;
            else
                sigmaGF = varargin{i};
            end
        end
        
        if i > 1
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
        
    end
    
else
    
    disp('jh_vs_divergenceFeature: Parameters missing')
    return
    
end

[n1,n2,n3] = size(im);
n = n1*n2*n3;


%% Image gradient
if bGF
    [GF, magGF] = jh_dip_imageGradient3D(im, sigmaGF, 3, anisotropic);

    if normalize
        imMagGF = jh_normalizeMatrix(imMagGF);
    end
    if saveResults
        fn = jh_buildString(nameRun, '_', nameParam, '_1magGF', '.TIFF');
        saveImageAsTiff3D(magGF, fn);
    end
end


%% Divergence
div = jh_dip_divergenceFromGradient3D(GF, sigmaDiv, 3, [1 1 3]);
if normalize
    div = jh_normalizeMatrix(div);
end
if saveResults
    fn = jh_buildString(nameRun, '_', nameParam, '_divGF', '.TIFF');
    saveImageAsTiff3D(div, fn);
end


end




