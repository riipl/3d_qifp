function [N_comp P A] = s_calculateCompactness(roix, roiy)
%
% Calculate the Normalized compactness (very accurately)
% The smaller N_comp is, the closer the shape is to a circle.
% 
% Note: If # ROI pts < 100, we interpolate ROIs using spline interpolation.
% Matrix distance is slower than for loop...???
%
% 03-17-2010 JJX

if (length(roix) < 100)
    % get more ROI spline interpolation
    [roix roiy] = s_spline_interpolate(roix, roiy);
end
NUM_ROI = length(roix);

% tic
P = 0;
tmp = [1:NUM_ROI 1];
for ii = 1:NUM_ROI
    tmp_ii = tmp(ii+1);
    P = P + sqrt((roix(ii) - roix(tmp_ii)).^2 ...
        + (roiy(ii) - roiy(tmp_ii)).^2);
end
% toc;tic
% D = ((roix - roix([2:end 1])).^2 + (roiy - roiy([2:end 1])).^2).^.5;
% P = sum(D);
% toc

A = polyarea(roix, roiy);

N_comp = 1 - 4*pi/(P.^2/A);
