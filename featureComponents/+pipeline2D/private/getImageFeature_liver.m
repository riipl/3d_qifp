function [res, startPos, featureGroupList, featureList] = getImageFeature_liver(lesion, RELOAD_IM_FROM_DICOM, GROUP_FV)
%
% Return Value:
%   res                 : Nx1 feature vector (all FV concatenated together)
%   startPos            : starting position of each FV group
%   featureGroupList    : name of each FV group
%   featureList         : name of each FV element
%
%   GROUP_FV     : if set to 1, do not group FV into FV groups (i.e.
%                         featureGroupList will be the same as featureList)
% 
% Last modified: 05-28-2011
%
if ~isfield(lesion, 'RELOAD_IM_FROM_DICOM'), RELOAD_IM_FROM_DICOM = 1; end
if ~exist('GROUP_FV', 'var'), GROUP_FV = 1; end

res = []; startPos = [];
fprintf('- Extracting features for %s\n',lesion.uid);

%% preprocessing
if ~RELOAD_IM_FROM_DICOM
    I = lesion.image;
else
    lesion.dicomFileName(lesion.dicomFileName=='\') = '/';
    I = loadDICOM(lesion.dicomFileName);
end

blur = fspecial('gaussian',[7 7], 2);
I = single(conv2(double(I),blur,'same'));
[h w dummy] = size(I);
d = []; do=[]; poly = lesion.roi;
bBox.left = uint16(ceil(min(poly.x)));
bBox.right = uint16(floor(max(poly.x)));
bBox.top = uint16(ceil(min(poly.y)));
bBox.bottom = uint16(floor(max(poly.y)));
centerX = uint16(floor(mean(poly.x)));
centerY = uint16(floor(mean(poly.y)));

sz = uint16(floor(min(bBox.right-bBox.left,bBox.bottom-bBox.top)/2/sqrt(2)/1.5));
iBox.left = centerX-sz;
iBox.right = centerX+sz;
iBox.top = centerY-sz;
iBox.bottom = centerY+sz;
inside = I(iBox.top:iBox.bottom, iBox.left:iBox.right);
inside = tileToSize(inside,64,64);

roimask = zeros(bBox.bottom, bBox.right);
roimask = roipoly(roimask, poly.x, poly.y);
% disp([length(d) length(do)])
Icrop = I(1:bBox.bottom, 1:bBox.right);
d = Icrop(roimask);
roimask = double(roimask);
roimask(bBox.top:bBox.bottom, bBox.left:bBox.right) = roimask(bBox.top:bBox.bottom, bBox.left:bBox.right) +1;

do = Icrop(roimask==1);

if 0
    figure;
    imshow(lesion.image, []); hold on; plot(poly.x-single(lesion.offset.x)+1, poly.y-single(lesion.offset.y)+1, 'r');
    rectangle('Position', [iBox.left iBox.top iBox.right-iBox.left+1 iBox.bottom-iBox.top+1]); hold off;
end


%% Feature List:
% 1. Proportion of pixels with intensity larger than xx 1
% 2. Entropy of histogram 1
% 3. Peak position 1
% 4. Histogram 9
% 5. Difference in and out 1
% 6. Variance 1
% 7. Gabor 32
% 8. Ankit 2D 2
% 9. Haar on Histogram 2
% 10. Daube on Histogram
% 11. Histogram on edge
% 12. semantic
% 13. Shape

featureGroupList = {};
featureList = {};

%% 1. Proportion of pixels with intensity larger than xx 1
startPos = [startPos; length(res)+1];
F1_THRESH = 1100;
featureGroupList{length(featureGroupList)+1} = ['Proportion of pixels with intensity larger than ' num2str(F1_THRESH)];
featureList{length(featureList)+1} = ['Proportion of pixels with intensity larger than ' num2str(F1_THRESH)];
d1=sum(d>F1_THRESH)/length(d);
res=[res; d1];

%% 2. Entropy of histogram 1
startPos = [startPos; length(res)+1];
featureGroupList{length(featureGroupList)+1} = 'Entropy of histogram';
featureList{length(featureList)+1} = 'Entropy of histogram';
OLD_HIST_BIN = 1;
if OLD_HIST_BIN
    bins = 1000:20:1160;
    p = hist(d, bins);
end
p=p+1e-6*sum(p);
p=p/sum(p);
p(p<0.2*max(p))=0;
p=p+1e-6*sum(p);
p=p/sum(p);
entropy=-p*log2(p)';
res=[res; entropy];

%% 3. Peak position 1
startPos = [startPos; length(res)+1];
featureGroupList{length(featureGroupList)+1} = 'Peak Position';
featureList{length(featureList)+1} = 'Peak Position';
[~,ind]=max(p);
res=[res; ind];

%% 4. Histogram (min, max, median, ...)
[~, tmp] = s_find_longest_axis(lesion.roi, 0);
tmp = [length(d(:)); tmp.major; tmp.minor; min(d); max(d); median(d); mean(d); std(d); skewness(d); kurtosis(d);]';
fv_name = {'Lesion-Size', 'Major Axis', 'Minor Axis', 'Histogram-min','Histogram-max','Histogram-median','Histogram-mean','Histogram-std','Histogram-skewness','Histogram-kurtosis'};

if GROUP_FV
    featureGroupList{length(featureGroupList)+1} = 'Histogram';
    startPos = [startPos; length(res)+1];
    res=[res; tmp'];
else
    [res startPos featureGroupList] = AppendFeatureList(tmp', fv_name, res, startPos, featureGroupList);
end
[~,~,featureList] = AppendFeatureList(tmp', fv_name, res, startPos, featureList);

%% 4.1 30-bin histogram itself
% tmp = p;
% fv_name = {};
% if OLD_HIST_BIN
%     for ii = 1:length(qpv)
%         fv_name{ii} = ['Histogram-bin-' num2str(ii) ' (' num2str(qpv(ii)) ')'];
%     end
% else
%     for ii = 1:length(qpv)-1
%         fv_name{ii} = ['Histogram-bin-' num2str(ii) ' (' num2str(qpv(ii)) '-' num2str(qpv(ii+1)) ')'];
%     end
%     fv_name{ii+1} = 'Histogram-bin-NaN';
% end
% if GROUP_FV
%     featureGroupList{length(featureGroupList)+1} = 'Histogram-bin';
%     startPos = [startPos; length(res)+1];
%     res=[res; tmp'];
% else
%     [res startPos featureGroupList] = AppendFeatureList(tmp', fv_name, res, startPos, featureGroupList);
% end
% [~,~,featureList] = AppendFeatureList(tmp', fv_name, res, startPos, featureList);

%% 5. Difference in and out 1
startPos = [startPos; length(res)+1];
featureGroupList{length(featureGroupList)+1} = 'Difference In and Out';
featureList{length(featureList)+1} = 'Difference In and Out';
res=[res; mean(do)-mean(d)];

%% 6. Variance 1
startPos = [startPos; length(res)+1];
featureGroupList{length(featureGroupList)+1} = 'Variance';
featureList{length(featureList)+1} = 'Variance';
res=[res; std(d)];

%% 7. Gabor 32
% The first and the second moments of the energy
% in the frequency domain in each corresponding sub-band
% are used as the components of the texture descriptor.
% To achieve the best result, a bank of Gabor filters is
% designed for 4 levels and 8 orientations to have the highest
% sensitivity to the different lesion regions.
tmp = GetFeatureGabor(lesion)';
if GROUP_FV
    startPos = [startPos; length(res)+1];
    res=[res; tmp];
    featureGroupList{length(featureGroupList)+1} = 'Gabor';
else
    [res startPos featureGroupList] = ...
        AppendFeatureList(tmp, 'Gabor', res, startPos, featureGroupList);
end
[~,~,featureList] = AppendFeatureList(tmp, 'Gabor', res, startPos, featureList);

%% 8. Edge Sharpness feature
[tmp fv_name] = getEdgeFeatureVector(lesion, 0);
if GROUP_FV
    startPos = [startPos; length(res)+1];
    res=[res; tmp];
    featureGroupList{length(featureGroupList)+1} = 'Edge Sharpness';
else
    [res startPos featureGroupList] = ...
        AppendFeatureList(tmp, fv_name, res, startPos, featureGroupList);
end
[~,~,featureList] = AppendFeatureList(tmp', fv_name, res, startPos, featureList);

%% 9. Haar on Histogram 2
startPos = [startPos; length(res)+1];
[c,l] = wavedec(p',3,'haar');
res=[res; c(l(1)+l(2))];
featureGroupList{length(featureGroupList)+1} = 'Haar on Histogram';
featureList{length(featureList)+1} = 'Haar on Histogram';

%% 10. Daube on Histogram
% Example:
%   s, [18 18;18 18;21 21;27 27;39 39;64 64]
%   c, 9636*1, 9369=18*18+3*18*18+3*21*21+3*27*27+3*39*39
% We collect the approx. coefficient at 4x downsampled image (18x18) for
% the 64x64 input image ("inside")

[c,s] = wavedec2(inside,4,'db8');
tmp = c(1:s(1,1)*s(1,2))'/100000;
if GROUP_FV
    startPos = [startPos; length(res)+1];
    res=[res; tmp];
    featureGroupList{length(featureGroupList)+1} = 'Daube on Histogram';
else
    [res startPos featureGroupList] = ...
        AppendFeatureList(tmp, 'Daube on Histogram', res, startPos, featureGroupList);
end
[~,~,featureList] = AppendFeatureList(tmp, 'Daube on Histogram', res, startPos, featureList);

%% 11. Histogram on edge
mask = poly2mask(poly.x,poly.y,h,w);
curve = sqrt((poly.x-double(centerX)).^2+(poly.y-double(centerY)).^2);
% radius = min(20,ceil(0.5*mean(curve)));
radius = 5;
se = strel('disk',radius);
maskD = imdilate(mask,se);
maskE = imerode(mask,se);
% maskEdge = maskD-maskE;   % never used
maskInEdge = mask-maskE;
maskOutEdge = maskD-mask;
nulVal = min(min(I))-2;

% tmpImg = I.*maskEdge+((~maskEdge).*nulVal);
% tmpImg = tmpImg(:);
% tmpImg(find(tmpImg<=nulVal+1))=[];

tmpImg1 = I.*maskInEdge+((~maskInEdge).*nulVal);
tmpImg1 = tmpImg1(:);
tmpImg1(tmpImg1<=nulVal+1)=[];
tmpImg2 = I.*maskOutEdge+((~maskOutEdge).*nulVal);
tmpImg2 = tmpImg2(:);
tmpImg2(tmpImg2<=nulVal+1)=[];

binCnt = max(8, min(min(length(tmpImg1)/30, length(tmpImg2)/30), 30));
bins = linspace(min([tmpImg1; tmpImg2]), max([tmpImg1; tmpImg2]), binCnt);
[h1 x1] = hist(tmpImg1, bins);
[h2 x2] = hist(tmpImg2, bins);
h1=h1/sum(h1);h2=h2/sum(h2);    % normalization
% d1 = sum((h1-h2).^2./(h1+h2));
d2 = sum(min(h1,h2).*(h1+h2));
startPos = [startPos; length(res)+1];
res=[res; d2];
featureGroupList{length(featureGroupList)+1} = 'Histogram on Edge';
featureList{length(featureList)+1} = 'Histogram on Edge';
if 0
    % visualization
    close all;
    subplot(2,2,1);
    imgToShow = I.*maskEdge;
    image(CTWindowing(imgToShow));axis image;axis off;colormap(gray(256));
    subplot(2,2,2);
    imgToShow(:,find(sum(maskEdge)==0))=[];
    imgToShow(find(sum(maskEdge')==0),:)=[];
    image(CTWindowing(imgToShow));axis image;axis off;colormap(gray(256));
    subplot(2,2,[3 4]);
    stem(x1,h1,'r');hold on;stem(x2,h2,'b');
    xlabel([num2str(lesionLabel) '    ' num2str(d2,'%.4f')]);
    figure;
    subplot(3,1,1)
    stem(x1,h1,'r');hold on;stem(x2,h2,'b'); 
    xlabel('pixel intensity');  ylabel('relative frequency')
    title('Histogram [red: h1(inEdge), blue: h2(outEdge)]')
    subplot(3,1,2)
    stem(x1,h1+h2,'k');
    xlabel('pixel intensity');  ylabel('relative frequency')
    title('Histogram [h1+h2]')
    subplot(3,1,3)
    stem(x1,min(h1,h2),'b');
    xlabel('pixel intensity');  ylabel('relative frequency')
    title('Min of (h1,h2)')
    pause;
end

%% 12. semantic
% if exist('voc.mat','file') ~= 2
%     disp('voc.mat (semantic term) missing. ');
% else
%     load voc;
if ~exist('voc', 'var'),
    global gfSESSION;
    if isfield(gfSESSION,'voc'),
        voc = gfSESSION.voc;
    else
        error('No semantic terms vocabulary found.');
    end
end

fv_name = {};
for ii = 1:length(voc)
    fv_name{ii} = ['Semantic-' num2str(ii) '-' voc{ii}];
end
tmp = find(ismember(lesion.chs, voc)==0);
for ii = 1:length(tmp)
    lesion.chs{tmp(ii)}
end
tmp = ismember(voc, lesion.chs)';
if GROUP_FV
    startPos = [startPos; length(res)+1];
    featureGroupList{length(featureGroupList)+1} = 'Semantic';
    res=[res; tmp];
else
    [res startPos featureGroupList] = ...
        AppendFeatureList(tmp, fv_name, res, startPos, featureGroupList);
end
[~,~,featureList] = AppendFeatureList(tmp, fv_name, res, startPos, featureList);

%% 13. Shape Features
[s_fv, ~, fv_name] = b_feature_mor_boundary(lesion);

if GROUP_FV
    % weight for combining the shape features (pre-computed)
    startPos = [startPos; length(res)+1];
    res = [res; s_fv];
    featureGroupList{length(featureGroupList)+1} = 'Shape';
else
    [res startPos featureGroupList] = ...
        AppendFeatureList(s_fv, fv_name, res, startPos, featureGroupList);
end
[~,~,featureList] = AppendFeatureList(s_fv, fv_name, res, startPos, featureList);

%% 14. SUV value
% load suv
% pname = lesion.patientName;
% tmp = find(pname=='-');
% pname = pname(1:tmp(1)-1);
% tmp = get(SUV, pname);
% if isempty(tmp)
%     tmp = 0;
% end
% startPos = [startPos; length(res)+1];
% res=[res; tmp];
% featureGroupList{length(featureGroupList)+1} = 'SUV';
% featureList{length(featureList)+1} = 'SUV';
% 
% featureList = featureList';
% featureGroupList = featureGroupList';

return;