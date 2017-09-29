function res = getFeatureFromAIM(SOP_UID_Map, AIM_FILENAME, SHOW_LESION)

% This script will extract image features from the DICOM and AIM file

if ~exist('SHOW_LESION', 'var'), SHOW_LESION = 1; end

warning('off');
LARGEST_LESION_H = 195;
LARGEST_LESION_W = 195;
GROUP_FV = 1;

% extract info from AIM file, construct lesion struct
lesion = GetRoi(AIM_FILENAME);

if lesion.valid == 0
    disp('Error parsing AIM file');
    return;
end

% load image data from DICOM file
lesion.dicomFileName = DCM_FILENAME;
I = dicomread( lesion.dicomFileName );
% lesion.fullImage = I;
[lesion.image, lesion.offset] = ...
    GetLesionImgSz(I, lesion.roi, LARGEST_LESION_H, LARGEST_LESION_W);

fprintf('Patnt Name : %s\n', lesion.patientName);
fprintf('Lesion UID : %s\n', lesion.AIM_UID);
fprintf('Dicom ID   : %s\n', lesion.SOPInstanceUID);

% get Features
[res, startPos, featureGroupList, featureList] = getImageFeature(lesion, 0, GROUP_FV);
disp(repmat('-', [1 40]));

res.features = res;
res.startPos = startPos;
res.featureGroupList = featureGroupList;
res.featureList = featureList;
res.patientName = lesion.patientName;

if SHOW_LESION
    % draw the image and ROI
    imshow(lesion.image, [800 1200]);
    hold on;
    plot(lesion.roi.x - double(lesion.offset.x)+1, lesion.roi.y - double(lesion.offset.y)+1, 'r.-' );
    hold off;
end
