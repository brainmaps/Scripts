function [nodes, edges, comments]= knossos2graph(fn)
%fn='N:\Tracings-Interareal\Single_neurons.nml';
%nodes = [nodeid x y z noderadius nodecolor thingid]
%fn='synapses_isonntag.400.nml';
%fn_out='output2.am';
%nodecolor=.5;

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
%fn='D:\external-capsule.002.nml';
%fn='N:\Tracings-Interareal\interareal-somamap-complete-labeled.nml';
fid = fopen(fn,'r');
fn_data = fscanf(fid,'%c');
fclose(fid);
fn_things = regexp(fn_data,'<thing id.*?</thing>','match');
fn_thingIDs = regexp(fn_things,'<thing id="(.*?)"','tokens');
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
    comments.node(i)=str2num(fn_comment.node{1,1}{1,1});
    comments.text{i}=fn_comment.text{1,1}{1,1};
end
        

for i=1:size(fn_things,2)
    thingid=str2num(fn_thingIDs{1,i}{1,1}{1,1});
    fn_nodes{i} = regexp(fn_things{1,i},'<node .*?/>','match');
    nodecolor=rand(1);    
    for j=1:size(fn_nodes{1,i},2)
        nodetempid=regexp(fn_nodes{1,i}{1,j},'id=".*?"','match');
        nodeid=str2double(nodetempid{1,1}(5:length(nodetempid{1,1})-1));
        nodetempx=regexp(fn_nodes{1,i}{1,j},'x=".*?"','match');
        nodetempy=regexp(fn_nodes{1,i}{1,j},'y=".*?"','match');
        nodetempz=regexp(fn_nodes{1,i}{1,j},'z=".*?"','match');
        nodetempradius=regexp(fn_nodes{1,i}{1,j},'radius=".*?"','match');
        noderadius=str2double(nodetempradius{1,1}(9:length(nodetempradius{1,1})-1));
        nodes=[nodes;nodeid str2double(nodetempx{1,1}(4:length(nodetempx{1,1})-1))/scalefactor ...  
            str2double(nodetempy{1,1}(4:length(nodetempy{1,1})-1))/scalefactor ...  
            str2double(nodetempz{1,1}(4:length(nodetempz{1,1})-1))/scalefactor ...  
            noderadius nodecolor thingid];
    end
    fn_edges{i} = regexp(fn_things{1,i},'<edge .*?/>','match');
    for j=1:size(fn_edges{1,i},2)
        edgetempsource=regexp(fn_edges{1,i}{1,j},'source=".*?"','match');
        edgetemptarget=regexp(fn_edges{1,i}{1,j},'target=".*?"','match');
        edges=[edges;str2double(edgetempsource{1,1}(9:length(edgetempsource{1,1})-1)) ... 
            str2double(edgetemptarget{1,1}(9:length(edgetemptarget{1,1})-1))];        
    end
end
 
if ~isempty(comments)
    comments.node_old=comments.node;
    for i=1:size(comments.node,2)
        comments.node(i)=find(nodes(:,1)==comments.node(i));
    end
end
nodes_old=nodes;
edges_old=edges;
for i=1:size(nodes,1)
    if ~isempty(edges)
        sourceindex=find(edges_old(:,1)==nodes(i,1));
        targetindex=find(edges_old(:,2)==nodes(i,1));
    else
        edges_old=[0 0];
        sourceindex=[];
        targetindex=[];
    end
    if isempty(sourceindex) && isempty(targetindex)
        edges=[edges;i i];
    else
        edges(sourceindex,1)=i;
        edges(targetindex,2)=i;
    end
end
newindex=1:size(nodes,1);
newindex=newindex';
nodes(:,1)=newindex;
     

 









