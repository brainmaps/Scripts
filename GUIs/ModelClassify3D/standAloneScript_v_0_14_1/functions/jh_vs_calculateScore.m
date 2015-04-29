function score = jh_vs_calculateScore(values, feature)


sigma = 1 * std(values);
mu = mean(values);

% Create score vector
% score = sign(feature-mu) .* (exp(-(feature - mu).^2 / (2*sigma^2)) - 1); % Gaussian shaped but defines larger or smaller
score = exp(-(feature - mu).^2 / (2*sigma^2)); % The original
% score = mu - feature;
% score = jh_normalizeMatrix(score);


end