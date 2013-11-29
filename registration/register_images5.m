%function register_images5
%includes 5-subregion stitching
%HOWTO: script consists of 2 parts. First part computes pairwise image offsets. Second applies offsets, 
%which can be filtered to remove debris, to output registered images
%author: Shawn Mikula

%warning('off', 'all');
%clear all

%disp('starting pause');pause(600);

genoffsets=1;  % this is first part of script
writeimages=1;  % this is second part
drawfigs=0;
regerrorthres=0.5 %0.3   This is threshold used for debris detection.

registrationdownsamplefactor=2; %use power of 2;

writesmallimages=1;  %writes cropped registered images, in order to better assess registration accuracy manually
outputmagmax=500; %maximum pixel shift to make or else ignore (prevents problems from debris)
%histothres_upper=160;  %upper threshold for debris detection
%histothres_upper=255;  %upper threshold for debris detection
histodelta=200; % if mean histogram value outside range of mean +/- histodelta, then debris detected

checkfilevalidity=0;

%filefilter='*.tif';
%filefilter='*.jpg';

invertimages=0;
applyfilter=1;  %apply filter (histonorm) to images)

outdir='output';

 
%usesubimage=1;  Now set to 1 always  ....  % set to 1 to use subimage for registration
subimage_size=1024; 
crop=[30 1 1 1]; %amount to crop image. Top Bottom Left Right

downsamplefactor=1; %amount to downsample output images


try
    matlabpool close force local
    try
        matlabpool open 70
    catch
        matlabpool open 4
    end
catch
end



if genoffsets

    %filelist=dir(filefilter); 
    filelist=[dir('*.tif'); dir('*.jpg')];
    
    
    
    %CHECKS FILE VALIDITY
    if checkfilevalidity
        disp('starting file validity check (showing invalid files)');
        for i=1:length(filelist)
            try
                temp=imfinfo(filelist(i).name);
                %temp(1).UnknownTags.Value shows xml metadata
                %temp(1).Width
            catch
                disp(filelist(i).name);
            end
        end
        disp('finishing file validity check');
    end
    
    
    outputmaghold=[];
    
    outputhold=[]; 
    outputholdall=[]; %includes debris offsets
    outputholdabs=[]; %zeros(length(filelist)-1,2);
     

    outputhold2=zeros(2,1);
    updateprev=1;

    for i=1:length(filelist)

        disp([num2str(i) '     ' filelist(i).name]); 
        try
            if invertimages
                img = 255-imread(filelist(i).name);
            else
                img = imread(filelist(i).name);
            end
        catch
            try
                pause(5);
                if invertimages
                    img = 255-imread(filelist(i).name);
                else
                    img = imread(filelist(i).name);
                end
            catch
                disp('problem reading in image');
            end
        end
        
        if i>1 && updateprev
            imsmallprev=imsmalltemp;
        end

        [height,width]=size(img);
        
 
 
        coordstart=[min((height-subimage_size)/2) min((width-subimage_size)/2)];
        %coordend=[min((height+subimage_size)/2) min((width+subimage_size)/2)]
        imsmall(:,:,1)=imresize( img(coordstart(1)+1:coordstart(1)+subimage_size,coordstart(2)+1:coordstart(2)+subimage_size) , 1/registrationdownsamplefactor); 
        
        imsmall(:,:,2)=imresize( img( crop(1)+1: crop(1)+subimage_size, crop(2)+1: crop(2)+subimage_size ) , 1/registrationdownsamplefactor);         
        imsmall(:,:,3)=imresize( img( crop(1)+1: crop(1)+subimage_size, end-crop(3)-subimage_size+1: end-crop(3)) , 1/registrationdownsamplefactor);         
        imsmall(:,:,4)=imresize( img( end-crop(4)-subimage_size+1: end-crop(4), crop(2)+1: crop(2)+subimage_size ) , 1/registrationdownsamplefactor);         
        imsmall(:,:,5)=imresize( img( end-crop(4)-subimage_size+1: end-crop(4), end-crop(3)-subimage_size+1: end-crop(3)) , 1/registrationdownsamplefactor);         
        
        parfor j=1:5
            imsmalltemp(:,:,j)=imenhance(imsmall(:,:,j));
        end
        
        %imsmalltemp=histeq(imsmall);    %adapthisteq
        %imsmalltemp=edge(histeq(imsmall));    %adapthisteq
        %imsmalltemp=computeHess2d(histeq(imsmall));

        outputvec=[];  
        if (i>1)
            parfor j=1:5
                [output Greg] = dftregistration(fft2(imsmallprev(:,:,j)),fft2(imsmalltemp(:,:,j)),100);
                outputvec(j,:)=output;
                outputmag(j)=(output(3)^2+output(4)^2)^(.5);
            end
                %outputmaghold=[outputmaghold; outputmag];

            
            %if outputmag > outputmagmax || mean(mean(img)') > histothres_upper
            %if outputmag > outputmagmax || mean(mean(img)') > histomean+histodelta || mean(mean(img)') < histomean-histodelta 
            if max(outputvec(:,1))>regerrorthres
                disp(['Debris Detected!  Skipping file: ' filelist(i).name '  max reg error:  ' num2str(max(outputvec(:,1)))])
                updateprev=0;
                outputholdall=[outputholdall; i outputvec(1,:) outputvec(2,:) outputvec(3,:) outputvec(4,:) outputvec(5,:)];
            else
                outputhold2=outputhold2+[median(outputvec(:,3)) median(outputvec(:,4))]*registrationdownsamplefactor;
                outputholdabs=[outputholdabs; round(outputhold2)];
%                 if mod(i,5)==1
%                     figure(393),plot(outputholdabs(:,2),-outputholdabs(:,1)), grid on,ylabel('yshift (abs)'),xlabel('xshift (abs)')
%                 end
                outputhold=[outputhold; i outputvec(1,:) outputvec(2,:) outputvec(3,:) outputvec(4,:) outputvec(5,:)]  ;  % sqrt(var(var(img*255)')) 
                outputholdall=[outputholdall; i outputvec(1,:) outputvec(2,:) outputvec(3,:) outputvec(4,:) outputvec(5,:)];
                disp(outputhold2);
                updateprev=1;            
            end
            
            if drawfigs
                if mod(i,5)==1
                    %figure(1);plot(outputmaghold); title('registration offset')
                    figure(2);plot([outputholdall(:,2) outputholdall(:,6) outputholdall(:,10) outputholdall(:,14) outputholdall(:,18) ]  ); title('registration error')
                    %figure(3);plot(outputhold(:,5)); title('mean intensity')
                    %figure(4);plot(outputhold(:,6)); title('std')
                end            
            end
            

        else
            [height,width]=size(img);
            outputvec=zeros(5,4);
            outputhold2=zeros(1,2);
            outputholdabs=zeros(1,2);
            outputhold=[i zeros(1,20)] ;            %sqrt(var(var(imsmall)'))
            outputholdall=[i zeros(1,20)] ;
        end

            %imsmallout=zeros(round(height+2*padding),round(width+2*padding));
            %imsmallout(padding+1+outputhold2(1):padding+height+outputhold2(1),padding+1+outputhold2(2):padding+width+outputhold2(2))=adapthisteq(img); %imsmalltemp;

    end

    save outputholdabs outputholdabs outputhold outputholdall filelist height width
    %figure(333),imshow(reslice,[]);

end













if writeimages
    
    load outputholdabs outputholdabs outputhold filelist height width
    
 
   
    mkdir(outdir);
    if writesmallimages
        mkdir([outdir '.cropped'])
    end
    
    
    padding=[ -(min(outputholdabs)<0).*min(outputholdabs)    (max(outputholdabs)>0).*max(outputholdabs) ];
    
 
    for i=1:size(outputhold,1)
        %fn_input=filelist(outputhold(i,1)).name;
          
        disp(i); 
        try
            if invertimages
                img2 = 255-imread(filelist(outputhold(i,1)).name);
            else
                img2 = imread(filelist(outputhold(i,1)).name);
            end
        catch
            try
                pause(5);
                if invertimages
                    img2 = 255-imread(filelist(outputhold(i,1)).name);
                else
                    img2 = imread(filelist(outputhold(i,1)).name);
                end
            catch
                disp('problem reading in image');
            end
        end
    
        
        %imMax = max(img(:));
        %imMin = min(img(:));
        %img = ((img-imMin)/(imMax-imMin));
        %img=imadjust(img);
        if applyfilter
            %img2=imenhance(img2);
            img2=imadjust(img2,stretchlim(img2(100:end,100:end), [0.02 0.998]));
            %img=gammacorrection(img,2);
        end
        

        disp([num2str(outputholdabs(i,1)) '  ' num2str(outputholdabs(i,2))  '  ' filelist(outputhold(i,1)).name]);

        imsmallout=uint8(ones(height+abs(padding(1))+padding(3), width+abs(padding(2))+padding(4))).*255;
        imsmallout(abs(padding(1))+1+outputholdabs(i,1):abs(padding(1))+height+outputholdabs(i,1), ...
            abs(padding(2))+1+outputholdabs(i,2):abs(padding(2))+width+outputholdabs(i,2))=img2;  %adapthisteq(img); %imsmalltemp;


        fname=[filelist(outputhold(i,1)).name '.tif'];
        try
            imwrite(imsmallout,[outdir '/' fname],'TIFF');
            if writesmallimages
                imwrite( imsmallout(floor(size(imsmallout,1)/2-255): floor(size(imsmallout,1)/2+256), ...
                    floor(size(imsmallout,2)/2-255): floor(size(imsmallout,2)/2+256)  )   ,[outdir '.cropped/' fname],'TIFF');
            end
        catch
            disp('failed to write TIFF: trying again');
            pause(5);
            try
                imwrite(imsmallout,[outdir '/' fname],'TIFF');
            catch
            end
        end        
        
        
        
        
    end
    
end



try
    matlabpool close force local
catch
end




 



