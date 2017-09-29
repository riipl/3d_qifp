
function [featureVector fv_str curHist rawData] = getEdgeFeatureVector(db, OSD, ORGAN, config_profile)
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

%all sigmoid fitting takes place here
if ~exist('OSD','var'), OSD = 1; end

allSigmoids = processLesionCubic(db, OSD);
if ~exist('ORGAN', 'var'), ORGAN = 'lung'; end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%Rest of the code is for creating histogram from the sigmoid parameters:

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is added to OOP this (2012-09-28)
if ~exist('config_profile', 'var') 
    config_profile = get_config_profile( ORGAN );
end
if strcmp(config_profile.name, 'null')==0 % 'null' is an empty profile
    curMin = config_profile.features.edge.curMin; % [x0 W S I0]
    curMax = config_profile.features.edge.curMax; % [x0 W S I0]
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

values = sort(allSigmoids.params);
N = size(values, 1);
limitedRangeParams = values( max(1,round(0.1 * N)) : round ( 0.9 * N ), : );


histSpan = curMax - curMin;

rawData = [];
curHist = [];
curStat = [];
params = limitedRangeParams;

for k = 1:4
    if isempty(params)
        rawData{k} = 0;
        curHist(:,k) = zeros(30,1);
        x = [];
    else
        rawData{k} = params(:,k);
        curHist(:,k) = hist(params(:,k), curMin(k) : histSpan(k)/29 : curMax(k));
        % mean, median, min, max, skewness
        x = params(:,k);
        x = x(x<curMax(k) & x>curMin(k)); % only take the ones within range
    end
    if isempty(x),
        y = zeros(7,1);
    else
        y = [min(x); max(x); median(x); mean(x); std(x); skewness(x); kurtosis(x)];
    end
    curStat = [curStat y];
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