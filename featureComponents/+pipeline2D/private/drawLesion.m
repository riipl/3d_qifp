function [tmp extra] = drawLesion( tmp_lesion, SHOW_CONTOUR, ZOOMIN, MODE, SHOW_SIZE, SHOW_SCALE, SPLINE_INTERPOLATION, ORGAN )

% tmp = drawLesion( tmp_lesion, [MODE=0], [SHOW_SIZE=0], [SHOW_CONTOUR=1], 
%                   [SHOW_SCALE=0], [SPLINE_INTERPOLATION=1] )
%
% ZOOMIN     : 0 - load full image if possible, no zoom
%            : 1 - display 197x197 if posssible, no zoom
%            : 2 - zoom to fit the lesion (very big zoom) 
% 
% SHOW_CONTOUR:     overlays a red contour on the lesion
% SHOW_SCALE:       draw a scale on the lower left corner
% SHOW_SIZE:        prints the size of the image on the UL corner
% SPLINE_INTERPOLATION: spline interpolates the contour when contour is
%                   drawn
%
% MODE - display the followings
%   (0) (publish quality) 100x100 image with ROI centered in the middle
%   (1) ROI only, no context, contrast enhanced
%   (2) cropped
%   (3-4) same as (1-2) but with contrast enhancement (imgshow)
%   (5) boundary only
%   (6) radical distance function
% 
% Modified: 2011-06-19

if ~exist('SHOW_CONTOUR', 'var'), SHOW_CONTOUR = 1;end
if ~exist('ZOOMIN', 'var'), ZOOMIN = 1; end
if ~exist('MODE', 'var'), MODE = 0; end
if ~exist('SHOW_SIZE', 'var'), SHOW_SIZE = 0;end
if ~exist('SHOW_SCALE', 'var'), SHOW_SCALE = 0;end
if ~exist('SPLINE_INTERPOLATION', 'var'), SPLINE_INTERPOLATION = 1;end
if ~exist('ORGAN', 'var'), ORGAN = 'lung'; end
if isfield(tmp_lesion, 'ORGAN'), ORGAN = tmp_lesion.ORGAN; end

[c_low c_high] = s_getCTWindow(ORGAN);
%  disp(['c_low:' num2str(c_low) ' c_high:' num2str(c_high)]);
extra = [];

switch(MODE)
    case 0
        FULL_IMAGE = 0;
        if ~ZOOMIN && isfield(tmp_lesion, 'fullImage')
            tmp = tmp_lesion.fullImage;
            FULL_IMAGE = 1;
        elseif isfield(tmp_lesion, 'image')
            tmp = tmp_lesion.image;
        elseif isfield(tmp_lesion, 'cimg')
            tmp = tmp_lesion.cimg;
        else
            tmp = loadDICOM(tmp_lesion.dicomFileName);
            FULL_IMAGE = 1;
        end
        % tmp(tmp<c_low) = c_low;
        % tmp(tmp>c_high) = c_high;

        imshow(tmp,[c_low c_high]);
       % disp(['c_low:' num2str(min(tmp(:))) ' c_high:' num2str(max(tmp(:)))]);
        

        if SHOW_CONTOUR
            hold on
            if isfield(tmp_lesion, 'offset') && ~FULL_IMAGE
                tmpx = tmp_lesion.roi.x - double(tmp_lesion.offset.x)+1;
                tmpy = tmp_lesion.roi.y - double(tmp_lesion.offset.y)+1;
            else
                tmpx = tmp_lesion.roi.x ;
                tmpy = tmp_lesion.roi.y ;
            end
            if SPLINE_INTERPOLATION
                [tmpx tmpy] = s_spline_interpolate(tmpx, tmpy);
            end
            plot(tmpx([1:end 1]), tmpy([1:end 1]), 'r-', 'LineWidth', 1)
            hold off
        end
        if ZOOMIN == 2
            axis([min(tmp_lesion.roi.x) - double(tmp_lesion.offset.x)-10 ...
                max(tmp_lesion.roi.x) - double(tmp_lesion.offset.x)+10 ...
                min(tmp_lesion.roi.y) - double(tmp_lesion.offset.y)-10 ...
                max(tmp_lesion.roi.y) - double(tmp_lesion.offset.y)+10]);
        end
        % tmp = size(tmp_lesion.img) / 2;
        % text(50+tmp(1)+1, 50,'\leftarrow', 'Color', 'red', 'FontSize', 15, 'FontWeight', 'demi', 'Clipping', 'on')
        T_SIZE = .08;
        if SHOW_SIZE, h=text(0,0,mat2str(size(tmp)),'Color','yellow','BackgroundColor','black','VerticalAlignment','Top','FontWeight', 'demi', 'Clipping', 'on','Margin',1); 
%             set(h, 'FontUnit', 'Normalized','FontSize',T_SIZE);
        end; 
        if SHOW_SCALE && isfield(tmp_lesion, 'scale') 
            xOff=1; yOff=1;
            bgColor = [1 1 1] * 0;
            tmp_y = round(size(tmp,2)*(1-T_SIZE/2))-yOff;
%             hold on;rectangle('Position', [xOff tmp_y-2 10/tmp_lesion.scale(1)+3 4], 'FaceColor','black');hold off;
            h=text(xOff, tmp_y, '          ','Color', bgColor,'BackgroundColor', bgColor,'VerticalAlignment','middle','FontWeight', 'demi ', 'Clipping', 'on','Margin',1); 
            set(h, 'FontUnit', 'Normalized','FontSize',T_SIZE);
            h=text(10/tmp_lesion.scale(1)+6+xOff, tmp_y, '1cm ','Color','white','BackgroundColor', bgColor,'VerticalAlignment','middle','FontWeight', 'demi ', 'Clipping', 'on','Margin',1); 
            set(h, 'FontUnit', 'Normalized','FontSize',T_SIZE);
            hold on;plot([1 10/tmp_lesion.scale(1)]+3+xOff, [1 1]*tmp_y, 'white', 'LineWidth', 2.5);hold off;
%             hold on;plot([1 1]+5, [-2 2]+tmp_y, 'r', 'LineWidth', 1);hold off;
%             hold on;plot([1 1]*(10/tmp_lesion.scale(1)+5), [-2 2]+tmp_y, 'r', 'LineWidth', 1);hold off;
        end; 
        
        
    case 1
        % no ROI + ROI
        if isfield(tmp_lesion, 'image')
            tmp = tmp_lesion.image;
        else
            tmp = tmp_lesion.cimg;
        end
        tmp = repmat(tmp, [1, 2]);
       
        imshow(tmp,[c_low c_high]);

        hold on
        tmpx = tmp_lesion.roi.x - double(tmp_lesion.offset.x)+1;
        tmpy = tmp_lesion.roi.y - double(tmp_lesion.offset.y)+1;
        if SPLINE_INTERPOLATION
            [tmpx tmpy] = s_spline_interpolate(tmpx, tmpy);
        end
        plot(tmpx([1:end 1]), tmpy([1:end 1]), 'r-', 'LineWidth', 1)
        hold off
        tmp = get(gcf, 'Position');
        set(gcf, 'Position', [tmp(1:2) 800 400]);
               
        
    case 2
        % Inside of ROI
        tmp = tmp_lesion.cropped;
        imshow(tmp, [c_low c_high]);
    case 3
        % ROI with no context
        tmp = tmp_lesion.img;
        imgshow(tmp);
        if SHOW_SIZE, text(0,0,mat2str(size(tmp)),'Color','yellow','BackgroundColor','black','VerticalAlignment','Top','FontWeight', 'demi', 'Clipping', 'on','Margin',1); end;    
    case 4
        % cropped inside ROI
        tmp = tmp_lesion.cropped;
        imgshow(tmp);
        if SHOW_SIZE, text(0,0,mat2str(size(tmp)),'Color','yellow','BackgroundColor','black','VerticalAlignment','Top','FontWeight', 'demi', 'Clipping', 'on','Margin',1); end;    
    case 5
        % lesion boundary only
        OSD = 0;
        if 1
            tmpx = tmp_lesion.roix;
            tmpy = tmp_lesion.roiy;
        else
            % This makes sure roix, roiy is positive and fits in a box.
            tmpx = tmp_lesion.roix; tmpx = tmpx - min(tmpx) + 20;
            tmpy = tmp_lesion.roiy; tmpy = tmpy - min(tmpy) + 20;
            tmp = zeros(max(tmpy)+20, max(tmpx)+20);
            tmp = roipoly(tmp, tmpx, tmpy);
            % FIND the CONTOUR
            row = round(tmpy(3))+1;       % pick a starting point row (might have problem with the 1st ROI)
            
            if OSD == 1
                H = gcf; figure, imshow(tmp)
            end
            for ii = 1:size(tmp, 2)
                if tmp(row, ii) == 1
                    col = ii; break
                end
                if OSD == 1
                    hold on; plot(ii, row, 'y*'); hold off;
                    drawnow
                end
            end
            if OSD == 1
                figure(H);
            end
            contour = bwtraceboundary(tmp, [row, col], 'W', 8, Inf, 'counterclockwise');
            tmpx = contour(:,2);
            tmpy = contour(:,1);
        end
        if SPLINE_INTERPOLATION
            [tmpx tmpy] = s_spline_interpolate(tmpx, tmpy);
        end
        plot(tmpx([1:end 1]), tmpy([1:end 1]), 'r-', 'LineWidth', 1)
        axis tight, axis image, axis off;
        tmp = axis; 
        PLOT_MODE = 1;
        switch PLOT_MODE
            case 0
                % tight fit
                axis([tmp(1)-2 tmp(2)+2 tmp(3)-2 tmp(4)+2])
            case 1
                % tight fit, square
                tmp = (tmp(2)+tmp(1))/2;
                HALF_SQ_WND = 5 + max(max(tmpx(:))-min(tmpx(:)), max(tmpy(:))-min(tmpy(:))) / 2;
                axis([tmp-HALF_SQ_WND HALF_SQ_WND+tmp tmp-HALF_SQ_WND HALF_SQ_WND+tmp])
            case 2
                % display the real scale
                tmp = (tmp(2)+tmp(1))/2;
                axis([tmp-100 100+tmp tmp-100 100+tmp])
        end
    case 6
        % plot radial distance signal
        % Initializ contourx, contoury
        % (0) only the roi's  OR (1) each pixel on the boundary
        contourx = tmp_lesion.roix;
        contoury = tmp_lesion.roiy;
        if SPLINE_INTERPOLATION
            [contourx contoury] = s_spline_interpolate(contourx, contoury);
        end
        % FIND the CONTOUR by following the boundary
        % IMPORTANT: plot(X, Y), tmp(Y, X), contour(Y, X);the Correct X and Y:
        %     figure, imshow(tmp), hold on
        %     plot(tmp_lesion.roix(:), tmp_lesion.roiy(:), 'r+'); hold off
        %     tmp(round(tmp_lesion.roiy(1)), round(tmp_lesion.roix(1)))

        % METHOD 0: bwtraceboundary
        % tic
        % MAG_SCALE = 200 / (max(tmp_lesion.roix)-min(tmp_lesion.roix));
        % roix = tmp_lesion.roix * MAG_SCALE;
        % roiy = tmp_lesion.roiy * MAG_SCALE;
        % tmp = zeros(ceil(max(roix)), ceil(max(roiy)));
        % tmp = roipoly(tmp, roix, roiy);
        % row = round((max(roiy)+min(roiy))/2);       % pick a starting point row (might have problem with the 1st ROI)
        % for ii = 1:size(tmp, 2)
        %     if tmp(row, ii) == 1
        %         col = ii; break
        %     end
        % end
        % contour = bwtraceboundary(tmp, [row, col], 'W', 8, Inf, 'counterclockwise');
        % if (isempty(contour))
        %     fprintf('** Boundary tracing failed :(\n');
        % end
        % contourx = contour(:,2);        % contour(1,:) = [Y1 X1];
        % contoury = contour(:,1);        % plot(X1, Y1); tmp(Y1, X1)
        % toc

        % METHOD 1: interpolation each line segment
        rds = s_calculateRDS(contourx, contoury);
        extra = rds;
        plot(rds.theta, rds.r);
        hold on; plot(-pi:.1:pi, mean(rds.r), 'r--'); hold off
        axis tight
        
        titleStr = sprintf('mean=%4.2f,std=%4.2f', mean(rds.r), std(rds.r));
        title(titleStr)

        % histogram
        % rds.r = ieScale(r, 0, 1);
        % hist(rds.r,20)
        % axis([0 1 0 40])
    case 7
        % plot LAII
        OSD = 0;
        % Initializ contourx, contoury can be
        % (0) only the roi's  OR (1) each pixel on the boundary
        if 0
            % use simply the roi's as the contour
            contourx = round(tmp_lesion.roix);
            contoury = round(tmp_lesion.roiy);
        else
            [tmpx tmpy] = s_scale_roi(tmp_lesion.roix, tmp_lesion.roiy, 200);
            tmpx = tmpx - min(tmpx) + 20;
            tmpy = tmpy - min(tmpy) + 20;

            tmp = zeros(max(tmpy)+20, max(tmpx)+20);
            tmp = roipoly(tmp, tmpx, tmpy);
            % FIND the CONTOUR
            % pick a starting point row (might have problem with the 1st ROI)
            row = round((max(tmpy)+min(tmpy))/2);
            if OSD == 1,H = gcf; figure, imshow(tmp);end

            for ii = 1:size(tmp, 2)
                if tmp(row, ii) == 1
                    col = ii; break;
                end
                if OSD == 1,hold on; plot(ii, row, 'y*'); hold off;drawnow;end
            end

            if OSD == 1,figure(H);end
            contour = bwtraceboundary(tmp, [row, col], 'W', 8, Inf, 'counterclockwise');
            if (isempty(contour))
                fprintf('** Boundary tracing failed :(\n');
                return;
            end
            contourx = contour(:,2);        % contour(1,:) = [Y1 X1];
            contoury = contour(:,1);        % plot(X1, Y1); tmp(Y1, X1)
        end
        %%% COPY FROM b_feature_mor_boundary
        % This makes sure roix, roiy is positive and fits in a box.
        [tmpx tmpy] = s_scale_roi(tmp_lesion.roix, tmp_lesion.roiy, 200);
        %     tmpx = tmp_lesion.roix;
        %     tmpy = tmp_lesion.roiy;
        tmpx = tmpx - min(tmpx) + 20;
        tmpy = tmpy - min(tmpy) + 20;

        if SPLINE_INTERPOLATION
            [tmpx tmpy] = s_spline_interpolate(tmpx, tmpy);
        end
        tmp = zeros(max(tmpy)+20, max(tmpx)+20);
        tmp = roipoly(tmp, tmpx, tmpy);
        if isfield(tmp_lesion, 'bigR')
            bigR = tmp_lesion.bigR;
        else
             bigR = max(max(tmpx)-min(tmpx), max(tmpy)-min(tmpy))-6;
        end
        PAPER_FIGURE = 1;
        if ~PAPER_FIGURE
            radius_list = round([bigR/5 bigR/4 bigR/2]);
        else
            % for generating figures for paper
            radius_list = round([bigR/5 bigR/3 bigR/2.4 bigR/2 bigR/1.65 bigR/1.4 bigR/1.2]);
        end
        for radius_idx = 1:length(radius_list)

            % make the round kernel mask
            k.R = radius_list(radius_idx);
            k.mask = zeros(k.R * 2+1);
            t = linspace(0, pi/2, 128);
            k.x = [(k.R)*cos(t)+k.R k.R];
            k.y = [(k.R)*sin(t)+k.R k.R];
            k.mask = roipoly(k.mask, round(k.x), round(k.y));
            k.mask = k.mask + k.mask(1:end, end:-1:1);
            k.mask = k.mask + k.mask(end:-1:1, 1:end);

            tmp_dilated = imfilter(double(tmp), double(k.mask), 'conv');

            % the contour is in the format of [row1 col1; row2 col2; ...] or [Y X]
            laii = diag(tmp_dilated(contoury, contourx));
            laii = laii / (pi*k.R^2);   % normalization by the area of the kernel

            fv_res(1) = mean(laii);
            fv_res(2) = std(laii);

            laii_r(radius_idx, :) = laii;
        end
        %%% end of copy

        %         plot(laii);
        plot(laii_r', 'LineWidth', 1.5);
        if ~PAPER_FIGURE
            hold on;
            plot(1:0.3:length(laii), mean(laii), 'r--')
            hold off
            axis tight
            set(gca, 'XTick', [])
            for ii = 1:size(laii_r,1)
                tmp_str = sprintf('M:%4.2f S:%4.2f', mean(laii_r(ii,:)), std(laii_r(ii,:)));
                text(2, 1-ii*.1, tmp_str);
            end
        else
            axis tight;
            tmp = axis;
            axis([tmp(1:2) tmp(3)*.95 tmp(4)*1.05]);
            set(gca, 'YTick', [.2:.1:.7])
            xlabel('Pixel Length')
            ylabel('LAII')
        end
end


return
