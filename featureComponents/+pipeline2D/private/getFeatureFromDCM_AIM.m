function [res, lesion] = getFeatureFromDCM_AIM(IMAGE, INFO, DCM_FILENAME, AIM_FILENAME, SHOW_LESION, lesion, ORGAN, config_profile)

% This script will extract image features from the DICOM and AIM file,
% optionally given the lesion and ORGAN type.
% 
% Note: If both are given, lesion.ORGAN overwrites ORGAN.
% 
% Last Modified: 09-27-2011

if ~exist('SHOW_LESION', 'var'), SHOW_LESION = 1; end

warning('off');
LARGEST_LESION_H = 195;
LARGEST_LESION_W = 195;
GROUP_FV = 1;

tmp = INFO;
I = IMAGE;

lesion.dicomFileName = DCM_FILENAME;
lesion.InstanceNumber = tmp.InstanceNumber;
lesion.fullImage = I;
lesion.BitDepth = single( tmp.BitDepth );


[lesion.image, lesion.offset, lesion.roi_interpolated] = ...
    GetLesionImgSz(I, lesion.roi, LARGEST_LESION_H, LARGEST_LESION_W);

lesion.RELOAD_IM_FROM_DICOM = 0;

fprintf('Patnt Name : %s\n', lesion.patientName);
fprintf('Lesion UID : %s\n', lesion.AIM_UID);
fprintf('InstanceNum: %d\n', lesion.InstanceNumber);
fprintf('Dicom ID   : %s\n', lesion.SOPInstanceUID);
fprintf('Dicom File : %s\n', lesion.dicomFileName);

% get Features
% ORGAN specific issues are handled inside getImageFeature.m
[res2, startPos, featureGroupList, featureList] = getImageFeature(lesion, 0, GROUP_FV, config_profile);

res.features = res2;
res.startPos = startPos;
res.featureGroupList = featureGroupList;
res.featureList = featureList;
res.patientName = lesion.patientName;
res.lesionName = lesion.lesionName;

if SHOW_LESION
    % draw the image and ROI
    figure;
    imshow(lesion.image, s_getCTWindow(ORGAN));
    set(gcf,'Name',lesion.patientName);
    hold on;
    plot(lesion.roi.x - double(lesion.offset.x)+1, lesion.roi.y - double(lesion.offset.y)+1, 'r.-' );
    hold off;
end
