function importAndPlotKnossosFile(fn,range)
% fn=knossos file
% range is optional 3-tuple specifying volume dimensions in voxels
%fn='D:\BOMAX-512px-cube-uhaeusler.083.nml';
if isempty(range)
    range=[512,512,512];
end
[things, thingIDs, comments]= knossos2graph_things(fn);
figure
plotted_things=0;
for i=1:length(things)
    try
    a=things{1,i}.edges;
    b=[things{1,i}.nodes(a',2:4)];
    b=reshape(b,[2,size(a,1),3]);
    plot3(b(:,:,1),b(:,:,2),b(:,:,3),'Color',rand(3,1));hold on;
    plotted_things=plotted_things+1;
    catch
    end
end
xlim([1 range(1)]);ylim([1 range(2)]);zlim([1 range(3)]);
xlabel('X'),ylabel('Y'),zlabel('Z'),axis square
hold off
disp(['Plotted things: ' num2str(plotted_things) ',  Total things: ' num2str(length(things))]);



























