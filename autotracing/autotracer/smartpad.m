function [padvw] = smartpad(vw, padpx)
%SMARTPAD Rolls vw over as a padding of width padpx. 

%build paddings
%nomenclature: Left Pane = LP, Right Pane = RP, Upper Pane = UP, Lower Pane
%= DP. ULC = Upper Left Corner, URC, LLC, LRC. 
LP = vw(:,(end-padpx):end);
RP = vw(:, 1:padpx); 
UP = fliplr(flipud(vw(1:padpx, :))); 
DP = fliplr(flipud(vw((end-padpx):end, :)));
ULC = flipud(vw(1:padpx, (end-padpx):end));
LRC = flipud(vw((end-padpx):end, 1:padpx));
LLC = flipud(vw((end-padpx):end, (end-padpx):end));
URC = flipud(vw(1:padpx, 1:padpx));

%put paddings together to build padvw
padvw = [ULC, UP, URC; LP, vw, RP; LLC, DP, LRC];

end