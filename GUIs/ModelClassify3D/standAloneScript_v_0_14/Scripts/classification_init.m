global classification

%{
classification structure
    .result
        .matrixed {minima, WS, score, scoreCutOff}
        .listed (possibly in future versions)
        .names {}
    .groundTruth
        .matrixed
            .class1
            .class2
        .listed
    .pClassification    
        .model
        .method

%}


% The results:
% features.classification.result{1} -> minima
% features.classification.result{2} -> WS

classification.available = { ...
    'KNN', ...
    'SVM'};
classification.inUse = 2;


