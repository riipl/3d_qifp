% Path parameters
% 
% DICOM_PATH - where external dicom/aim should go
% DB_PATH    - where local database vectors will be stored
% UNKNOWN_LESION_PATH - where new lesions for retrieval should go
% 

% DICOM_PATH = '../CBIR/dcm/';   % external to project folder
% UNKNOWN_LESION_PATH = '../CBIR/Unknown_Lesions/';
AIM_PATH = '../CBIR/aim/';

DB_PATH = './_Local_DB/';
TMP_FOLDER = './_Temp/';
% GS_PATH = '../CBIR/_GoldStandard/';

DB_FILE_NAME = [DB_PATH 'DB_Local.mat'];
path(path, [pwd DB_PATH]);

% Optional folder creation (save for future use)
% 
if ~exist(DB_PATH,'dir'), mkdir(DB_PATH); end;
% if ~exist(TMP_FOLDER,'dir'), mkdir(TMP_FOLDER); end;
% if ~exist(DICOM_PATH,'dir'), mkdir(DICOM_PATH); end;
% if ~exist(GS_PATH,'dir'), mkdir(GS_PATH); end;
% if ~exist(UNKNOWN_LESION_PATH,'dir'), mkdir(UNKNOWN_LESION_PATH); end;

LESION_W_SHIRNK = 0;
LESION_H_SHIRNK = 0;

LARGEST_LESION_W = 195;
LARGEST_LESION_H = 195;

