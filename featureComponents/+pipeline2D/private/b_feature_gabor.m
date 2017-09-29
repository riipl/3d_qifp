
%% Gabor filtering
% Degree of Freedom:
%   - Scale
%   - Orientation
%   - f_max
%   - gabor filter size (128 or variable to image size) <- i think 128 !!
%   - im_size (no-resize? resize to 32, 64?)
%   - im source (whole lesion, cropped, further cropped, whole lesion with
%               bg filled?)

% load gold_standard.mat
clear all
if 0
    % Ankit-30
    load lesion_roi_raw.mat

    rect = [    3.5100    8.5100   12.9800   13.9800];
    kk = 26;lesion{kk}.cropped = imcrop(lesion{kk}.img, rect);
    rect = [...
        10.5100    8.5100   36.9800   48.9800];
    kk = 27;lesion{kk}.cropped = imcrop(lesion{kk}.img, rect);
    rect = [...
        7.5100    2.5100   17.9800   18.9800];
    kk = 30;lesion{kk}.cropped = imcrop(lesion{kk}.img, rect);
    image_type = image_type + 'A'-1;
else
%     load test_lesion_roi_raw.mat % this is the partial update lesions
    load all_90_roi_raw.mat
%     load Ankit_30_roi_raw.mat
    if 0
        % im_RANGE= setdiff(1:90, [49 50 51 87 70 33]); % get rid of A, F, L, Y types
        % all_90 has A, F, L, Y, C, H, M, N, X
        im_RANGE = [];
        for ii = 'CHMNX'     % type in the types you want to include
            im_RANGE = [im_RANGE find(image_type == ii )];
        end
        im_RANGE =  sort(im_RANGE);
    else
        im_RANGE = 1:nFiles;
    end
    nFiles = length(im_RANGE);
    lesion = test_lesion(im_RANGE);
    image_type = image_type(im_RANGE);
    gs = s_fake_gs(image_type);
    im_RANGE = 1:nFiles;
    
end

s_display_dataset_info(image_type)

% load all_lesion_roi_raw.mat
% lesion = super_lesion;
OSD = 0;
fv_cmt = 'Gabor';

OPTIMIZE_CLASSIFICATION = 0;    % for classification or retrieval problem

GABOR_ONLY_range = 1;

nS_range = 3;
nO_range = 4;
nF_range = 1;                 % mean or mean+std
f_max_range = [0.44 ];
im_size_range = [16.1];

METHOD = 2;                 % metric method
NUM_K = 6;                  % we optimize the mean top-K precision

% Massive Search range:
% GABOR_ONLY_range = 0:1;
% nS_range = 3:5;
% nO_range = 4:10;
% nF_range = 1:2;                 % mean or mean+std
% f_max_range = [0.25  0.15 0.2 0.3 0.35 0.4 0.43 0.44 0.45];
% f_max_range = [ 0.3 0.35 0.4 0.44 0.45];
% im_size_range = [16.1 32.1 16 32 0];

% im_RANGE = [1:23];         % no H 
im_RANGE = 1:nFiles;         % full 30 images 

lesion_label = image_type(im_RANGE)';

bestcv = 0;
cnti = 1;
toti = length(nS_range)*length(nO_range)*length(nF_range) ...
    *length(f_max_range)*length(im_size_range)*length(GABOR_ONLY_range);
for GABOR_ONLY = GABOR_ONLY_range
    for nS = nS_range
        for nO = nO_range
            for numFeature = nF_range
                for im_size = im_size_range

                    for f_max_idx = 1:length(f_max_range)
                        f_max = f_max_range(f_max_idx);
                        disp([num2str(cnti) '/' num2str(toti)]);
                        cnti = cnti + 1;

                        if (im_size>0)
                            gaborBank = sg_createfilterbank([128 128], f_max, nS, nO, 'pf', 0.99,'verbose',0);
                        end

                        if (GABOR_ONLY == 1)
                            f_vector = zeros(length(im_RANGE), nS * nO * numFeature);
                        else
                            f_vector = zeros(length(im_RANGE), nS * nO * numFeature + 2);
                        end
                        for kk = im_RANGE

                            img = lesion{kk}.cropped;   % 1st batch of cropping
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
                                            img = img(1:min(size(img)), 1:min(size(img)));
                                            img = imresize(img, [im_size im_size ]);
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
                            f_vector(kk, :) = tmp_f_vector;
                        end
                        %                     lesion_inst = [lesion_inst f_vector];
                        lesion_inst = [f_vector];

                        % normalizing each feature
                        for ii = 1:size(lesion_inst, 2)
                            lesion_inst(:, ii) = ieScale(lesion_inst(:, ii), 0, 1);
                        end

                        if OPTIMIZE_CLASSIFICATION == 1
                            [tbt, tbc, tbg, tbcv] = search_svm_param(lesion_inst, lesion_label, 10, 0);
                        else
                            % optimize top K precision
                            tbt = NaN;tbc = NaN; tbg = NaN;

                            % Calculate precision matrix
                            [retrieve_s precision] = c_calculate_precision(lesion_inst, gs, METHOD, fv_cmt, 0, NUM_K);
                           
                            tbcv = mean(mean(precision(:, 1:NUM_K))) * 100;
                        end

                        if (tbcv > bestcv) || isnan(tbcv)
                            bestcv = tbcv; bestc = tbc; bestg = tbg; bestt = tbt;
                            bestnO = nO; bestnS = nS; bestnF = numFeature;
                            bestTNF = size(lesion_inst, 2);
                            best_f_max = f_max;
                            best_im_size = im_size;
                            best_G_O = GABOR_ONLY;
                        end
                    end %f_max
                end % im_size
            end %nF
        end %nS
    end %nO
end % GABOR_ONLY 

if OPTIMIZE_CLASSIFICATION == 1
    fprintf('\n*** CLASSIFICATION PROBLEM\n');
else
    fprintf('\n*** Optimizing Mean Top-%g Precision (Method %g)\n', NUM_K, METHOD);
end
fprintf('***\n*** nS=%g, nO=%g, nF=%g, %g-D FV (f_max: %4.2f) (im: %gpx)\n*** (t=%g, c=%g, g=%g, rate=%g%%)\n', ...
    bestnS, bestnO, bestnF, bestTNF, best_f_max, best_im_size, bestt, bestc, bestg, bestcv);
if best_G_O == 1
    fprintf('*** GABOR_ONLY\n');
else
    fprintf('*** GABOR with Mean+Std.\n');
end
fprintf('***\n');

% prepare data for drawing the ROC curve
if 0 
    tmp = 1:15;
    % write_training_data(lesion_label(tmp, :), lesion_inst(tmp, :));
    tmp = setdiff([im_RANGE], [tmp]);
    % write_training_data(lesion_label(tmp, :), lesion_inst(tmp, :), 'test_data.txt');

    % 
end
c_eval_feature

%% display the similarity matrix
tmp = retrieve_s;
tmp(tmp==0) = 1;
[a b] = sort(image_type);

figure(9951)
subplot(2,2,1);imshow(tmp,[]);   title(['Using Features Sorted by image Number']);
subplot(2,2,2);imshow(tmp(b,b),[]);   title(['Using Features Sorted by lesion types']);
set(gca, 'XTick', find([1 a(2:end)-a(1:end-1)]))
set(gca, 'YTick', find([1 a(2:end)-a(1:end-1)]))
axis on

subplot(2,2,3);imshow(gs,[]); title('GS (Sorted by image Number)');
subplot(2,2,4);imshow(gs(b,b),[]);
title('GS (Sorted by lesion types)');
set(gca, 'XTick', find([1 a(2:end)-a(1:end-1)]))
set(gca, 'YTick', find([1 a(2:end)-a(1:end-1)]))
% set(gca, 'XTick', [find([1 a(2:end)-a(1:end-1)]) length(b)])
% set(gca, 'YTick', [find([1 a(2:end)-a(1:end-1)]) length(b)])
axis on
