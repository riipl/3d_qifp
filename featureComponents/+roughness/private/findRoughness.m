function [ out ] = findRoughness(segVOI, patchDistance, featureSize)
%FINDROUGHNESS 

%% Find the "True" boundary
    [xx,yy,zz] = ndgrid(-featureSize:featureSize);
    nhood = sqrt(xx.^2 + yy.^2 + zz.^2) <= featureSize;
    
    % Lets first erode and dilate
    referenceSegErosion = segVOI;
    referenceSegErosion = imerode(referenceSegErosion, nhood);
    referenceSegErosion = imdilate(referenceSegErosion, nhood);
    
    % Lets then dilate and then erode 
    referenceSegDilation = segVOI;
    referenceSegDilation = imdilate(referenceSegDilation, nhood);
    referenceSegDilation = imerode(referenceSegDilation, nhood);

    referenceSeg = referenceSegDilation & referenceSegErosion;

%%
    segBoundary = bwperim(segVOI, 26);
    referenceBoundary = bwperim(referenceSeg, 26);
    maskSegBoundary = false(size(segBoundary));
    skipped = 0;
    
    %% Find roughness for patches around each border voxel
    boundaryIdx = find(segBoundary);
    skipBoundaryIdx = false(size(boundaryIdx));
    
    [globalOriginCoordX, globalOriginCoordY, globalOriginCoordZ] = ...
        ind2sub(size(segBoundary), boundaryIdx);
    numOfPoints = numel(boundaryIdx);
    roughnessArray = cell(numOfPoints,1); 

    for iPoint = 1:numOfPoints
        % Local Output variable
        localRoughness = struct();
        
        if skipBoundaryIdx(iPoint)
            skipped = skipped + 1;
            continue;
        end
        
        % Create mask to show which is the origin voxel
        maskRadius = false(size(segBoundary));
        originPoint = boundaryIdx(iPoint);
        localOriginCoordX = globalOriginCoordX(iPoint);
        localOriginCoordY = globalOriginCoordY(iPoint);
        localOriginCoordZ = globalOriginCoordZ(iPoint);
        maskRadius(originPoint) = true;
       
        % Extract a block around the region to optimize computation
        lowWindowX = max(localOriginCoordX - patchDistance, 1);
        highWindowX = min(localOriginCoordX + patchDistance, ...
            size(segBoundary,1));
        
        lowWindowY = max(localOriginCoordY - patchDistance, 1);
        highWindowY = min(localOriginCoordY + patchDistance, ...
            size(segBoundary,2));
        
        lowWindowZ = max(localOriginCoordZ - patchDistance, 1);
        highWindowZ = min(localOriginCoordZ + patchDistance, ...
            size(segBoundary,3));
        
        voiMaskRadius = maskRadius(lowWindowX:highWindowX, ...
            lowWindowY:highWindowY, lowWindowZ:highWindowZ);
        voiBoundary = segBoundary(lowWindowX:highWindowX, ...
            lowWindowY:highWindowY, lowWindowZ:highWindowZ);
        voiReference = referenceBoundary(lowWindowX:highWindowX, ...
            lowWindowY:highWindowY, lowWindowZ:highWindowZ);
        
        % Find distances to voxel:
        distance = bwdistgeodesic(voiBoundary,voiMaskRadius, ...
            'quasi-euclidean');
        
        % Keep voxels below patch size
        distanceIdx = find(distance <= patchDistance);
        
        % Find Coordinates of points
        [originCoordX, originCoordY, originCoordZ] = ...
                ind2sub(size(distance), distanceIdx);

        % Remove all points we are going to use now
        originalIdxToErase = ...
            sub2ind(size(segBoundary), ...
            originCoordX + (lowWindowX - 1), ...
            originCoordY+ (lowWindowY - 1), ...
            originCoordZ + (lowWindowZ - 1));
        
        overlapPercentage = sum(maskSegBoundary(originalIdxToErase)) / numel(distanceIdx) ;

        if overlapPercentage > 0.70
            skipped = skipped + 1;
            continue;
        end

        reverseIdx = ismember(boundaryIdx, originalIdxToErase);        
        skipBoundaryIdx(reverseIdx) = true;
        
        % Mark all points that are going to be sampled
        maskSegBoundary(originalIdxToErase) = true;
        
        [smoothedCoordX, smoothedCoordY, smoothedCoordZ] = ...
            ind2sub(size(voiReference), find(voiReference));
               
        if numel(smoothedCoordX) == 0
            skipped = skipped + 1;
            continue;
        end
        
        % Find the closest point in the plane for each boundary point
        closestSampleIdx = dsearchn(....
            [smoothedCoordX(:),smoothedCoordY(:),smoothedCoordZ(:)],...
            [originCoordX, originCoordY, originCoordZ]);

        displacements = sqrt( ...
            (originCoordX - smoothedCoordX(closestSampleIdx)).^2 + ...
            (originCoordY - smoothedCoordY(closestSampleIdx)).^2 + ...
            (originCoordZ - smoothedCoordZ(closestSampleIdx)).^2 ...
            );
        
        % Local Roughness Radius
        localRoughnessRadius = displacements;
%         
%         Calculate Roughness Statistics
        meanRadius = mean(localRoughnessRadius);
        deviations = (localRoughnessRadius - meanRadius);
%         
%         Arithmetic Average of Absolute Values
        localRoughness.arithmeticAverageOfAbsoluteValues = ...
            mean(abs(deviations));
        
%         Root mean squared 
        localRoughness.rootMeanSquared = ...
            sqrt(mean(deviations.^2));

%         Maximum Valley Depth
        localRoughness.maximumValleyDepth = min(deviations);
%         
%         Maximum Peak Height
        localRoughness.maximumPeakHeight = max(deviations);
%         
%         Maximum Height of the Profile
        localRoughness.maximumHeightOfProfile = ...
            max(deviations) - min(deviations);      
% 
%         Skewness
        localRoughness.skewness = ...
            mean(deviations.^3) ./ power(sqrt(mean(deviations.^2)),3);
%         
%         Kurtosis
        localRoughness.kurtosis = mean(deviations.^4) ./ ...
            power(sqrt(mean(deviations.^2)),4);
% 
        roughnessArray{iPoint} = localRoughness;
        
    end
    
    %% Combine roughness into one structure
    out = struct();
    nonEmptyRoughnessArrayIdx = find(~cellfun(@isempty, roughnessArray));
    nonEmptyRoughnessArray = roughnessArray(nonEmptyRoughnessArrayIdx);
    numOfRoughnessArray = numel(nonEmptyRoughnessArray);
    for iPoint = 1:numOfRoughnessArray
        localRoughness = nonEmptyRoughnessArray{iPoint};
        propertyNames = fieldnames(localRoughness);
        nPropertyNames = numel(propertyNames);
        for iPropertyName = 1:nPropertyNames
            localPropertyName = propertyNames{iPropertyName};
            % If the field does not exist create it
            if ~isfield(out, localPropertyName)
                out.(localPropertyName) = [];
            end
            % Concatenate all the same metrics under the top structure
            out.(localPropertyName) = [out.(localPropertyName) ...
                localRoughness.(localPropertyName)];
        end
    end

    %% Add summary values:
    % average distance between the highest peak and lowest valley in 
    % each sampling length, ASME Y14.36M - 1996 Surface Texture Symbols	
    out.rDIN = mean(out.maximumHeightOfProfile);
    
    % Japanese Industrial Standard for 
    % {\displaystyle R_{\text{z}}} R_{{\text{z}}}, 
    % based on the five highest peaks and lowest valleys over the entire 
    % sampling length
    highestPeaks = sort(out.maximumPeakHeight(:),1,'descend');
    lowestValleys = sort(out.maximumValleyDepth(:));
    minHighesPeaks = min(numel(highestPeaks), 5);
    minLowestValleys = min(numel(lowestValleys), 5);
    out.rJIS = mean(highestPeaks(1:minHighesPeaks) - lowestValleys(1:minLowestValleys));

end

