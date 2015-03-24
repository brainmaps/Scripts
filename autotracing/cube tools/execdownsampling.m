segpath = '/Users/nasimrahaman/Documents/MATLAB/MPI/Myelin/data/20130318.membrane.ctx.40nm-seg';
dspath = [segpath '-ds'];

tic;
cubeprocessor(segpath, dspath, @downsamplecube, 'cube');
toc

