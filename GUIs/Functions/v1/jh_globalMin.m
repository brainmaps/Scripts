function gm = jh_globalMin(M)

gm = squeeze(min(M));

while size(gm, 2) > 1
    
    gm = squeeze(min(gm));
    
end

end