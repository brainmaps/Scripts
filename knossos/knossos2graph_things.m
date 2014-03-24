function [things, thingIDs, comments]= knossos2graph_things(fn)
%fn='N:\Tracings_Eval\Interareal\ALL\20130728-med-fib-aboveseedlayer-subset-2-uhaeusler.045.nml';
%fn='D:\interareal_progress.nml';
%fn='D:\Dropbox\SCRIPTS\MATLAB\common\ivo\misc\somamap.nml';
%nodes = [nodeid x y z noderadius nodecolor]
%fn='synapses_isonntag.400.nml';
%fn_out='output2.am';
%nodecolor=.5;
%fn='D:\tracing.045.nml';
%fn='D:\interareal.nml';
%fn='D:\BOMAX-512px-cube-uhaeusler.083.nml'

%%
%fn='D:\20130410.membrane.striatum.10x10x30.synapses2-uhaeusler.013.nml';
%fn='D:\BOMAX-512px-cube-uhaeusler.083.nml'

scalefactor=1;


%fn='wb01_cc_user3_task006_2x.002.nml'
%fn_out='wb01_cc_user3_task006_2x.002.nml.am'

%fn='seedpoints.shawn.nml';
%fn_dir='F:\_MOUSE_PROJECTOME\STACKS\01331-100603-01\analysis\';

%fn='cc-diametertask.010.nml';
%fn_dir='D:\_MOUSE_PROJECTOME\TRACING\wholebrain_sm\tracings\';

% 
% fn='trainingv1test.015.nml';
% fn_dir='W:\wholebrain_sm\tracings\training\v1\';

%fn_out='knossos2amiraoutput.am';

%cd(fn_dir);
%fn='D:\carving-test.nml';
fid = fopen(fn,'r');
fn_data = fscanf(fid,'%c');
fclose(fid);
fn_things = regexp(fn_data,'<thing id.*?</thing>','match');
fn_thingIDs = regexp(fn_things,'<thing id="(.*?)"','tokens');
thingIDs=[];
for i=1:size(fn_thingIDs,2)
    thingIDs(i)=str2num(fn_thingIDs{1,i}{1,1}{1,1});
end
fn_comments = regexp(fn_data,'<comment node.*?/>','match');

nodes=[];
edges=[];
nodesamira='';
nodewidthsamira='';
nodecolorsamira='';
edgesamira='';

 
nodecomment=[];
comments=[];
for i=1:size(fn_comments,2)
    %fn_comments(i)
    %fn_comment.node = regexp(fn_comments{1,i},'node=".*?"','match');
    fn_comment.node = regexp(fn_comments{1,i},'node="(.*?)"','tokens');
    %fn_comment.text = regexp(fn_comments{1,i},'content=".*?"','match');
    fn_comment.text = regexp(fn_comments{1,i},'content="(.*?)"','tokens');
    comments{i,1}=fn_comment.node;
    comments{i,2}=fn_comment.text;
    
%     findmatch=strfind(fn_comment.text,'ranv');
%     if findmatch{1,1}
%         %num2str(fn_comment.node{1,1}(7:end-1))
%         nodecomment=[nodecomment; str2num(fn_comment.node{1,1}(7:end-1))];
%         %disp('ranv found');
%     end
end
        
things=[]; 
for i=1:size(fn_things,2)
    
    nodes=[];
    nodes2=[];
    edges=[];
%for i=3:3
    fn_nodes{i} = regexp(fn_things{1,i},'<node .*?/>','match');
    nodecolor=.5;%rand(1);
    
    for j=1:size(fn_nodes{1,i},2)
        %nodecolor=0.85;
        nodetempid=regexp(fn_nodes{1,i}{1,j},'id=".*?"','match');
        nodeid=str2double(nodetempid{1,1}(5:length(nodetempid{1,1})-1));
        nodetempx=regexp(fn_nodes{1,i}{1,j},'x=".*?"','match');
        nodetempy=regexp(fn_nodes{1,i}{1,j},'y=".*?"','match');
        nodetempz=regexp(fn_nodes{1,i}{1,j},'z=".*?"','match');
        nodetempradius=regexp(fn_nodes{1,i}{1,j},'radius=".*?"','match');
        noderadius=str2double(nodetempradius{1,1}(9:length(nodetempradius{1,1})-1));
        %noderadius=1;  %1.5
        if find(nodecomment==nodeid) 
            %disp('node of Ranvier detected')
            noderadius=noderadius*10;
            
            %nodecolor=0.9;
        end
        nodes=[nodes;nodeid str2double(nodetempx{1,1}(4:length(nodetempx{1,1})-1))/scalefactor   str2double(nodetempy{1,1}(4:length(nodetempy{1,1})-1))/scalefactor   str2double(nodetempz{1,1}(4:length(nodetempz{1,1})-1))/scalefactor   noderadius nodecolor];
    end
    
    if length(nodes)>0
        nodes=sortrows(nodes,1);
        nodes2=nodes;
        newnodeIDs=1:size(nodes,1);
        nodes2(:,1)=newnodeIDs';    
    end
    
    fn_edges{i} = regexp(fn_things{1,i},'<edge .*?/>','match');
    for j=1:size(fn_edges{1,i},2)
        edgetempsource=regexp(fn_edges{1,i}{1,j},'source=".*?"','match');
        edgetemptarget=regexp(fn_edges{1,i}{1,j},'target=".*?"','match');
        %edges=[edges;str2double(edgetempsource{1,1}(9:length(edgetempsource{1,1})-1)) ...
         %   str2double(edgetemptarget{1,1}(9:length(edgetemptarget{1,1})-1))];
         edgesource=str2double(edgetempsource{1,1}(9:length(edgetempsource{1,1})-1));
         edgetarget = str2double(edgetemptarget{1,1}(9:length(edgetemptarget{1,1})-1));
         try
         edges=[edges; nodes2(ismember(nodes(:,1),edgesource),1)  nodes2(ismember(nodes(:,1),edgetarget),1) ];
         catch
         end
         %ismember(things{1}.nodes(:,1),25)
        
    end
    

    
%     
%     for i2=1:size(nodes,1)
%         if i2~=nodes(i2,1)
%             nodecorrection=nodes(i2,1)-i;
%             for j=1:nodes(i2,1)-i2
%                 nodes=[nodes(1:i2-1+j-1,:); i2-1+j 0 0 0 0 0; nodes(i2+j-1:size(nodes,1),:)];
%             end
%         end
%     end
    
    
    things{i}.nodes=nodes2;
    things{i}.edges=edges;
    
end
 




























