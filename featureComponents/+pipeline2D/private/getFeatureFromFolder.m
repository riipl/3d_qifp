function C = getFeatureFromFolder(conf, lesion)
% getFeatureFromFolder()
%
% Input:
%       dicomImage            : Matrix containing intensity values of the
%                               dicom slice.
%       dicomSegmentation     : A list of X and Y Values.
%       dicomInfo:            : Dicom Information.
%       organ                 : liver/lung/..., see get_config_profile.m
%
% Output:
%      Cell array with a list of features names in the first column and values in the second column. 
%
% Originally created by Jiajing Xu
% Modified by Sebastian Echegaray

% Set up environment
% [rootFolder, ~, ~] = fileparts(mfilename('fullpath'));
% addpath(fullfile(rootFolder, '/supporting_routines'));
% addpath(fullfile(rootFolder, '/supporting_routines/shape'));
% addpath(fullfile(rootFolder, '/supporting_routines/edge_sharpness'));
% addpath(fullfile(rootFolder, '/supporting_routines/gabor'));
% addpath(fullfile(rootFolder, '/supporting_routines/gabor/simplegabortb-v1.0.0'));
% addpath(fullfile(rootFolder, '/supporting_routines/glcm'));

config_profile = get_config_profile(lesion.ORGAN);



%% 1. Extract features

    
    info = conf.dicomInfo; 
    I = conf.dicomImage;    
    
    lesion.dicomFileName = info.Filename;
    if ~isfield(info, 'PixelSpacing'), info.PixelSpacing(1)=1; end
    lesion.PixelSpacing = info.PixelSpacing(1);

    lesion.NormalizationFactor = 1;

    [res,lesion] = getFeatureFromDCM_AIM(I, info, lesion.dicomFileName, '', 0, lesion, '', config_profile);
    features = res.features;
    featureList = res.featureList;

%% save to excel file, and make collage
C = cell(length(featureList)+1, 2);

% this is to shuffle the order of the image for Sandy: 8/20/2012
% newOrder = [1,3,9,8,5,7,4,6,2];
% lesions = reshuffle(lesions, newOrder);
% features = features(:, newOrder);

rowOffset = 12;
% feature name column
C{1,1} = '[ Patient Name (DICOM) ]';
C{2,1} = '[ Slice Location (DICOM)]';
C{3,1} = '[ Slice Number (DICOM)]';
C{4,1} = '[ Slice Thickness (DICOM) ]';
C{5,1} = '[ Series Instance UID (DICOM) ]';
C{6,1} = '[ Study Instance UID (DICOM) ]';
C{7,1} = '[ SOPUID of Instance (DICOM) ]';
C{8,1} = '[ Organ (Configuration) ]';
C{9,1} = '[ Control Points X ]';
C{10,1} = '[ Control Points Y ]';
C{11,1} = '[ Number of Interpolated Control Points ]';
C{12,1} = '[ Pixel Spacing ]';

for ii = 1:length(featureList)
    C{ii+rowOffset, 1} = featureList{ii};
end

% column headers
pp = 1;

    % read patient name from DICOM file
    tmpDicomInfo = conf.dicomInfo;
    if isfield(tmpDicomInfo, 'PatientName') && isfield(tmpDicomInfo.PatientName, 'FamilyName') 
        tmpPatientName = tmpDicomInfo.PatientName.FamilyName;
    else
        tmpPatientName = 'BLANK_NAME';
    end
    C{1, pp+1} = tmpPatientName;   % second row: patient name (from DICOM)
    C{2, pp+1} = tmpDicomInfo.SliceLocation;        % ninth row, the location of the slice
    C{3, pp+1} = tmpDicomInfo.InstanceNumber;      % Slice number
    C{4, pp+1} = tmpDicomInfo.SliceThickness;      % The thickness of the slice
    C{5, pp+1} = tmpDicomInfo.SeriesInstanceUID;   % Dicom Series UID
    C{6, pp+1} = tmpDicomInfo.StudyInstanceUID;    % Dicom Study UID
    C{7, pp+1} = tmpDicomInfo.SOPInstanceUID;      % Dicom ID
    C{8, pp+1} = lesion.ORGAN;                % Under which organ have we run the experiment
    C{9, pp+1} =  strjoin(strtrim(cellstr(num2str(lesion.roi.x, 30)))', '||'); %X control Points
    C{10, pp+1} =  strjoin(strtrim(cellstr(num2str(lesion.roi.y, 30)))', '||'); %U control Points
    C{11, pp+1} =  numel(lesion.roi_interpolated.x);        % Number of interpolated control points
    C{12, pp+1} = lesion.PixelSpacing;
    % feature values
    for ll = 1:length(features)
        C{ll+rowOffset, pp+1} = features(ll);
    end
    pp = pp + 1;
    
    %%
end




