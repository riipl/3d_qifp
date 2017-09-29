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


function [rect] = s_find_biggest_rect(tmp_lesion)
OSD = 0;

%% UNCOMMENT THESE WHEN YOU NEED TO DO UNIT  TEST
% clear all;
% load all_90_roi_raw.mat; lesion= test_lesion;
% OSD = 1; %load lesion_roi_raw.mat;
% 
% imgID = 25;
% % for imgID = 1:nFiles  % comment this out for single test
% tmp_lesion = lesion{imgID};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

roimask = logical(tmp_lesion.img);
[ym xm] = size(roimask);
%
if OSD == 1
    figure(3422)
    subplot(1,2,1); imshow(roimask);
end

max_rect_area = -1;
for x1 = 1 : xm
    for x2 = xm : -1 : 1
        if (x1<x2)
            dx = x2 - x1+1;
            y = roimask(:,x1).*roimask(:,x2);
            tmp = find(y);
            if (length(tmp)>0 && (sum(roimask(tmp(1):tmp(end),x1))==tmp(end)-tmp(1)+1) ...
                    && (sum(roimask(tmp(1):tmp(end),x2))==tmp(end)-tmp(1)+1))
                dy = tmp(end)-tmp(1)+1;
                area = dx*dy;
                %                     [x1 x2 tmp(1) tmp(end)]
                if (area > max_rect_area && ...
                        ( (dx<dy && 1.2*dx>dy) || (dy<dx && dy*1.2>dx)) && ...
                        sum(sum(roimask(tmp(1):tmp(end), x1:x2)))==dx*dy )
                    max_rect_area = area;
                    x1_best = x1;
                    y1_best = tmp(1);
                    w_best = dx-1;
                    h_best = dy-1;
                    if OSD == 1
                        hold on; rectangle('Position', [x1_best y1_best w_best h_best], 'EdgeColor','y'); hold off;
                        drawnow
                    end
                end

            else
                area = 0;
            end
        end
    end
end
if (~exist('x1_best', 'var'))
    x1_best = 1;
    y1_best = 1;
    w_best = xm;
    h_best = ym;
end

if OSD == 1
    figure(3422)
    subplot(1,2,1); imshow(roimask);
%     hold on; plot(contourx, contoury, 'r.'); hold off
    hold on; rectangle('Position', [x1_best y1_best w_best h_best]); hold off;
    drawnow
end

rect = [x1_best y1_best w_best h_best ];

% end % comment this out for single test

