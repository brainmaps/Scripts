function [listedWS, listedSeeds] = GUI_labeledWS2Listed(labWS, labSeeds, connectivity, varargin)
%
% INPUT
%   labWS: labeled watershed regions
%   labSeeds: labeled seed points
%   connectivity: 8, 16, ...

%% Check input

% Defaults
waitbarHandle = false;
% Check input
i = 0;
while i < length(varargin)
    i = i+1;
    
    if strcmp(varargin{i}, 'waitbar')
        waitbarHandle = varargin{i+1};
        waitbarFrom = varargin{i+2};
        waitbarTo = varargin{i+3};
        i = i+3;
    end
        
end

%%

CC = bwconncomp(labWS, connectivity); 

% Contains the positions of the watershed basins for each included voxel
listedWS.positions = permute(CC.PixelIdxList, [2 1]);
% Create a list of the labels of each basin
listedWS.labels = cellfun(@(v) v(1), listedWS.positions(:));
listedWS.labels = labWS(listedWS.labels);
% Sort the basins according their label
[listedWS.labels, index] = sort(listedWS.labels);
listedWS.positions = listedWS.positions(index);

% Find the seeds 
listedSeeds.positions = find(labSeeds > 0);
% Create reference label vector again to sort the entries according to
% above
listedSeeds.labels = labWS(listedSeeds.positions);
[listedSeeds.labels, index] = sort(listedSeeds.labels);
listedSeeds.positions = listedSeeds.positions(index);
% Make sure every region contains only one seed
[listedSeeds.labels, ia, ~] = unique(listedSeeds.labels);
listedSeeds.positions = listedSeeds.positions(ia);

% The size of each basin
listedWS.sizes = cellfun(@numel,listedWS.positions);

if waitbarHandle
    waitbar( 1 * (waitbarTo - waitbarFrom) / 1 + waitbarFrom , waitbarHandle);
end


end