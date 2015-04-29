function nh = jh_getNeighborhoodFromConnectivity(conn, dimensions)

switch conn
    case 1
        if dimensions == 2
            nh = [0, 1, 0; 1, 1, 1; 0, 1, 0]; % 4
        elseif dimensions == 3
            nh(:,:,1) = [0, 0, 0; 0, 1, 0; 0, 0, 0]; % 6
            nh(:,:,2) = [0, 1, 0; 1, 1, 1; 0, 1, 0];
            nh(:,:,3) = [0, 0, 0; 0, 1, 0; 0, 0, 0];
        end
    case 2
        if dimensions == 2
            nh = [1, 1, 1; 1, 1, 1; 1, 1, 1]; % 8
        elseif dimensions == 3
            nh(:,:,1) = [0, 1, 0; 1, 1, 1; 0, 1, 0]; % 18
            nh(:,:,2) = [1, 1, 1; 1, 1, 1; 1, 1, 1];
            nh(:,:,3) = [0, 1, 0; 1, 1, 1; 0, 1, 0];
        end
    case 3
        if dimensions == 3
            nh(:,:,1) = [1, 1, 1; 1, 1, 1; 1, 1, 1]; % 26
            nh(:,:,2) = [1, 1, 1; 1, 1, 1; 1, 1, 1];
            nh(:,:,3) = [1, 1, 1; 1, 1, 1; 1, 1, 1];
        end
end
        
end