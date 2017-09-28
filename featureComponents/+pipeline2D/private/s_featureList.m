function s_FeatureList(feature_vector, startPos, featureList, beta)

% display what features are in feature_vector
% if beta is provide, we display that next to the feature_vector
% 
% example: s_FeatureList(feature_vector, startPos, featureList, beta)

if ~exist('beta', 'var'), beta = []; end

[d NumLesions] = size(feature_vector);
N = length(startPos);

if (N ~= length(featureList))
    error('startPos has different length from featureList');
end

startPos = [startPos; d+1];
disp([' ' repmat('-', [1 40])]);
fprintf('  Total: %d lesions. %d-D feature vector\n', NumLesions, d);
disp([' ' repmat('-', [1 40])]);

for i = 1:N
    if length(beta)~= 0
        fprintf('%9.3f ', beta(i));
    end
    fprintf('  Feature %2d (length: %3d) %s\n', i, startPos(i+1)-startPos(i), featureList{i});
end

disp([' ' repmat('-', [1 40])]);

%% display bar graph
if length(beta)==0
    return;
end

if (length(beta) <= 20) 
    DISPLAY_LEGEND = 1;
else
    DISPLAY_LEGEND = 0;
end
figure; hold on;
l_str = {};
if DISPLAY_LEGEND
    non_zero_ind = 1:N;
else
    non_zero_ind = find(beta(1:end-1) > 1e-5);
end
% for ii = 1:length(beta)-1
for j = 1:length(non_zero_ind)
    ii = non_zero_ind(j);   % only draw the nonzero bars
    bar(ii, beta(ii),'FaceColor', [1 1 1]*ii/length(beta)); 
    if DISPLAY_LEGEND
        tmp = [num2str(ii) '. ' featureList{ii}];
        if (length(tmp)>23)
            tmp = [tmp([1:20]) '...'];
        end
        l_str{ii} = tmp;
    end
end
hold off;
if DISPLAY_LEGEND
    legend(l_str);
end
tmp = axis; axis([0 length(beta) 0 tmp(4)])
if DISPLAY_LEGEND
    set(gca, 'XTick', [1:2:length(beta)-1]);
else
    set(gca, 'XTick', non_zero_ind);
end
