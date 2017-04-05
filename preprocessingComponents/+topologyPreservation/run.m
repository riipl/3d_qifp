function [ out ] = run( inputs )
%RUN Summary of this function goes here
%   Detailed explanation goes here

    %% Initialization
    infoVOI = inputs.infoVOI;
    segmentationVOI = inputs.segmentationVOI;
    radius = inputs.radius;
    
    %% Calculate pixel voxel sizes
    % Find pixel spacing in millimeters in plane and between planes
    ySpacing = abs(infoVOI{1}.PixelSpacing(1));
    xSpacing = abs(infoVOI{1}.PixelSpacing(2));
    zSpacing = abs(infoVOI{2}.ImagePositionPatient(3) - ...
        infoVOI{1}.ImagePositionPatient(3));
    
    %% Calculate New Segmentation
    newVOI = topologyPreservation(segmentationVOI, radius, xSpacing, ySpacing, zSpacing);
      
    %% Return New Segmentation
    out = { ... 
        struct(...
        'name', 'segmentationVOI',...
        'value', newVOI ...
        )
    };
end

