function [ indexTableArray ] = create_index(baseFolder, progressBar)
%CREATE_INDEX the function scans a directory and all its subdirectories and
% creates an index of its Dicom images and its Dicom Segmentation Images
%
% baseFolder:       a simple folder or an  array of basefolders to crawl
% progressBar:      a boolean variable that controls the display of the
%                   progressbar
%
% Output:
%   indexTableArray.
%     DcmImageFileTable                 hashtable of the form:
%                                       DcmImageFileTable(SopUID) = FileName
%
%     DcmSegmentationObjectFileTable    hashtable of the form:
%                                       DcmImageFileTable(SopUID) = FileName
%
%     DcmSegmentationObjectInfoTable    hashtable of the form:
%                                       DcmImageFileTable(Filename) = DcmInfo
%
%
% Created by:       Sebastian Echegaray 
% Created on:       2013-04-02
%

% Initiatlization
% Check correct number of Arguments 
if nargin == 1
    progressBar = true;
elseif nargin ~= 2
    error('Create index takes either 1 or 2 arguments');
end

% If basefolder is a string make it a cell list
if ischar(baseFolder)
    baseFolderArray = {baseFolder};
elseif iscellstr(baseFolder)
    baseFolderArray = baseFolder;
else
    error('The base folder can only be a string or a cell of strings');
end

% Create our output variable
indexTableArray = struct();
fileDcmArray = {};

% Get files from all the directories
    for iBaseFolder = 1:numel(baseFolderArray)
        fileArray = get_all_files(baseFolderArray{iBaseFolder});
        
        %Skip files that have a dot at the beginning
        fileDcmArrayIndex = ...
            cellfun(@(x) get_dcm_files(x), fileArray);
        fileDcmArray = [fileDcmArray; fileArray(fileDcmArrayIndex)];
    end
    
    fileDcmArrayNo = numel(fileDcmArray);
    
    if (fileDcmArrayNo < 1)
        error('Could not find any DCM objects');
    end
    
% Create the hash table
    indexTableArray.DcmImageFileTable = containers.Map;
    indexTableArray.DcmSegmentationObjectFileTable = containers.Map;
    indexTableArray.DcmImageFileSeriesNumber = containers.Map;
    indexTableArray.DcmImageFileSeriesLocation = containers.Map;
    indexTableArray.DcmImageFileSeriesLocationsAvailable = ...
        containers.Map;

% Load each file and choose if it is a segmentation object or an image
    for iDcmFile = 1:fileDcmArrayNo        
        try 
            dicomFileInfo = dicominfo(fileDcmArray{iDcmFile}); 
        catch 
            disp(['File Ignored: ' fileDcmArray{iDcmFile}]);
            continue;
        end
        
        if ~isfield(dicomFileInfo, 'Modality')
            error ([fileDcmArray(iDcmFile) ' is not a valid Dicom file, ' ...
                'the field Modality is missing']);
        end
        
        %Modality
        switch lower(dicomFileInfo.Modality)
        
            % If it is a DSO
            case 'seg'
                indexTableArray.DcmSegmentationObjectFileTable( ... 
                    dicomFileInfo.SOPInstanceUID) = ...
                    fileDcmArray{iDcmFile};
                
            % If its just another type of DICOM
            otherwise
                indexTableArray.DcmImageFileTable( ...
                    dicomFileInfo.SOPInstanceUID) = ...
                    fileDcmArray{iDcmFile};
            
                % Lets also store the series ID
                indexTableArray.DcmImageFileSeriesNumber( ...
                    [dicomFileInfo.SeriesInstanceUID '-' num2str(dicomFileInfo.InstanceNumber)]) = ...
                    fileDcmArray{iDcmFile};
                disp([dicomFileInfo.SeriesInstanceUID '-' num2str(dicomFileInfo.InstanceNumber)]);

                % Store series and patient location
                indexTableArray.DcmImageFileSeriesLocation( ...
                    [dicomFileInfo.SeriesInstanceUID '-' ...
                    num2str(dicomFileInfo.ImagePositionPatient(3))]) = ...
                    fileDcmArray{iDcmFile};

                % Store all locations available
                if isKey(indexTableArray.DcmImageFileSeriesLocationsAvailable, ...
                    dicomFileInfo.SeriesInstanceUID)
                    prevLocations = indexTableArray.DcmImageFileSeriesLocationsAvailable( ...
                    dicomFileInfo.SeriesInstanceUID);
                else
                    prevLocations = [];
                end
                indexTableArray.DcmImageFileSeriesLocationsAvailable( ...
                    dicomFileInfo.SeriesInstanceUID) = ...
                    [prevLocations, dicomFileInfo.ImagePositionPatient(3)];

        end
        
    end    
end

%% This function returns a mask with the DCMs 
function fileDcmIndex = get_dcm_files(fileName)
    [~, name, ext] = fileparts(fileName);
    try
      if ~strcmp(name, '')
          if name(1) == '.'
              fileDcmIndex = false;
          else 
              fileDcmIndex = true;
          end
      else
          fileDcmIndex = false;
      end
    catch
        fileDcmIndex = false;
        disp(['File Ignored: ' fileName]);
    end
end

%% This function returns a list of all the files in a directory recursively
function fileArray = get_all_files(dirName)
    % Get the data for the current directory
    dirData = dir(dirName);
    
    % Find the index for directories
	dirIndex = [dirData.isdir];
    
    % Get a list of the files
    fileArray = {dirData(~dirIndex).name}';  
    
    % Prepend path to files
    if ~isempty(fileArray)
        fileArray = cellfun(@(x) fullfile(dirName,x),...
                       fileArray,'UniformOutput',false);
    end
    
    % Get a list of the subdirectories
    subDirs = {dirData(dirIndex).name};  
    
    % Find index of subdirectories that are not '.' or '..'
    validIndex = ~ismember(subDirs,{'.','..'});  
    
    % Loop over valid subdirectories
    for iDir = find(validIndex)                  
        % Get the subdirectory path
        nextDir = fullfile(dirName,subDirs{iDir});
        
        % Recursively call getAllFiles
        fileArray = [fileArray; get_all_files(nextDir)];  
    end
end