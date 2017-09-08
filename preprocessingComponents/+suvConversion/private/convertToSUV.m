function [ petSUVIntensityVOI, infoVOI ] = convertToSUV(intensityVOI, infoVOI)
% CONVERTTOSUV % Convert BQML or CNTS units of PET image to SUV units
% This function converts the PET image volume units of BQML or CNTS to SUV units normalized by patient 
% body weight (SUVbw). This function uses SeriesTime to determine image acquisition time and 
% RadiopharmaceuticalStartTime to determine the injection start time. This code was adapted based on QIBA
% guidelines (http://qibawiki.rsna.org/index.php/Standardized_Uptake_Value_(SUV)). 
%
% Created by:       Sarah Mattonen
% Created on:       2017-08-10

%% Check if dicom series is a PET image (with a Units field)
try 
    units = infoVOI{1, 1}.Units;
catch
    error('Dicom series is not a PET image.')
end

%% Convert to SUV units
if units == 'BQML'
    % Get required information from dicom header
    totalInjectedDose = infoVOI{1, 1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose;   % in Bq
    halfLife = infoVOI{1, 1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife;   % in seconds
    startTime = infoVOI{1, 1}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartTime;
    seriesTime = infoVOI{1, 1}.SeriesTime;
    seriesDate = infoVOI{1, 1}.SeriesDate;
    patientWeight = infoVOI{1, 1}.PatientWeight; % in kg

    % Calculate decay time
    seriesTimeFormat = strcat(seriesDate(1:4), '-', seriesDate(5:6), '-', seriesDate(7:8), {' '}, seriesTime(1:2), ':', seriesTime(3:4), ':', seriesTime(5:6));
    startTimeFormat = strcat(seriesDate(1:4), '-', seriesDate(5:6), '-', seriesDate(7:8), {' '}, startTime(1:2), ':', startTime(3:4), ':', startTime(5:6));
    formatIn = 'yyyy-mm-dd HH:MM:SS';
    seriesTimeVec = datevec(seriesTimeFormat, formatIn);
    startTimeVec = datevec(startTimeFormat, formatIn);
    decayTime = etime(seriesTimeVec, startTimeVec); % in seconds
    
    % Calculated decayed dose
    decayedDose = totalInjectedDose*exp(log(2) * -decayTime/halfLife);

    % Normalize scale factor by patient weight
    SUVbwScaleFactor = (patientWeight*1000)/decayedDose;

    % Convert to SUV by applying scale factor to raw PET intensities
    petSUVIntensityVOI = intensityVOI.*SUVbwScaleFactor;
    
    % Change units in infoVOI to indicate they have been changed to SUV
    for i = 1:length(infoVOI)
        infoVOI{i, 1}.Units = 'SUVbw';
    end
    
elseif units == 'CNTS'      % Phillips scanner, SUV conversion factor is in private tag (7053,1000)
    try
        SUVFactor = infoVOI{1, 1}.Private_7053_1000;
        petSUVIntensityVOI = intensityVOI.*SUVFactor;
           
        % Change units in infoVOI to indicate they have been changed to SUV
        for i = 1:length(infoVOI)
            infoVOI{i, 1}.Units = 'SUVbw (Phillips)';
        end
    
    catch
        error('PET image is in CNTS units and the SUV conversion factor tag (7053,1000) is not present in the dicom header.')
    end
    
else
    error('PET image is not in BQML or CNTS units.')
end

end

