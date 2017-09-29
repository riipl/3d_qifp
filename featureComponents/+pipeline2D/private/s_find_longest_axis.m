function [sum_axis stat] = s_find_longest_axis(rf_roi, OSD)

% return values in pixels
% 
% OSD:  1 - new figure handle
%       2 - current figure handle

if isempty(rf_roi.x), sum_axis = 0; return; end
if ~exist('OSD', 'var'), OSD = 0; end

scale = 50/max(max(rf_roi.x) - min(rf_roi.x), max(rf_roi.y) - min(rf_roi.y));

rf_roi.x = rf_roi.x*scale;
rf_roi.y = rf_roi.y*scale;

[roi.x roi.y] = s_spline_interpolate(rf_roi.x, rf_roi.y);

N = length(roi.x);

pts = [roi.x; roi.y];
tmp = L2_distance(pts, pts);
tmp = find(tmp==max(tmp(:)));

if length(tmp)>2, disp('Multiple longest axis found'); end;
[p1 p2] = ind2sub([N N], tmp(1));
if p1 > p2, tmp = p2; p2 = p1; p1 = tmp; end;

theta = atan(diff(roi.y([p1 p2]))/diff(roi.x([p1 p2])) );
% work in the rotated version
nx =  roi.x * cos(theta) + roi.y * sin(theta);
ny = -roi.x * sin(theta) + roi.y * cos(theta);
nx = nx - min(nx);  ny = ny - min(ny);

It = zeros(round(max(ny)), round(max(nx)));
It = roipoly(It, nx, ny);
[dummy mind] = max(sum(It));
tmp = (abs(nx - mind) < 1);

nnx = 1:N;
m1 = (nnx<p2)&(nnx>p1);
m2 = ~m1;
if nnz(tmp & m1) * nnz(tmp & m2) == 0, error('error'); end
p3 = find(tmp&m1);
p3 = p3(1);

tmp = abs(nx - nx(p3)) < .5;
p4 = find(tmp&m2);
[dummy ind] = min(abs(nx(p4)-nx(p3)));
p4 = p4(ind);
p(1) = p1; p(2) = p2; p(3) = p3; p(4) = p4;

res = [nx(p); ny(p)];
tmp = L2_distance(res,res);
sum_axis = (tmp(1,2) + tmp(3,4)) / scale;

roi.x = roi.x / scale; roi.y = roi.y / scale;
rf_roi.x = rf_roi.x / scale;
rf_roi.y = rf_roi.y / scale;
stat.roi_interp = roi;
stat.p = p;
stat.point.x = roi.x(p);
stat.point.y = roi.y(p);
stat.major = tmp(1,2)/scale;
stat.minor = tmp(3,4)/scale;

switch(OSD)
    case 1
        figure(743);
        clf
        plot(roi.x, roi.y);
        hold on; plot(rf_roi.x, rf_roi.y, 'b.'); hold off;
        hold on; plot(roi.x([p1 p2]), roi.y([p1 p2]), 'ro-'); hold off;
        hold on; plot(roi.x([p3 p4]), roi.y([p3 p4]), 'ro-'); hold off;
        %     hold on; plot(nx, ny, 'g.'); hold off;
        %     hold on; plot(nx([p1 p2]), ny([p1 p2]), 'go'); hold off;
        axis image
    case 2
        hold on; plot(roi.x([p1 p2]), roi.y([p1 p2]), 'g.-'); hold off;
        hold on; plot(roi.x([p3 p4]), roi.y([p3 p4]), 'g.-'); hold off;
        
end