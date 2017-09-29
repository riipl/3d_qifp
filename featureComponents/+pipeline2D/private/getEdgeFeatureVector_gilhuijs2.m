function [featureVector fv_str num_pts_on_border] = getEdgeFeatureVector_gilhuijs2(lesion, OSD, ORGAN)

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
% see also: getEdgeFeatureVector_levman2.m

if ~exist('OSD','var'), OSD = 1; end

I = lesion.image;
roi = lesion.roi;
Z = 0;
if isfield(lesion, 'offset')
    roi.x = roi.x - lesion.offset.x + Z;  %% this is a DoF
    roi.y = roi.y - lesion.offset.y + Z;
end

roimask = I *0;
roimask = roipoly(roimask, roi.x, roi.y);
bn = bwboundaries(roimask);
bn = bn{1};
xx = bn(:,2)'; yy = bn(:,1)';

%% skip boundary cases (see processLesionCubic2.m)
if strcmp(ORGAN, 'lung')==1
    % lung area (see tweakLungEdge.m)
    c_low = -426; c_high = 1074;
    pad = 500;
    if isfield(lesion, 'fullImage')
        x = double(lesion.fullImage);
    else
        x = loadDICOM(lesion.dicomFileName);
    end
    if OSD > 0
        figure
        if OSD < 3
            [~, lung] = c_lung_area(x, 1, gcf);
        else
            [~, lung] = c_lung_area(x, 0);
            subplot(141); imshow(lesion.image, [c_low, c_high]); hold on; plot(xx, yy, 'r', 'LineWidth', 2); hold off;
            subplot(142);
        end
    else
        [~, lung] = c_lung_area(x, 0);
    end
    lung = padarray(lung,[pad,pad]);
    mask = lung((lesion.offset.y+1-Z : lesion.offset.y + size(lesion.image,1)-Z)+pad, pad+(lesion.offset.x+1-Z : lesion.offset.x+size(lesion.image,2)-Z));
    
    tmpx = xx;
    tmpy = yy;
    if OSD > 0
        imshow(mask, [0 2]);
        hold on; plot(tmpx, tmpy, 'y', 'LineWidth', 2); hold off;
    end
    tmp = roimask | mask;
    
    tmp = imclose(imopen(tmp, ones(3)), ones(3));
    C = bwconncomp(tmp);
    L = labelmatrix(C);
    mask = L==L(round(mean(tmpx)), round(mean(tmpy)));
elseif strcmp(ORGAN, 'liver') && isfield(lesion, 'borders') % liver case
    mask = I*0;
    mask = roipoly(mask, lesion.borders.x, lesion.borders.y);    
end    

bl = bwboundaries(mask);
bl = bl{1};
b = intersect(bn, bl, 'rows');

% skip the boundary cases
x=L2_distance([yy; xx], b');
[~,ind]=min(x);
num_pts_on_border = length(ind);

borderMask = roimask *0;
for ii = 1:num_pts_on_border
    borderMask(yy(ind(ii)), xx(ind(ii))) = 1;
end
IborderBand = logical(imdilate(borderMask, strel('disk',1) ) - imerode(borderMask, strel('disk',2) ));

%%
H = fspecial('sobel');
Ix = imfilter(I,H,'replicate');
Iy = imfilter(I,H','replicate');
Igrad = (Ix.^2+Iy.^2).^.5;

Iband = logical(imdilate(roimask, strel('disk',1) ) - imerode(roimask, strel('disk',2) ));
Iband = Iband & ~IborderBand;

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
    imshow(Igrad.*Iband + (IborderBand)*max(Igrad(Iband))*2, []);
    title(['max mean gradient: ' num2str(m, '%4.2f') ' (white is border ROI)'])
end

