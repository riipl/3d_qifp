function [ out ] = run( inputs )
%RUN Summary of this function goes here
%   Detailed explanation goes here

    %% Initialization
    infoVOI = inputs.infoVOI;
    segmentationVOI = inputs.segmentationVOI;

    featureRootName = inputs.featureRootName;
    out = struct('featureRootName', featureRootName);
    
    %% Calculate pixel voxel sizes
    sizeToNormalize = [1, 1, 1];
    normalizedSegmentation = ...
        (spacingNormalization(segmentationVOI, sizeToNormalize, infoVOI) > 0.5);

    %% Split all structure elements that are going to be calculated
    radius = strsplit(inputs.featureSize, ',');
    patchSize = inputs.patchDistance;
    nRadius = numel(radius);
    out.output = {};
    for iRadius = 1:nRadius
        % Wtap in exception. Sometimes a structure element size dwarfs the
        % tumor
        try
            %% Calculate Roughness
            roughness = findRoughness(normalizedSegmentation, patchSize, ...
                str2double(radius{iRadius}));
            %% Return roughness values
            roughnessFeatures = fieldnames(roughness);
            nRoughnessFeatures = numel(roughnessFeatures);
            for iRoughnessFeatures = 1:nRoughnessFeatures
                fieldName = roughnessFeatures{iRoughnessFeatures};
                out.output = [out.output, { ... 
                    struct(...
                    'name', [fieldName ...
                    '.patchSize.' num2str(patchSize) 'mm' ....
                    '.featureSize.' num2str(radius{iRadius}) 'mm'],...
                    'value', roughness.(fieldName) ...
                    ) ...
                }];
            end
         catch
            continue;
         end
    end
end

