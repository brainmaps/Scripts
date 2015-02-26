function ind = jh_zeroBasedSub2Ind(imSize, position)

position = position+1;
imSize = [imSize(2), imSize(1), imSize(3)];

try
    ind = sub2ind(imSize, position(2), position(1), position(3));
catch
    ind = jh_sub2Ind(imSize, [position(2), position(1), position(3)]);
end


end