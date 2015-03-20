function labWS = jh_vs_synchronizeMinAndWS(labMin, labWS)

prefType = class(labWS);
[n1,n2,n3] = size(labMin);

values = zeros(n1, n2, n3, prefType);
values(labMin > 0) = labMin(labMin > 0);
clear iL1L2L3
WSValues = values;
clear values
tValues = zeros(n1, n2, n3, prefType);
while ~isequal(WSValues,tValues)
    
    tValues = WSValues;
    WSValues = imdilate(WSValues, [1 1 1; 1 1 1; 1 1 1]);
    WSValues(labWS == 0) = 0;
    
end
clear tValues

labWS = WSValues;
clear WSValues


end