function [result, resultNames] = GUI_postProcessingFromScript(im, pPP, WS, data, features, classification, varargin)
%
% INPUT
%   pPP: Structure
%       .method
%       .parameters
%       .dimensions
%       .WS
%       .data
%       .features
%       .scriptPath


%% Check input

% Defaults
waitbarHandle = false;
prefType = 'single';
% Check input
i = 0;
while i < length(varargin)
    i = i+1;
    
    if strcmp(varargin{i}, 'waitbar')
        waitbarHandle = varargin{i+1};
        waitbarFrom = varargin{i+2};
        waitbarTo = varargin{i+3};
        i = i+3;
    elseif strcmp(varargin{i}, 'prefType')
        prefType = varargin{i+1};
        i = i+1;
    elseif strcmp(varargin{i}, 'anisotropic')
        anisotropic = varargin{i+1};
        i = i+1;
    end
        
end

%%

% Get feature and script names
featureName = ['PP_' pPP.method];
scriptName = [pPP.scriptPath, featureName, '.m'];

global gPP

% Store parameters in temporary field
gPP.parameters = pPP.parameters;
gPP.mult = 3;
gPP.anisotropic = anisotropic;
gPP.image = im;
gPP.WS = WS;
gPP.data = data;
gPP.features = features;
gPP.classification = classification;
% Run selected script
run(scriptName)

result = gPP.result;
resultNames = gPP.resultNames;
clear -global gPP

if waitbarHandle
    waitbar( 1 * (waitbarTo - waitbarFrom) / 1 + waitbarFrom , waitbarHandle);
end


end