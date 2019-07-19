function max3DDiameter =  calculateMax3DDiameter(segVOI, xSpacing, ySpacing, zSpacing)
% CALCULATE3DMAXDIAMETER This function calculates the maximum 3D diameter (in mm based on voxel 
% dimensions).   

    X = []; Y = []; Z = [];
    
    % Go through each slice to find boundary points
    for slice = 1:size(segVOI,3)  
        
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
    
    % Determine distances between all points on boundary 
    % Updated with if statement to save memrory for large ROIs 
    if length(coordinates) < 75000      
        distances = pdist(coordinates);   
    else 
        distances = [];
        
        % Loop through each point and measure distance between all others
        for i=1:length(coordinates)-1                    
            thisPoint = coordinates(i,:);
            allOtherPoints = coordinates(i+1:end,:);    % Avoids duplicate measures already taken
            thisPointDistances = pdist2(thisPoint, allOtherPoints);
            distances = [distances; max(thisPointDistances)];
        end
        
    end
    
    max3DDiameter = max(distances);
    
    return;
