function [ indexTableArray ] = runIndex( input )
%RUNINDEX Summary of this function goes here
%   Detailed explanation goes here

%% Initialize to local variables to save keystrokes
stackFolder = input.dicomFolder;
dsoFolder = input.dsoFolder;
recomputeHashTable = input.recomputeHashTable;
saveHashTable = input.saveHashTable;

%% Check if the index exists and load it if it does, if it doesn't create it
% Dicom Series
if ~exist(fullfile(stackFolder,...
        'dicomImageIndex.mat'), 'file') || recomputeHashTable
    tmpIndexTableArray = ....
        create_index(stackFolder); 
else
    tmpLoadVar = ...
        load(fullfile(stackFolder, ...
        'dicomImageIndex.mat'));
    tmpIndexTableArray.DcmImageFileTable = ...
            tmpLoadVar.DcmImageFileTable;
    tmpIndexTableArray.DcmImageFileSeriesNumber =  ...
            tmpLoadVar.DcmImageFileSeriesNumber;
    tmpIndexTableArray.DcmImageFileSeriesLocation = ...
            tmpLoadVar.DcmImageFileSeriesLocation;
    tmpIndexTableArray.DcmImageFileSeriesLocationsAvailable = ...
            tmpLoadVar.DcmImageFileSeriesLocationsAvailable;
    clear tmpLoadVar;
end

% Dicom segmentation Object
if ~exist(fullfile(dsoFolder,...
        'dicomSegmentationIndex.mat'), 'file') || recomputeHashTable
    tmpIndexTableArray2 =  ...
            create_index(dsoFolder);
        tmpIndexTableArray.DcmSegmentationObjectFileTable = ...
            tmpIndexTableArray2.DcmSegmentationObjectFileTable;
        clear tmpIndexTableArray2;    
else
    tmpLoadVar = ...
        load(fullfile(dsoFolder, ...
            'dicomSegmentationIndex.mat'));
    tmpIndexTableArray.DcmSegmentationObjectFileTable = ...
        tmpLoadVar.DcmSegmentationObjectFileTable;
    clear tmpLoadVar;
end
     
indexTableArray = tmpIndexTableArray;
clear tmpIndexArray;


%% Save the indexes in their root folders;
if saveHashTable
    % Dicom Images Index
    DcmImageFileTable = indexTableArray.DcmImageFileTable;
    DcmImageFileSeriesNumber = indexTableArray.DcmImageFileSeriesNumber;
    DcmImageFileSeriesLocation = ...
    indexTableArray.DcmImageFileSeriesLocation;
    DcmImageFileSeriesLocationsAvailable = ...
    indexTableArray.DcmImageFileSeriesLocationsAvailable;

    save(fullfile(stackFolder, ...
        'dicomImageIndex.mat'), ...
        'DcmImageFileTable', 'DcmImageFileSeriesNumber', ...
        'DcmImageFileSeriesLocation', 'DcmImageFileSeriesLocationsAvailable');
    clear DcmImageFileTable;

    % Dicom Segmentation Index
    DcmSegmentationObjectFileTable = indexTableArray.DcmSegmentationObjectFileTable;
    save(fullfile(dsoFolder, ...
        'dicomSegmentationIndex.mat'), ...
        'DcmSegmentationObjectFileTable');
    clear DcmSegmentationObjectFileTable;
end
end

