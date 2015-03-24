function supcube = loadtoycontext(basepath, limiter)
%LOADSUPERCUBE Load all cubes from a toy Knossos cube directory within limiter scope. 
%limiter cannot be omitted and must be correct. 

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
            lcube = loadcube(loadnow, basepath);
            
            %-----DEBUGGER------
            %if std(double(lcube(:))) < 1
            %    save vardump
            %    asdf
            %end
            %-------------------
            
            thread = cat(3, thread, lcube);
            
        end
        sheet = cat(2, sheet, thread);
    end
    stack = cat(1, stack, sheet);
end

%return stack 
supcube = stack;

end

