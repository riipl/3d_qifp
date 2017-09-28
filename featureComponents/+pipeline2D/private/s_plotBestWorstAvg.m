function plotBestWorstAvg(data, K, plotErrorbar)
%% Plot best case / worst case / average case with error bar
% data: M by N matrix of M test results, each have N values
%       the value should between 0 and 1, with 1 meaning the ideal case
% K:    we only care about the first K elements for each test result
%       if we care about all, set K = N

% figH = figure;

if nargin == 2
    plotErrorbar = 0;
end

MEAN_ONLY = 0;

if ~MEAN_ONLY
    plot(max(data(:,1:K)),'>');
    hold on;
    plot(min(data(:,1:K)),'.');
end

m = mean(data(:,1:K));
if plotErrorbar == 1
    errorbar(1:K,m,min(std(data(:,1:K)),m),min(1-m,std(data(:,1:K))),'o-');
else
    if ~MEAN_ONLY
        plot(m,'o-');
    else
        plot(m,'.-');
    end
end

hold off

set(gca,'XGrid','off','YGrid','on','XMinorGrid','off');
if MEAN_ONLY
    legend();
else
    legend('Best Case','Worst Case','Average','Location','SouthWest');
end
axis([0.4 K+0.5 0 1.05]);
set(gca, 'XTick', [0:max(1,round(K/6)):K])
