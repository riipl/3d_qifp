function [featureVector fv_str] = getEdgeFeatureVector_levman(lesion, OSD)

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
% see also: getEdgeFeatureVector_gilhuijs.m

if ~exist('OSD','var'), OSD = 1; end

I = lesion.image;
roi = lesion.roi;
if isfield(lesion, 'offset')
    roi.x = roi.x - lesion.offset.x+1;
    roi.y = roi.y - lesion.offset.y+1;
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
    imshow(Imap, [])
    title(['max mean gradient: ' num2str(featureVector(1), '%4.2f')])
end

