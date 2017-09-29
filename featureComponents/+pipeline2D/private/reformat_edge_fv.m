function [featureVector fv_str] = reformat_edge_fv(params, curMin, curMax, BINS)

% given raw edge data, re-calculate histogram according to new min/max.

curHist = [];
curStat = [];
for k = 1:2
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
end

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
    for k = 1:2
        qpv(k,:) = linspace(curMin(k), curMax(k), BINS);
    end
    
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
