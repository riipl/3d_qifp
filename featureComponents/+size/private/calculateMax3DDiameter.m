function max3DDiameter =  calculateMax3DDiameter(segVOI, xSpacing, ySpacing, zSpacing)
% CALCULATE3DMAXDIAMETER This function calculates the maximum 3D diameter (in mm based on voxel 
% dimensions).   

    X = []; Y = []; Z = [];
    
    for slice = 1:size(segVOI,3)  % Go through each slice
        
        tempCoordinates = cell2mat(bwboundaries(segVOI(:,:,slice)));
        
        if isempty(tempCoordinates)==0
            x = xSpacing*tempCoordinates(:,2);
            y = ySpacing*tempCoordinates(:,1);
            z = zSpacing*slice*ones(numel(x),1);
            X = [X;x];
            Y = [Y;y];
            Z = [Z;z];
        end
    end
    
    coordinates = [X,Y,Z];
    distances = pdist(coordinates);
    max3DDiameter = max(distances);
    
    return;
