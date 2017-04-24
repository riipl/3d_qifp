function newVOI = spacingNormalization(VOI, sizeToNormalize, volumeInfo) 
    %% Normalize Spacing 
    %% Configuration 

    %% Find pixel spacing in millimeters.
    rowSpacing = abs(volumeInfo{1}.PixelSpacing(1));
    colSpacing = abs(volumeInfo{1}.PixelSpacing(2));
    depSpacing = abs(volumeInfo{1}.zResolution);

    %% Original Coordinates: 
    origSizes = size(VOI);
    Xm = (1:origSizes(2)).*colSpacing;
    Ym = (1:origSizes(1)).*rowSpacing;
    Zm = (1:origSizes(3)).*depSpacing;

    [X, Y, Z] = meshgrid(Xm, Ym, Zm);


    %% Wanted Values 
    Xmi = 1:sizeToNormalize(2):(origSizes(2)*colSpacing);
    Ymi = 1:sizeToNormalize(1):(origSizes(1)*rowSpacing);
    Zmi = 1:sizeToNormalize(3):(origSizes(3)*depSpacing);

    [Xi, Yi, Zi] = meshgrid(Xmi, Ymi, Zmi);

    %% Interpolate
    newVOI = interp3(X, Y, Z, double(VOI), Xi, Yi, Zi, 'linear');
    newVOI(isnan(newVOI)) = 0;
    
end