function [res, startPos, featureGroupList, featureList] = getImageFeature(lesion, RELOAD_IM_FROM_DICOM, GROUP_FV, config_profile)
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
% Last modified: 05-24-2012
%

if ~exist('RELOAD_IM_FROM_DICOM', 'var'), RELOAD_IM_FROM_DICOM = 1; end
if ~isfield(lesion, 'RELOAD_IM_FROM_DICOM'), RELOAD_IM_FROM_DICOM = 1; end
if ~exist('GROUP_FV', 'var'), GROUP_FV = 1; end
APPEND_RAW_INTENSITY  = 0;

res = []; startPos = [];
fprintf('- Extracting features for %s\n',lesion.uid);

% organ specific threshold
if isfield(lesion, 'ORGAN'), 
    ORGAN = lesion.ORGAN;
else
    ORGAN = 'lung';
end

%% preprocessing
if ~RELOAD_IM_FROM_DICOM
    Icrop = lesion.image;
    if ~isfield(lesion, 'roi_interpolated')
        [lesion.roi_interpolated.x lesion.roi_interpolated.y] = s_spline_interpolate(lesion.roi.x, lesion.roi.y);
    end
    highestIntensity = max(Icrop(:));
else
    lesion.dicomFileName(lesion.dicomFileName=='\') = '/';
    I = loadDICOM(lesion.dicomFileName, ORGAN, config_profile);
    LARGEST_LESION_H = 195;
    LARGEST_LESION_W = 195;
    [lesion.image, lesion.offset, lesion.roi_interpolated] = ...
        GetLesionImgSz(I, lesion.roi, LARGEST_LESION_H, LARGEST_LESION_W);
    Icrop = lesion.image;
end

% from this point, these are garanteed:
%         lesion.image              : cropped image (padded)
%         lesion.roi                : raw roi (on full image)
%         lesion.roi_interpolated   : spline interpolated ROI
%         lesion.offset             : offset for cropped image

%% organ specific threshold

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is added to OOP this (2012-09-28)
if ~exist('config_profile', 'var') 
    config_profile = get_config_profile( ORGAN );
end
if strcmp(config_profile.name, 'null')==0 % 'null' is an empty profile
    c_low = config_profile.display.c_low;
    c_high = config_profile.display.c_high;
    
    F1_THRESH = config_profile.features.hist.F1_THRESH;
    bin_l = config_profile.features.hist.bin_l;
    bin_h = config_profile.features.hist.bin_h;
    NUM_BINS = config_profile.features.hist.NUM_BINS;
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% pre-processing
% blur = fspecial('gaussian',[7 7], 2);
% Icrop = single(conv2(double(Icrop),blur,'same'));
[h, w, ~] = size(Icrop);
poly = lesion.roi_interpolated;
poly.x = poly.x-lesion.offset.x+1;
poly.y = poly.y-lesion.offset.y+1;

bBox.left = lesion.offset.x;
bBox.right = uint16(floor(max(poly.x)));
bBox.top = lesion.offset.y;
bBox.bottom = uint16(floor(max(poly.y)));
centerX = uint16(floor(mean(poly.x)));
centerY = uint16(floor(mean(poly.y)));

sz = uint16(floor(min(w,h)/2/sqrt(2)/1.5));
iBox.left = centerX-sz;
iBox.right = centerX+sz;
iBox.top = centerY-sz;
iBox.bottom = centerY+sz;
% "inside" is used for wavelet feature
inside = Icrop(iBox.top:iBox.bottom, iBox.left:iBox.right);
inside = tileToSize(inside,64,64);

roimask = Icrop*0;
roimask = roipoly(roimask, poly.x, poly.y+1);

d = Icrop(roimask);
do = Icrop(roimask==0);

if 0
    figure;
    subplot(1,2,1);
    imshow(lesion.image, []); hold on; plot(poly.x, poly.y, 'r');
    rectangle('Position', [iBox.left iBox.top iBox.right-iBox.left+1 iBox.bottom-iBox.top+1]); hold off;
    title(sprintf('raw [%4.0f~%4.0f]', min(lesion.image(:)), max(lesion.image(:))))
    subplot(1,2,2);
    imshow(lesion.image.*roimask, []); hold on; plot(poly.x, poly.y, 'r', 'LineWidth', 2);
    rectangle('Position', [iBox.left iBox.top iBox.right-iBox.left+1 iBox.bottom-iBox.top+1]); hold off;
    title(sprintf('ROI Mask [%4.0f~%4.0f]', min(d(:)), max(d(:))))
    drawnow;
end


%% Feature List:
% 1. Proportion of pixels with intensity larger than F1_THRESH
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

%% 1. Proportion of pixels with intensity larger than F1_THRESH
startPos = [startPos; length(res)+1];
featureGroupList{length(featureGroupList)+1} = ['Proportion of pixels with intensity larger than ' num2str(F1_THRESH)];
featureList{length(featureList)+1} = ['Proportion of pixels with intensity larger than ' num2str(F1_THRESH)];
d1=sum(d>F1_THRESH)/length(d);
res=[res; d1];

%% 2. Entropy of histogram 1
startPos = [startPos; length(res)+1];
featureGroupList{length(featureGroupList)+1} = 'Entropy of histogram';
featureList{length(featureList)+1} = 'Entropy of histogram';
OLD_HIST_BIN = 0;
if OLD_HIST_BIN
    %qpv = [-Inf linspace(120, 1200, 10) Inf] ;
    bins = linspace(bin_l, bin_h, NUM_BINS);
    qpv  = [-Inf (bins(2:end)+bins(1:end-1))/2 Inf];

else
%     qpv = [-Inf 328 473 668 880 1002 1032 1046 1058 1072 1091 Inf];
%     qpv = [-Inf linspace(bin_l, bin_h, NUM_BINS-1) Inf];
      qpv = [-Inf linspace(min(d(:)), max(d(:)), NUM_BINS-1) Inf];

    p = histc(d, qpv)';
    p = p(1:end-1);
end
nz = p>0;
% p = p(1:end-1);
% p=p+1e-6*sum(p);
p= p/sum(p);
% p(p<0.1*max(p))=0;
% p=p+1e-6*sum(p);
% p=p/sum(p);
entropy=-sum(p(nz).*log(p(nz)));
res=[res; entropy];

%% 3. Peak position 1
startPos = [startPos; length(res)+1];
featureGroupList{length(featureGroupList)+1} = 'Peak Position';
featureList{length(featureList)+1} = 'Peak Position';
[~,ind]=max(p);
res=[res; ind];

%% 4. Histogram (min, max, median, ...)
[~, tmp] = s_find_longest_axis(lesion.roi, 0);
tmp = [
    length(d(:)); 
    tmp.major; 
    tmp.minor; 
    length(d(:))*lesion.PixelSpacing^2; 
    tmp.major*lesion.PixelSpacing; 
    tmp.minor*lesion.PixelSpacing; 
    min(d); max(d); median(d); mean(d); std(d); skewness(d); kurtosis(d);
    ]';
fv_name = {
    'Lesion-Size (px^2)', 'Major Axis (px)', 'Minor Axis (px)', ...
    'Lesion-Size (mm^2)', 'Major Axis (mm)', 'Minor Axis (mm)', ...
    'Histogram-min','Histogram-max','Histogram-median', ...
    'Histogram-mean','Histogram-std','Histogram-skewness','Histogram-kurtosis'};

if GROUP_FV
    featureGroupList{length(featureGroupList)+1} = 'Histogram';
    startPos = [startPos; length(res)+1];
    res=[res; tmp'];
else
    [res startPos featureGroupList] = AppendFeatureList(tmp', fv_name, res, startPos, featureGroupList);
end
[~,~,featureList] = AppendFeatureList(tmp', fv_name, res, startPos, featureList);

%% 4.1 30-bin histogram itself
tmp = p;
fv_name = {};
if OLD_HIST_BIN
    for ii = 1:length(qpv)-1
        fv_name{ii} = ['Histogram-bin-' num2str(ii) ' (' num2str(qpv(ii)) '-' num2str(qpv(ii+1)) ')'];
    end
else
    for ii = 1:length(qpv)-1
%        fv_name{ii} = sprintf('Histogram-bin-%d (%4.0f-%4.0f)', ii, qpv(ii), qpv(ii+1));
         fv_name{ii} = sprintf('Histogram-bin-%d', ii);
    end
end
if GROUP_FV
    featureGroupList{length(featureGroupList)+1} = 'Histogram-bin';
    startPos = [startPos; length(res)+1];
    res=[res; tmp'];
else
    [res startPos featureGroupList] = AppendFeatureList(tmp', fv_name, res, startPos, featureGroupList);
end
[~,~,featureList] = AppendFeatureList(tmp', fv_name, res, startPos, featureList);

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
[tmp fv_name] = getEdgeFeatureVector(lesion, 0, ORGAN, config_profile);
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
[c,l] = wavedec(p(2 : NUM_BINS)', 3,'haar');
%res=[res; c(l(1)+l(2))];
startPos = [startPos; length(res)+1];
res=[res; c];
featureGroupList{length(featureGroupList)+1} = 'Haar on Histogram';
[~,~,featureList] = AppendFeatureList(c, 'Haar on Histogram', res, startPos, featureList);

%featureList{length(featureList)+1} = 'Haar on Histogram';

%% 9.1 Contrast
michelson_contrast = (max(d) - min(d))/(max(d)+ min(d));
normalized_d = (d - min(d));
normalized_d = normalized_d/max(d);
rms_contrast = sqrt(mean((normalized_d - mean(normalized_d)).^2));
tmp = [
    michelson_contrast;
    rms_contrast;
    ]';
fv_name = {
    'Michelson Contrast',
    'RMS Contrast'};

if GROUP_FV
    featureGroupList{length(featureGroupList)+1} = 'Contrast';
    startPos = [startPos; length(res)+1];
    res=[res; tmp'];
else
    [res, startPos, featureGroupList] = AppendFeatureList(tmp', fv_name, res, startPos, featureGroupList);
end
[~,~,featureList] = AppendFeatureList(tmp', fv_name, res, startPos, featureList);


%% 9.2 GLCM
gl_img = lesion.image;
x = lesion.roi.x - double(lesion.offset.x);
y = lesion.roi.y - double(lesion.offset.y);

% find the biggest rect and apply the feature extraction
gl_roiMask = roipoly(gl_img, x, y) ;
gl_bbox = regionprops(double(gl_roiMask), 'BoundingBox') ;
gl_bbox = ceil(gl_bbox.BoundingBox) ;
gl_roi = gl_img ;

% img contains ROI only, no surrounding content
gl_roi(~gl_roiMask) = 0 ;
gl_ROI = gl_roi(gl_bbox(2):gl_bbox(2) + gl_bbox(4) - 1, gl_bbox(1):gl_bbox(1) + gl_bbox(3) - 1);

gl_tmp_lesion.img = double(gl_ROI);
gl_rect = s_find_biggest_rect(gl_tmp_lesion);
gl_tmp_lesion.cropped = imcrop(gl_tmp_lesion.img, gl_rect);

%Distance 2
[gl_val, gl_tmp] = glcm(gl_tmp_lesion.cropped, 2);
tmp = gl_tmp';
fv_name = gl_val'; 
if GROUP_FV
    featureGroupList{length(featureGroupList)+1} = 'GLCMDistance2';
    startPos = [startPos; length(res)+1];
    res=[res; tmp'];
else
    [res startPos featureGroupList] = AppendFeatureList(tmp', fv_name, res, startPos, featureGroupList);
end
[~,~,featureList] = AppendFeatureList(tmp', fv_name, res, startPos, featureList);

%Distance 3
[gl_val, gl_tmp] = glcm(gl_tmp_lesion.cropped, 3);
tmp = gl_tmp';
fv_name = gl_val'; 
if GROUP_FV
    featureGroupList{length(featureGroupList)+1} = 'GLCMDistance3';
    startPos = [startPos; length(res)+1];
    res=[res; tmp'];
else
    [res startPos featureGroupList] = AppendFeatureList(tmp', fv_name, res, startPos, featureGroupList);
end
[~,~,featureList] = AppendFeatureList(tmp', fv_name, res, startPos, featureList);

%Distance 5
[gl_val, gl_tmp] = glcm(gl_tmp_lesion.cropped, 5);
tmp = gl_tmp';
fv_name = gl_val'; 
if GROUP_FV
    featureGroupList{length(featureGroupList)+1} = 'GLCMDistance5';
    startPos = [startPos; length(res)+1];
    res=[res; tmp'];
else
    [res startPos featureGroupList] = AppendFeatureList(tmp', fv_name, res, startPos, featureGroupList);
end
[~,~,featureList] = AppendFeatureList(tmp', fv_name, res, startPos, featureList);

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
mask = poly2mask(poly.x, poly.y, h, w);
% curve = sqrt((poly.x-double(centerX)).^2+(poly.y-double(centerY)).^2);
% radius = min(20,ceil(0.5*mean(curve)));
radius = 5;
se = strel('disk',radius);
maskD = imdilate(mask,se);
maskE = imerode(mask,se);
% maskEdge = maskD-maskE;   % never used
maskInEdge = mask-maskE;
maskOutEdge = maskD-mask;
nulVal = min(min(Icrop))-2;

% tmpImg = Icrop.*maskEdge+((~maskEdge).*nulVal);
% tmpImg = tmpImg(:);
% tmpImg(find(tmpImg<=nulVal+1))=[];

tmpImg1 = Icrop.*maskInEdge+((~maskInEdge).*nulVal);
tmpImg1 = tmpImg1(:);
tmpImg1(tmpImg1<=nulVal+1)=[];
tmpImg2 = Icrop.*maskOutEdge+((~maskOutEdge).*nulVal);
tmpImg2 = tmpImg2(:);
tmpImg2(tmpImg2<=nulVal+1)=[];

binCnt = max(8, min(min(length(tmpImg1)/30, length(tmpImg2)/30), 30));
bins = linspace(min([tmpImg1; tmpImg2]), max([tmpImg1; tmpImg2]), binCnt);
[h1 ] = hist(tmpImg1, bins);
[h2 ] = hist(tmpImg2, bins);
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
    imgToShow = Icrop.*maskEdge;
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

%% histogram run length
if APPEND_RAW_INTENSITY == 1
    [val cnt] = s_run_length_code(d);
    fv = double([val'; cnt']);
    fv = fv(:);
    fv_name = 'Raw Pixel Intensity (Value/Count)';
    if GROUP_FV
        startPos = [startPos; length(res)+1];
        res = [res; fv];
        featureGroupList{length(featureGroupList)+1} = 'Raw Pixel Intensity';
    else
        [res startPos featureGroupList] = ...
            AppendFeatureList(fv, fv_name, res, startPos, featureGroupList);
    end
    [~,~,featureList] = AppendFeatureList(fv, fv_name, res, startPos, featureList);
end

return;