function volume = calculateVolume(segVOI, xSpacing, ySpacing, zSpacing)
%CALCULATEVOLUME Summary of this function goes here
%   Detailed explanation goes here

    volume = sum(logical(segVOI(:))) * (xSpacing * ySpacing * zSpacing);

end

