
fndir='C:\wholebrain\Dropbox\SCRIPTS\MATLAB\Tracings_Eval\Spiny_redundant_CTX\DATA';
fndir='D:\Dropbox\SCRIPTS\MATLAB\Tracings_Eval\Spiny_redundant_CTX\DATA';
voxel_size=[10 10 30];
thresT=500;thresN=800; %in nm

cmap=lines;

things_total = importAndPlotKnossosFiles(fndir);
%%
clear points_total num_things;points_total=[];num_things=0;
figure
for j=1:length(things_total)
    things=things_total{j}.things;
    num_things=num_things+length(things);
    clear nodes edges;nodes=[];edges=[];
    for i=1:length(things)
        try
        nodes=[nodes; things{1,i}.nodes];
        edges=[edges; things{1,i}.edges];
        catch
        end
    end        
    points=tracing2points(nodes,edges,2);
    points_total{j}=points;
    scatter3(points(:,1),points(:,2),points(:,3),repmat(8,size(points,1),1),repmat(cmap(j,:),size(points,1),1),'fill'),hold on
end

disp(['adding T sphere at ' num2str(points(1,1)) ', ' num2str(points(1,2)) ', ' num2str(points(1,3))])
scatter3(points(1,1),points(1,2),points(1,3),thresT,'b');hold on
disp(['adding N sphere at ' num2str(points(1,1)) ', ' num2str(points(1,2)) ', ' num2str(points(1,3))])
scatter3(points(1,1),points(1,2),points(1,3),thresN,'r');hold on

xlabel('X'),ylabel('Y'),zlabel('Z'),axis auto,grid on,view([-48 6])

hold off

%%
clear distances_total
for j=1:length(things_total)
    distances_total{j}(:,j)=single(repmat(0,length(points_total{j}),1));
    for i=j+1:length(things_total)
        D=pdist2(single(points_total{j}).*single(repmat(voxel_size,length(points_total{j}),1)),single(points_total{i}).*single(repmat(voxel_size,length(points_total{i}),1)),'euclidean');
        distances_total{j}(:,i)=min(D')';
        distances_total{i}(:,j)=min(D)';
    end
end

%%
clear TofN;TofN=[];
for i=1:length(distances_total)
    TofN=[TofN; [sum(distances_total{i}'<=thresT)' sum(distances_total{i}'<=thresN)']];
end

votehist = zeros(length(distances_total));
for i = 1:size(TofN,1)
    votehist(TofN(i,1),TofN(i,2)) = votehist(TofN(i,1),TofN(i,2))+1;
end
figure,imagesc(log10(votehist))

%% Estimate Pe distribution
Pe_dist_size=50;maxfunceval=50;optimcalls=4;optimcallstol=-Inf;vote_radius=1000;

output=estimate_Pe_dist(votehist,Pe_dist_size,maxfunceval,optimcalls,optimcallstol);
  
%% Compute RESCOP error-free path length

[Pe_dist_NT,binsout,total_error_prob,error_prob,error_probs,error_free_pathlength] = ...
    compute_rescop(output.Pe_dist,output.binsout,length(votehist),vote_radius);

disp(['Error-free path-length: ' num2str(error_free_pathlength) ' nm'])
 




