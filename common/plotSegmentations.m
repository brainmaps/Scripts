
s.a=nii_read_volume('D:\SEGMENTATIONS\sarah-output.nii');
%%
temp=s.a(200:800,200:800,200:800);
temp=s.a;
temp=temp(1:4:end,1:4:end,1:4:end);
%figure,isosurface(temp,temp)
figure,isosurface(temp,temp)
colormap lines,xlabel('x'),ylabel('y');view([-25 36]),daspect([1,1,1]),%camlight('infinite')


    
%%
%figure
cmap = rand(max(supercube(:)),3); 
%cmap = lines(76);
%cmap= linspecer(16,'qualitative');
%b=temp2;
%b=temp2(1:1:end,1:1:end,1:1:end);

for i=1:max(supercube(:))
    disp(i)
    try
    b_new=supercube;
    b_new=single(b_new);
    %b_new(b_new>2)=b_new(b_new>2)+40;
    %b_new(b_new<1)=NaN;
    b_new(b_new<i)=NaN;
    b_new(b_new>i)=NaN;
    b_new(b_new==i)=1;
    if sum(b_new(:)==1)>100
        figure(999)
        p = PATCH_3Darray(b_new,cmap(i,:),'col');
        view(3),xlabel('x'),ylabel('y'),zlabel('z'),daspect([1 1 1]),
        xlim([0 size(supercube,1)]),ylim([0 size(supercube,2)]),zlim([0 size(supercube,3)]),
        %pause(3),
        hold off;%clf
        %camlight; lighting gouraud %phong
        %colormap lines
    end
    catch,end
end

%%
b_new=uint16(b);
b_new(b_new==2)=120;
%b_new2=(b_new==2); b_new(b_new==2)=0;
[M,N,P]=size(b);
[x y z] = meshgrid(1:N, 1:M, 1:P);%x=single(x);y=single(y);z=single(z);
%[F,V,col]=isosurface(x,y,z,b_new,.9,b_new);
%figure,p=patch('vertices',V,'faces',F); %,'FaceVertexCData',col
figure
p=patch(isosurface(x,y,z,b_new,.9,b_new));
isonormals(x,y,z,b_new,p);
isocolors(x,y,z,b_new,p);
set(p,'FaceColor','flat','EdgeColor','none');
view(3),daspect([1,1,1/3]),xlabel('x'),ylabel('y'),zlabel('z')
camlight; lighting gouraud %phong
colormap lines

%%
[F,V,col] = MarchingCubes(single(x),single(y),single(z),single(b_new),.9,single(b_new));
figure    
p = patch('Faces',F,'Vertices',V,'FaceVertexCData',col, 'FaceColor','interp', 'EdgeColor', 'none');
%colormap(jet(256))
%p=patch('vertices',V,'faces',F);%,'FaceVertexCData',col
%isonormals(x,y,z,b_new,p)
%isocolors(x,y,z,b_new,p);
%set(p, 'FaceColor','flat','EdgeColor','none');
view(3),daspect([1,1,1/3]),xlabel('x'),ylabel('y'),zlabel('z')
camlight; lighting gouraud %phong
colormap lines

%%
tic
b=temp2(1:4:end,1:4:end,1:4:end);
c=bwconncomp(b>2);
b_labeled=zeros(size(b));
for i=1:c.NumObjects
    b_labeled(c.PixelIdxList{1,i})=i;
end
figure,isosurface(b,b_labeled)
%FV=isosurface(b,b_labeled);

hold on
isosurface(b==2,(b==2).*(c.NumObjects+1))
daspect([1,1,1/3]),xlabel('x'),ylabel('y'),zlabel('z')
toc

%%
tic
b=temp2(1:4:end,1:4:end,1:4:end);
figure
for i=1:max(b(:))
    if sum(b(:)==i)>0
        p1 = patch(isosurface(smooth3(b==i,'box',[3 3 3])),'FaceColor',rand(1,3),'EdgeColor','none');
        isonormals(b==i,p1);hold on
    end
end
view(3); axis tight; daspect([1,1,1/3])
camlight; lighting gouraud %phong
toc

%%
tmpvol = true(20,20,20); % Zeros on the inside means 
tmpvol(8:12,8:12,5:15) = 0; % isosurface makes triangles 
fv = isosurface(tmpvol, 0.5); % point out of object 
faceColVal = fv.vertices(fv.faces(:,1),3); % Colour by Z height 
cRange = [min(faceColVal) max(faceColVal)]; 
nCols = 255; 
colMap = jet(nCols); 
faceColsDbl = interp1(linspace(cRange(1),cRange(2),nCols),colMap, faceColVal); 
faceCols8bit = faceColsDbl*255; 
%stlwrite('testCol.stl',fv,'FaceColor',faceCols8bit) 
figure, patch(fv,'FaceVertexCData',faceColsDbl,'FaceColor','flat')










%%
tic
b=temp==2;
figure,isosurface(b)
%p = patch(isosurface(b));isonormals(p)
hold on

b=temp;
c=bwconncomp(b);
b_labeled=zeros(size(b));
for i=1:c.NumObjects
    b_labeled(c.PixelIdxList{1,i})=i;
end
isosurface(b,b_labeled),axis square,xlabel('x'),ylabel('y'),zlabel('z')
toc

%%
tic
b=temp==2;
b=b(1:2:end,1:2:end,1:2:end);
figure,%isosurface(b)
% Create surface from voxels
offset=[0 0 0];
id=1;
[faces,vertex]=voxel_bnd_faces(b,[1 1 1/3],offset,id);
    
facecolor=['red'];
edgecolor=facecolor;
% Plot surface
[fighndl]=plotsurf(faces,vertex,facecolor,edgecolor);  
 
hold on

b=temp;
c=bwconncomp(b);
b_labeled=zeros(size(b));
for i=1:c.NumObjects
    b_labeled(c.PixelIdxList{1,i})=i;
end
isosurface(b,b_labeled),axis square,xlabel('x'),ylabel('y'),zlabel('z')
toc




%%
tic
figure
for i=1:max(temp(:))
    disp(i);
    b=temp==i;
    b=b(1:2:end,1:2:end,1:2:end);
    isosurface(b,b)
    hold on
end
axis square,xlabel('x'),ylabel('y'),zlabel('z')
toc

%%
b=temp;
b=b(1:2:end,1:2:end,1:2:end);
figure,isosurface(b,b)

colormap lines



