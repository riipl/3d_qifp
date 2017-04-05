function out = computeLVII(segVOI, radius, xSpacing, ySpacing, zSpacing)
%COMPUTELVII Summary of this function goes here
%   Detailed explanation goes here
    
    %% Size where the sphere will be created
    spaceSize = repmat((radius*2), 1,3);
    resolution = [xSpacing, ySpacing, zSpacing];
    realSpaceSize = ceil(spaceSize ./ resolution);

    %% Create Sphere
    xValues = 1:realSpaceSize(1);
    yValues = 1:realSpaceSize(2);
    zValues = 1:realSpaceSize(3);
    xValues = (xValues - median(xValues)).*xSpacing;
    yValues = (yValues - median(yValues)).*ySpacing;
    zValues = (zValues - median(zValues)).*zSpacing;
    [x,y,z] = meshgrid(xValues, yValues, zValues);

    
    Osphere = sqrt(double(x.^2 + ...
        y.^2 + ...
        z.^2));
       
    sphere = (Osphere < radius);

    %% Find intersection
    out = intersectSphere(segVOI, sphere);
   
end

