function boundarytuple = boundaryanalysis(basepath, limiter)
%UNTITLED Returns a n by 2 tuple list of connected labels over cube boundaries. 
%   Rows in boundary tuple correspond to connected label pairs, which could
%   then be used to compile a graph. 
%   [ARGUMENTS] basepath: path to globally enumerated labeled directory
%               limiter: limits processing to a sub-supercube. See
%               cubeprocessor for more on this.


%fetch supercube size
[numY, numX, numZ] = fetchSupercubeDimensions(basepath);

%set default value for limiter
if ~exist('limiter', 'var')
    limiter = [1 1 1; numY, numX, numZ];
end

%initialize return variable
tuplist = [];

%begin loop
for J = 1:numY
    for I = 1:numX
        for K = 1:numZ
            %continue if no processing requested
            if any(~(([J I K] >= limiter(1,:)) & ([J I K] <= limiter(2, :))))
                continue
            end
            
            %load cube and take measurements
            currcube = loadcube([J I K], basepath);
            currcubecoord = [J I K];
            [sizy, sizx, sizz] = size(currcube);
            
            %proceed like updateinvlist. Initialize a 6-neighborhood 
            %expansion matrix
            expmat = false(3,3,3);
            %set the forward three neighbors to true
            
            %expmat(5) = true;
            %expmat(11) = true;
            %expmat(13) = true; 
            expmat(15) = true;
            expmat(17) = true;
            expmat(23) = true;
            
            %loop over expmat
            for l = 1:numel(expmat)
                if expmat(l)
                    [I1, I2, I3] = ind2sub([3, 3, 3], l);
                    I1 = I1 - 2; I2 = I2 - 2; I3 = I3 - 2;
                    gonext = double(currcubecoord) + [I1, I2, I3];
                    
                    if any(~((gonext >= limiter(1,:)) & (gonext <= limiter(2, :))))
                        continue
                    end
                    
                    nextcube = loadcube(gonext, basepath);
                    
                    %look for connected cc's in gonext
                    m1vec = [I1, I2, I3] == -1; %m1vec: Minus 1 VECtor
                    p1vec = [I1, I2, I3] == 1;
                    
                    if any(m1vec)
                       %don't look back
                       continue
                       %----------------
                       %go forward: true
                       if m1vec(1) == 1
                           %load the correct edge
                           currcubeedge = reshape(double(currcube(1, :, :)), [sizx, sizx]);
                           %"AND" with the correct edge of the next cube
                           %(which must not be binary) and concatenate
                           %unique results to ccid.
                           
                           nextedge = reshape(nextcube(end,:,:), [sizx, sizx]);
                           
                           %make tuple
                           subtup = [currcubeedge(:), nextedge(:)];
                           tuplist = [tuplist; subtup];
                           
                       end
                       
                       %go left: true
                       if m1vec(2) == 1
                           %load the correct edge
                           currcubeedge = reshape(double(currcube(:, 1, :)), [sizx, sizx]);
                           %"AND" with the correct edge of the next cube
                           %(which must not be binary) and concatenate
                           %unique results to ccid.
                           
                           nextedge = reshape(nextcube(:,end,:), [sizx, sizx]);
                                                     
                           %make tuple
                           subtup = [currcubeedge(:), nextedge(:)];
                           tuplist = [tuplist; subtup];
                           
                       end
                       
                       %go up: true
                       if m1vec(3) == 1
                           %load the correct edge
                           currcubeedge = reshape(double(currcube(:, :, 1)), [sizx, sizx]);
                           %"AND" with the correct edge of the next cube
                           %(which must not be binary) and concatenate
                           %unique results to ccid.
 
                           nextedge = reshape(nextcube(:,:,end), [sizx, sizx]);
                           
                           %make tuple
                           subtup = [currcubeedge(:), nextedge(:)];
                           tuplist = [tuplist; subtup];

                       end
                   end
                   
                   if any(p1vec)
                       %go backwards: true
                       if p1vec(1) == 1
                           %load the correct edge
                           currcubeedge = reshape(double(currcube(end, :, :)), [sizx, sizx]);
                           %"AND" with the correct edge of the next cube
                           %(which must not be binary) and concatenate
                           %unique results to ccid.
                           
                           nextedge = reshape(nextcube(1,:,:), [sizx, sizx]);
                           
                           %make tuple
                           subtup = [currcubeedge(:), nextedge(:)];
                           tuplist = [tuplist; subtup];
                           
                       end
                       
                       %go right: true
                       if p1vec(2) == 1
                           %load the correct edge
                           currcubeedge = reshape(double(currcube(:, end, :)), [sizx, sizx]);
                           %"AND" with the correct edge of the next cube
                           %(which must not be binary) and concatenate
                           %unique results to ccid.
                           
                           nextedge = reshape(nextcube(:,1,:), [sizx, sizx]);
                           
                           %make tuple
                           subtup = [currcubeedge(:), nextedge(:)];
                           tuplist = [tuplist; subtup];
                           
                       end
                       
                       %go down: true
                       if p1vec(3) == 1
                           %load the correct edge
                           currcubeedge = reshape(double(currcube(:, :, end)), [sizx, sizx]);
                           %"AND" with the correct edge of the next cube
                           %(which must not be binary) and concatenate
                           %unique results to ccid.
                           
                           nextedge = reshape(nextcube(:,:,1), [sizx, sizx]);
                           
                           %make tuple
                           subtup = [currcubeedge(:), nextedge(:)];
                           tuplist = [tuplist; subtup];
                           
                       end
                   end   
                end
            end
            
            %clean up tuplist for next pass. Saves memory at the cost of
            %cpu time. 
            %begin by getting rid of all rows with zeros
            tuplist = tuplist(all(tuplist, 2), :);
            %pick unique elements
            tuplist = unique(tuplist, 'rows');
            
        end
    end
end

boundarytuple = tuplist;

end

