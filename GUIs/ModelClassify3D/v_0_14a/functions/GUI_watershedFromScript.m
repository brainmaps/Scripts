function result = GUI_watershedFromScript(im, pWS, varargin)
%
% SYNOPSIS
%   function result = GUI_watershedFromScript(im, pWS)
%   function result = GUI_watershedFromScript(___, 'waitbar', waitbarHandle, from, to)
%   function result = GUI_watershedFromScript(___, 'prefType', prefType)
%   function result = GUI_watershedFromScript(___, 'dimensions', dimensions)
%   function result = GUI_watershedFromScript(___, 'anisotropic', anisotropic)
%
% INPUT
%   pWS: Structure
%       .preStep
%           .method
%           .bInvert
%           .bInvertRaw
%           .parameters
%       .parameters
%           .conn
%           .maxDepth
%           .maxSize
%           .dimensions
%       .scriptPath
%
% OUTPUT
%   result: Cell
%       {labWS, labSeeds, labSeedsNotCleared, calculated}

%% Check input

% Defaults
waitbarHandle = false;
prefType = 'single';
dimensions = 3;
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
    elseif strcmp(varargin{i}, 'dimensions')
        dimensions = varargin{i+1};
        i = i+1;
    elseif strcmp(varargin{i}, 'anisotropic')
        anisotropic = varargin{i+1};
        i = i+1;
    end
        
end

%%
result = cell(1, 4);

%% Calculate the desired input image

% Get feature and script names
featureName = ['WS_' pWS.preStep.method];
scriptName = [pWS.scriptPath, featureName, '.m'];

% Invert raw image
if pWS.preStep.bInvertRaw
    im = jh_invertImage(im);
end

global gWS

% Store parameters in temporary field
gWS.this.parameters = pWS.preStep.parameters;
gWS.this.mult = 3;
gWS.this.anisotropic = anisotropic;
gWS.this.image = im;
gWS.this.pWS = pWS;
% Run selected script
run(scriptName)

if pWS.preStep.bInvert
    gWS.input = jh_invertImage(gWS.input);
end

output = gWS.input;
clear -global gWS

result{4} = output;


if waitbarHandle
    waitbar( 1 * (waitbarTo - waitbarFrom) / 2 + waitbarFrom , waitbarHandle);
end

%% Watershed

[labWS, labSeeds] = jh_waterseeds3D(output, ...
    'outType', 'lab', ...
    'connectivity', pWS.parameters.conn, ...
    'maxDepth', pWS.parameters.maxDepth, ...
    'maxSize', pWS.parameters.maxSize, ...
    'calcType', [num2str(dimensions) 'D']);

result{3} = labSeeds;
% Clear everything near the borders
cnb = max(anisotropic);
cnb = cnb - anisotropic;
cnb = jh_normalizeMatrix(cnb, 1, max(anisotropic));
labSeeds = cast(jh_clearNearBorder(labSeeds, cnb(1), cnb(2), cnb(3)), prefType);

% Synchronize the cleared WS minima with the regions
% labWS = jh_vs_synchronizeMinAndWS3D(labMin, labWS);
nh = jh_getNeighborhoodFromConnectivity(pWS.parameters.conn, dimensions);
labWS = jh_regionGrowing3D(labSeeds, labWS, nh, 0, 'l', 'iterations', 0, 'prefType', prefType);
labSeeds(labWS == 0) = 0;

result{2} = labSeeds;
result{1} = labWS;

if waitbarHandle
    waitbar( 2 * (waitbarTo - waitbarFrom) / 2 + waitbarFrom , waitbarHandle);
end

end

