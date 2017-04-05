function [ out ] = run( inputs )
%RUN Summary of this function goes here
%   Detailed explanation goes here

    %% Initialization
    featureRootName = inputs.featureRootName;
    out = struct('featureRootName', featureRootName);
    
    %% Extract Dicom Stack Information
    volumeInfo = inputs.infoVOI{1};
    volumeOut = extractInfo(volumeInfo, 'original');
    
    %% Extract Patient Information 
    if isfield(volumeInfo, 'PatientName')
        patientOut = extractInfo(volumeInfo.PatientName, 'patient');
    else
        patientOut = {};
    end

    %% Extract Pixel Information 
    if isfield(volumeInfo, 'PixelSpacing')
        pixelSpacing = {... 
            struct(...
                'name',  'pixelSpacing', ...
                'value', volumeInfo.PixelSpacing(1) ...
            )...
        };
    else
        pixelSpacing = {};
    end
    
    %% Extract DSO Information
    segInfo = inputs.segmentationInfo;
    segmentationOut = extractInfo(segInfo, 'segmentation');

        

    %% Return intensity values
    out.output = [patientOut, pixelSpacing, volumeOut, segmentationOut];

end

