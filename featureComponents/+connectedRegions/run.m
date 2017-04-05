function [ out ] = run( inputs )
%RUN Summary of this function goes here
%   Detailed explanation goes here

    %% Initialization
    segmentationVOI = inputs.segmentationVOI;
    connectivity = inputs.connectivity;
    featureRootName = inputs.featureRootName;
    out = struct('featureRootName', featureRootName);

        
    %% Calculate Number of Regions
    bw = bwconncomp(segmentationVOI, connectivity);
	nRegions = numel(bw.PixelIdxList); 
           

    %% Return intensity values
    out.output = { ... 
        struct(...
        'name', 'count',...
        'value', num2str(nRegions) ...
        ) ...
    };
end