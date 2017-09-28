function roughness = s_roughness(roix, roiy)

% Returns the ratio between the perimeters of the original curve and its
% convex hull 
%
% example: r = s_roughness(contourx, contoury);
%

OSD = 0;

% perimeters before
D = ((roix - roix([2:end 1])).^2 + (roiy - roiy([2:end 1])).^2).^.5;
P = sum(D);

k = convhull(roix, roiy);

if OSD
    figure
    plot(roix,roiy, 'b.-','LineWidth', 2);
    hold on; plot(roix(k),roiy(k), 'ro-','LineWidth', 2); hold off;
end

roix = roix(k);
roiy = roiy(k);

% perimeters of the convex hull
D = ((roix - roix([2:end 1])).^2 + (roiy - roiy([2:end 1])).^2).^.5;
P1 = sum(D);

roughness = P/P1;