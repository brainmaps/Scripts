function [meanvec] = normvecmean(vec1, vec2)
%NORMVECMEAN Normalizes vec1 and vec2 and returns their mean. 

meanvec = 0.5*((vec1/norm(vec1)) + (vec2/norm(vec2)));

end

