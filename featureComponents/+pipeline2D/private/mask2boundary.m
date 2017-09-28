function rf_roi = mask2boundary(mask, OSD)

if nnz(mask)==0, rf_roi.x = []; rf_roi.y = []; return; end

if ~exist('OSD','var'), OSD = 0; end;

x = find(sum(mask));
y = find(mask(:, x(1)));
tmp = bwtraceboundary(mask,[y(1) x(1)],'N');
rf_roi.x = tmp(:,2);
rf_roi.y = tmp(:,1);

if OSD
    figure;
    imshow(mask);
    hold on; plot(rf_roi.x, rf_roi.y, 'bo'); hold off
end