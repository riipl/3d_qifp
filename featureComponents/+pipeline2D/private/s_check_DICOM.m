function isInverted = s_check_DICOM(I, OSD)
% take a slice of I on four sides

if ~exist('OSD', 'var'), OSD = 0; end

W = 5;

md = [];
I = double(I);
ii = 1; tmp = I(1:W, :);
md(ii, 1) = mean(tmp(:)); md(ii, 2) = std(tmp(:)); %(max(tmp(:)) - min(tmp(:)));

ii = 2; tmp = I(end-W:end, :);
md(ii, 1) = mean(tmp(:)); md(ii, 2) = std(tmp(:)); %(max(tmp(:)) - min(tmp(:)));

ii = 3; tmp = I(:, end-W:end);
md(ii, 1) = mean(tmp(:)); md(ii, 2) = std(tmp(:)); %(max(tmp(:)) - min(tmp(:)));

ii = 4; tmp = I(:, 1:W);
md(ii, 1) = mean(tmp(:)); md(ii, 2) = std(tmp(:)); %(max(tmp(:)) - min(tmp(:)));


[~, idx] = min(md(:,2)); % find the part with smallest spread

isInverted = 0;
if (md(idx,1) > max(I(:))/2)
    isInverted = 1;
end
if OSD
    md
end