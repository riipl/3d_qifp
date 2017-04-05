function haralick = processGLCM( glcm )
%PROCESSGLCM Summary of this function goes here
%   Detailed explanation goes here

% Cluster Shade, Tendency, Max Probability and Inverse Variance formulas
% taken from:
% https://www.uio.no/studier/emner/matnat/ifi/INF4300/h08/undervisningsmateriale/glcm.pdf

% Descriptions for the features extracted in this function come from:
% Nourhan Zayed and Heba A. Elnemr, “Statistical Analysis of Haralick 
%  Texture Features to Discriminate Lung Abnormalities,” International 
%  Journal of Biomedical Imaging, vol. 2015, Article ID 267807, 7 pages, 
%  2015. doi:10.1155/2015/267807

%% Initialization (i=x=row, j=y=col)
    
    % Make the GLCM to sum 1
    glcm = glcm ./ sum(glcm(:));

    % Positional Values of each cell in the matrix
    [Y,X] = meshgrid(1:size(glcm,1), 1:size(glcm,2));

    % Mean and SDev in X direction
    muX = sum(sum(repmat((1:size(glcm,1))', [1, size(glcm,2)]).*glcm));
    sdX = sum(sum(repmat((((1:size(glcm,1))-muX).^2)', ...
        [1, size(glcm,2)]).*glcm));
    
    % Mean and SDev in Y direction
    muY = sum(sum(repmat(1:size(glcm,2), [size(glcm,1),1]).*glcm));
    sdY = sum(sum(repmat((((1:size(glcm,1))-muY).^2), ...
        [size(glcm,1),1]).*glcm));
    
    % Output structure
    haralick = struct();
%% Energy
% Energy is derived from the Angular Second Moment (ASM). 
% The ASM measures the local uniformity of the gray levels. 
% When pixels are very similar, the ASM value will be large
    haralick.energy = sum(glcm(:).^2);

%% Entropy
% Entropy is the randomness or the degree of disorder present in the image. 
% The value of entropy is the largest when all elements of the cooccurrence 
% matrix are the same and small when elements are unequal
    haralick.entropy = -nansum(glcm(:).*log10(glcm(:)));

%% Correlation  
% Correlation feature shows the linear dependency of gray level values in 
% the cooccurrence matrix   
    haralick.correlation = sum(sum(((X-muX).*(Y-muY) / (sdX*sdY)) .* glcm));

%% Contrast
% (Moment 2 or standard deviation) is a measure of intensity or gray level 
% variations between the reference pixel and its neighbor. Large contrast 
% reflects large intensity differences in GLCM
    haralick.contrast = sum(sum((Y-X).^2 .* glcm));

%% Homogeneity
% Measures how close the distribution of elements in the GLCM is to the 
% diagonal of GLCM. As homogeneity increases, the contrast, typically, 
% decreases
    haralick.homogeneity = nansum(nansum(glcm.*(1 ./ (1 + (Y-X).^2))));

%% Variance

    haralick.variance = sum(sum((((X - muX).^2).*glcm) + ...
        (((Y - muY).^2).*glcm)))/2;
    
%% Sum Mean
    haralick.sumMean = sum(sum((Y+X).*glcm))/2;
        
%% Inertia
    haralick.inertia = sum(sum((Y-X).^2.*glcm));

%% Cluster Shade
    haralick.clusterShade = sum(sum(((X+Y-muX-muY).^3).*glcm));

%% Cluster Tendency
    haralick.clusterTendency = sum(sum(((X+Y-muX-muY).^4).*glcm));

%% Max Probability
    haralick.maxProbability = max(glcm(:));

%% Inverse Variance
    tmpInvVar = glcm./((Y-X).^2);
    tmpInvVar(abs(tmpInvVar) == Inf) = NaN;
    haralick.inverseVariance = nansum(nansum(tmpInvVar));

%% First Moment
% The mean which is the average of pixel values in an image 
%     haralick.firstMoment = sum(sum((Y-X).*glcm));
% 
% %% Second Moment
% % Standard deviation   
%     haralick.secondMoment = sum(sum((Y-X).^2.*glcm));
% 
% %% Third Moment
% % Degree of asymmetry in the distribution
%     haralick.thirdMoment = sum(sum((Y-X).^3.*glcm));    
% 
% %% Fourth Moment
% %  Relative peak or flatness of a distribution and is also known as kurtosis
%     haralick.fourthMoment = sum(sum((Y-X).^4.*glcm));    
