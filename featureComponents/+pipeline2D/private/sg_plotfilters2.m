%SG_PLOTFILTERS2 displays Gabor filter bank
%
% sg_plotfilters(N, fmax, m, n)
%
% This function displays a Gabor filter bank in frequency space.
% It is mainly meant to be called from sg_createfilterbank
% with verbose option.
%
%   N - size of the image, [height width].
%   fmax - frequency of the highest frequency filter
%   m - number of filter frequencies.
%   n - number or filter orientations
%
% Optional arguments are
%   k         - factor for selecting filter frequencies
%               (1, 1/k, 1/k^2, 1/k^3...), default is sqrt(2)
%   p         - crossing point between two consecutive filters, 
%               default 0.5
%   gamma     - gamma of the filter
%   eta       - eta of the filter
%
% $Name: V_1_0_0 $ $Id: sg_plotfilters2.m,v 1.4 2005-09-27 10:53:00 ilonen Exp $

function sg_plotfilters2(N,fmax,m,n,varargin)

conf = struct(...,
       'gamma',0, ...
       'eta',0,...
       'k',sqrt(2),...
       'p',0.5 ...
       );
       
       
conf = getargs(conf, varargin);     
       
[gamma_,eta_]=sg_solvefilterparams(conf.k, conf.p,m,n);

if conf.gamma==0,
  conf.gamma=gamma_;
end;

if conf.eta==0
  conf.eta=eta_;
end;

f=fmax*conf.k.^-(0:(m-1));

o=(0:(n-1))*pi/n;

%N=200

map=zeros(N(1),N(2));

count=1;
for ff=f
  for oo=o %+ pi + pi/no
    % be verbose
    fprintf('Preparing filter bank for display, %d/%d\r',count,length(f)*length(o));
    count=count+1;
    
    % create the filter and prepare the display
    g=sg_createfilterf2(ff,oo,conf.gamma,conf.eta,N);
    map=map+g;
  
  end;
end;
fprintf('Preparing filter bank for display, done.    \n');

imagesc(fftshift(max(max(map))-map)); colormap(gray); drawnow

tick=get(gca,'YTick');
set(gca,'YTickLabel',1-tick/max(tick)-0.5);
tick=get(gca,'XTick');
set(gca,'XTickLabel',tick/max(tick)-0.5);
