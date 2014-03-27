function [things, thingIDs, comments]= knossos2graph_things(fn)
 
scalefactor=1;
 
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
    

    
    
    things{i}.nodes=nodes2;
    things{i}.edges=edges;
    
end
 




























