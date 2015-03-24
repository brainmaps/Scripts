function steplog2plot(steplog, manualtracing)
%STEPLOG2PLOT Takes in a steplog from steve and plots the skeleton with
%hardwired plot parameters. 
%   ARGUMENT: 
%       steplog: steve's output
%       manualtracing: manual tracing if available (as n-by-3 array)
%   OUTPUT: 
%       h: handle to plot figure

%assemble points to plot in a cell array
plotpoints = [steplog(1, 1); steplog(:, 4)];

%assemble controlpoints in a cell array
contp = steplog(:, 6); 
contparr = []; 
for k = 1:size(steplog, 1)
    contparr = [contparr; cell2mat(contp{k})]; 
end

%convert to array
pointarray = cell2mat(plotpoints);

%extract x, y and z
x = pointarray(:,2); 
y = pointarray(:,1); 
z = pointarray(:,3); 

cpx = contparr(:,2);
cpy = contparr(:,1); 
cpz = contparr(:,3); 

%plot
plot3(y, x, z, 'LineWidth', 3, 'MarkerSize', 5, 'Color', 'b'); 
hold on
scatter3(cpy, cpx, cpz, 'fill'); 
hold off

if exist('manualtracing', 'var')
    %check if context coordinates given
    if size(manualtracing, 2) == 6
        %convert from context to global coordinates
        manualtracing = context2globalcoordinates(manualtracing(:, 4:6), manualtracing(:, 1:3));
    end
    hold on
    plot3(manualtracing(:, 1), manualtracing(:, 2), manualtracing(:, 3), 'LineWidth', 3, 'MarkerSize', 5, 'Color', 'r');
    hold off
end

% xlim([min(x) max(x)])
% ylim([min(y) max(y)])
% zlim([min(z) max(z)])

xlabel('y index');
ylabel('x index');
zlabel('z index');

end

