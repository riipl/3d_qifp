function [ normalizedImage ] = normalizeImageRange( image, minValue, maxValue )
%NORMALIZEIMAGERANGE gets an image and returns it as 0...1 image. If a
%value is below minValue it's converted to 0. If a value is greater than
%maxValue is converted to 1.

normalizedImage = max(image, minValue);
normalizedImage = min(normalizedImage, maxValue);
normalizedImage = normalizedImage - min(normalizedImage(:));
normalizedImage = normalizedImage / max(normalizedImage(:));

end

