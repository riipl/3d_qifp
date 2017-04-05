function [ out ] = run( inputs )
%RUN Summary of this function goes here
%   Detailed explanation goes here

    %% Initialization
    segmentationVOI = inputs.segmentationVOI;
        
    %% Calculate New Segmentation
    newVOI = fillHoles(segmentationVOI); 
      
    %% Return New Segmentation
    out = { ... 
        struct(...
        'name', 'segmentationVOI',...
        'value', newVOI ...
        )
    };
end

