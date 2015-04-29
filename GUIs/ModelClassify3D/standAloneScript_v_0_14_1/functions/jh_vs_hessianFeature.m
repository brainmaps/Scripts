function [l1, l2, l3, iL1L2L3] = jh_vs_hessianFeature(im, sigmaH, varargin)
%
%   [l1, l2, l3, iL1L2L3] = jh_vs_hessianFeature(im, sigmaH)
%   [l1, l2, l3, iL1L2L3] = jh_vs_hessianFeature(___, 'save', nameRun, nameParam)
%   [l1, l2, l3, iL1L2L3] = jh_vs_hessianFeature(___, 'anisotropic', anisotropic)
%   [l1, l2, l3, iL1L2L3] = jh_vs_hessianFeature(___, 'prefType', prefType)
%   [l1, l2, l3, iL1L2L3] = jh_vs_hessianFeature(___, 'normalize')

%% Check input

% Defaults
anisotropic = [1 1 1];
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


%% Hessian

[l1, l2, l3, ~,~,~] = jh_dip_hessian3D(im, sigmaH, 3, anisotropic);
if normalize
    l1 = jh_normalizeMatrix(l1);
    l2 = jh_normalizeMatrix(l2);
    l3 = jh_normalizeMatrix(l3);
    iL1L2L3 = jh_normalizeMatrix(((1-l1) + l2 + l3) / 3);
else
    nl1 = jh_normalizeMatrix(l1);
    nl2 = jh_normalizeMatrix(l2);
    nl3 = jh_normalizeMatrix(l3);
    iL1L2L3 = ((1-nl1) + nl2 + nl3) / 3;
    clear nl1 nl2 nl3;
end

if saveResults
    fn = jh_buildString(nameRun, '_', nameParam, '_2iL1L2L3', '.TIFF');
    saveImageAsTiff3D(iL1L2L3, fn);
end


end

