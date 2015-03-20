classdef DisplayPlanes < handle
    
    properties
        
        XY
        XZ
        ZY
        
    end
    
    methods 
        
        %% Initialization
        
        function this = DisplayPlanes(xy, xz, zy)
            
            this.XY = xy;
            this.XZ = xz;
            this.ZY = zy;
            
        end
        
        %% Operations
        
        function toRGB(this)
            
            if size(this.XY, 3) == 1, this.XY = jh_convertGray2RGB(this.XY); end
            if size(this.XZ, 3) == 1, this.XZ = jh_convertGray2RGB(this.XZ); end
            if size(this.ZY, 3) == 1, this.ZY = jh_convertGray2RGB(this.ZY); end
            
        end
        
        function resize(this, anisotrFactor, displaySize, type)
            
            ds = displaySize;
            
            if anisotrFactor(1) ~= 1 || anisotrFactor(2) ~= 1
                this.XY = imresize(this.XY, [ds, ds], type);
                this.XY(this.XY < 0) = 0;
            end
            if anisotrFactor(1) ~= 1 || anisotrFactor(3) ~= 1
                this.XZ = imresize(this.XZ, [ds, ds], type);
                this.XZ(this.XZ < 0) = 0;
            end
            if anisotrFactor(2) ~= 1 || anisotrFactor(3) ~= 1
                this.ZY = imresize(this.ZY, [ds, ds], type);
                this.ZY(this.ZY < 0) = 0;
            end
            
        end
        
        function addWhiteDot(this, displaySize)
            
            if isempty(displaySize)
                ds(1) = round(size(this.XY) / 2);
                ds(2) = round(size(this.XZ) / 2);
                ds(3) = round(size(this.YZ) / 2);
            else
                ds = displaySize;
            end
            
            this.XY(ds(2)/2, ds(1)/2, :) = 1;
            this.XZ(ds(3)/2, ds(1)/2, :) = 1;
            this.ZY(ds(2)/2, ds(3)/2, :) = 1;
            
        end
        
        function addSectionalPlanes(this, displaySize)

            if isempty(displaySize)
                ds(1) = round(size(this.XY) / 2);
                ds(2) = round(size(this.XZ) / 2);
                ds(3) = round(size(this.YZ) / 2);
            else
                ds = displaySize;
            end

            % Red, greed and blue lines
            this.XY(:, ds(1)/2, 3) = 1;
            this.XY(ds(2)/2, :, 2) = 1;
            this.XZ(:, ds(1)/2, 3) = 1;
            this.XZ(ds(3)/2, :, 1) = 1;
            this.ZY(ds(2)/2, :, 2) = 1;
            this.ZY(:,ds(3)/2, 1) = 1;

            % Border around each image
            this.XY(:, 1:2, 1) = 1;
            this.XY(:, end-1:end, 1) = 1;
            this.XY(1:2, :, 1) = 1;
            this.XY(end-1:end, :, 1) = 1;
            this.XZ(:, 1:2, 2) = 1;
            this.XZ(:, end-1:end, 2) = 1;
            this.XZ(1:2, :, 2) = 1;
            this.XZ(end-1:end, :, 2) = 1;
            this.ZY(:, 1:2, 3) = 1;
            this.ZY(:, end-1:end, 3) = 1;
            this.ZY(1:2, :, 3) = 1;
            this.ZY(end-1:end, :, 3) = 1;
             
        end
        
        function [gridXY, gridXZ, gridZY] = createIndexGrids(this, imSize, position)
            %   imSize: Size of the image data on which the display grids are
            %       based
            %   position: Current position within the image data
            
            os = imSize;
            
            sizeX = size(this.XY, 2);
            sizeY = size(this.XY, 1);
            sizeZ = size(this.XZ, 1);
            minPositionVisible = position - (round([sizeX, sizeY, sizeZ] / 2)-1);
            maxPosition = position + round([sizeX, sizeY, sizeZ] / 2);
            minPosition = minPositionVisible;
            minPosition(minPosition<0) = 0;
            offset = -minPositionVisible;
            offset(offset < 0) = 0;
            
            %       For xy
            [g1, g2, g3] = meshgrid( ...
                (minPosition(1)*os(2)):os(2):(maxPosition(1)*os(2)), ...
                minPosition(2):maxPosition(2), ...
                (position(3))*os(1)*os(2));
            
            tGridXY = g1+g2+g3+1;
            gridXY = zeros(sizeY, sizeX);
            gridXY(offset(2)+1:end, offset(1)+1:end) = tGridXY;
            
%             disp('XY:');
%             g1(1:3, 1:3)
%             g2(1:3, 1:3)
%             g3(1:3, 1:3)
%             gridXY(1:3, 1:3)
            
            %       For xz
            [g1, g2, g3] = meshgrid( ...
                (minPosition(1)*os(2)):os(2):(maxPosition(1)*os(2)), ...
                (minPosition(3)*os(1)*os(2)):(os(1)*os(2)):(maxPosition(3)*os(1)*os(2)), ...
                position(2));
            
            tGridXZ = g1+g2+g3+1;
            gridXZ = zeros(sizeZ, sizeX);
            gridXZ(offset(3)+1:end, offset(1)+1:end) = tGridXZ;
%             disp('XZ:');
%             g1(1:3, 1:3)
%             g2(1:3, 1:3)
%             g3(1:3, 1:3)
%             tGridXZ(1:3, 1:3)
%             gridXZ(end-3:end, end-3:end)
            
            %       For zy
            [g1, g2, g3] = meshgrid( ...
                (minPosition(3)*os(2)*os(1)):(os(2)*os(1)):(maxPosition(3)*os(2)*os(1)), ...
                minPosition(2):maxPosition(2), ...
                (position(1))*os(2));
            
            tGridZY = g1+g2+g3+1;
            gridZY = zeros(sizeY, sizeZ);
            gridZY(offset(2)+1:end, offset(3)+1:end) = tGridZY;
%             disp('ZY:');
%             g1(1:3, 1:3)
%             g2(1:3, 1:3)
%             g3(1:3, 1:3)
%             gridZY(1:3, 1:3)
            
        end
        
    end
    
end