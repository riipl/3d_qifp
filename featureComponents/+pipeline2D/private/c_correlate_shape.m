%
% use LASSO from now on
% 
% Last Modified: 11/16/2009

clear all;
SHAPE_FOLDER = './shape/';
% SHAPE_FOLDER = './';

% load/build database, i.e. parse AIM and DICOM files
global rtSESSION;
% DB = LoadDB();
rtSESSION.DB = [];

if 1
    % all 90 lesions
    load all_90_roi_raw.mat
    if 1
        % this is 86 dataset
        im_RANGE = setdiff(1:90,[63 70 87 47]);
        % this is 72 dataset only 3 shape types (round/lobulated/ovoid)
        im_RANGE = setdiff(1:90, [51 46 45 86 61 31 30 29 28 27 25 24 65 64 63 70 87 47]);
    else
        im_RANGE = 1:nFiles;
    end
    nFiles = length(im_RANGE);      
    lesion = test_lesion(im_RANGE); % we pick the selected lesions out
    im_RANGE = 1:nFiles;            % then im_RANGE can go back to normal
else
    load Ankit_30_roi_raw.mat
    im_RANGE = 1:nFiles;
    lesion = test_lesion(im_RANGE);
end

%%
    
shape_code = {'RID5812', 'RID5800', 'RID5811', 'RID5809', 'LID11', 'LID9', 'RID5803', 'RID5808', 'RID5806', 'LID7', 'RID5810', 'RID5807', 'RID5804', 'RID5802', 'RID5815', 'RID5814', 'RID5801', 'RID5813', 'LID10', 'RID5799', 'RID5805', 'LID127', 'RID5816'};
shape_code_meaning = {'wedge-shaped', 'ovoid', 'linear', 'irregularly shaped', 'rectangular', 'polygonal', 'micronodular','asymmetrically shaped', 'pedunculated', 'amorphous', 'plate-like', 'symmetrically shaped', 'macronodular', 'nodular', 'straightened', 'spoke-wheel', 'lobular', 'beaded', 'square', 'round', 'polypoid', 'geographic', 'curved'};

shape_matrix = zeros(nFiles, length(shape_code));
shape_matrix_code = false(1, length(shape_code));  % record which appeared
for kk = im_RANGE
    imgID = kk;
    tmp_lesion = lesion{imgID};

    %     shapeStr = '';      % contains the shape meaning strings
    for ii = 1:length(lesion{imgID}.ioc)
        cur_shape = lesion{imgID}.ioc{ii}.codeMeaning;
        %         shapeStr = [shapeStr ', ' cur_shape];
        [dummy LOC] = ismember(lesion{imgID}.ioc{ii}.codeValue, shape_code);
        if LOC == 20
%             LOC = 2;  % 2009-08-11 for smooth/lobulated only
        end
        shape_matrix_code(LOC) = 1;
        shape_matrix(kk, LOC) = 1;
    end
    %     shapeStr = shapeStr(3:end);
    %     disp(shapeStr);
    if shape_matrix(kk, 17) == shape_matrix(kk, 2)
        % if a lesion is both lobular and ovoid, ???
%         shape_matrix(kk, 2) = 0;  % 2009-08-11 for smooth/lobulated only
    end
end

% shape_matrix = shape_matrix(:, shape_matrix_code);
[total_count ordering] = sort(sum(shape_matrix), 'descend');
ordering = ordering(1:sum(shape_matrix_code));
hack_ordering = [2 1 3 4 5 6 8 7 9]; % for all_90, 72-lesion set
% hack_ordering = [2 3 1 4]; % for ankit_30
ordering = ordering(hack_ordering(1:length(ordering)));
ordering = ordering(end:-1:1);

if 0
    tmp = [];
    for ii = im_RANGE%1:nFiles
        tmp = [tmp bin2dec(num2str(shape_matrix(ii, ordering(end:-1:1))))];
    end
    [dummy im_ordering] = sort(tmp, 'descend');
else
    tmp = 1:nFiles;
    im_ordering=[];
    for ii = 1: length(ordering)-1
        res = tmp(shape_matrix(tmp, ordering(ii)) == 1);
        [dummy tmp_ind] = sort(shape_matrix(res, ordering(ii+1)));
        res=res(tmp_ind);
        im_ordering = [im_ordering res];
        tmp = setdiff(tmp, res);
    end
    im_ordering = [im_ordering tmp];
    im_ordering = im_ordering(end:-1:1); % for better viewing
end

figure(881), clf;
subplot(2,1,1);
imshow(shape_matrix(im_ordering, ordering)' );axis normal
xlabel('Image Number','FontSize', 18);
ylabel('');

% shape_code_meaning{[ordering]} % this displays the type of shapes appeared
for ii = 1:length(ordering)
    text(0,ii, shape_code_meaning(ordering(ii)),'HorizontalAlignment', 'Right','FontSize', 14);
end
for ii = 1:nFiles
    text(ii,length(ordering)+.6, num2str(im_ordering(ii)),'HorizontalAlignment', 'Right','Rotation',90,'FontSize', 10);
end
colormap copper

%% calculate the feature vectors
shape_features = [];
feature_filename = [SHAPE_FOLDER 'features_' num2str(nFiles) '.mat'];
if ~exist(feature_filename, 'file')
    for kk = im_RANGE
        imgID = kk;
        tmp_lesion = lesion{imgID};
        disp(tmp_lesion.name);
        [fv_res startPos featureList] = b_feature_mor_boundary(tmp_lesion);     % fv_cmt, fv_res are generated
        shape_features = [shape_features fv_res];
    end
    save(feature_filename, 'shape_features', 'startPos', 'featureList');
else
    load(feature_filename, 'shape_features', 'startPos', 'featureList');
end
% display summary of features
s_featureList(shape_features, startPos, featureList);


%% plot the feature descriptor
if 0
    % res will contain the feature vector in the order of sorted order
    res = [];
    for ii = 1:length(ordering)
        res = [res fv_res(:, shape_matrix(:, ordering(ii)) == 1)];
    end

    figure(881);subplot(2,1,1);hold on;
%     stem(res(:, 10))

    stem(ieScale(fv_res(10, im_ordering), 0, length(ordering)))
    set(gca,'XTick',[]);
    for ii = 1:nFiles
        text(ii,-.02, num2str(im_ordering(ii)),'HorizontalAlignment', 'Right','Rotation',90);
    end
    hold off
end

%% build a fake gold standard for the shapes
if 1
    gs = ones(nFiles, nFiles);
    for ii = 1:nFiles
        tmp_shape_type = find(shape_matrix(ii,:)==1);
        for jj = 1:length(tmp_shape_type)
            gs(ii, shape_matrix(:,tmp_shape_type(jj))==1) = 3;
        end
    end

    % set diagonal to 0
    for ii = 1 : nFiles
        gs(ii,ii) = 0;
    end
end

for kk = im_RANGE
    lesionUIDs{kk} = lesion{kk}.name;
end

% make sure GS is properly set
gs = gs + eye(size(gs))*5;
shape_gs = gs;

% Get feature for all lesions
[Dequal Ds] = GetDist(shape_features, startPos, ones(1,length(startPos)));

% calculate the combined distance matrix
% [Dcombined, beta] = LassoCombineDist(Ds, shape_gs, true);
% [NDCGs res] = TestNDCG(Dcombined, 1:nFiles, shape_gs, lesionUIDs,0);
[Dcombined, beta] = LassoCombineDistLOO(Ds, shape_gs, true);
NDCGs = TestNDCGLOO(Dcombined, shape_gs, lesionUIDs,0);

%%
figure(885); clf;
tmp = length(im_RANGE);
PLOT_EACH_SEPARATE = 1;   % 0 - # of lesions in each type, 1 - the whole range
NUM_K = nFiles - 1;
ordering_to_show = ordering([1:end]);
[nR nC] = ieGetSubplotArrange(length(ordering_to_show)+1, 0 , 1);   % make sure figures are 1 row

for tt = 1:length(ordering_to_show)
    subplot(nR, nC, tt)
    ii = ordering_to_show(tt);
    if PLOT_EACH_SEPARATE == 0
        tmp = min(tmp, sum(shape_matrix(:, ii))-1);
        % plotBar(NDCGs(image_type==ii, 1:(sum(image_type==ii)-1)));
        % axis([1 (sum(image_type==ii)-1) 0 1]);
        s_plotBestWorstAvg(NDCGs(shape_matrix(:, ii)==1,:), (sum(shape_matrix(:,ii))-1));
    else
        tmp = NUM_K;
        % plotBar(NDCGs(image_type==ii, :));
        % axis([1 tmp 0 1]);
        s_plotBestWorstAvg(+NDCGs(shape_matrix(:,ii)==1,:), NUM_K);
    end
    xlabel(['Number of Images Retrieved' char(10) ' (K)']);ylabel('NDCG');
%     titleStr = sprintf('Type %s (%g)', shape_code_meaning{ii}, sum(shape_matrix(:,ii)));
    titleStr = sprintf('(%c) Type %s', char('A'-1+tt), shape_code_meaning{ii});
    title(titleStr);
    set(gca, 'FontSize', 12);
end
subplot(nR,nC, length(ordering_to_show)+1)
% plotBar(NDCGs(:, 1:tmp));
s_plotBestWorstAvg(+NDCGs, tmp);
xlabel(['Number of Images Retrieved' char(10) ' (K)']);ylabel('NDCG');
titleStr = sprintf('Overall');
title(titleStr);
title(sprintf('(%c) Overall', char('A'+length(ordering_to_show))));
set(gca, 'FontSize', 12);

% show the similarity matrix GS
if 0
    figure(882);
    tmp = retrieve_s;
    tmp(tmp==0) = 1;
    subplot(2,2,1); imshow(tmp,[]);   title(['Using Features Sorted by image Number' num2str(size(tmp,1))]);
    subplot(2,2,2); imshow(tmp(im_ordering,im_ordering),[]);   title('Using Features Sorted by  shape types');
    subplot(2,2,3);
    imshow(gs,[]);  title(['Sorted by image Number' num2str(size(gs,1))]);

    subplot(2,2,4);imshow(gs(im_ordering,im_ordering),[]); title('Sorted by shape types');
end

%% this is useful when you just need a few types of shapes
res=[];
for ii = 1:min(4, length(ordering))
    res = [res find(shape_matrix(:, ordering(ii)) == 1)'];
end
res = unique(res);


%% use this to find a good/bad CBIR example to show
% display the really terrible results (the weakest link)ii = 8;
ii = length(ordering);
tt = ordering(ii);  tt_NUM_K = 20;
fprintf('** These are: %s. good/bad retrievals: (sorted by NDCG @ K=%d)\n',...
    upper(shape_code_meaning{tt}), tt_NUM_K);

% [find(shape_matrix(:,tt)) NDCGs(shape_matrix(:,tt)==1,1:tt_NUM_K)]
tmp = NDCGs(shape_matrix(:,tt)==1, tt_NUM_K);

%  = NDCGs(:, 5);
[tmp_b tmp_i] = sort(tmp);
tmp = [find(shape_matrix(:,tt)) NDCGs(shape_matrix(:,tt)==1, 1:tt_NUM_K)];

% find the index of lesion whose NDCG@K is above/below the threshold
tmp_f = tmp(tmp_i(tmp_b<0.8), :);
% tmp(tmp_i, :)

% [ID,LesionType] NDCG@K=1, NDCG@K=2, ...
for ii = 1:size(tmp_f, 1)
    fprintf('  [%g,%c] ', tmp_f(ii, 1), image_type(tmp_f(ii,1)));
    for jj = 2:size(tmp_f, 2)
        fprintf('\t%4.1f%%%', tmp_f(ii, jj)*100);
    end
    fprintf('\n');
end
tmp = mean(tmp);
tmp(1+[5 10 15]) % first col is lesion index, not NDCG

%% some useful figure to show
c_display_all_lesions(test_lesion, 5, 1); % show all the ROI with shape, sorted by shape type
c_display_all_lesions(test_lesion, 0, 1); % show all the ROI with shape, sorted by shape type
