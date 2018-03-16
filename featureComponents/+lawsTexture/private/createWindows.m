function [windowsPoints, percentageCovered] = createWindows(intensityVOI, segmentationVOI, resolution, ...
    samplePoints, spacing)

%% Find origins and convert it to real life coordinates (mm)
[originRow, originCol, originDepth] = ind2sub(size(segmentationVOI), ...
    find(segmentationVOI));
originPoints = [originRow, originCol, originDepth] .* ...
    repmat(spacing, [size(originRow,1), 1]);

%% Create mapping to the direction and distances needed for the windowMapping

halfSamplePoints = floor(samplePoints/2);
distanceRow = zeros(2*halfSamplePoints, 1);
direction = zeros(2*halfSamplePoints, 3);
iDistance = 1;
for zPoint = -halfSamplePoints:halfSamplePoints
    for xPoint = -halfSamplePoints:halfSamplePoints
        for yPoint = -halfSamplePoints:halfSamplePoints
            if all([zPoint,xPoint,yPoint]==0)
                continue
            end
            distanceRow(iDistance) = max(abs([yPoint, xPoint, zPoint]))*resolution;
            direction(iDistance, :) = [yPoint, xPoint, zPoint];
            iDistance = iDistance + 1;
        end
    end
end

%% Calculate displacement direction and distance
numDirections = size(direction,1);
% Calculate displacement
% Introduced on 2017b: vecnorm(displacement, 2, 2)
displacementNorm = sqrt(sum(direction.^2,2));
displacement = direction ./ repmat(displacementNorm, [1 3]) .* repmat(distanceRow, [1,3]);

% Change displacements to make directions in the 3rd Dimension
displacement3D = reshape(displacement',1,3,numDirections);
displacement3D(1,:,numDirections+1) = [0,0,0];

%% Find destination points
originPoints3D = repmat(originPoints,[1,1,size(displacement3D,3)]);
destPoints3D = originPoints3D + repmat(displacement3D, ... 
    [size(originPoints,1), 1, 1]);

% Interpolate mask to see if any destination point is outside the
% mask
originalRowLength = (1:size(intensityVOI,1)) * spacing(1);
originalColLength = (1:size(intensityVOI,2)) * spacing(2);
originalDepthLength = (1:size(intensityVOI,3)) * spacing(3);
[X,Y,Z] = meshgrid(originalColLength, originalRowLength, ...
    originalDepthLength);

%% Find new segmentation mask for interpolated points
destPoints3DConcat = reshape(shiftdim(destPoints3D,2), ...
    [(numDirections+1)*size(originPoints,1), 3]);
    % Each numDirections*+1 is a new center point

newMask = (interp3(X,Y,Z,double(segmentationVOI),squeeze(destPoints3DConcat(:,2)), ...
    squeeze(destPoints3DConcat(:,1)), squeeze(destPoints3DConcat(:,3))) > 0.5);

% If there is a point that is outside the segmentation then remove the
% whole center point
newWholeMask = true(size(newMask));
step = numDirections+1;
numberOfComputedPoints = size(originPoints,1);
for iOriginPoint = 0:(size(originPoints,1)-1)
    iterRange = (iOriginPoint*step+1):((iOriginPoint+1)*step);
    if any(newMask(iterRange)==0)
        newWholeMask(iterRange) = 0;
        numberOfComputedPoints = numberOfComputedPoints - 1;
    end
end

percentageCovered = double(numberOfComputedPoints) ./ size(originPoints, 1);

% Eliminate destination points that are away from segmentation mask
maskedDestPoints = destPoints3DConcat(newWholeMask,:);

%% Separate windows for each origin point

windowsPoints = zeros(samplePoints, samplePoints, samplePoints, numberOfComputedPoints);
numberOfPointsInAWindow = size(windowsPoints,1) *  size(windowsPoints,2) * size(windowsPoints,3);
reOrderedMaskedDestPoints = zeros(numberOfPointsInAWindow*numberOfComputedPoints,3);

for iWindow = 1:numberOfComputedPoints
    % Grab a windowframe
    windowFrame = maskedDestPoints(((numDirections+1)*(iWindow-1)+1):((numDirections+1)*iWindow),:);
    
    % Find the gray levels of destination pointsd (It reorders the points
    % to put the center in the center and adds all the values to one
    % matrix.
    reOrderedMaskedDestPoints( ...
        (((iWindow-1)*numberOfPointsInAWindow)+1)...
            :(((iWindow)*numberOfPointsInAWindow)),:) = ...
                vertcat(windowFrame(1:floor(numDirections/2), :), ...
                    windowFrame(numDirections+1,:), ...
                    windowFrame((floor(numDirections/2)+1):(end-1), :));
end
  
    % Find interpolation for all points
    destinationValues = interp3(X,Y,Z,intensityVOI,reOrderedMaskedDestPoints(:,2), ...
        reOrderedMaskedDestPoints(:,1), reOrderedMaskedDestPoints(:,3));

    
for iWindow = 1:numberOfComputedPoints
    localDestinationValues = ...
        destinationValues((((iWindow-1)*numberOfPointsInAWindow)+1): ...
                            (((iWindow)*numberOfPointsInAWindow)));
    % Reshape intensity values to the correct shape
    windowsPoints(:,:,:,iWindow) = reshape(localDestinationValues, [samplePoints, ...
        samplePoints, samplePoints]);
end 
end