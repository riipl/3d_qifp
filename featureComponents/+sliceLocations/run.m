function [ out ] = run( inputs )
%RUN Summary of this function goes here
%   Detailed explanation goes here

    %% Initialization
    featureRootName = inputs.featureRootName;
    out = struct('featureRootName', featureRootName);
    
    %% Extract intensity values
    intensityVOI = inputs.intensityVOI;
    segmentationVOI = inputs.segmentationVOI;
    intensityValues = intensityVOI(segmentationVOI);

    %% Return intensity values
    out.output = { ... 
        struct(...
        'name', 'histogram',...
        'value', intensityValues ...
        ) ...
    };
end

