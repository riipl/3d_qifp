%%
% Input:
%     - imgID
% Output:
%     - fv_res      : feature vector
%     - plots if OSD=1
% Degree of freedom:
%   1. Distance, or normalized Distance by its std
%
%   *. scale every shape to the same THRESH? s_scale_roi?
%   **. ieScale(r,0,1) or just r/max(r)?
%


function [fv_res startPos featureList laiis] = b_feature_mor_boundary(tmp_lesion, TEST_BIGR_MODE)
OSD = 0;
OLD_72_LESION_METHOD = 0;

%% UNCOMMENT THESE WHEN YOU NEED TO DO UNIT  TEST
% clear all; imgID = 17; OSD = 1; %load lesion_roi_raw.mat;
% % load fake_lesion_raw.mat;
% % load all_90_roi_raw.mat; 
% load Ankit_30_roi_raw.mat
% lesion= test_lesion;
% tmp_lesion = lesion{imgID};
% % TEST_BIGR_MODE = 1;

% tmp_lesion.roix = [50 25 75];tmp_lesion.roiy = [25 75 75]; % verification
% tmp_lesion.roix = [40 60 60 40];tmp_lesion.roiy = [40 40 60 60]; % verification

%% what feature vector to use
if ~exist('TEST_BIGR_MODE', 'var'), TEST_BIGR_MODE = 0; end;
MODE = 2;  % 0-rds only; 1-laii only; 2- both;
startPos = [];
featureList = [];

switch MODE
    case 0
        USE_RDS  = 1;
        USE_LAII = 0;
    case 1
        USE_RDS  = 0;
        USE_LAII = 1;
    case 2
        USE_RDS  = 1;
        USE_LAII = 1;
end
fv_res = [];

if ~isfield(tmp_lesion, 'roix')
    tmp_lesion.roix = tmp_lesion.roi.x;
    tmp_lesion.roiy = tmp_lesion.roi.y;
end

%% trace the contour (initialize contourx, contoury)
% (0) only the roi's  OR (1) each pixel on the boundary
% (3) spline interpolation
if OLD_72_LESION_METHOD
    FIND_CONTOUR_METHOD = 1;
else
    FIND_CONTOUR_METHOD = 3;
end

switch (FIND_CONTOUR_METHOD)
    case 0
        % use simply the roi's as the contour
        contourx = round(tmp_lesion.roix);
        contoury = round(tmp_lesion.roiy);
    case 1
        % FIND the CONTOUR by following the boundary
        % IMPORTANT: plot(X, Y), tmp(Y, X), contour(Y, X);the Correct X and Y:
        %     figure, imshow(tmp), hold on
        %     plot(tmp_lesion.roix(:), tmp_lesion.roiy(:), 'r+'); hold off
        %     tmp(round(tmp_lesion.roiy(1)), round(tmp_lesion.roix(1)))
        
        % This makes sure roix, roiy is positive and fits in a box.
        MARGIN = 5;
        if 0
            [tmpx tmpy] = s_scale_roi(tmp_lesion.roix, tmp_lesion.roiy, 50);
        else
            tmpx = tmp_lesion.roix;
            tmpy = tmp_lesion.roiy;
        end
        tmpx = tmpx - min(tmpx) + MARGIN;
        tmpy = tmpy - min(tmpy) + MARGIN;
        
        roimask = zeros(max(round(tmpy))+MARGIN, max(round(tmpx))+MARGIN);
        roimask = roipoly(roimask, tmpx, tmpy);
        % FIND the CONTOUR
        % pick a starting point row (might have problem with the 1st ROI)
        row = round((max(tmpy)+min(tmpy))/2);
        if OSD == 1,H = gcf; figure, imshow(roimask);end
        
        for ii = 1:size(roimask, 2)
            if roimask(row, ii) == 1
                col = ii; break;
            end
            if OSD == 1,hold on; plot(ii, row, 'y*'); hold off;drawnow;end
        end
        
        if OSD == 1,figure(H);end
        contour = bwtraceboundary(roimask, [row, col], 'W', 8, Inf, 'counterclockwise');
        if (isempty(contour))
            fprintf('** Boundary tracing failed :(\n');
            return;
        end
        contourx = contour(:,2);        % contour(1,:) = [Y1 X1];
        contoury = contour(:,1);        % plot(X1, Y1); roimask(Y1, X1)
        
        % spline interpolation
        [tmpx tmpy] = s_spline_interpolate(tmpx, tmpy);
    case 2
        % linear interpolation each line segment
        NUM_ROI = length(tmp_lesion.roix);
        tmp = [1:NUM_ROI 1];
        NUM_INTERP_SAMP = 10;
        contour = [];
        for ii = 1:NUM_ROI
            next_ii = tmp(ii + 1);
            if (tmp_lesion.roix(ii) ~= tmp_lesion.roix(next_ii))
                x_int = linspace(tmp_lesion.roix(ii), tmp_lesion.roix(next_ii), NUM_INTERP_SAMP);
                y_int = interp1(x_int([1 end]), tmp_lesion.roiy([ii next_ii]), x_int);
                contour = [contour; x_int' y_int'];
            end
        end
        contourx = round(contour(:,2));        % contour(1,:) = [Y1 X1];
        contoury = round(contour(:,1));        % plot(X1, Y1); roimask(Y1, X1)
    case 3
        % spline interpolation
        MARGIN = 5;
        % normalization step
        [tmp_lesion.roix tmp_lesion.roiy] = s_scale_roi(tmp_lesion.roix, tmp_lesion.roiy, 50);
%         [max(tmp_lesion.roix) - min(tmp_lesion.roix) ...
%         max(tmp_lesion.roiy) - min(tmp_lesion.roiy)]
        [tmpx tmpy] = s_spline_interpolate(tmp_lesion.roix, tmp_lesion.roiy);
        tmpx = tmpx - min(tmpx) + MARGIN;
        tmpy = tmpy - min(tmpy) + MARGIN;
        contourx = round(tmpx);
        contoury = round(tmpy);
%         [~,k]=s_unique([contourx' contoury']);
%         if nnz(k) > 0
%             contourx = contourx(k);
%             contoury = contoury(k);
%         end
end

%%

if USE_LAII == 1
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Local Area Integral Invariant
    %   (1) mean of the LAII
    %   (2) std of the LAII
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % convolve the image with a circle of radius R
    
    if ~exist('roimask', 'var')
        % This makes sure roix, roiy is positive and fits in a box.
        %     [tmpx tmpy] = s_scale_roi(tmp_lesion.roix, tmp_lesion.roiy, 200);
        tmpx = tmp_lesion.roix;
        tmpy = tmp_lesion.roiy;
        tmpx = tmpx - min(tmpx) + MARGIN;
        tmpy = tmpy - min(tmpy) + MARGIN;

        roimask = zeros(max(round(tmpy))+MARGIN, max(round(tmpx))+MARGIN);
        roimask = roipoly(roimask, tmpx, tmpy);
    end
    if TEST_BIGR_MODE == 1
        max_rect_box = max(max(tmpx)-min(tmpx), max(tmpy)-min(tmpy))-MARGIN;
        radius_list = round(max_rect_box) : 2.5*round(max_rect_box);
    else
        % couple of ways checking bigR
        if isfield(tmp_lesion, 'bigR')
            bigR = tmp_lesion.bigR;
            bigR_method = '(pre-computed)';            
        else
            bigR = max(max(tmpx)-min(tmpx), max(tmpy)-min(tmpy))-6;
            bigR_method = '(rough max)';
            if 1
                % 1. naive, very slow
                NN = length(tmpx);
                for pp1=1:round(NN/2)
                    for pp2= round(pp1+NN/6 : pp1+NN/6*4)
                        pp2 = round(1+mod(pp2-1, NN));
                        t_dist = slmetric_pw([tmpx(pp1);tmpy(pp1)], [tmpx(pp2);tmpy(pp2)], 'eucdist');
                        if t_dist > bigR
                            bigR = t_dist;
                        end
                    end
                end
                bigR_method = '(brute force)';
            end
        end
        
        radius_denominator = [10,9,8,7,6,5,4,3,2];
        if OLD_72_LESION_METHOD
            % old method (for 72-lesion)
            radius_list = round([bigR/6 bigR/3 bigR/2]);
        else
            radius_list = round(bigR ./ radius_denominator);
        end
    end
%     fprintf('  bigR = %4.2f %s\n', bigR, bigR_method);
%         radius_list = [5 10 15 20 25]; % for square test chart
    laiis = [];
    for radius_idx = 1:length(radius_list)

        % make the round kernel mask
        k.R = radius_list(radius_idx);
        k.mask = zeros(k.R * 2+1);
        t = linspace(0, pi/2, (k.R)^2);
        k.x = [(k.R)*cos(t)+k.R k.R];
        k.y = [(k.R)*sin(t)+k.R k.R];
        k.mask = roipoly(k.mask, round(k.x), round(k.y));
        k.mask = k.mask + k.mask(1:end, end:-1:1);
        k.mask = k.mask + k.mask(end:-1:1, 1:end);
%         if OSD == 1
%             figure(3469);
%             nR = s_nR(length(radius_list));
%             nC = s_nC(length(radius_list));
%             subplot(nR, nC, radius_idx), imshow(k.mask);title(['r = ' num2str(k.R)])
%         end
        
        tmp_dilated = imfilter(double(roimask), double(k.mask), 'conv');
        
        if OSD == 1
            figure(3422)
            subplot(1,2,1); imshow(roimask);
            hold on; plot(contourx, contoury, 'r.'); hold off
            subplot(1,2,2); imshow(tmp_dilated,[])
            hold on; plot(contourx, contoury, 'r.'); hold off
            drawnow
        end

        % the contour is in the format of [row1 col1; row2 col2; ...] or [Y X]
        contoury = contoury(contoury < size(tmp_dilated,1));
        contourx = contourx(contourx < size(tmp_dilated,2));
        laii = diag(tmp_dilated(contoury, contourx));
        laii = laii / (pi*k.R^2);   % normalization by the area of the kernel
        laiis{radius_idx} = laii;

        p = hist(laii, .2:.1:.8);
        p=p+1e-6*sum(p);
        p=p/sum(p);
        p(p<0.2*max(p))=0;
        p=p+1e-6*sum(p);
        p=p/sum(p);
        [c,l] = wavedec(p',3,'haar');
        res = c(l(1)+l(2));

        denominator = radius_denominator(radius_idx);
        
        startPos = [startPos; length(fv_res)+1];
        fv_res = [fv_res res];
        featureList{length(featureList)+1} = ['LAII Haar r=1/' num2str(denominator) 'R' ];

        startPos = [startPos; length(fv_res)+1];
        fv_res = [fv_res mean(laii)];
        featureList{length(featureList)+1} = ['LAII Mean r=1/' num2str(denominator) 'R' ];

        startPos = [startPos; length(fv_res)+1];
        fv_res = [fv_res std(laii)];
        featureList{length(featureList)+1} = ['LAII Std r=1/' num2str(denominator) 'R' ];

        startPos = [startPos; length(fv_res)+1];
        fv_res = [fv_res min(laii)];
        featureList{length(featureList)+1} = ['LAII Min r=1/' num2str(denominator) 'R' ];

        startPos = [startPos; length(fv_res)+1];
        fv_res = [fv_res max(laii)];
        featureList{length(featureList)+1} = ['LAII Max r=1/' num2str(denominator) 'R' ];
        
        startPos = [startPos; length(fv_res)+1];
        fv_res = [fv_res skewness(laii)];
        featureList{length(featureList)+1} = ['LAII skewness r=1/' num2str(denominator) 'R' ];

        laii_r(radius_idx, :) = laii;
        if (TEST_BIGR_MODE == 1)
            if std(laii) < 0.001, 
                radius_list = round(max_rect_box):k.R;  fv_res = radius_list; 
                fprintf('%g\t%s\n',k.R, mat2str(fv_res)); break; 
            end;
        end
        
    end
    
    if OSD == 1
        figure(3433); plot(laii_r', 'LineWidth', 1.5); title(['Normalized Local Area Invariant Integral (r = ' mat2str(radius_list) 'px)']);
        ll = {};
        for ij = 1:length(radius_list),ll{ij} = num2str(radius_list(ij)); end
        legend(ll);
    end
    if (TEST_BIGR_MODE == 1)
        fv_res = k.R;
        return;
    end
end

if USE_RDS

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Radial Distance Signal related features
    %   (1) mean of the rds
    %   (2) std of the rds
    %   (3) normalized Compactness
    %   (4) entropy of the rds
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if OLD_72_LESION_METHOD
        % old method (for 72-lesion)
        rds = s_calculateRDS(contourx, contoury);
    else
        rds = s_calculateRDS(tmpx, tmpy);
    end

    if OSD == 1
        figure(3434);clf;subplot(1,2,1);%drawLesion(tmp_lesion, 0);
%         plot(contourx, contoury, 'r-');axis image; axis([0 0 max(contourx)+20 max(contoury)+20])
        imshow(1-roimask); 
%         hold on;plot(mcx,mcy, 'y*');hold off;
        subplot(1,2,2); plot(rds.theta, rds.r); title('Normalized Radial Distance Signal');
    end

    % normalized Compactness, the lower the closer to circle
    if OLD_72_LESION_METHOD
        % old method (for 72-lesion)
%         tmp = roipoly(tmp_lesion.cimg, contourx, contoury);
        tmp = roipoly(zeros(max(contourx), max(contoury)), contourx, contoury);
        P = rds.P / rds.mag;
        A = sum(tmp(:)==1)/rds.mag.^2;
        N_comp = 1 - 4*pi/(P.^2/A);
    else
        N_comp = s_calculateCompactness(tmpx, tmpy);
    end

    startPos = [startPos; length(fv_res)+1];
    fv_res = [fv_res mean(rds.r)];            % mean
    featureList{length(featureList)+1} = ['RDS Mean'];
    
    startPos = [startPos; length(fv_res)+1];
    fv_res = [fv_res std(rds.r)];             % std
    featureList{length(featureList)+1} = ['RDS std'];

    startPos = [startPos; length(fv_res)+1];
    fv_res = [fv_res N_comp];
    featureList{length(featureList)+1} = ['Compactness'];

%     fv_res(4) = entropy(rds.r);
%     fv_res(5) = s_count_zc(rds.r);

    % use histogram directly as feature vector
%     [fv_res dummy] = hist(rds.r);
    
    %% take a look at FFT
%     L = length(rds.r);Fs = L;
%     y = rds.r;
%     NFFT = 2^nextpow2(L); % Next power of 2 from length of y
%     Y = fft(y,NFFT)/L;
%     f = Fs/2*linspace(0,1,NFFT/2);
% 
%     % Plot single-sided amplitude spectrum.
%     subplot(2,2,4); 
%     plot(f,2*abs(Y(1:NFFT/2)))
%     title('Single-Sided Amplitude Spectrum of y(t)')
%     xlabel('Frequency (Hz)')
%     ylabel('|Y(f)|')
%     axis tight
end

if OLD_72_LESION_METHOD
    % old method (for 72-lesion)
    roughness = s_roughness(contourx, contoury);
else
    roughness = s_roughness(tmpx, tmpy);
end

startPos = [startPos; length(fv_res)+1];
fv_res = [fv_res roughness];
featureList{length(featureList)+1} = ['Roughness'];

% shape distribution
if ~OLD_72_LESION_METHOD && 0
    dist = b_shape_distribution(tmpx, tmpy);
    startPos = [startPos; length(fv_res)+1];
    fv_res = [fv_res dist];
    featureList{length(featureList)+1} = ['ShapeDistribution'];
end

fv_res = fv_res';

return;

%% user friendly code for find the contour
% row = round(tmp_lesion.roiy(3));       % pick a starting point row (might have problem with the 1st ROI)
%
% if OSD == 1
%     figure, imshow(tmp)
% end
% for ii = 1:size(tmp, 2)
%     if tmp(row, ii) == 1
%         col = ii; break
%     end
%     if OSD == 1
%         hold on; plot(ii, row, 'y*'); hold off;
%         drawnow
%     end
% end
%
% contour = bwtraceboundary(tmp, [row, col], 'W', 8, Inf, 'counterclockwise');
% if OSD == 1
%     imshow(tmp)
%     if(~isempty(contour))
%         hold on;
%         plot(contour(:,2),contour(:,1),'g','LineWidth',2);
%         plot(col, row,'gx','LineWidth',2);
%         hold off;
%     else
%         hold on; plot(col, row,'rx','LineWidth',2);            hold off;
%     end
% end
% if (isempty(contour))
%     fprintf('** Boundary tracing failed :(\n');
% end