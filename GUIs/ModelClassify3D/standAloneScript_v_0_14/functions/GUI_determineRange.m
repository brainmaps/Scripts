function [rangeX, rangeY, rangeZ] = GUI_determineRange(data)

% rangeX
%   Get list of folders in the main folder (define the range for x)
d = dir(data.folder);
isub = [d(:).isdir]; % # returns logical vector
nameFoldsX = {d(isub).name}';
nameFoldsX(ismember(nameFoldsX,{'.','..'})) = [];
%   Get range
rangeX = [str2double(nameFoldsX{1}(2:end)), str2double(nameFoldsX{end}(2:end))];

% rangeY
d = dir([data.folder, filesep, nameFoldsX{1}]);
isub = [d(:).isdir]; % # returns logical vector
nameFoldsY = {d(isub).name}';
nameFoldsY(ismember(nameFoldsY,{'.','..'})) = [];
%   Get range
rangeY = [str2double(nameFoldsY{1}(2:end)), str2double(nameFoldsY{end}(2:end))];

% rangeZ
d = dir([data.folder, filesep, nameFoldsX{1}, filesep, nameFoldsY{1}]);
isub = [d(:).isdir]; % # returns logical vector
nameFoldsZ = {d(isub).name}';
nameFoldsZ(ismember(nameFoldsZ,{'.','..'})) = [];
%   Get range
rangeZ = [str2double(nameFoldsZ{1}(2:end)), str2double(nameFoldsZ{end}(2:end))];


end