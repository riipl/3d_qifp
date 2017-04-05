function [ imageWithBoundary ] = returnImageBoundary( image, mask )
%RETURNIMAGEBOUNDARY Returns the original image with a red boundary around
%the the mask
%   Input:
%       - image: Original Image
%       - mask: Binary mask showing what part of the image is tumor
%
%   Output:
%       - imageWithBoundary: Original image with red pixels over the
%       boundary

% If its gray-scale convert it to RGB
if size(image,3) == 1
    image = repmat(image, [1 1 3]);
end

% The image and mask should have the same size:
if (size(image,1) ~= size(mask,1)) || (size(image,2) ~=  size(mask,2))
    error('Original Image and Mask have to be the same height and width')
end

% Check if the image is a float (max: 1)
if isfloat(image)
    maxImageValue = 1.0;
else 
    %TODO: check for other types of images. 
    maxImageValue = 255;
end

% Get the index of boundary pixels
boundaryPixels = (bwperim(mask) == 1);

redC = max(boundaryPixels*maxImageValue, image(:,:,1));
otherC = min(~repmat(boundaryPixels, [1 1 2]), image(:,:,2:3));

imageWithBoundary = zeros(size(image));
imageWithBoundary(:,:,1) = redC;
imageWithBoundary(:,:,2:3) = otherC;
end

