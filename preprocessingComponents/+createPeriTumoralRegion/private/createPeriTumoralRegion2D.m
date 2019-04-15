function [ periTumoralVOI ] = createPeriTumoralRegion2D(segmentationVOI, operation, distance, xSpacing, ySpacing)
% CREATEPERITUMORALREGION This function will create a 2D peri-tumoral region (ie. an expansion surrounding the tumor segmentation) 
%           with a distance specified (in mm). Initial implemention for 2D mammogram images.
% Created by:       Sarah Mattonen
% Created on:       2019-04-15

%% Create expanded ROI
voxelDimensions = [xSpacing, ySpacing, 1];
distanceTransformSegmentationVOI = zeros(size(segmentationVOI));

% Perform the distance transform from the tumor segmentation on each 2D slice
for slice = 1:size(segmentationVOI,3) % Go through each slice
        thisSlice = segmentationVOI(:,:,slice);
        if any(thisSlice(:)) % Check if this slice contains the segmentation
            distanceTransformSegmentationSlice = bwdistsc1({thisSlice}, voxelDimensions, distance*2);
            distanceTransformSegmentationVOI(:,:,slice) = cell2mat(distanceTransformSegmentationSlice);
        else
            distanceTransformSegmentationVOI(:,:,slice) = thisSlice;
        end
end

% Determine whether to include or exclude segmentationVOI in final VOI
if (strcmp(operation, 'include'))
    periTumoralVOI = (distanceTransformSegmentationVOI <= distance);           
elseif (strcmp(operation, 'exclude'))
    periTumoralVOI = (distanceTransformSegmentationVOI <= distance) & (distanceTransformSegmentationVOI > 0);           
else
    periTumoralVOI = segmentationVOI;
    logger('WARN', ['Could not complete preprocessing component createPeriTumoralRegion: Invalid operation specified.']);
end
  
end 
