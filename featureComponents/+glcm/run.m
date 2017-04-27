function [ out ] = run( inputs )

%RUN Summary of this function goes here
%   Detailed explanation goes here
    featureRootName = inputs.featureRootName;
    out = struct('featureRootName', featureRootName);

%% Initialize
intensityVOI = inputs.intensityVOI;
segmentationVOI = inputs.segmentationVOI;
distances = inputs.distance;
grayLevels = inputs.grayLevels;
volumeInfo = inputs.infoVOI;
customIntensity = inputs.customIntensity;
if customIntensity
    minIntensity = inputs.minIntensity;
    maxIntensity = inputs.maxIntensity;
else
    minIntensity = NaN;
    maxIntensity = NaN;
end
symmetric = inputs.symmetric;

%% Calculate pixel voxel sizes
    % Find pixel spacing in millimeters in plane and between planes
    ySpacing = abs(volumeInfo{1}.PixelSpacing(1));
    xSpacing = abs(volumeInfo{1}.PixelSpacing(2));
    zSpacing = abs(volumeInfo{1}.zResolution);


%% Split distances
distanceArray = str2double(strsplit(distances, ','))';

%% Calculate the haralick features for each distance and report them
out.output = {};
for dist = 1:numel(distanceArray)
    try
        distance = distanceArray(dist);
        [featureVector, ~] = calculateGLCM (intensityVOI, ...
            segmentationVOI, ...
            distance, ...
            xSpacing,ySpacing, zSpacing, ...
            grayLevels, ...
            symmetric, ...
            minIntensity, ...
            maxIntensity ...
        );

        %% Group features that have same name in each direction
        nDirections = numel(featureVector);
        distOutputs = {};

        for iDirection = 1:nDirections
            directionFeatureVector = featureVector{iDirection}.features;
            featureNames = fieldnames(directionFeatureVector);
            nFeatures = numel(featureNames);

            % Put all features inside the same structure
            for iFeature = 1:nFeatures
                featureName = featureNames{iFeature};
                if ~isfield(distOutputs, featureName)
                    distOutputs.(featureName) = [];
                end
                distOutputs.(featureName) = [distOutputs.(featureName), ...
                    directionFeatureVector.(featureName)];
            end    
        end

        %% Create output structure
        outputFeatureNames = fieldnames(distOutputs);
        nFeature = numel(outputFeatureNames);
        for iFeature = 1:nFeature
            featureName = featureNames{iFeature};
            out.output = [out.output, ...
                struct( ...
                'name', ['distance.' num2str(distanceArray(dist)) 'mm.' featureName], ...
                'value', distOutputs.(featureName) ...
                )
            ]; 
        end
    catch
        out.output = {};
    end
end
