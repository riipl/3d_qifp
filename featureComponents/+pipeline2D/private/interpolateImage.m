function pixelValues = interpolateImage(image, points)


%returns pixel values at positions given by points
%points : n x 2
%output : pixelValues

pixelValues = interp2(image, points(:,1), points(:,2), 'linear');
% pixelValues = interp2(image, points(:,1), points(:,2), 'spline');


end