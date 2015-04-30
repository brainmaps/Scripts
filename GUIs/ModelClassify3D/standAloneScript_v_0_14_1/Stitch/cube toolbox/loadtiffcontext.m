function cube = loadtiffcontext(cubecoordinates, basepath)
%LOADCONTEXT Loads cubes in vicinity of a cube and concatenate all to a
%larger cube. Cubes beyond scope are replaced by empty cubes of the same size 
%   For example: loadcontext([2, 3, 4], true(3,3,3)) loads all 26 cubes
%                around [2, 3, 4].
%   [NOT TESTED] Cuboid ready

%parse inputs
x = cubecoordinates(2);
y = cubecoordinates(1);
z = cubecoordinates(3);

%load a sample cube to take measurements
samplecube = loadtiff2mat(cubecoordinates, basepath);

%determine supercube dimensions
wherewasi = pwd;
cd(basepath);
flistX=dir(basepath);
flistY=dir([basepath filesep 'x0000']);
flistZ=dir([basepath filesep 'x0000' filesep 'y0000']);

numX=sum(arrayfun(@(x) sum(x.isdir),flistX))-2;
numY=sum(arrayfun(@(x) sum(x.isdir),flistY))-2;
numZ=sum(arrayfun(@(x) sum(x.isdir),flistZ))-2;
cd(wherewasi);

stack = [];
for J = -1:1 %loop to stack sheets
    sheet = [];
    for I = -1:1 %loop to weave threads to a sheet
        thread = []; 
        for K = -1:1 %loop to load a thread
            loadnow = [y+J, x+I, z+K];
            %load cube if loadnow a valid coordinate
            if all(loadnow >= [1, 1, 1] & loadnow <= [numY, numX, numZ])
                lcube = loadtiff2mat(loadnow, basepath);
                
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


%return
cube = stack;
return

end

