function status = initDipImage(folder)
%
% INPUT
%   folder: Main folder of DIPimage library, 
%       e.g. 'C:\Program Files\DIPimage 2.5.1\'

% Try to initialize the Dip library
try
    
    warning off
    try
        addpath([folder 'common\dipimage']);
    catch
    end
    warning on
    evalc('dip_initialise;');
    
    fprintf('Dip library found and loaded successfully.\n');
    
    status = 1;
    
catch
    
    close(handles.figMain);
    
    fprintf('\nERROR: Dip library not found. \n');
    
    status = 0;
    
end


end
