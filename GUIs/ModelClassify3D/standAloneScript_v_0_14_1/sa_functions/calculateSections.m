function calculateSections(settings)

nos = noOfSections( ...
    settings.secSize, ...
    settings.overlap, ...
    settings.cubeSize, ...
    settings.range);
settings.noOfSections = nos;

fprintf(  '____________________________________________________________')

for x = 0:nos(1)-1
    for y = 0:nos(2)-1
        for z = 0:nos(3)-1
            
            fprintf(jh_buildString('\nx = ', x, ', y = ', y, ', z = ', z, '\n')) 
            
            calculateCurrentSection(x, y, z, settings);
            
            fprintf('____________________________________________________________')
            
        end
    end
end

end

function nos = noOfSections(secSize, overlap, cubeSize, range)

nos = ( (range(:,2)-range(:,1)+1) * cubeSize ) / ( secSize - overlap );

end
