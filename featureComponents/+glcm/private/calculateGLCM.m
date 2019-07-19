function [ glcmFeatures, glcmCombinedFeatures ] = ...
    calculateGLCM(intensityVOI, segmentationVOI, distance, xSpacing, ...
    ySpacing, zSpacing, grayLevels, symmetric, minIntensity, maxIntensity, entropyLogBase)
%CALCULATEGLCM Summary of this function goes here
%   Detailed explanation goes here
    %% Initialization
    % Directions to calculate GLCMs on [row,col,depth]
    directions = [  0, 1, 0;
                   -1, 1, 0;
                    1, 0, 0;
                   -1,-1, 0;
                    0, 1,-1;
                    0, 0,-1;
                    0,-1,-1;
                   -1, 0,-1;
                    1, 0,-1;
                   -1, 1,-1;
                    1,-1,-1
                   -1,-1,-1;     
                    1, 1,-1;
                  ];
                  
    spacing = [ySpacing,xSpacing,zSpacing];
    
    %% Generate all GLCM (in each direction
    nDirections = size(directions, 1);
    commulativeGLCM = zeros(grayLevels);
    glcmFeatures = cell(nDirections,1);
    
    for iDirection = 1:nDirections 
        % Forward in the direction
        fwdDirection = directions(iDirection,:);
        glcm = createGLCM(intensityVOI, segmentationVOI, ...
        fwdDirection, distance, spacing, grayLevels, minIntensity,...
        maxIntensity);
        
        % If symmetric flag is set then we calculate the inverse direction
        % and 
        if symmetric
            % In the inverse direction
            invDirection = -fwdDirection;
            invGlcm = createGLCM(intensityVOI, segmentationVOI, ...
            invDirection, distance, spacing, grayLevels,  minIntensity,...
            maxIntensity);
    
            % Combining forward and backwards
             glcm = glcm + invGlcm;
        end
        
        % Calculate haralick features for this matrix
        glcmFeatures{iDirection} = struct (...
        'direction', fwdDirection,...
        'features', processGLCM(glcm, entropyLogBase)...
        );
            
        % Add the GLCM to the commulative GLCM
        commulativeGLCM = commulativeGLCM + glcm;
    end
    
    %% Find the features of the combination of all GLCMs (rotational invariant)
    glcmCombinedFeatures = processGLCM(commulativeGLCM, entropyLogBase);   

end

