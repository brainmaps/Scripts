function outcube = consolidatelabels(cube, cgcc)
%CONSOLIDATELABELS Consolidates all labels by loading the connected component
%analysis on the connectivity graph and relabeling the argument cube accordingly. 

%relabeling
%get uniques in cube
uic = unique(cube);
%get rid of that zero
uic(uic == 0) = [];
%transpose for for
uic = uic';

if ~isempty(uic)
    for k = uic
        %for k unique in cube, read from cgcc and label accordingly
        %LOLWTH MATLAB
        %save test
        kbincube = cube == k;
        cube(kbincube) = cgcc(k);
    end
end

%return
outcube = cube;

end

