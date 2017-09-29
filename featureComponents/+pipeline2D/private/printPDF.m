function printPDF(figHandle, orientation, filename, keepAxisRatio, fillPage, EXT,OSD)

%PRINTPDF   Print figure into PDF file
%   PRINTPDF(figHandle, orientation, filename, keepAxisRatio, fillPage, EXT)
% 
%   orientation     = 'landscape' or 'l'
%                   = 'portrait' or 'p'
%   keepAxisRatio   = 1 (Fill Page, default)
%                   = 0 (what you see)
%   fillPage        = 1 (default)
%                   = 0 (exactly what you see on screen)
%
%   e.g. printPDF(gcf, 'l', 'deleteMe', 1, 0)  
%        => exactly what's on screen: keep AR, NOT fillPage
%   e.g. printPDF(gcf, 'l', 'deleteMe', 1, 0, 'png')  
%        => exactly what's on screen: keep AR, NOT fillPage; as png

%   Last Modified: 2012-10-06 JJX

if ~exist('orientation', 'var'), orientation = 'l'; end;
if ~exist('keepAxisRatio', 'var'), keepAxisRatio = 1; end
if ~exist('fillPage', 'var'), fillPage = 1; end
if ~exist('EXT', 'var'), EXT = 'pdf'; end
if ~exist('OSD', 'var'), OSD = 1; end

switch lower(orientation(1))
    case 'l'
        orient landscape
    case 'p'
        orient portrait
end

margin = .1;    % paper margin
pSize = get(figHandle, 'PaperSize');ppos(1) = margin;ppos(2) = margin;
ppos(3) = pSize(1) - 2*margin;ppos(4) = pSize(2) - 2*margin;

if keepAxisRatio == 1
    % keep the ratio as seen on the screen
    tmp = get(figHandle, 'Position');
    % scale the figure (keep ratio)
    AR = tmp(3) / tmp(4) * 1.0;
    a = min(ppos(3)/AR, ppos(4));
    b = a * AR;
    if fillPage == 0
        % the case when user wants exactly what's on screen
        dotPerInch = get(0, 'ScreenPixelsPerInch');
        ppos(3) = tmp(3) / dotPerInch; 
        ppos(4) = tmp(4) / dotPerInch;
        if OSD, fprintf('   -- Keeping AR. Exact size as on screen.\n'); end
    else
        ppos(3) = b;    ppos(4) = a;
        if OSD, fprintf('   -- Keeping AR. Fill paper\n'); end
    end
    ppos(1) = (pSize(1) - ppos(3)) / 2;
    ppos(2) = (pSize(2) - ppos(4)) / 2;
end
set(figHandle, 'PaperPosition', ppos);

if (length(filename) > 3)
    if sum(lower(filename(end-3:end)) == '.pdf') == 4
        filename = filename(1:end-4);
    end
end

print(['-d' EXT],'-r300',[filename '.' EXT]);

if strcmp(EXT, 'pdf')
    dos(['c:\Progra~2\Adobe\Reader~1.0\Reader\AcroRd32.exe ' pwd '\' filename '.' EXT ' &']);
end

return

