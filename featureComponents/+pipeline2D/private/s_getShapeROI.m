% this script deals with the fake geometric data only.

FINAL_IM_SIZE = 100;
SHAPE_PERCENTAGE = .5;
N = 12;

lesion{1}.name = 'Round1';
lesion{2}.name = 'Round2';
lesion{3}.name = 'Round3';
lesion{4}.name = 'Microlobulated1';
lesion{5}.name = 'Microlobulated2';
lesion{6}.name = 'Microlobulated3';
lesion{7}.name = 'Lobulated1';
lesion{8}.name = 'Lobulated2';
lesion{9}.name = 'Lobulated3';
lesion{10}.name = 'Spiculated1';
lesion{11}.name = 'Spiculated2';
lesion{12}.name = 'Spiculated3';

clear DB;
DB.lesions = hashtable;
nFiles = N;
image_type = [];
for imgID = 1:nFiles
    im = double(rgb2gray(imread(['shape\sample shapes\s' num2str(imgID) '.bmp'])));

    im(im<240) = 0;
    im(im~=0) = 1;
    im = 1-im;
    % im = uint8(logical(im));
    % im = imresize(im, [100 100]);

    [m n] = size(im);
    Y = round(m/2);

    for X = 1:n
        if (im(Y, X) == 1 )
            break
        end
    end

    contour = bwtraceboundary(im, [Y X], 'W', 8, Inf, 'counterclockwise');

    roix = contour(:,2);
    roiy = contour(:,1);

    if 0
        lowP = (1 - SHAPE_PERCENTAGE)/2;
        highP = 1 - lowP;
        roix = ieScale(roix, lowP*FINAL_IM_SIZE, highP*FINAL_IM_SIZE);
        roiy = ieScale(roiy, lowP*FINAL_IM_SIZE, highP*FINAL_IM_SIZE);
    else
        FINAL_IM_SIZE = max(max(roix(:))-min(roix(:)), max(roiy(:))-min(roiy(:))) + 100;
        roix = roix - min(roix(:)) + 50;
        roiy = roiy - min(roiy(:)) + 50;
    end
    im = zeros(FINAL_IM_SIZE);
    cimg = roipoly(im, roix, roiy);
    lesion{imgID}.roix = roix';
    lesion{imgID}.roiy = roiy';
    lesion{imgID}.cimg = cimg;
    lesion{imgID}.type = lesion{imgID}.name(1);
    image_type = [image_type lesion{imgID}.type];
    figure(776), subplot(s_nR(N), s_nC(N), imgID); imshow(cimg); 
    title(mat2str(size(cimg)));
    
    tmp_lesion.valid = 1;
    tmp_lesion.roi.x = roix;
    tmp_lesion.roi.y = roiy;
    tmp_lesion.uid = lesion{imgID}.name;
    tmp_lesion.image = cimg;
    tmp_lesion.offset.x = 0;
    tmp_lesion.offset.y = 0;
    tmp_lesion.observations = '';
    
    DB.lesions = put(DB.lesions, tmp_lesion.uid, tmp_lesion);
    
end
% save('fake_lesion_raw.mat', 'image_type', 'lesion', 'nFiles', 'gs');

% REMEMBER TO SAVE TO fake_lesion_roi.mat
%% WHAT YOU NEED TO DO TO CREATE A FAKE DATA SET
if 0
    clear all;load fake_lesion_raw.mat
    nFile = length(lesion);
    image_type = [1 2 3 4 5];
end


