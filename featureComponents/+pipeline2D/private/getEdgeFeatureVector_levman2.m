function [featureVector fv_str num_pts_on_border] = getEdgeFeatureVector_levman2(lesion, OSD, ORGAN)

% Levman (2011) Margin sharpness feature:
%   1. mean margin gradient
% 
% it boils down to: mean pixel intensity diff between A and B's, 
% A is a point on on the red band (inside), and B's are A's 4-connected
% neighbor and also lives on the blue band (outside)
% 
% This is done in 4 directions, in each direction, diff is used to figure
% out the pixel intensity diff

% Edge paper related:
%   D:\Sandy\LesionRetrieval\toJessica\code_distribute_to_studaent
% 
% see also: getEdgeFeatureVector_gilhuijs2.m

if ~exist('OSD','var'), OSD = 1; end

I = lesion.image;
roi = lesion.roi;
Z = 0;
if isfield(lesion, 'offset')
    roi.x = roi.x - lesion.offset.x+Z;
    roi.y = roi.y - lesion.offset.y+Z;
end

roimask = I *0;
roimask = roipoly(roimask, roi.x, roi.y);

% outside band
Iblue = logical(imdilate(roimask, strel('disk',1) ) - roimask);
% inside band
Ired = logical(roimask - imerode(roimask, strel('disk',1) ));

% loop each direction
d1 = diff(I) .* ( diff(roimask) >0 ); d1 = ([zeros(1, size(I,2)); d1]);
I = rot90(I); roimask = rot90(roimask);
d2 = diff(I) .* ( diff(roimask) >0 ); d2 = ([zeros(1, size(I,2)); d2]);  d2 = rot90(d2, -1);
I = rot90(I); roimask = rot90(roimask);
d3 = diff(I) .* ( diff(roimask) >0 ); d3 = ([zeros(1, size(I,2)); d3]);  d3 = rot90(d3, -2);
I = rot90(I); roimask = rot90(roimask);
d4 = diff(I) .* ( diff(roimask) >0 ); d4 = ([zeros(1, size(I,2)); d4]);  d4 = rot90(d4);
I = rot90(I); roimask = rot90(roimask);

Imap = -(d1+d2+d3+d4) ./ ( (d1~=0) + (d2~=0) + (d3~=0) + (d4~=0) );
Imap(isnan(Imap)) = 0;

% imshow(d1,[])
% imshow(d2,[])
% imshow(d3,[])
% imshow(d4,[])

%% skip boundary cases (see processLesionCubic2.m)
bn = bwboundaries(roimask);
bn = bn{1};
xx = bn(:,2)'; yy = bn(:,1)';

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

for ii = 1:num_pts_on_border
    Ired(yy(ind(ii)), xx(ind(ii))) = 0;
end

%%
featureVector = [mean(Imap(Ired)); std(Imap(Ired))];
fv_str = {'EdgeSharpness_Levman_mean'};

if OSD
    subplot(2,2,1);
%     drawLesion(lesion, 2);
    
    Ic = repmat(ieScale(CTWindowing(I, -426, 1074), 0,1),[1 1 3]);
    Ic(:,:,1) = Ic(:,:,1) + Ired;
    Ic(:,:,2) = Ic(:,:,2) .*(1- Ired);
    Ic(:,:,3) = Ic(:,:,3) .*(1- Ired);
    
    Ic(:,:,3) = Ic(:,:,3) + Iblue;
    Ic(:,:,2) = Ic(:,:,2) .*(1- Iblue);
    Ic(:,:,1) = Ic(:,:,1) .*(1- Iblue);
    
    imshow(Ic, []);
    subplot(2,2,2);
    imshow(Iblue*0.5 + Ired, []);
    subplot(2,2,3);
    imshow( ( (d1~=0) + (d2~=0) + (d3~=0) + (d4~=0) ), []);
    imshow(Imap.*Ired, [])
    title(['max mean gradient: ' num2str(featureVector(1), '%4.2f') ' (skipped border ROI)'])
end

