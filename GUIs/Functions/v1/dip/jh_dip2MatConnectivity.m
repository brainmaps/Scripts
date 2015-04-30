function matConn = jh_dip2MatConnectivity(dipConn, dimensions)
switch dipConn
    case 1
        if dimensions == 2
            matConn = 4;
        elseif dimensions == 3
            matConn = 6;
        end
    case 2
        if dimensions == 2
            matConn = 8;
        elseif dimensions == 3
            matConn = 18;
        end
    case 3
        if dimensions == 3
            matConn = 26;
        end
end
end