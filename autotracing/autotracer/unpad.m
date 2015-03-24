function [vw] = unpad(padvw, padpx)
%UNPAD Inverts smartpad. 
%   ARGUMENTS: 
%       padvw: padded view
%       padpx: number of pixels by which vw was padded to obtain padvw
%   OUTPUT: 
%       vw: original

%take measurements
[sizy, sizx] = size(padvw);

%crop padvw
vw = padvw((padpx+1):(sizy-padpx-1), (padpx+2):(sizx-padpx)); 


end

