function [ imageCard ] = createImageCard( image, width, height )
%CREATEIMAGECARD returns a matrix of size width*height with the image 
%provided on the center

if (size(image, 1) > height) || (size(image,2) > width)
    error('The image is larger than the provided width or height');
end

freeVerticalSpace = height - size(image,1);
freeHorizontalSpace = width - size(image,2);

%TODO: Create logic to handle images that are integers
backgroundColor = 1.0;
imageCard = ones([height, width, size(image,3)]) * backgroundColor;

imageCard((freeVerticalSpace+1):end, (ceil(freeHorizontalSpace/2)+1):(end-floor(freeHorizontalSpace/2)), :)  = image;
end

