%%% define folder and rootpath
clear

rootpath='D:\Dropbox\SCRIPTS\MATLAB\';

addpath(genpath([rootpath,'BAIVo'])) 
addpath(genpath([rootpath,'SAMP']))
addpath(genpath([rootpath,'KLEE\KLEEv4_minimal']))
addpath(genpath([rootpath,'geom3d']))
addpath(genpath([rootpath,'tracing']))

folder = [rootpath,'Tracings_Eval\redundant_Wm\wm2\'];
%folder = [rootpath,'Tracings_Eval\Spiny_redundant_STR\DATA\'];
%folder = [rootpath,'Tracings_Eval\Spiny_redundant_CTX\DATA\'];
%folder = [rootpath, 'Tracings_Eval\20130318.membrane.ctx.40nm_DATA\'];


%% load DATA
pskel = {};
flist = dir([folder filesep '*.nml']);
tic
for i = 1:size(flist,1)
    disp(flist(i).name);
    [pskel{i}.nodes pskel{i}.edges pskel{i}.comments] = ...
        knossos2graph([folder,flist(i).name]);
end
toc


%% Plot pskels
subplot = @(m,n,p) subtightplot(m,n,p);  %opt = {gap, width_h, width_w} 

range=[512, 512];

figure(2)

for i=1:length(pskel)
    disp(i)
    a0=pskel{1,i}.nodes;
    a=pskel{1,i}.edges;
    b=pskel{1,i}.nodes(a',2:3);
    %b=pskel{1,i}.nodes(a',1:2);
    b=reshape(b,[2,size(a,1),2]);  
    
    subplot(5,4,i)
    plot(b(:,:,1),b(:,:,2),'Color','b')
    set(gca,'xtick',[]),set(gca,'ytick',[]), 
    %set(gca,'LooseInset',get(gca,'TightInset'))
    %hold on,scatter(a0(:,1),a0(:,2),'.b'),
    xlim([0 range(1)]); ylim([0 range(2)]),axis square%, axis tight; pause(.5)
    text(30,90,num2str(i),'FontSize',14)
    
    %title([num2str(i)])%,pause(2)   ':  ' flist(i+2,1).name(end-20:end)
end


















%% OLD CODE

figure

a0=skel.nodes;
a=skel.edges;
b=skel.nodes(a',1:3);
b=reshape(b,[2,size(a,1),3]);  

subplot(2,2,1)
plot(b(:,:,1),b(:,:,2),'Color','b'),title('XY')
subplot(2,2,2)
plot(b(:,:,2),b(:,:,3),'Color','b'),title('YZ')
subplot(2,2,3)
plot(b(:,:,1),b(:,:,3),'Color','b'),title('XZ')
%subplot(2,2,3)
%plot(b(:,:,1),b(:,:,3),'Color','b'),title('XZ')
%set(gca,'xtick',[]),set(gca,'ytick',[]),



%%


figure,
a=pskel{1,3}.edges
 
%b=[pskel{1,3}.nodes(a(:,1),1) pskel{1,3}.nodes(a(:,2),1)];
%c=[pskel{1,3}.nodes(a(:,1),2) pskel{1,3}.nodes(a(:,2),2)];

b=pskel{1,3}.nodes(a',1:2);
b=reshape(b,[2,size(a,1),2]);  
figure,plot(b(:,:,1),b(:,:,2),'Color','b')
% 
% b=[pskel{1,3}.nodes(a(:,1),1:2) pskel{1,3}.nodes(a(:,2),1:2)];
%    
% for i=1:length(a)
%         plot([pskel{1,3}.nodes(a(i,1),1) pskel{1,3}.nodes(a(i,2),1)],...
%         [pskel{1,3}.nodes(a(i,1),2) pskel{1,3}.nodes(a(i,2),2)]  ) ,hold on      
% end
%   


%%

AllEdgesAsNodes = pskel.nodes(pskel{DS2use}{task}{user}.edges',1:3);
AllEdgesAsNodes_reshaped = reshape(AllEdgesAsNodes,[2,size(pskel{DS2use}{task}{user}.edges,1),3]);
AllEdgesAsNodes_reshaped = AllEdgesAsNodes_reshaped(:,pskel{DS2use}{task}{user}.accepted_edges,:);
plot(AllEdgesAsNodes_reshaped(:,:,1),AllEdgesAsNodes_reshaped(:,:,2),'Color','green'); hold on




%% load DATA (old)

skeleton = {};
flist = dir([folder filesep '*.nml']);
tic
for i = 1:size(flist,1)
    disp(flist(i).name);
    skeleton{i} = KNOSSOS_readNML([folder,flist(i).name]);
    if size(skeleton{i},2)>1
        for nz = 1:size(skeleton{i},2)
            nodeSize(nz) = size(skeleton{i}{nz}.nodes,1);
        end
        [~, idx] = max(nodeSize);
        skeleton{i}{idx}.parameters = skeleton{i}{1}.parameters;
        token = skeleton{i}{idx};
        skeleton{i} = {};
        skeleton{i} = token;
    else
        skeleton{i} = skeleton{i}{1};
    end
end
toc

%for i=1:size(flist,1), disp([num2str(i) ' ' flist(i).name]),end
pskel=skeleton;


















