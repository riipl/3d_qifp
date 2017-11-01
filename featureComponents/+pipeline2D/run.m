function [ out ] = run( inputs )
%RUN Summary of this function goes here
%   Detailed explanation goes here

    %% Initialization
    featureRootName = inputs.featureRootName;
    out = struct('featureRootName', featureRootName);

    intensityVOI = inputs.intensityVOI;
    intensityInfo = inputs.infoVOI;
    customConfig = struct('glcmMinAndMaxIntensity', inputs.glcmMinAndMaxIntensity, ...
        'glcmNumLevels', inputs.glcmNumLevels, ...
        'glcmSymmetric', inputs.glcmSymmetric);

    segmentationVOI = inputs.segmentationVOI;
    
    % Create lesion template structure for configuration
    lesion.uid = '';
    lesion.AIM_UID = '';
    lesion.SOPInstanceUID = '';
    lesion.chs = [];
    lesion.chsy = [];
    lesion.lesionName = '';
    lesion.lesionComment = '';
    lesion.userName = '';
    lesion.patientName = '';
    lesion.patientId = '';
    lesion.valid = 1;
    lesion.roi = struct();
    lesion.roi.x = [];
    lesion.roi.y = [];
    lesion.ORGAN = inputs.organ;
    
    %% Choose which slices to send to the 2D Pipeline
    
    %% Middle Slice 
    middleSliceFeatures = {};
    if inputs.middleSlice
        [segmentationSlice, intensitySlice, intensitySliceInfo] ...
            = selectMiddleSlice(segmentationVOI, intensityVOI, intensityInfo);
        middleSliceFeatures = find2DFeatures(segmentationSlice, ...
            intensitySlice, intensitySliceInfo, lesion, customConfig);
    end
    
    %% Largest Slice
    largestSliceFeatures = {};
    if inputs.largestSlice
        [segmentationSlice, intensitySlice, intensitySliceInfo] ...
            = selectLargestSlice(segmentationVOI, intensityVOI, intensityInfo);
        largestSliceFeatures = find2DFeatures(segmentationSlice, ...
            intensitySlice, intensitySliceInfo, lesion, customConfig);
    end
    
    %% Return intensity values
    out.output = horzcat( ...
        convertOutputToStructureArray(middleSliceFeatures, ...
                                      inputs.middleSliceName, ...
                                      inputs.separator), ...
        convertOutputToStructureArray(largestSliceFeatures, ...
                                      inputs.largestSliceName , ...
                                      inputs.separator) ...
        );
end

%% Find 2D features from a slice
function features2D = find2DFeatures(segmentationSlice, intensitySlice, ...
    intensitySliceInfo, lesion, customConfig)
    % If there are multiple disjoint segmentations keep the largest one:
        L = bwconncomp(segmentationSlice, 8);
        vsize = zeros(size(L.PixelIdxList));
        
        % Find the volume of each region
        for pil = 1:numel(L.PixelIdxList);
            vsize(pil) = numel(L.PixelIdxList{pil});
        end
        
        [~, idxA] = max(vsize);

        % Get the largest region by eliminating the mask everywhere else
        for tti = 1:numel(L.PixelIdxList);
            if tti == idxA 
                continue;
            end
            segmentationSlice(L.PixelIdxList{tti}) = 0;
        end

    % Set image and dicom metadata
    conf.dicomImage = intensitySlice;
    conf.dicomInfo = intensitySliceInfo;
    
    % Convert DSO mask to control points
    lesion.SOPInstanceUID = intensitySliceInfo.SOPInstanceUID;
    lesion = maskToPoints(segmentationSlice, lesion);
        features2D = getFeatureFromFolder(conf, lesion, customConfig);
end

%% Convert output to normal structure Array
function outputArray = convertOutputToStructureArray(output, prefix, separator)
    numOfFeatures = size(output, 1);
    outputArray = cell(1, numOfFeatures);
    for iFeature = 1:numOfFeatures
        outputArray{iFeature} = struct( ...
        'name', [prefix, separator, output{iFeature,1}],...
        'value', output{iFeature,2}...
        );
    end
end

%% Select Middle Slice
function [segmentationSlice, intensitySlice, intensitySliceInfo] ...
    = selectMiddleSlice(segmentationVOI, intensityVOI, intensityInfo)
    slicesWithData = logical(squeeze(sum(sum(segmentationVOI(:,:,:),1),2)));
    
    %Ignore padding slices
    segmentationVOI = segmentationVOI(:,:,slicesWithData);
    intensityVOI = intensityVOI(:,:,slicesWithData);
    intensityInfo = intensityInfo(slicesWithData);
    
    % Select middle slice
    middleSlice = ceil(size(squeeze(segmentationVOI),3) / 2);
    segmentationSlice = logical(segmentationVOI(:,:,middleSlice));
    intensitySlice = intensityVOI(:,:, middleSlice);
    intensitySliceInfo = intensityInfo{middleSlice};
end

%% Select Largest Slice
function [segmentationSlice, intensitySlice, intensitySliceInfo] ...
    = selectLargestSlice(segmentationVOI, intensityVOI, intensityInfo)
    slicesWithData = logical(squeeze(sum(sum(segmentationVOI(:,:,:),1),2)));
    
    %Ignore padding slices
    segmentationVOI = segmentationVOI(:,:,slicesWithData);
    intensityVOI = intensityVOI(:,:,slicesWithData);
    intensityInfo = intensityInfo(slicesWithData);
    
    % Select largest slice
    numberOfSlices = size(segmentationVOI, 3);
    maxConnectedVoxelsPerSlice = zeros(numberOfSlices,1);
    for iSlice = 1:numberOfSlices
        segmentationSlice = segmentationVOI(:,:, iSlice);
        L = bwconncomp(segmentationSlice, 8);
        vsize = zeros(size(L.PixelIdxList));
        
        % Find the volume of each region
        for pil = 1:numel(L.PixelIdxList);
            vsize(pil) = numel(L.PixelIdxList{pil});
        end
        
        maxConnectedVoxelsPerSlice(iSlice) = max(vsize);
    end
    
    % Select largest slice
    [~, largestSlice] = max(maxConnectedVoxelsPerSlice);
    segmentationSlice = logical(segmentationVOI(:,:,largestSlice));
    intensitySlice = intensityVOI(:,:, largestSlice);
    intensitySliceInfo = intensityInfo{largestSlice};
end


%% Convert Segmentation Slice into X,Y values
function lesion = maskToPoints(segmentationSlice, lesion) 
    segslice = imfill(segmentationSlice,'holes');
    segline = bwboundaries(segslice, 'noholes');
    segline = segline{1};
    segline = circshift(segline, [0 1]);
    lesion.roi = struct();
    lesion.roi.x = segline(:,1);
    lesion.roi.y = segline(:,2);
end
