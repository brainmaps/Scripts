function s = jh_size(M)
% jh_size returns the size of a 3D matrix in [x,y,z] coordinate system and
% zero-based
%

ts = size(M);
ts = ts-1;
s(1) = ts(2);
s(2) = ts(1);
s(3) = ts(3);

end