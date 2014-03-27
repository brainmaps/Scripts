function things_total = importAndPlotKnossosFiles(fndir,range)
% fndir=directory of knossos files
% range is optional 3-tuple specifying volume dimensions in voxels
%fndir='C:\wholebrain\Dropbox\SCRIPTS\MATLAB\Tracings_Eval\Spiny_redundant_CTX\DATA';

cmap=lines;
flist=dir([fndir filesep '*.nml']);
clear things_total
for i=1:length(flist)
    [things, thingIDs, comments]= knossos2graph_things([fndir filesep flist(i).name]);
    things_total{i}.things=things;
    things_total{i}.thingIDs=thingIDs;
    things_total{i}.comments=comments;
end

%%

figure 
plotted_things=0;num_things=0;
for j=1:length(flist)
    things=things_total{j}.things;
    num_things=num_things+length(things);
    for i=1:length(things)
        try
        a=things{1,i}.edges;
        b=[things{1,i}.nodes(a',2:4)];
        b=reshape(b,[2,size(a,1),3]);
        plot3(b(:,:,1),b(:,:,2),b(:,:,3),'Color',cmap(j,:));hold on;
        plotted_things=plotted_things+1;
        catch
        end
    end
end
try,xlim([1 range(1)]);ylim([1 range(2)]);zlim([1 range(3)]);catch,end
xlabel('X'),ylabel('Y'),zlabel('Z'),axis auto,grid on,view([-48 6])
hold off
disp(['Plotted things: ' num2str(plotted_things) ',  Total things: ' num2str(num_things)]);



























