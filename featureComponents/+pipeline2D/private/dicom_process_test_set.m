function dicom_process_test_set%(dicomDir, lesionDir, ROImode)

% clean-slate dicom pre-processing script
%
% right now, I still rely on the crop region.  it'd be removed later.
%
% Input:    - Liver CT Dicom Files
%           - AIM files that associated with the DICOM
% Output:   - Lesion Struct
%                  img  : (double) ROI img, no surrounding context
%                 cimg  : (double) 100x100 img contains ROI and surroundings
%                 name  : Dicom file ID in string format
%                 roix  : x of the ROIs
%                 roiy  : y of the ROIs
%                 type  : C, H, M, N, X, Y, see below for details
%           image_type  : the full lesion type (cysts, mets, ...)
%                 bigR  : useful for LAII
%                 rect  : the rect handle used to crop the ROI
%              cropped  : (double) inside of the ROI of the lesion
%                  ioc  : shape-related struct contains the exact IOC
%                         observations from the original AIM file
%
% Prepare Test Set 101:
%   1. Extracted what you downloaded from BIMM into the a folder 
%   2. prepare image_type array (HCC - X, the rest with its intial)
%   3. BigR
%   4. You are all set, load 'test_lesion_roi_raw.mat' and do work!
%
% 2009-05-26 JJX

% load test_lesion_roi_raw.mat

% test_set_name = 'all_90';
test_set_name = 'Ankit_30';

if exist([test_set_name '_bigR.mat'])
    fprintf('** bigR mat file detected.');
    load([test_set_name '_bigR.mat']);
else
    bigR = zeros(1,100);
end

rootDir = ['images\' test_set_name];
dicomDir = [rootDir '\.'];
lesionDir = [rootDir '\.'];

count = 0;
lesion = {};


% load gold_standard.mat
% load([rootDir 'image_type.mat']);
if ~ieNotDefined('test_lesion'), lesion_backup = test_lesion; end;

directory = dir(fullfile(dicomDir, '*.aim')) ;
names =  {directory.name} ;
image_number = [];
image_type = [];
for k = 1 : length(names)
    aimname = names{k} ;
    dicomname = [aimname(1:end-3) 'dcm'];

    k = strfind(aimname, '.') ;
    id = aimname(1:k(2)-1) ;

    if length(dir([lesionDir '/' aimname]))
        tmp = captureROI([dicomDir '/' dicomname], [lesionDir '/' aimname]) ;

        for ii = 1:length(tmp)
            count = count + 1;
            lesion{count} = tmp{ii};
            lesion{count}.name = id;
            lesion{count}.bigR = bigR(k);
            switch lesion{count}.image_type
                case 'hepatocellular carcinoma'
                    lesion{count}.type = 'X';
                case 'indeterminate or low suspicion for HCC'
                    lesion{count}.type = 'Y';
                    
                case 'focal nodular hyperplasia'
                    lesion{count}.type = 'N';
                otherwise
                    lesion{count}.type = upper(lesion{count}.image_type(1));
            end
            lesion{count}.type = lesion{count}.type;
            image_type = [image_type lesion{count}.type];
            lesion{count}.rect = s_find_biggest_rect(lesion{count});
            lesion{count} = s_cropLesion(lesion{count});
%             if ~ieNotDefined('lesion_backup')
%                 if ~isfield(lesion_backup{1},'rect')
%                     lesion{count} = s_cropLesion(lesion{count});
% 
%                 else
%                     lesion{count}.rect = lesion_backup{count}.rect;
%                     lesion{count}.cropped = lesion_backup{count}.cropped;
%                 end
%             end

        end
%                 drawLesion(tmp{1} , 0);
    end
end
nFiles = count;
test_lesion = lesion;
save( [test_set_name '_roi_raw.mat'], 'test_lesion',...
     'image_number', 'image_type', 'nFiles');

% save('test_lesion_roi_raw.mat', 'test_lesion',...
%     'image_number', 'image_type', 'nFiles');
fprintf('\n*** %g lesion ROIs processed. ***\n\n', count);

fprintf('\n*** try:\n load %s\n c_display_all_lesions(test_lesion, 4, 1) %% show lesion cropped ROI\n\n', [test_set_name '_roi_raw.mat']);
fprintf(' c_display_all_lesions(test_lesion, 1, 1) %% show lesion with rect\n\n');

return;

function lesion_struct = captureROI(dicomfile, aimfile)
% function roi = captureROI(dicomfile, aimfile)
% capture the pixels from an ROI of a DICOM image into a data matrix
% uses the coordinates from the aimfile to extract a polygonal ROI from the
% dicom file
if nargin == 0
  uiwait(msgbox('first, you will get a window to select a DICOM file...'))
  [dicomfilename, pathname] = uigetfile('*.dcm', 'Select DICOM file to load' ) ;
  dicomfile = [pathname dicomfilename] ;
  metadata = dicominfo([pathname dicomfilename]) ;
  uiwait(msgbox('next, select an AIM file.'))
  [aimfilename, pathname] = uigetfile('*.aim', 'Select AIM file to load' ) ;
  aimfile = [pathname aimfilename] ;
end 
if nargin == 1
  error('only one input argument given. need 0 or 2 inputs')
end
if nargin == 2
  if strcmp(class(dicomfile), 'char') == 0
    error('dicomfile must be a path string for the location of the file to read')
  end
  if strcmp(class(aimfile), 'char') == 0
    error('dicomfile must be a path string for the location of the file to read')
  end
end  

shape_code = {'RID5812','RID5800', 'RID5811', 'RID5809', 'LID11', 'LID9', 'RID5803', 'RID5808', 'RID5806', 'LID7', 'RID5810', 'RID5807', 'RID5804', 'RID5802', 'RID5815', 'RID5814', 'RID5801', 'RID5813', 'LID10', 'RID5799', 'RID5805', 'LID127', 'RID5816'};
diag_code = {'RID5231','RID4734','RID4271','RID3890','RID3969','RID3711','LID115','RID3778','RID5216'};


img = dicomread(dicomfile) ;
metadata = dicominfo(dicomfile) ;
aimStr = fileread(aimfile) ;
aim = xml_parseany(aimStr) ;




% get some attributes out
shape_diag_code = {};
cnt = 1;
for jj = 1: length(aim.imagingObservationCollection{1}.ImagingObservation)
    io = aim.imagingObservationCollection{1}.ImagingObservation{jj};
    
    % this is for the shape descriptor
    if isfield(io.imagingObservationCharacteristicCollection{1},'ImagingObservationCharacteristic')
        ioc = aim.imagingObservationCollection{1}.ImagingObservation{jj}.imagingObservationCharacteristicCollection{1}.ImagingObservationCharacteristic;%{1}.ATTRIBUTE.codeMeaning
        for ii = 1:length(ioc)
            if isMEMBER(ioc{ii}.ATTRIBUTE.codeValue, shape_code)
%                 disp(    ioc{ii}.ATTRIBUTE.codeMeaning);
                shape_diag_code{cnt} = ioc{ii}.ATTRIBUTE;
                cnt = cnt+1;
            end
        end
    end
    
    % this is for the diagnoses
    if isfield(io,'ATTRIBUTE')
        if isMEMBER(io.ATTRIBUTE.codeValue, diag_code)
%             disp(    io.ATTRIBUTE.codeMeaning);
%             shape_diag_code{cnt} = io.ATTRIBUTE;
%             cnt = cnt+1;
            
            image_type = io.ATTRIBUTE.codeMeaning
        end
    end
end
% shape_diag_code;


% get ROIs
numROIs = length(aim.geometricShapeCollection{1}.GeometricShape) ;
ROI = cell(numROIs, 1) ;
for k = 1 : numROIs
    numVertices = length(aim.geometricShapeCollection{1}.GeometricShape{k}.spatialCoordinateCollection{1}.SpatialCoordinate) ;
    x = [] ;
    y = [] ;
    for kVertex = 1 : numVertices
      x = [x str2double(aim.geometricShapeCollection{1}.GeometricShape{k}.spatialCoordinateCollection{1}.SpatialCoordinate{kVertex}.ATTRIBUTE.x)] ;
      y = [y str2double(aim.geometricShapeCollection{1}.GeometricShape{k}.spatialCoordinateCollection{1}.SpatialCoordinate{kVertex}.ATTRIBUTE.y)] ;
    end
   roiMask = roipoly(img, x, y) ;
   bbox = regionprops(double(roiMask), 'BoundingBox') ;
   bbox = ceil(bbox.BoundingBox) ;
   roi = img ;
   
   % img contains ROI only, no surrounding content
   roi(~roiMask) = 0 ;
   ROI{k} = roi(bbox(2):bbox(2) + bbox(4) - 1, bbox(1):bbox(1) + bbox(3) - 1) ;

   % 100x100 img contains ROI, with surrounding content
   WIN_SIZE = max(100, max(bbox(4), bbox(3)) + 2*10);
   roi = img;
   bbox(2) = bbox(2) - (WIN_SIZE/2 - bbox(4)/2);
   bbox(4) = WIN_SIZE;
   bbox(1) = bbox(1) - (WIN_SIZE/2 - bbox(3)/2);
   bbox(3) = WIN_SIZE;
   tmp = roi(bbox(2):bbox(2) + bbox(4) - 1, bbox(1):bbox(1) + bbox(3) - 1) ;

   lesion_struct{k}.roix = x+1 - bbox(1);
   lesion_struct{k}.roiy = y+1 - bbox(2);
   lesion_struct{k}.img = double(ROI{k});
   lesion_struct{k}.cimg = double(tmp);
   lesion_struct{k}.ioc = shape_diag_code;
   lesion_struct{k}.image_type = image_type;
   lesion_struct{k}.scale = metadata.PixelSpacing; % 1px = X mm
      
end
