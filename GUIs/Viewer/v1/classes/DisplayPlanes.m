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
            
            this.XY = jh_convertGray2RGB(this.XY);
            this.XZ = jh_convertGray2RGB(this.XZ);
            this.ZY = jh_convertGray2RGB(this.ZY);
            
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
        
    end
    
end