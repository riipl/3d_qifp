function rds = s_calculateRDS(roix, roiy)
%
% Calculate the Radial distance signal
% Take care of ROI interpolation problem.  If # ROI pts < 100, we
% interpolate along each edge linearly.
%

if ~exist('OSD','var'), OSD = 0; end;

if (length(roix) < 100)
    % ROI interpolation
    NUM_INTERP_SAMP = 10;
    [roix roiy] = s_interp_ROI(roix, roiy, NUM_INTERP_SAMP);
end
NUM_ROI = length(roix);

mcx = mean(roix);        % centroid of the lesion
mcy = mean(roiy);

r = zeros(1, NUM_ROI);
theta = zeros(1, NUM_ROI);
P = 0;
for ii = 1:NUM_ROI
    [tmp_r tmp_theta ] = s_euc2pol(roix(ii)-mcx, roiy(ii)-mcy);
    r(ii) = tmp_r;
    theta(ii) = tmp_theta;
    tmp_ii = mod(ii, NUM_ROI) + 1;
    P = P + sqrt((roix(ii) - roix(tmp_ii)).^2 ...
        + (roiy(ii) - roiy(tmp_ii)).^2);
end
[theta tmp_i] = sort(theta);
r = r(tmp_i);

rds = {};
rds.P = P;      % circumstance
rds.mag = max(r(:));          % normalization factor
rds.r = r / rds.mag;            % normalized r
rds.theta = theta;

if OSD == 1
    figure(3434),subplot(1,2,1);%drawLesion(tmp_lesion, 0);
    MARGIN = 5;
    plot(roix, roiy, 'r-');axis image;
    axis([min(roix)-MARGIN max(roix)+MARGIN min(roiy)-MARGIN max(roiy)+MARGIN])
    %     imshow(1-roimask)
    hold on;plot(mcx,mcy, 'b*');hold off;
    subplot(2,2,2); plot(rds.theta, rds.r); title('Normalized Radial Distance Signal');
    hold on; plot(-pi:.1:pi, mean(rds.r), 'r--'); hold off
    axis tight

    subplot(2,2,4)
    % histogram
    %         rds.r = ieScale(r, 0, 1);
    hist(rds.r,20)
    tmp = axis;
    axis([0 max(rds.r) 0 tmp(4)])
    title('histogram')
end
