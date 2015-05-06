function result = cropResult(result, settings, boundsRangeIdx)

% ol = settings.overlap;
% ol2 = ol/2;
% result = result(ol2(2)+1:end-ol2(2), ol2(1)+1:end-ol2(1), ol2(3)+1:end-ol2(3));



%% Old version


% For shorter variable names
olp = settings.overlap;
olp2 = olp/2;
bid = boundsRangeIdx;

% Determine the section of the image which is needed
result_size = jh_size(result)';
start = 1+(olp2');
start(bid(1,:)) = 1;
stop = result_size - (olp2');
stop(bid(2,:)) = result_size(bid(2,:));

% Crop the result
result = result(start(2):stop(2), start(1):stop(1), start(3):stop(3));


end