function max2DDiameterSlice =  calculateMax2DDiameterSlice(segVOI, xSpacing, ySpacing, zSpacing)
% CALCULATEMAX2DDIAMETERSLICE This function calculates the maximum 2D in-plane (slice) diameter (in mm based on voxel 
% dimensions). The diameter is calculated in the xy-plane (slice) unique to the image loaded (e.g. axial, coronol, or sagittal).  

    allDiameters = zeros(size(segVOI,3),1);
    
    for slice = 1:size(segVOI,3) % Go through each slice
        
        tempCoordinates = cell2mat(bwboundaries(segVOI(:,:,slice)));
        
        if isempty(tempCoordinates) == 0
            x = xSpacing*tempCoordinates(:,2); 
            y = ySpacing*tempCoordinates(:,1); 
            z = zSpacing*slice*ones(numel(x),1);

            coordinates = [x,y,z];
            distances = pdist(coordinates);
            allDiameters(slice) = max(distances);
        end
        
    end
    
    max2DDiameterSlice = max(allDiameters);
    
return;