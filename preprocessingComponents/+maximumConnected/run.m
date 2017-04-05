function [ out ] = run( inputs )
%RUN Summary of this function goes here
%   Detailed explanation goes here

    %% Initialization
    segmentationVOI = inputs.segmentationVOI;
    segmentationInfo = inputs.segmentationInfo;
    reportOriginalRegions = inputs.reportOriginalRegions;
    connectivity = inputs.connectivity;
        
    %% Calculate New Segmentation
    [newVOI, nRegions] = maximumConnected(segmentationVOI, connectivity); 
    
    %% Add the original number of regions in the metadata if asked
    if reportOriginalRegions
        segmentationInfo.countOfOriginalSegmentedRegions = nRegions;
    end
    
    %% Return New Segmentation
    out = { ... 
        struct(...
            'name', 'segmentationVOI',...
            'value', newVOI ...
        )
        struct(...
            'name', 'segmentationInfo',...
            'value', segmentationInfo ...
        )
    };
end

