function [steplog] = initializeretrotrace(skelfile)
%INITIALIZERETROTRACE Generates steplog for retrotracing from the
%seedpoint (first node in skeleton). Use if branchfinder switched off in Stacy. 

%initialize steplog
steplog = {}; 

%load first segment in first branch
try
    steplogrow = skelfile.B1S1(1,:);
catch
    warning('B1S1 not found in skelfile. Returning {}')
    return
end

%flip direction vector
steplogrow{5} = -steplogrow{5}; 

%flip source and target
steplogrow([1 4]) = steplogrow([4 1]); 

%return
steplog = steplogrow;

end

