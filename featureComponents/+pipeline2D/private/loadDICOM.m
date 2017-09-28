function [I info rawI] = loadDICOM( DCM_FILENAME, ORGAN, config_profile )

% takes care of the scale issue, also return the header, raw Image if
% neededa

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is added to OOP this (2012-08-28)
if exist('config_profile', 'var') && strcmp(config_profile.name, 'null')==0
    load_dicom_method = config_profile.load_dicom_method;
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('ORGAN', 'var'), ORGAN = 'none'; end

% load image data from DICOM file
info = dicominfo( DCM_FILENAME );
I = dicomread( info );

if nargout==3
    rawI = I;
end

if exist('load_dicom_method', 'var') && strcmp(load_dicom_method, 'nop')
 %   return
end

if ~isfield(info, 'Modality')
    info.Modality = 'CT';
end

switch ORGAN
    case 'knee'
        if strcmp('MR', info.Modality)
            RescaleOffset = 0;
            if isfield(info,'RescaleType') && strcmp('normalized', info.RescaleType)
                if isfield(info,'RescaleSlope') && strcmp('normalized', info.RescaleType)
                    I = double(I) * info.RescaleSlope;
                end
            end
            if isfield(info,'WindowCenter') && isfield(info,'WindowWidth')
                %        ieScale(I, info.WindowCenter-info.WindowWidth/2, info.WindowCenter+info.WindowWidth/2);
                I = (double(I) - info.WindowCenter) *1.0/ info.WindowWidth * 16384 + 8192;
            end
        end
        return;
end

if strcmp('CT', info.Modality)
    %% Rescale Offset
    RescaleOffset = 0;
    if isfield(info,'RescaleType') && strcmp('HU', info.RescaleType)
        RescaleOffset = 0;
    elseif  isfield(info,'RescaleIntercept')
        RescaleOffset = info.RescaleIntercept + 1024;        
    end
   % RescaleOffset = info.RescaleIntercept + 1024;  
    I = I + RescaleOffset;
    
elseif strcmp('CR', info.Modality)  
    % need to invert the intensity, if RescaleType is 'LOG_E REL'
    if ~isfield(info, 'RescaleType')
        warning('Missing RescaleType for CR DICOM file, using borders to estimate.');
        info.RescaleType = 'OD REL';
        if (s_check_DICOM(I) == 1)
            info.RescaleType = 'LOG_E REL';
        end
    end
    if strcmp('LOG_E REL', strtrim(info.RescaleType))
        I = uint16( 2^single(info.BitDepth) - single(I) );
    end
    I = ieScale(I, 0, 2^single(info.BitDepth));
elseif strcmp('MR', info.Modality)
    RescaleOffset = 0;
    if isfield(info,'RescaleType') && strcmp('normalized', info.RescaleType)
        if isfield(info,'RescaleSlope') && strcmp('normalized', info.RescaleType)
            I = double(I) * info.RescaleSlope;
        end
    end
    if isfield(info,'WindowCenter') && isfield(info,'WindowWidth')
%        ieScale(I, info.WindowCenter-info.WindowWidth/2, info.WindowCenter+info.WindowWidth/2);
        I = (double(I) - info.WindowCenter) *1.0/ info.WindowWidth * 1024 + 512;
    end
elseif strcmp('DX', info.Modality)      % bone
    if isfield(info, 'PixelIntensityRelationshipSign')
%         tmp = single(I)*single(info.PixelIntensityRelationshipSign);
%         if min(tmp(:))<0
%             tmp = tmp + 2^single(info.BitDepth);
%         end
%         I = uint16(tmp);
    end
elseif strcmp('XA', info.Modality)      % bone
    if max(I(:)) <=  2^single(info.BitDepth)/2
        I = I * 2;
    end
end
