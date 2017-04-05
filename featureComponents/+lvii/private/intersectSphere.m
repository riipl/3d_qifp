function intersect = computeLVII(segVOI, sphere)
%INTERSECTSPHERE Summary of this function goes here
%   Detailed explanation goes here

%% Initialize
    % Find boundary points
    boundaryImage = bwperim(segVOI, 26);
    bCoord = find(boundaryImage == 1);

    % Number of boundary points
    cNum = numel(bCoord);

    % Storage variable
    LVIIMat = zeros(cNum,1);
    
    % Center Point
    sizeXYZ = floor(double(size(sphere))/2);
    if (numel(sizeXYZ) == 2)
        sizeXYZ = [sizeXYZ 1];
    end
    evenOffset = 1-mod(double(size(sphere)),2);
    sizeX = sizeXYZ(1);
    sizeY = sizeXYZ(2);
    sizeZ = sizeXYZ(3);

    
%% Intersect Across every point
    for i = 1:cNum;
        [xx, yy, zz] = ind2sub(size(boundaryImage), bCoord(i));
        try
            
            tmpSEG = segVOI((xx-sizeX):(xx+sizeX-evenOffset(1)), ...
                (yy-sizeY):(yy+sizeY-evenOffset(2)), ...
                (zz-sizeZ):(zz+sizeZ-evenOffset(3)));
            overlap = (tmpSEG & sphere);
            LVII =  sum(overlap(:))./sum(sphere(:));
            if any(evenOffset > 0) 
                tmpSEG = segVOI((xx-sizeX+evenOffset(1)):(xx+sizeX), ...
                    (yy-sizeY+evenOffset(2)):(yy+sizeY), ...
                    (zz-sizeZ+evenOffset(3)):(zz+sizeZ));
                overlap = (tmpSEG & sphere);
                LVII =  mean([LVII, (sum(overlap(:))./sum(sphere(:)))]);               
            end
            LVIIMat(i) = LVII;
        catch
            LVIIMat(i) = nan;
        end
    end
    
%% Return intersect values
    intersect = LVIIMat;
end

