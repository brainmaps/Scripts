function array2tifstack(matarray,fname)

%minval=min(matarray(:));
%matarray=(matarray - minval )./(max(matarray(:)) - minval ) ;
 
imwrite(matarray(:,:,1),fname,'tif','Compression','none','WriteMode','overwrite');
for i=2:size(matarray,3)
    imwrite(matarray(:,:,i),fname,'tif','Compression','none','WriteMode','append');
end
end

 