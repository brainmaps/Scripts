function [prod] = normdot(vec1, vec2)
%NORMDOT Normalizes input vectors and returns their dot product. 

prod = dot(vec1/norm(vec1), vec2/norm(vec2)); 

end

