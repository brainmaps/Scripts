function result = GUI_watershed(im, WS, data, waitbarHandle)

%% Calculate the desired input image

pWS.preStep.method = WS.available{WS.inUse};
pWS.preStep.bInvert = WS.pWS.preStep.bInvert;
pWS.preStep.bInvertRaw = WS.pWS.preStep.bInvertRaw;
pWS.preStep.parameters = WS.pWS.preStep.parameters;
pWS.parameters.conn = WS.pWS.parameters.conn;
pWS.parameters.maxDepth = WS.pWS.parameters.maxDepth;
pWS.parameters.maxSize = WS.pWS.parameters.maxSize;
pWS.scriptPath = WS.pWS.scriptPath;

result.matrixed = GUI_watershedFromScript(im, pWS, ...
    'waitbar', waitbarHandle, 0, .66, ...
    'prefType', data.prefType, ...
    'dimensions', WS.pWS.parameters.dimensions, ...
    'anisotropic', data.anisotropic);


%% WS list and size

[result.listed.WS, result.listed.seeds] = GUI_labeledWS2Listed( ...
    result.matrixed{1}, result.matrixed{2}, ...
    dip2MatConnectivity(WS.pWS.parameters.conn, WS.pWS.parameters.dimensions), ...
    'waitbar', waitbarHandle, .66, 1);


        
end

function matConn = dip2MatConnectivity(dipConn, dimensions)
switch dipConn
    case 1
        if dimensions == 2
            matConn = 4;
        elseif dimensions == 3
            matConn = 6;
        end
    case 2
        if dimensions == 2
            matConn = 8;
        elseif dimensions == 3
            matConn = 18;
        end
    case 3
        if dimensions == 3
            matConn = 26;
        end
end
end
