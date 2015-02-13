function gm = jh_globalMax(M)

gm = squeeze(max(M));

while size(gm, 2) > 1
   
    gm = squeeze(max(gm));
    
end

end