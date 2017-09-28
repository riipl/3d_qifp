function [area lung figHandle] = c_lung_area(I1, OSD, figHandle)
%% return the lung area o fI1
if ~exist('OSD', 'var'), OSD = 1; end;

c_low = -426; c_high = 1074;

if ~exist('figHandle', 'var'), figHandle = 8105; end;
SHOW_AIR = 0;

I1(I1<0) = 0;
if OSD
    figure(figHandle);
    subplot(1,2,1); imshow(I1,[c_low, c_high]);
    subplot(1,2,2);
end

H = fspecial('average',3);
I1 = imfilter(I1, H, 'replicate');

%% find the optimal threshold
T = 1000;
T_old = 0;
tmp = I1(:);
while (T_old ~= T)
    body_mean = mean((tmp(tmp <  T)));
    nonbody_mean = mean((tmp(tmp >= T)));
    T_old = T;
    T = (body_mean + nonbody_mean)/2;
end
T = 805;

% find the thorax mask
BW_thresh = (I1 > T)*1;
BW = imfill(BW_thresh, 'holes');
[L n]= bwlabel(BW);
if 1
    res = zeros(1,n);
    for i = 1:n
        res(i) = sum(sum(L==i));
    end
    [dummy ind] = sort(res,'descend');
else
    ind = L(256,256);
end
thorax_mask = BW .* (L==ind(1));

BW = thorax_mask .* (1 - BW_thresh);
air = (I1 < 110) .* thorax_mask;
BW = BW - air;
[L n]= bwlabel(BW);
res = zeros(1,n);
for i = 1:n
    res(i) = sum(sum(L==i));
    if ( res(i) < 200 )
        BW(L==i) = 0;
        %     elseif ( res(i) < 1000 )
        %         tmp = find(L==i);
        %         mean(mod(tmp(:), 512))
    end
end
lung = BW;
lung = bwmorph(lung, 'close');
lung = imfill(lung,'holes');
area = sum(lung(:));

if OSD
    if SHOW_AIR
        RGB = repmat(I1 .* lung, [1 1 3]);
        % RGB = ieWindowScale(RGB,T,1024);
        % RGB = ieScale(RGB, 0, 1);
        air_3 = repmat(air, [1 1 3]);
        air_3(:,:,2:3) = 0;
        RGB = RGB + air_3;
        
        imshow(RGB);
        title(num2str(area))
    else
        imshow(lung)
    end
end