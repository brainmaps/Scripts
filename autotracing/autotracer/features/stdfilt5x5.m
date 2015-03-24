function [out] = stdfilt5x5(in)
%STDFILT5X5 MATLAB stdfilt with 5x5 1 neighborhood. 

out = stdfilt(in, ones(5,5)); 

end

