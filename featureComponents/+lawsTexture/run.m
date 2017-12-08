function [ out ] = run( inputs )

%RUN Summary of this function goes here
%   Detailed explanation goes here
    featureRootName = inputs.featureRootName;
    out = struct('featureRootName', featureRootName);

%% Initialize
intensityVOI = inputs.intensityVOI;
segmentationVOI = inputs.segmentationVOI;
samplePoints = inputs.samplePoints;
volumeInfo = inputs.infoVOI;

%% Calculate pixel voxel sizes
    % Find pixel spacing in millimeters in plane and between planes
    ySpacing = abs(volumeInfo{1}.PixelSpacing(1));
    xSpacing = abs(volumeInfo{1}.PixelSpacing(2));
    zSpacing = abs(volumeInfo{1}.zResolution);


%% Calculate the law's features for a resolution and distance
resolutions = str2double(strsplit(inputs.resolutions, ','))';

nResolutions = numel(resolutions);

out.output = {};
for iResolution = 1:nResolutions
    [windowFilterResponse, uniqueFilter, percentageCovered] = computeLawsFilters( intensityVOI, ...
        segmentationVOI, resolutions(iResolution), samplePoints, xSpacing, ySpacing, zSpacing);
    out.output = [out.output, windowFilterResponse', uniqueFilter', struct( ...
        'name', 'percentageCovered', ...
        'value', percentageCovered ...
        )];
end

end
