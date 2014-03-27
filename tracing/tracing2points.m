function points=tracing2points(nodes,edges,points2add)
%converts tracing to point cloud by adding uniformly-spaced points to each
%edge

points=nodes(:,2:4);
for i=1:points2add
    points=[points; (nodes(edges(:,1),2:4)+ i*( nodes(edges(:,2),2:4)-nodes(edges(:,1),2:4) )./(points2add+1) )];
end











