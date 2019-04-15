function [ periTumoralVOI ] = createPeriTumoralRegion3D(segmentationVOI, operation, distance, xSpacing, ySpacing, zSpacing)
% CREATEPERITUMORALREGION This function will create a 3D peri-tumoral region (ie. an expansion surrounding the tumor segmentation) 
%           with a distance specified (in mm)
% Created by:       Sarah Mattonen
% Created on:       2018-02-08

%% Create expanded ROI
% Perform the distance transform from the tumor segmentation
voxelDimensions = [xSpacing, ySpacing, zSpacing];
distanceTransformSegmentationVOI = bwdistsc1(segmentationVOI, voxelDimensions, distance*2);

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
