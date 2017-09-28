
function [featureVector fv_str curHist rawData stats] = getEdgeFeatureVector2(db, OSD, ORGAN)
% To use code:
%       featureVector = getEdgeFeatureVector(DB{i});
% 
% Returns a 60x1 feature vector for current image
% Here, DB is the same database you had sent me earlier. The following fields are required:
% 
% DB{i}.image
% DB{i}.offset
% DB{i}.roi
%
% - Useful return values (for debugging purpose)
%         rawData         - see reformat_edge_fv.m
%         stats.curMin
%         stats.curMax
%         stats.numborderPoints - number of points on the boundary 

%all sigmoid fitting takes place here
if ~exist('OSD','var'), OSD = 1; end
if ~exist('ORGAN', 'var'), ORGAN = 'lung'; end

% [x0 W S I0]
switch(ORGAN)
    case 'liver'
        % for liver (Neeraj's latest code)
        curMin = [0.0357    0.0014   -0.2273    1.0407];
        curMax = [0.0438    0.0065    0.2273    1.1026];
        curMin = [0.0357   -0.0400   -0.4873    1.0407];
        curMax = [0.0438    0.0400    0.4873    1.1026];
    case 'lung'
        % for lung
        curMin = [0.0357    0.0001   -2.0973    1.0407];
        curMax = [0.0438    0.1000    2.0973    1.1026];
    case 'debug'
        % for unit test in a_edge_unit_test.m
        curMin = [0.0357    0.0000   -2.0973    1.0407];
        curMax = [0.0438    0.0400    2.0973    1.1026];
end

curMin = curMin * 1e3;
curMax = curMax * 1e3;

[allSigmoids numborderPoints] = processLesionCubic2(db, OSD, ORGAN);

stats.numborderPoints  = numborderPoints;
stats.curMin = curMin;
stats.curMax = curMax;

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%Rest of the code is for creating histogram from the sigmoid parameters:

% Histogram bins parameters

% find the good fit lines
x = allSigmoids.params;
x = x(~isnan(x(:,1)), :); % avoid nan results
ranges = 0*(x(:,1))+1;
for k = 2:3
    ranges = ranges & (curMin(k) < x(:,k) & x(:,k)< curMax(k));
end

if nnz(ranges)==0
    disp('not a single good fit found for this lesion');
    return;
end

% values = sort(allSigmoids.params);
% N = size(values, 1);
% limitedRangeParams = values( round(0.1 * N) : round ( 0.9 * N ), : );
limitedRangeParams = x(ranges, :);
BINS = 30;

rawData = [];
curHist = [];
curStat = [];
params = limitedRangeParams;

for k = 1:4
    curHist(:,k) = hist(params(:,k), linspace(curMin(k), curMax(k), BINS));
    % mean, median, min, max, skewness 
    x = params(:,k);
    x = x(x<curMax(k) & x>curMin(k)); % only take the ones within range
    if isempty(x),
        y = zeros(7,1);
    else
        y = [min(x); max(x); median(x); mean(x); std(x); skewness(x); kurtosis(x)];
    end
    curStat = [curStat y];
    rawData{k} = params(:,k);
end

curHist = curHist(:,2:3);
curStat = curStat(:,2:3);
curHist = curHist ./ repmat(sum(curHist), [size(curHist, 1) 1]);

featureVector = [curStat];
fv_str = {'Edge Sharpness - window min', ...
    'Edge Sharpness - window max', ...
    'Edge Sharpness - window median', ...
    'Edge Sharpness - window mean', ...
    'Edge Sharpness - window std', ...
    'Edge Sharpness - window skewness', ...
    'Edge Sharpness - window kurtosis', ...
    'Edge Sharpness - scale min', ...
    'Edge Sharpness - scale max', ...
    'Edge Sharpness - scale median', ...
    'Edge Sharpness - scale mean', ...
    'Edge Sharpness - scale std', ...
    'Edge Sharpness - scale skewness', ...
    'Edge Sharpness - scale kurtosis'
    };

featureVector = featureVector(:);

OLD_EDGE_HIST = 1;

% add histogram itself to the 
qpv_str = {'window histogram','scale histrogram'};
if OLD_EDGE_HIST
    for k = 2:3
        qpv(k,:) = linspace(curMin(k), curMax(k), 30);
    end
    qpv = qpv(2:3,:);
    
    for k = 1:2
        for i = 1:size(qpv, 2)
            fv_str{end+1} = ['Edge Sharpness - ' qpv_str{k} '-' num2str(i) ' (' num2str(qpv(k, i),'%3.2f') ')'];
        end
    end
    featureVector = [featureVector; curHist(:)];
else
    qpv = [...
        -Inf  0.94  1.33  1.62  1.89  2.17  2.52  3.11  3.99  5.43  8.71  Inf
        -Inf  -908  -876  -854  -825  -790  -727  -542  -179    40  232   Inf
        ];
    for k = 2:3
        p = histc(rawData{k}, qpv(k-1,:));
        p=p+1e-6*sum(p);
        p=p/sum(p);
        featureVector = [featureVector; p];
    end
    for k = 1:2
        for i = 1:size(qpv, 2)
            fv_str{end+1} = ['Edge Sharpness - ' qpv_str{k} '-' num2str(i) ' (' num2str(qpv(k, i)) ')'];
        end
    end
end