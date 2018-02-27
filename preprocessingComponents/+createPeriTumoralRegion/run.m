function [ out ] = run( inputs )
%RUN Run peri-tumoral pre-processing module

    %% Initialization
    infoVOI = inputs.infoVOI;
    segmentationVOI = inputs.segmentationVOI;
    operation = inputs.operation;
    distance = inputs.distance;
    
    %% Calculate pixel voxel sizes
    % Find pixel spacing in millimeters in plane and between planes
    ySpacing = abs(infoVOI{1}.PixelSpacing(1));
    xSpacing = abs(infoVOI{1}.PixelSpacing(2));
    zSpacing = abs(infoVOI{2}.ImagePositionPatient(3) - infoVOI{1}.ImagePositionPatient(3));
    
    %% Calculate New Segmentation
    newVOI = createPeriTumoralRegion(segmentationVOI, operation, distance, xSpacing, ySpacing, zSpacing);
      
    %% Return New Segmentation
    out = { ... 
        struct(...
        'name', 'segmentationVOI',...
        'value', newVOI ...
        )
    };
end
