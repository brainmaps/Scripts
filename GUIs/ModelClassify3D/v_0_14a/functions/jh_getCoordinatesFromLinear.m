function [r, c, d] = jh_getCoordinatesFromLinear(linear, imSize)

n1 = imSize(1);
n2 = imSize(2);
n3 = imSize(3);

d = ceil(linear / (n1*n2));
c = ceil((linear - (d-1)*(n1*n2)) / n1);
r = linear - (d-1)*(n1*n2) - (c-1)*n1;


end