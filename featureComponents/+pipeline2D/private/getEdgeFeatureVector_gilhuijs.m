function [featureVector fv_str] = getEdgeFeatureVector_gilhuijs(lesion, OSD)

% Gilhuijs Margin sharpness feature:
%   1. mean margin gradient
%   2. variance of margin gradient
% 
% it boils down to ( mean gradient / mean pixel intensity )
% over the range of pixels located at a 3-pixel band around the lesion
% 
% 3D sobel filter is used to calculate the gradient

% Edge paper related:
%   D:\Sandy\LesionRetrieval\toJessica\code_distribute_to_student
% 
% see also: getEdgeFeatureVector_levman.m

if ~exist('OSD','var'), OSD = 1; end

I = lesion.image;
roi = lesion.roi;
if isfield(lesion, 'offset')
    roi.x = roi.x - lesion.offset.x +1;
    roi.y = roi.y - lesion.offset.y+1;
end

H = fspecial('sobel');
Ix = imfilter(I,H,'replicate');
Iy = imfilter(I,H','replicate');
Igrad = (Ix.^2+Iy.^2).^.5;

roimask = I *0;
roimask = roipoly(roimask, roi.x, roi.y);

Iband = logical(imdilate(roimask, strel('disk',1) ) - imerode(roimask, strel('disk',2) ));

m = mean(abs(Igrad(Iband))) / mean(I(Iband));
v = var(abs(Igrad(Iband))) / mean(I(Iband)).^2;

featureVector = [m;v];
fv_str = {'EdgeSharpness_Gilhuijs_mean',  'EdgeSharpness_Gilhuijs_var'};


if OSD
    subplot(2,2,1);
%     drawLesion(lesion, 2);
    
    Ic = repmat(ieScale(CTWindowing(I, -426, 1074), 0,1),[1 1 3]);
    Ic(:,:,1) = Ic(:,:,1) + Iband;
    Ic(:,:,2) = Ic(:,:,2) .*(1- Iband);
    Ic(:,:,3) = Ic(:,:,3) .*(1- Iband);
    imshow(Ic, []);
    subplot(2,2,2);
    imshow(Igrad, []); title('Gradient Image');
    subplot(2,2,3);
    imshow(Igrad.*Iband, []);
    title(['max mean gradient: ' num2str(m, '%4.2f')])
end

