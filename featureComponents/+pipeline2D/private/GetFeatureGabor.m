function [fv] = GetFeatureGabor(lesion)

% This function reads in a lesion struct and calcualte the gabor filter
% response to the ROI.
%
% example: GetFeatureGabor(LESION_STRUCT, [nS=3], [nO=4]);
%
% Last modified: 10-19-2009
%

img = lesion.image;
x = lesion.roi.x - double(lesion.offset.x);
y = lesion.roi.y - double(lesion.offset.y);

% find the biggest rect and apply the feature extraction
roiMask = roipoly(img, x, y) ;
bbox = regionprops(double(roiMask), 'BoundingBox') ;
bbox = ceil(bbox.BoundingBox) ;
roi = img ;

% img contains ROI only, no surrounding content
roi(~roiMask) = 0 ;
ROI = roi(bbox(2):bbox(2) + bbox(4) - 1, bbox(1):bbox(1) + bbox(3) - 1) ;

tmp_lesion.img = double(ROI);
rect = s_find_biggest_rect(tmp_lesion);
tmp_lesion.cropped = imcrop(tmp_lesion.img, rect);


% basically copied from b_feature_gabor.m
GABOR_ONLY = 1;
OSD = 0;
if ~exist('nS', 'var'), nS = 5; end
if ~exist('nO', 'var'), nO = 4; end
nF = 2;                 % mean or mean+std
numFeature = nF;
f_max = [0.44 ];
im_size = [16.1];

if (im_size>0)
    gaborBank = sg_createfilterbank([128 128], f_max, nS, nO, 'pf', 0.99,'verbose',0);
end

% if (GABOR_ONLY == 1)
%     f_vector = zeros(length(im_RANGE), nS * nO * numFeature);
% else
%     f_vector = zeros(length(im_RANGE), nS * nO * numFeature + 2);
% end

% img = lesion{kk}.cropped;   % 1st batch of cropping
%                             img = lesion2{kk}.cropped;  % further cropped
%                             img = lesion{kk}.img;       % full image

if (im_size>0)
    if 1
        if min(size(img)) > im_size
            if (im_size==floor(im_size))
                % (1) pick a square of 16x16 or
                % 32x32 , when im_size is int 16
                img = img(1:im_size, 1:im_size);
            else
                % (2) pick a square, then resize.
                % when im_size is 16.1
                img = tmp_lesion.cropped(1:min(size(tmp_lesion.cropped)), 1:min(size(tmp_lesion.cropped)));
                %img = imresize(img, [im_size im_size ]);
                img = imresize(img, [128, 128]);
            end
        else
            % (3) resize the small square
            img = imresize(img, [im_size im_size ]);
            fprintf('.');
        end
    else
        % (3) resize the small square
        img = imresize(img, [im_size im_size ]);
        fprintf('.');
    end
else
    gaborBank = sg_createfilterbank(size(img)*2, f_max, nS, nO, 'pf', 0.99,'verbose',0);
end

% Filter with the filter bank
%     fResp = sg_filterwithbank(img, gaborBank);
%     Convert responses to simple 3-D matrix
%     fResp = sg_resp2samplematrix(fResp);
%     Normalise
%     fResp = sg_normalizesamplematrix(fResp);

fResp2 = sg_filterwithbank2(img, gaborBank);

% Display scaled responses
if OSD == 1
    figure(3244)
    fprintf('Displaying input image and the same but "unscaled" responses...');
    subplot(1,3,1);
    imagesc(img);        axis off;
    title('Input');
    for iS = 1 : nS        % size(fResp2.freq,2)
        for iO = 1 : nO    % size(fResp2.freq{1}.resp,1)
            figure(3244)
            subplot(1,3,2);
            imagesc(squeeze(real(fResp2.freq{iS}.resp(iO,:,:))));
            axis([1 size(img,1) 1 size(img,2)]);
            axis off
            title('Real');
            subplot(1,3,3);
            imagesc(squeeze(imag(fResp2.freq{iS}.resp(iO,:,:))));
            axis([1 size(img,1) 1 size(img,2)]);
            axis off
            title('Imaginary');
            %                                     input('<RETURN>');
            figure(3211)
            tsubplot(nS, nO, (iS-1)*nO+iO)
            imagesc(squeeze(imag(fResp2.freq{iS}.resp(iO,:,:))));
            axis off, axis image; colormap gray
        end;
    end;
    return;
    
end

if (GABOR_ONLY ~= 1)
    tmp = lesion{kk}.img;
    tmp_m = mean(tmp(:));
    tmp_st = std(tmp(:), 1);
    tmp_f_vector = [tmp_m tmp_st];
else
    tmp_f_vector = [];
end
for iS = 1:nS
    for iO = 1:nO
        tmp = fResp2.freq{iS}.resp(iO,:,:);
        tmp_m = mean(abs(tmp(:)));
        tmp_var = var(abs(tmp(:)));
        
        if (numFeature == 2)
            tmp_f_vector = [tmp_f_vector tmp_m tmp_var];
        else
            tmp_f_vector = [tmp_f_vector tmp_m];
        end
    end
end
fv = tmp_f_vector;

% normalizing each feature
% for ii = 1:size(lesion_inst, 2)
%     lesion_inst(:, ii) = ieScale(lesion_inst(:, ii), 0, 1);
% end


return