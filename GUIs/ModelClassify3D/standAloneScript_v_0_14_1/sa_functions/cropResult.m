function result = cropResult(result, settings, bc1, bc2)

% For shorter variable names
olp = settings.overlap;

% Determine the section of the image which is needed
result_size = jh_size(result)';
start = 1+(olp');
start(bc1) = 1;
stop = result_size+1 - (olp');
stop(bc2) = result_size(bc2) + 1;

% Crop the result
result = result(start(2):stop(2), start(1):stop(1), start(3):stop(3));

end