%SG_FILTERWITHBANK2 - Gabor filtering with filterbank
%
% r = sg_filterwithbank2(s, bank)
%
% Filter 2D signal using a filterbank. 
%
%   s - signal (image)
%   bank - filterbank, created with sg_createfilterbank()
%
% Optional arguments are
%   max_zoom  - Maximum scaling to be used with method 1. Will be used 
%               only if lower than scaling factor based on highest 
%               frequency of the filter. Default 0 means that the
%               image will be downscaled as much as possible.
%
% Response structure includes
%   .N      - the size of the filtered image
%   .freq   - a cell array of filter responses which contains fields
%      .f    - frequency of the filter
%      .zoom - scaling factor at with this filter frequency (currently
%              always the same as the same field in the main structure)
%      .resp - actual filter responses, [N x X x Y] matrix where 
%              N is number of filter orientations and X and Y are
%              the response resolution
%   .zoom       - integer factor of how much the image was downscaled 
%                 during filtering for each filter frequency
%   .respSize   - the resolution of responses for each filter frequency
%   .actualZoom - actual scaling factors for x and y directions, may differ
%                 slightly to .zoom for each filter frequency
%
% This is an alternate version of SG_FILTERWITHBANK which computes
% responses of each filter frequency scaled to as low resolution as
% possible. Amplitudes of responses are normalized (unlike with
% SG_FILTERWITHBANK). 
%
% Note that other functions working with response structure 
% returned by SG_FILTERWITHBANK do not work because the resolutions
% are not the same for all filters.
%
% Authors: 
%   Jarmo Ilonen, 2007
%
% $Name: V_1_0_0 $ $Id: sg_filterwithbank2.m,v 1.1 2007-07-30 10:17:46 ilonen Exp $

function [m]=sg_filterwithbank(s, bank, varargin)

conf = struct(...,
       'points',[], ...
       'domain',0, ...
       'max_zoom',0 ...
       );

conf = getargs(conf, varargin);

[N(2) N(1)]=size(s);

m.N=[N(2) N(1)];

% downscale as much as possible separately for every filter
  
for find=1:length(bank.freq)
	m.zoom(find)=0.5/bank.freq{find}.orient{1}.fhigh;

	if conf.max_zoom>0 && m.zoom(find)>conf.max_zoom
  		m.zoom(find)=conf.max_zoom;
	end;   
  
  	if m.zoom(find)<1
		printf('Zoom factor smaller than 1, wtf?\n');
		m.zoom(find)=1;
	end;    

	% the responsesize is always wanted to be divisible by two
   	m.respSize(find,:)=round(N/m.zoom(find)/2)*2; 
    
	% actual zoom factor
	m.actualZoom(find,:)=(N./m.respSize(find));
      
end;


% perform the filtering

fs=fft2(ifftshift(s));
  
% the loop for calculating responses at all frequencies
  
for find=1:length(bank.freq),
    	f0=bank.freq{find}.f;
    
    	m.freq{find}.f=f0;
        
    	% zero memory for filter responses, each frequency is of different size now 
    	if isempty(conf.points)
      		m.freq{find}.resp=zeros(length(bank.freq{find}.orient),m.respSize(find,2),m.respSize(find,1));
    	end;      
    
    	% loop through orientations
    	for oind=1:length(bank.freq{find}.orient),
      
      		a= bank.freq{find}.orient{oind}.envelope;
      		fhigh=bank.freq{find}.orient{oind}.fhigh;
      
      		m.freq{find}.zoom=m.zoom(find);
        	f2_=zeros(m.respSize(find,2),m.respSize(find,1));
        
        	lx=a(2)-a(1);
        	ly=a(4)-a(3);

        	% coordinates for the filter area in filtered fullsize image
        	xx=mod( (0:lx) + a(1) + N(1) , N(1) ) + 1;
        	yy=mod( (0:ly) + a(3) + N(2) , N(2) ) + 1;
        
        	% coordinates for the filter area in downscaled response image
        	xx_z=mod( (0:lx) + a(1) + m.respSize(find,1) , m.respSize(find,1) ) + 1;
        	yy_z=mod( (0:ly) + a(3) + m.respSize(find,2) , m.respSize(find,2) ) + 1;
 
        	% filter the image
        	f2_(yy_z,xx_z) = bank.freq{find}.orient{oind}.filter .* fs(yy,xx);
        
      		% set the responses to response matrix and normalize amplitudes for the zoom factor
      		m.freq{find}.resp(oind,:,:)=fftshift(ifft2(f2_))./prod(m.actualZoom(find,:));
        end;    

end;

