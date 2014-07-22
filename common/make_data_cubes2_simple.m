%function make_data_cubes2_simple(experiment_name, res, nfiles,downsamplefactor)
experiment_name='BRAX-striatum-20nm-isotropic-deconvolved', res=[20 20 20],downsamplefactor=1
%function make_data_cubes2_simple
%res = res of orig data
% downsamplefactor = 1,2,4,etc..
% experiment_name='striatum.substack';
% experiment_name='skm_thinCutting7_06_mag1';
% experiment_name='skm_thinCutting7_06_avg3_mag1';
% experiment_name='2012-10-20.20nm.1024px';
% experiment_name='2013-02-20';
% experiment_name='20130410.membrane.striatum.10nm';
% experiment_name='20130408.cytoplasm.ctx.40nm';
% 
% 
%  
% xres=40;yres=40;zres=40  %original acquisition resolution in nm
%xres=10;yres=10;zres=30  %original acquisition resolution in nm
%xres=27;yres=27;zres=27  %original acquisition resolution in nm
%xres=20;yres=20;zres=30  %original acquisition resolution in nm

nfiles=128; %nfiles must be equal to cubesize or bad things happen
cubesize=128;

res=res*downsamplefactor;
xres=res(1);yres=res(2);zres=res(3);

blankgendo=1;  %for executing blankgen()

%experiment_name=[experiment_name '_mag' num2str(downsamplefactor)];
 
%nfiles=16;   %number of files to load simultaneously. Should be factor of cubesize

 

filelist=[dir('*.tif'); dir('*.jpg')];
%filelist=filelist(1:downsamplefactor:end);
totalfiles=length(filelist);

%a=imresize(imread(filelist(3).name),1/downsamplefactor);
a = imread(filelist(3).name);
%a = imresize(a, 1/downsamplefactor ,'Method','bicubic','Antialiasing',false); %'lanczos2' 
%a = a(1:downsamplefactor:end,1:downsamplefactor:end);
%a = a(1:2:end,1:2:end);
[height,width]=size(a);  

blanks=ceil(totalfiles/(cubesize)) * (cubesize) - totalfiles;
if (blankgendo)
    if downsamplefactor==1
        %blanksgen(width,height,blanks,''); 
        fnprefix='';
        blankswrite=uint8(ones(height,width));  
        for i=1:blanks
               %imwrite(blankswrite,[fnprefix,sprintf('%05d',start+i),'.tif'],'TIFF');
               imwrite(blankswrite,['zzz_blank-',fnprefix,sprintf('%05d',i),'.tif'],'TIFF');
        end
    end
end

experiment_name=[experiment_name '_mag' num2str(downsamplefactor)];
mkdir([experiment_name]);

numslices=totalfiles;


%cubeimagestack(pwd,'',experiment_name,1,width,height,cubesize,xres,yres,zres,numslices);

          
        
    
    


%cd('D:\Program Files\MATLAB\R2010a');












dirstem=pwd;
dirpath='';
magnum=1;



%function cubeimagestack(dirstem,dirpath,experiment_name,magnum,width,height,cubesize,xres,yres,zres,numslices)

    %stackdirbase= 'F:\_MOUSE_PROJECTOME\STACKS\2010-09-24-external-capsule';  
    stackdirbase=[dirstem filesep dirpath];
    %basefilename='2010-09-24-external-capsule-2x'; %experiment name
    basefilename=[experiment_name]; %experiment name
    stackname='';
    savedirname=[experiment_name];
    %width=2048;height=1768;numSlices=1792;xres=40;yres=40;zres=40;mag=1;
    numslices=ceil(numslices/cubesize)*cubesize; 
    xres=round(xres*magnum);yres=round(yres*magnum);zres=round(zres*magnum);
    %width=683; height=590;numSlices=640;xres=120;yres=120;zres=120;mag=3;

    stackdirs = stackdirbase;
    %[s,msg,msgid]=mkdir([stackdirbase,'\',savedirname]);

    [stackdirbase,filesep,savedirname,filesep 'knossos.conf']
    fid=fopen([stackdirbase,filesep,savedirname,filesep 'knossos.conf'],'w');
    knossos=['experiment name "',experiment_name,'";\n scale x ',sprintf('%9.1f',xres),';\n scale y ',sprintf('%9.1f',yres),';\n scale z ',sprintf('%9.1f',zres),';\n boundary x ',num2str(width),';\n boundary y ',num2str(height),';\n boundary z ',num2str(numslices),';\n magnification ',num2str(downsamplefactor),';'];
    fprintf(fid,knossos);   
    fclose(fid);fclose('all');



    %cubesize = 128; 

    savedir = [stackdirbase filesep savedirname filesep];

    %stackdirs
   % cd(stackdirs);

    fclust=ceil(totalfiles/nfiles)   %number of file clusters

    numx=ceil(width/cubesize);numy=ceil(height/cubesize);

    fcount=0;
    debugmat=[];

    for (i=1:fclust)  
        i
        tic
        fclose('all');
        a=uint8(zeros(max(cubesize*numy,height),max(cubesize*numx,width),nfiles))+255;
        for(j=1:nfiles)
            fcount=(i-1)*nfiles+j;
            if fcount<=totalfiles
                %(i-1)*nfiles+j
                %filelist((i-1)*fclust+j).name
                if j==1
                    %disp(filelist((i-1)*nfiles+j).name)
                end
                try
                    disp(filelist((i-1)*nfiles+j).name)
                    a_temp=imread(filelist((i-1)*nfiles+j).name);
                    a_temp=imresize(a_temp,1/downsamplefactor);
                    %a_temp=a_temp(1:2:end,1:2:end);
                    a(1:size(a_temp,1),1:size(a_temp,2),j)=a_temp;
                    %figure(1),imagesc(a(:,:,j));
                catch err
                    disp('problem reading file');
                    disp(err.identifier);
                end
            else
                disp('Error: fcount greater than totalfiles');
            end
        end

        %a=uint8([a, zeros(height,cubesize-rem(width,cubesize),nfiles)]);
        %a=uint8([a; zeros(cubesize-rem(height,cubesize),width+cubesize-rem(width,cubesize),nfiles)]); 
        %size(a);

        z2=floor((i*nfiles-1)/cubesize);
        for (x2=1:numx)
            for (y2=1:numy)

                x2=int32(x2);y2=int32(y2);z2=int32(z2);

                pathx=[stackdirbase,filesep,savedirname,filesep 'x', num2str(x2-1,'%04d')];
                pathy=[pathx,filesep 'y',num2str(y2-1,'%04d')];
                pathz=[pathy,filesep 'z',num2str(z2,'%04d')];
                cubename=[pathz,filesep,basefilename,'_x',num2str(x2-1,'%04d'),'_y',num2str(y2-1,'%04d'),'_z',num2str(z2,'%04d'),'.raw'];
                
                if x2==1 && y2==1
                    %disp(cubename);
                end

                debugmat=[debugmat;i,x2-1,y2-1,z2];

                %tempcube=zeros(cubesize,cubesize,cubesize)+;
                [s,msg,msgid]=mkdir(pathz);


                %[1+(x2-1)*cubesize x2*cubesize 1+(y2-1)*cubesize y2*cubesize rem(1+(i-1)*nfiles,cubesize) rem(i*nfiles,cubesize)]
                try
                    if mod(fclust*nfiles,cubesize)==nfiles;
                        fid=fopen(cubename,'a');
                    else
                        fid=fopen(cubename,'A');
                    end
                    %disp(cubename)
                    %cnt=fwrite(fid, a(1+(x2-1)*cubesize:x2*cubesize, 1+(y2-1)*cubesize:y2*cubesize, 1:nfiles)); %rem(1+(i-1)*nfiles,cubesize):rem(i*nfiles,cubesize)
                    cnt=fwrite( fid, permute(a(1+(y2-1)*cubesize:y2*cubesize, 1+(x2-1)*cubesize:x2*cubesize, 1:nfiles),[2 1 3]), 'uint8'  );  %rem(1+(i-1)*nfiles,cubesize):rem(i*nfiles,cubesize)
                    fclose(fid);
                    %fclose('all');
                catch 
                    disp('problem writing file');
                end
            end
        end

    toc
    end			
%end












 
