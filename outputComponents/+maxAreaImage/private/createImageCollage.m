function collageImage = createImageCollage(images, boundary)
%createImageCollage returns an image created by arranging all images in
%imags in a 3 column format.
%
% Input:
%   - images: cell array containing the images to put in the collage. 
%   - boundary: number of pixels to pad in each direction [h w] per image
%
% Output:
%   - collageImage: variable with all 

if numel(boundary) == 1
    boundary = repmat(boundary, [2,1]);
end

numberOfImages = numel(images);
numberOfColumns = 3;

getHeight = @(x) size(x, 1);
getWidth = @(x) size(x, 2);
maxHeight = max(cellfun(getHeight, images));
maxWidth = max(cellfun(getWidth, images));
fullHeight = maxHeight + floor(boundary(1)/2);
fullWidth = maxWidth + floor(boundary(2)/2);

getCard = @(x) createImageCard(x, fullWidth, fullHeight);
imageCards = cellfun(getCard, images, 'UniformOutput', false);

%FIXME: Function breaks when the number of images is not a multiple of the
%number of columns.
collageRow = cell(ceil(numberOfImages/numberOfColumns) ,1);
for i = 1:numberOfColumns:numberOfImages
    collageRow{ceil(i / numberOfColumns)} = horzcat(imageCards{i:i+(numberOfColumns-1)});
end

collageImage = vertcat(collageRow{:});

end

