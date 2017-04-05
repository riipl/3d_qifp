function glcm = createGLCM(intensityVOI, segmentationVOI, direction, ...
    distance, spacing, grayLevels, minIntensity, maxIntensity)
%createGLCM Summary of this function goes here
%   Detailed explanation goes here

%% Find origins and convert it to real life coordinates (mm)
[originRow, originCol, originDepth] = ind2sub(size(segmentationVOI), ...
    find(segmentationVOI));
originPoints = [originRow, originCol, originDepth] .* ...
    repmat(spacing, [size(originRow,1), 1]);

%% Convert directions into real life coordinates (mm)
displacement = direction;
displacement = (displacement / norm(displacement)).* distance;

%% Find destination points
destPoints = originPoints + repmat(displacement, ... 
    [size(originPoints,1), 1]);

% Interpolate mask to see if any destination point is outside the
% mask
originalRowLength = (1:size(intensityVOI,1)) * spacing(2);
originalColLength = (1:size(intensityVOI,2)) * spacing(1);
originalDepthLength = (1:size(intensityVOI,3)) * spacing(3);
[X,Y,Z] = meshgrid(originalColLength, originalRowLength, ...
    originalDepthLength);

%% Find new segmentation mask for interpolated points
newMask = (interp3(X,Y,Z,double(segmentationVOI),destPoints(:,2), ...
    destPoints(:,1), destPoints(:,3)) > 0.5);
% Eliminate destination points that are away from segmentation mask
maskedDestPoints = destPoints(newMask,:);

% Find the gray levels of destination points
destinationValues = interp3(X,Y,Z,intensityVOI,maskedDestPoints(:,2), ...
    maskedDestPoints(:,1), maskedDestPoints(:,3));

% Origin Values
maskedOriginPoints = [originRow(newMask), originCol(newMask), ...
    originDepth(newMask)];
originValues = intensityVOI(sub2ind(size(intensityVOI), ...
    maskedOriginPoints(:,1), maskedOriginPoints(:,2), ...
    maskedOriginPoints(:,3)));

%% Convert them into gray levels
% Using histcounts to get the edge of the histograms as discretize
% did not return the edge values in MATLAB Version: 8.6.0.267246 (R2015b)
if ~isnan(minIntensity) 
    originValues(originValues < minIntensity) = minIntensity;
    originValues(originValues > maxIntensity) = maxIntensity;
    destinationValues(destinationValues < minIntensity) = minIntensity;
    destinationValues(destinationValues > maxIntensity) = maxIntensity;
    [~,E] = histcounts([minIntensity, maxIntensity], grayLevels);
else
    [~,E] = histcounts([originValues;destinationValues], grayLevels);
end

grayLevelOriginPoints = discretize(originValues, E);
grayLevelDestPoints = discretize(destinationValues, E);

%% GLCM
glcm = accumarray([grayLevelOriginPoints, grayLevelDestPoints], 1, ... 
    [grayLevels, grayLevels]);
end