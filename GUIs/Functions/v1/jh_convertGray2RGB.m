function RGB = jh_convertGray2RGB(gray)
    if size(gray, 3) == 1
        RGB(:,:,1) = gray;
        RGB(:,:,2) = gray;
        RGB(:,:,3) = gray;
    elseif size(gray, 3) > 1 && size(gray, 4) == 1
        RGB(:,:,:,1) = gray;
        RGB(:,:,:,2) = gray;
        RGB(:,:,:,3) = gray;
    end
end
