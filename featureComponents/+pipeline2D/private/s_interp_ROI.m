function [contourx contoury] = s_interp_ROI(roix, roiy, NUM_INTERP_SAMP)
%
% interpolate ROI points
%

if ~exist('NUM_INTERP_SAMP', 'var'), NUM_INTERP_SAMP = 10; end

NUM_ROI = length(roix);
if (NUM_ROI > 100)
    contourx = roix;
    contoury = roiy;
    return;
end

% METHOD 1: interpolation each line segment
%           SLOW but ACURATE
tmp = [1:NUM_ROI 1];
contour = [];
for ii = 1:NUM_ROI
    next_ii = tmp(ii + 1);
    if (roix(ii) ~= roix(next_ii))
        x_int = linspace(roix(ii), roix(next_ii), NUM_INTERP_SAMP);
        y_int = interp1(x_int([1 end]), roiy([ii next_ii]), x_int);
        contour = [contour; x_int' y_int'];
    end
end

contourx = contour(:,2);        % contour(1,:) = [Y1 X1];
contoury = contour(:,1);        % plot(X1, Y1); tmp(Y1, X1)
