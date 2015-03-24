
%compute 2 minimas such that min1
        toydistlist = [10 8 7 9 12 13 9 14];
        while true
            %calculate minima
            [~, minind1] = min(toydistlist);
            %drop minind and recalculate minima
            toydistlist(minind1) = Inf;
            [~, minind2] = min(toydistlist);
            
            if abs(minind1 - minind2) == 1
                break
            elseif minind1 == minind2
                %well, shit
                '';
                break
            else
                toydistlist(minind2) = Inf; 
            end    
        end