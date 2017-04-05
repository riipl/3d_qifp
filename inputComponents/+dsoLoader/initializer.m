function [ indexTableArray ] = initializer( inputs )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% If there's a root directory then concatenate the directories
if isfield(inputs, 'inputRoot')
    inputRoot = inputs.inputRoot;
    inputs.dicomFolder = fullfile(inputRoot, inputs.dicomFolder);
    inputs.dsoFolder = fullfile(inputRoot, inputs.dsoFolder);
end


%% Create the index
indexTableArray = runIndex(inputs);

%% Return list of UIDs that are going to be processed
if strcmp(inputs.uidToProcess, 'all')
    indexTableArray.uidToProcess = indexTableArray. ...
                                    DcmSegmentationObjectFileTable.keys;
else 
    indexTableArray.uidToProcess = strsplit(inputs.uidToProcess, ',');
end


end

