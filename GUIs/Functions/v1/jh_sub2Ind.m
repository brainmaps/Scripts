function ind = jh_sub2Ind(imSize, sub)

ind = (sub(1)-1) + imSize(1)*(sub(2)-1) + imSize(1)*imSize(2)*(sub(3)-1) + 1;


end