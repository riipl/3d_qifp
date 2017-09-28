function gs = NormalizeGoldStandard(gs, minSimi, maxSimi)
if ~exist('minSimi', 'var'), minSimi = 1; end
if ~exist('maxSimi', 'var'), maxSimi = 5; end
N = size(gs,1);

% if it's the full 2D GS matrix
if size(gs,2) == N
    gs = gs + gs';
    epislon = 1e-5;
    % for diag terms to be the max
    gs = gs.*(~eye(N)) + (max(gs(:)) + epislon)*eye(N); % ???
end

% do the scaling
gs = (gs - min(gs(:))) / (max(gs(:)) - min(gs(:))) * ...
    (maxSimi - minSimi) + minSimi;
