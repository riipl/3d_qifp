function [ out ] = run( inputs )
%RUN Summary of this function goes here
%   Detailed explanation goes here

    %% Initialization
    infoVOI = inputs.infoVOI;
    segmentationVOI = inputs.segmentationVOI;

    featureRootName = inputs.featureRootName;
    out = struct('featureRootName', featureRootName);
    
    %% Calculate pixel voxel sizes
    % Find pixel spacing in millimeters in plane and between planes
    ySpacing = abs(infoVOI{1}.PixelSpacing(1));
    xSpacing = abs(infoVOI{1}.PixelSpacing(2));
    zSpacing = abs(infoVOI{1}.zResolution);
    
    %% Calculate Sphericity 
    area = calculateSurfaceArea(segmentationVOI, xSpacing, ySpacing, ...
        zSpacing);
    volume = calculateVolume(segmentationVOI, xSpacing, ySpacing, ...
        zSpacing);
    sphericity = (power(pi, 1/3) * power((6*volume), 2/3)) / area;

    %% Return intensity values
    out.output = { ... 
        struct(...
        'name', 'value',...
        'value', sphericity ...
        ) ...
    };
end

