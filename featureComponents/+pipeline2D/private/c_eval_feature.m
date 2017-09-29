%
%
% Last Modified: 11/16/2009

%%
% Input:
%     - lesion_inst
%     - gs
% Degree of freedom:
%   1. Distance, or normalized Distance by its std
%   2. How to evaulate top-k entries (using NDCG) 2009-04-17

% load lesion_roi_raw.mat

% fprintf('** Evaulating %g-D FV [%s] (Valid Method %g)\n', size(lesion_inst, 2), fv_cmt, METHOD);

% normalizing each feature
for ii = 1:size(lesion_inst, 2)
    lesion_inst(:, ii) = ieScale(lesion_inst(:, ii), 0, 1);
end

% nFiles = 30;
im_RANGE = 1:nFiles;
NUM_K = nFiles-1;

retrieve_s = -Dcombined;
% [retrieve_s precision] = c_calculate_precision(lesion_inst, gs, METHOD,
% fv_cmt, 0);

% figure(553), plot(precision(1:10,1:NUM_K)')
% plot(mean(precision), 'bs-');
% xlabel('Num of Images Retrieved (K)');ylabel('Top K Precision')
% titleStr = sprintf('%g-D FV Top K Precision', size(lesion_inst, 2));
% title(titleStr);
% precision(30, 1:6)=[1 1 0.6667 0.75 0.8 0.5]

figure(554)
im_type_range = unique(image_type);
tmp = length(im_RANGE);
PLOT_RANGE = 1;         % 0 - the number of lesions in each type
                        % 1 - the whole range
for tt = 1:length(im_type_range)
    nR = s_nR(length(im_type_range)+1);
    nC = s_nC(length(im_type_range)+1);
    subplot(nR, nC,tt)
    ii = im_type_range(tt);
    if PLOT_RANGE == 0
        tmp = min(tmp, sum(image_type==ii)-1);
        % plotBar(precision(image_type==ii, 1:(sum(image_type==ii)-1)));
        % axis([1 (sum(image_type==ii)-1) 0 1]);
        s_plotBestWorstAvg(precision(image_type==ii,:), (sum(image_type==ii)-1));
    else
        tmp = NUM_K;
        % plotBar(precision(image_type==ii, :));
        % axis([1 tmp 0 1]);
        s_plotBestWorstAvg(precision(image_type==ii,:), NUM_K);
    end
    xlabel('K (Number of Retrieved Images)');ylabel('NDCG');
    titleStr = sprintf('Type %c (%g)', ii, sum(image_type==ii));
    title(titleStr);
%     set(gca, 'FontSize', 12);
end
subplot(nR,nC, length(im_type_range)+1)
% plotBar(precision(:, 1:tmp));
s_plotBestWorstAvg(precision, tmp);
xlabel('K (Number of Retrieved Images)');ylabel('NDCG');
% titleStr = sprintf('Overall (Method %g)', METHOD);
titleStr = sprintf('Overall (Method NDCG)');
title(titleStr);
s_format_fig('ppt', 'full');

%% display the really terrible results (the weakest link)
NUM_K_SORT = 10;
tmp = precision(:, NUM_K_SORT);
[tmp_b tmp_i] = sort(tmp);
tmp = [[1:nFiles]' precision(:, NUM_K_SORT:NUM_K_SORT+5)];

tmp_f = tmp(tmp_i(tmp_b<0.8), :);
% tmp_f = tmp(tmp_i(tmp_b>0.9), :);
% tmp(tmp_i, :)

% img_num, top1, top2, top3, top4, top5
fprintf('** not so good retrievals:\n');
for ii = 1:size(tmp_f, 1)
    fprintf('  [%g,%c] ', tmp_f(ii, 1), image_type(tmp_f(ii,1)));
    for jj = 2:size(tmp_f, 2)
        fprintf('\t%4.1f%%%', tmp_f(ii, jj)*100);
    end
    fprintf('\n');
end

%% summary of top-6 and top-28 mean precision
for tmp_f = [6 NUM_K]
    fprintf('** Overall Top-%g Mean: %4.2f%%\n', tmp_f, mean(mean(precision(:, 1:tmp_f))) * 100);
end
