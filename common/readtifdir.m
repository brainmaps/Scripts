function a=readtifdir()

filelist='*.tif';
for i = 1:size(filelist,1)
    a(:,:,i) = imread(filelist(i).name); 
end
