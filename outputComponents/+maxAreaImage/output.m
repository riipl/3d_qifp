function output( inputs )
%OUTPUT Summary of this function goes here
%   Detailed explanation goes here

    %% Initialization 
    volumeVOI = inputs.intensityVOI;
    segVOI = inputs.segmentationVOI;
    
    %% Calculate minimum and maximum values
    if strcmp(inputs.windowLevelPreset, 'custom')
        window = inputs.window;
        level = inputs.level;
    else
        windowAndLevels = levelAndWindowSettings();
        if ~isfield(windowAndLevels, inputs.windowLevelPreset)
            error([inputs.windowLevelPreset ' is not a valid preset']);
        end
        window = windowAndLevels.(inputs.windowLevelPreset).window;
        level = windowAndLevels.(inputs.windowLevelPreset).level;
    end

    minValue = round(level - window/2);
    maxValue = round(level + window/2);

    %% Create segmentation proof
    segmentationProof = showSegmentationProof(volumeVOI, segVOI, ...
        [minValue, maxValue]);
    
    %% Save the image to disk
    outputRoot = inputs.outputRoot;
    outputFolder = inputs.outputFolder;
    outputRootName = inputs.outputRootName;
    outputUidName = inputs.processingUid;
    outputExtension = inputs.outputExtension;
    c = fullfile(outputRoot, outputFolder, ...
        [outputRootName '.' outputUidName '.' outputExtension]);

    imwrite(segmentationProof, c);
end

