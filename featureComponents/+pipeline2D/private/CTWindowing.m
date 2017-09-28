function imgWindowed = CTWindowing(img, c_low, c_high)

if ~exist('c_low','var'), c_low = 840; end
if ~exist('c_high','var'), c_high = 1240; end

img(img<c_low) = c_low;
img(img>c_high) = c_high;

% imshow(img, [c_low c_high]);

imgWindowed = ieScale(img, 0, 255);
