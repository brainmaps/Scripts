function supcube = loadsupercube(basepath, limiter)
%LOADSUPERCUBE Load all cubes from a Knossos cube directory within limiter scope. 
%Omitting limiter results in the function loading the entire directory.
%For more on limiter, see cubeprocessor. 

%fetch dimension 
[numY, numX, numZ] = fetchSupercubeDimensions(basepath);


%assign defaults
if ~exist('limiter', 'var')  
    limiter = [1, 1, 1; numY, numX, numZ];
end

%parse
firstcoord = limiter(1,:);
lastcoord = limiter(2,:);

%load a cube to take measurements
samplecube = loadcube(firstcoord, basepath);

stack = [];
for J = firstcoord(1):lastcoord(1) %loop to stack sheets
    sheet = [];
    for I = firstcoord(2):lastcoord(2) %loop to weave threads to a sheet
        thread = []; 
        for K = firstcoord(3):lastcoord(3) %loop to load a thread
            loadnow = [J I K];
            %load cube if loadnow a valid coordinate
            if all(loadnow >= [1, 1, 1] & loadnow <= [numY, numX, numZ])
                lcube = loadcube(loadnow, basepath);
                
                %-----DEBUGGER------
                %if std(double(lcube(:))) < 1
                %    save vardump
                %    asdf
                %end
                %-------------------
                
                thread = cat(3, thread, lcube);
            %load an empty cube if loadnow is no valid coordinate
            else 
                lcube = zeros(size(samplecube));
                thread = cat(3, thread, lcube);
            end
        end
        sheet = cat(2, sheet, thread);
    end
    stack = cat(1, stack, sheet);
end

%return stack 
supcube = stack;

end

