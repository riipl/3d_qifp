function [contourx contoury] = s_RDStoXY(rds)
%
% RETURN VALUE:
% rds.r     - 
% rds.mag   - normalization factor
% rds.theta
%  
% Note: centered at origin
%

N = length(rds.theta);
contourx = zeros(1,N);
contoury = contourx;

if 0
    % naive, slow version
    for ii = 1:N
        [contourx(ii) contoury(ii)] = s_pol2euc(rds.r(ii), rds.theta(ii));
    end
else
    % a bit faster
    contourx = rds.r .* cos(rds.theta);
    contoury = rds.r .* sin(rds.theta);
end

% contourx = contourx - min(contourx) + 1;
% contoury = contoury - min(contoury) + 1;

% figure;
% plot(contourx, contoury)
