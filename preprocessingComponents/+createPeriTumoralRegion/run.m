function [ out ] = run( inputs )
%RUN Run peri-tumoral pre-processing module

    %% Initialization
    infoVOI = inputs.infoVOI;
    segmentationVOI = inputs.segmentationVOI;
    operation = inputs.operation;
    distance = inputs.distance;
    
    %% Calculate voxel sizes and create new segmentation
    % Find voxel spacing in millimeters the create new peri-tumoral segmentation
    if infoVOI{1, 1}.Modality == 'MG'   % If mammogram, create a 2D peri-tumoral region
        ySpacing = abs(infoVOI{1, 1}.ImagerPixelSpacing(1));
        xSpacing = abs(infoVOI{1, 1}.ImagerPixelSpacing(2));
        
        newVOI = createPeriTumoralRegion2D(segmentationVOI, operation, distance, xSpacing, ySpacing);
    else
        ySpacing = abs(infoVOI{1}.PixelSpacing(1));
        xSpacing = abs(infoVOI{1}.PixelSpacing(2));
        zSpacing = abs(infoVOI{2}.ImagePositionPatient(3) - infoVOI{1}.ImagePositionPatient(3));
        
        newVOI = createPeriTumoralRegion3D(segmentationVOI, operation, distance, xSpacing, ySpacing, zSpacing);
    end
    
    %% Return New Segmentation
    out = { ... 
        struct(...
        'name', 'segmentationVOI',...
        'value', newVOI ...
        )
    };
end
