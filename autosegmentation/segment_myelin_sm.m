%% Myelin Segmentation 1
%cd 'D:\Dropbox\SCRIPTS\MATLAB\segtest'
%load simondata
%J:\_MOUSE_PROJECTOME\STACKS\20130318\st001\output
filelist=dir('*.tif');
mkdir('output-otsu');
for j=1:length(filelist)
    %f=double(imread(filelist(j).name)) ;
    f=medfilt2( double(imread(filelist(j).name)) ,[2 2]);
    numclust=5;
    f2=f(:);
    %kout=kmeans(f(:),numclust,'EmptyAction','drop','Replicates',5);
    kout=otsu(f(:),numclust);
    kout2=reshape(kout,[size(f,1),size(f,2),size(f,3)]);
    figure,imshow(kout2(:,:,1),[])
    clustmeans=[];
    for i=1:numclust
        clustmean(i)=mean(f(kout==i));
    end
    myelinmap=kout2==find(clustmean==min(clustmean));
    %figure,imshow(myelinmap(:,:,1),[])    
    imwrite(myelinmap, ['output-otsu' filesep filelist(j).name], 'tif' );
end
    
cd 'output'
    
%% Myelin Segmentation 2

filelist=dir('*.tif');
mkdir('output');

%Read everything into memory for conncomp 3D
%outhold=logical([]);
%for j=1:length(filelist)
%    outhold(:,:,j)=imread(filelist(j).name)>1;
%end

for j=1:length(filelist)
    disp(j)
    f=imread(filelist(j).name)>0;
    %f=medfilt2( double(imread(filelist(j).name)) ,[3 3]);
    f = bwareaopen( f , 50, 4);
    
    disp(['writing:  ' filelist(j).name])
    imwrite(f, ['output' filesep filelist(j).name], 'tif' );  
    %imwrite(f*256, ['output' filesep filelist(j).name], 'tif' );   
end
    

%se = strel('disk',1);
%outhold2= imopen(outhold,se);

%outhold2 = bwareaopen( outhold , 200, 6);  

%f=bwareaopen( double(imread(filelist(j).name))>1 , 30, 4); 

%Read everything into memory for conncomp 3D
%for j=1:length(filelist)
%     imwrite(outhold2(:,:,j)*256, ['output' filesep filelist(j).name], 'tif' );    
% end
    
    
    

%% Myelin Segmentation 3 (Downsample segmentation for visualization)

filelist=dir('*.tif');
mkdir('output-small2');


for j=1:2:length(filelist)
    disp(j)
    try 
        f1=single(imread(filelist(j).name));
        f2=single(imread(filelist(j+1).name));
        f=uint8(imresize((f1+f2)./2,.5)); %>200;
        imwrite(f, ['output-small2' filesep filelist(j).name], 'tif' );  
    catch
    end 
end

%% Myelin Segmentation 4 (Run conncomp in 3D for downsampled stack

filelist=dir('*.tif');
mkdir('output-conn3d');
outhold=logical([]);
for j=1:length(filelist)
   outhold(:,:,j)=imread(filelist(j).name)>.9;
end
outhold2 = bwareaopen( outhold , 400, 6);  
for j=1:length(filelist)
    imwrite(outhold2(:,:,j), ['output-conn3d' filesep filelist(j).name], 'tif' );    
end

