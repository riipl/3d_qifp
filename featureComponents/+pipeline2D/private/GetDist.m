function [D Ds] = GetDist(va, startPos, fWeights, featureList)
%
% example: GetDist(features, startPos, ones(1,length(startPos)));
%
% Note: will apply different weights according to featureList, if provided.
% 
% numLesion (n) - number of lesions
% numFeature (F) - number of features
%
% D - <nxn matrix> combined distance matrix
% Ds - <1xF cell> each cell is the nxn distance matrix for n lesions.
%
% Last modified: 04-26-2010
%

[d, numLesion] = size(va);
numFeature = length(startPos); 
startPos = [startPos; d+1];
D = zeros(numLesion);

if ~exist('featureList','var'), featureList = cell(1,numFeature); end

% va(1,:)=va(1,:)>.2;
% va(3,:)=va(3,:)>3;

% va(1,:) = sigmf(va(1,:), [500, .2]);    % 1. Proportion of pixels with intensity larger than xx 1
% va(2,:) = sigmf(va(2,:), [5, .5]);      % 2. Entropy of histogram 1
% va(3,:) = sigmf(va(3,:), [500, 3]);     % 3. Peak position 1

s_beta = [    
    0.000   % Feature  1 (length:   1) LAII Haar r=1/11R
    0.789   % Feature  2 (length:   1) LAII Mean r=1/11R
    0.000   % Feature  3 (length:   1) LAII std r=1/11R
    0.000   % Feature  4 (length:   1) LAII Haar r=1/9R
    0.798   % Feature  5 (length:   1) LAII Mean r=1/9R
    0.000   % Feature  6 (length:   1) LAII std r=1/9R
    3.050   % Feature  7 (length:   1) LAII Haar r=1/5R
    0.000   % Feature  8 (length:   1) LAII Mean r=1/5R
    0.000   % Feature  9 (length:   1) LAII std r=1/5R
    0.000   % Feature 10 (length:   1) LAII Haar r=1/3R
    0.000   % Feature 11 (length:   1) LAII Mean r=1/3R
    0.000   % Feature 12 (length:   1) LAII std r=1/3R
    4.258   % Feature 13 (length:   1) LAII Haar r=1/2R
    0.000   % Feature 14 (length:   1) LAII Mean r=1/2R
    0.000   % Feature 15 (length:   1) LAII std r=1/2R
    1.888   % Feature 16 (length:   1) RDS Mean
    0.000   % Feature 17 (length:   1) RDS std
    5.262   % Feature 18 (length:   1) Compactness
    3.487   % Feature 19 (length:   1) Roughness
    ]; % 72-lesion, GS:Round/Ovoid/...
% s_beta = [ones(14,1); zeros(20, 1)];

Ds = cell(1, numFeature);
for i = 1:numFeature
    rows = startPos(i):(startPos(i+1)-1);
    switch featureList{i}
        case 'ShapeDistribution'
            % histogram
            disp('+ Using Chi-squared distance for ShapeDistribution (GetDist.m)');
            Ds{i} = slmetric_pw(va(rows,:), va(rows,:), 'chisq');
        case 'Shape'
            if ( length(rows)==length(s_beta) )
                % apply the weights to shape feature vectors
                disp('+ Custom weights for shape feature (GetDist.m)');
                % s_beta'
                va(rows,:) = va(rows,:) .* repmat(s_beta, [1, numLesion]);
                Ds{i} = L2_distance(va(rows,:), va(rows,:));
            end
        case 'Semantic'
            global rtSESSION
%             if isfield(rtSESSION, 'FV_SEMANTIC_MANUAL') && 
            if  rtSESSION.FV_SEMANTIC_MANUAL.ENABLED == 1
                s_beta = rtSESSION.FV_SEMANTIC_MANUAL.WEIGHTS';
                if length(rows)==length(s_beta)
                    % apply the weights to shape feature vectors
                    disp('+ Custom weights for semantic feature (GetDist.m)');
                    va(rows,:) = va(rows,:) .* repmat(s_beta, [1, numLesion]);
                    Ds{i} = L2_distance(va(rows,:), va(rows,:));
                else
                    disp('+ Your custom weights for semantic feature is invalid (GetDist.m)');
                end
            end
    end
    if isempty(Ds{i})
        Ds{i} = L2_distance(va(rows,:), va(rows,:));
    end
end
D = CombineDist(Ds, fWeights);

return;