function save2skel(steplog, b, s, skelfile) %#ok<INUSL>
%SAVE2SKEL Saves steplog as a variable BbSs in skelfile and updates
%fileindex. 

%generate string & evaluate
eval(['skelfile.B', num2str(b), 'S', num2str(s), ' = steplog;'])

%update fileindex
skelfile.fileindex = [skelfile.fileindex; b, s]; 

end

