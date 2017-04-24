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
    
    %% Split all radii that are going to be calculated
    radius = strsplit(inputs.sphereRadius, ',');
    nRadius = numel(radius);
    out.output = {};
    for iRadius = 1:nRadius
        %% Calculate LVII
        lviiValues = computeLVII(segmentationVOI, str2num(radius{iRadius}),...
             xSpacing, ySpacing, zSpacing);
        if all(isnan(lviiValues))
            continue
        end
        %% Return intensity values
        out.output = [out.output, { ... 
            struct(...
            'name', ['Radius.' num2str(radius{iRadius}) 'mm'],...
            'value', lviiValues ...
            ) ...
            struct(...
                'name', ['Radius.' num2str(radius{iRadius}) 'mm.harmonicMean'],...
                'value', harmmean(lviiValues) ...
            ) ...
        }];
    end
end

