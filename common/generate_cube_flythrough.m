dirname='/Users/Shawn/WHOLE-BRAIN/20130410.membrane.striatum.10x10x30nm';
dirname=pwd;
 
cubesize=128;
[xcubes ycubes zcubes] = compute_numcubes(dirname);
xstart=floor(xcubes/2)-1;
ystart=floor(ycubes/2)-1;

zskip=1;

%outvol=uint8(zeros(128*3,128*4,128*zcubes/zskip));
outvol=uint8(zeros(128*4,128*5,128*zcubes/zskip));
   
downsamplefac=1;

 
ycount=0;
for i=1:zcubes 
    disp(i);
    ycount=0;
    for j=ystart-1:ystart+2
        ycount=ycount+1;
        xcount=0;
        for k=xstart-2:xstart+2
            xcount=xcount+1;

            xcube=int32(k-1); ycube=int32(j-1);  zcube=int32(i-1);
            pathx=[dirname filesep 'x', num2str(xcube,'%04d')];
            pathy=[pathx filesep 'y',num2str(ycube,'%04d')];
            pathz=[pathy filesep 'z',num2str(zcube,'%04d')];
            cubename=dir([pathz filesep '*.raw']);
            cubename=[pathz filesep cubename.name];
            %cubename=[pathz filesep experiment_name,'_x',num2str(xcube,'%04d'),'_y',num2str(ycube,'%04d'),'_z',num2str(zcube,'%04d'),'.raw'];

            %disp(cubename)
            fid=fopen(cubename,'r');
            cube=fread(fid);     
            fclose(fid);
            try
                cube=uint8(reshape(cube,cubesize,cubesize,cubesize));
                cube=permute(cube,[2 1 3]);
                cube=cube(:,:,1:zskip:end);
                outvol(128*(ycount-1)+1:128*ycount , 128*(xcount-1)+1:128*xcount , (i-1)*128/zskip+1:i*128/zskip ) = ...
                    cube;
                %zx_reslice((j-1)*cubesize2+1:j*cubesize2,(i-1)*cubesize2+1:i*cubesize2)=...
                 %   imresize(squeeze(cube(mod(pt(2),cubesize),:,:)),1/downsamplefac)';
            catch
            end
        end
        
    end
   
end
 
 %%
for i=1:size(outvol,3)
    figure(23),imshow(outvol(:,:,i))
end



%%
aviobj = avifile('test2.avi');
aviobj.Quality = 80;
aviobj.COMPRESSION ='None';%%color image
 
hh=figure(23)
for i =1:size(outvol,3)
    imshow(outvol(:,:,i))
    currFrame = getframe(hh);
    aviobj = addframe(aviobj,currFrame.cdata);
end
aviobj = close(aviobj);


%%

%// Will open an avi file name test.avi in local folder
aviobj = avifile('test.avi');
%// the quality of this video file
aviobj.Quality = 80;
%// compression method. See matlab manual for details.
aviobj.COMPRESSION ='None';%%color image
 
for i =1:size(outvol,3)
    %// apply image processing algorithms to the image here. 
    %// image must be in size width x height x 3
    %//  in other words, color image. 
    ..........
    ..........
    %// add image to the end of the avi file
    image=uint8(zeros(size(outvol,1),size(outvol,2),3));
    image(:,:,1)=outvol(:,:,i); 
    image(:,:,2)=outvol(:,:,i); 
    image(:,:,3)=outvol(:,:,i);
    aviobj = addframe(aviobj,image);
end
%// close the file handle.
aviobj = close(aviobj);





