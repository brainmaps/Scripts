%function knossos2stack(knossosdir)
%converts knossos cubes to tif stack

knossosdir='M:\smikula\IMAGES\20130506\st001\output\20130506-interareal_mag8';
basefilename='20130506-interareal_mag8'

knossosdir='M:\isonntag\Simon\20130318.myelinseg.otsu_final\';
basefilename='20130318.myelinseg.otsu_final';

cd(knossosdir)
numx=length(dir('x*'));
numy=length(dir('x0000/y*'));
numz=length(dir('x0000/y0000/z*'));
%mkdir('../output-stack-from-knossoscubes')
mkdir('M:\smikula\IMAGES\simon-output\');

 
slicenum=0;
cubesize=128;

for z2=0:0%numz-1
    a=zeros(numy*128,numx*128,128);
    for x2=0:numx-1
        for y2=0:numy-1
            pathx=[knossosdir,filesep 'x', num2str(x2,'%04d')];
            pathy=[pathx,filesep 'y',num2str(y2,'%04d')];
            pathz=[pathy,filesep 'z',num2str(z2,'%04d')];
            cubename=[pathz,filesep,basefilename,'_x',num2str(x2,'%04d'),'_y',num2str(y2,'%04d'),'_z',num2str(z2,'%04d'),'.raw'];
            disp(cubename);
            fid=fopen(cubename,'r');
            cube=fread(fid,cubesize^3);
            fclose(fid);
            cube=reshape(cube,cubesize,cubesize,cubesize);
            %figure(232),imshow(cube(:,:,64))
            a(1+y2*128:(y2+1)*128,1+y2*128:(y2+1)*128,:)=cube;
        end
    end
    for i=1:128
        slicenum=slicenum+1;
        imout=a(:,:,i);
        %imwrite(imout,['../output-stack-from-knossoscubes/' num2str(slicenum,'%06d') '.tif']);
        imwrite(imout,['M:\smikula\IMAGES\simon-output\' num2str(slicenum,'%06d') '.tif']);
    end
end















