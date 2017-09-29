
function [sigmoidFeature num_pts_on_border ] = processLesionCubic2(data, OSD, ORGAN, MAXLENGTH)

% Return values:
%     sigmoidFeature.params      - raw [x0 W S I0] tuplets
%     sigmoidFeature.pixelValues - interpolated pixel values along norm
%     num_pts_on_border          - as it says

% OSD == 1, show boundary points, draw each line by green or red (bad fitting)
% OSD == 2, show boundary points
% OSD == 3, figure quality for paper

DEBUG = 0;          % show detail data/fitting when bad fitting
SUPERDEBUG = 1;     % show detail data/fitting for all points

color_roi = 'r';    % color of the ROI (red)
color_normal = 'g'; % color of normal lines (yellow)
color_normal_bad_fitting = 'r'; % color of normal line if bad fitted

if ~exist('OSD', 'var'), OSD = 0; end
if ~exist('ORGAN', 'var'), ORGAN = 'lung'; end
if ~exist('MAXLENGTH', 'var'), MAXLENGTH = 10; end

params = [];
num_pts_on_border = 0;

image = double(data.image);
        
if isfield(data, 'offset')
    pointsX = data.roi.x - double(data.offset.x) + 1;
    pointsY = data.roi.y - double(data.offset.y) + 1;
else
    pointsX = data.roi.x;
    pointsY = data.roi.y;
end

pointsX(end+1) = pointsX(1);
pointsY(end+1) = pointsY(1);

%go at most 10 pixel units in each direction, and atleast 3 pixels
% MAXLENGTH = 10;
MINLENGTH = 3;
T_FREQUENCY = 4;
FREQUENCY = 4;

counter = 1;

[xx yy normalVector] = getPointsAndNormalsCubic(pointsX, pointsY, T_FREQUENCY);

ind = [];       % index for points on the boundary
c_low = 840; c_high = 1240;     % liver
if strcmp(ORGAN, 'lung')==1
    %% lung area (see tweakLungEdge.m)
    c_low = -426; c_high = 1074;
    pad = 500;
    if isfield(data, 'fullImage')
        x = double(data.fullImage);
    else
        x = loadDICOM(data.dicomFileName);
    end
    if OSD > 0
        figure
        if OSD < 3
            [~, lung] = c_lung_area(x, 1, gcf);
        else
            [~, lung] = c_lung_area(x, 0);
            subplot(141); imshow(data.image, [c_low, c_high]); hold on; plot(xx, yy, color_roi, 'LineWidth', 2); hold off;
            subplot(142);
        end
    else
        [~, lung] = c_lung_area(x, 0);
    end
    lung = padarray(lung,[pad,pad]);
    mask = lung((data.offset.y : data.offset.y + size(data.image,1)-1)+pad, pad+(data.offset.x : data.offset.x+size(data.image,2)-2));
     
    tmpx = xx;
    tmpy = yy;
    if OSD > 0
        imshow(mask, [0 2]);
        hold on; plot(tmpx, tmpy, 'y', 'LineWidth', 2); hold off;
    end
    tmp = mask * 0;
    tmp = roipoly(tmp, tmpx, tmpy);
    bn = bwboundaries(tmp);
    bn = bn{1};
    tmp = tmp | mask;
    
    tmp = imclose(imopen(tmp, ones(3)), ones(3));
    C = bwconncomp(tmp);
    L = labelmatrix(C);
    mask = L==L(round(mean(tmpx)), round(mean(tmpy)));
    
    bl = bwboundaries(mask);
    bl = bl{1};
    
    b = intersect(bn, bl, 'rows');
    
    %%
    % skip the boundary cases
    x=L2_distance([yy; xx], b');
    [~,ind]=min(x);
    num_pts_on_border = length(ind);

    if OSD ==3, subplot(143); imshow(mask, [0 2]); end
end

if OSD > 0
    switch(ORGAN)
        % [x0 W S I0]
        case 'liver'
            % for liver (Neeraj's latest code)
            curMin = [0.0357    0.0014   -0.2273    1.0407];
            curMax = [0.0438    0.0065    0.2273    1.1026];
        case 'lung'
            % for lung
            curMin = [0.0357    0.0000   -2.0973    1.0407];
            curMax = [0.0438    0.0100    2.0973    1.1026];
        case 'debug'
            % for unit test in a_edge_unit_test.m
            curMin = [0.0357    0.0000   -2.0973    1.0407];
            curMax = [0.0438    0.0400    2.0973    1.1026];
    end
    curMin = curMin * 1e3;
    curMax = curMax * 1e3;
    
    if OSD ~= 3, figure; else subplot(1,4,4); end
    imshow(data.image, [c_low c_high]);
    hold on; plot(xx, yy, [color_roi '.'])
    if OSD ~= 3, hold on; plot(xx(ind), yy(ind), 'rs'); end
end

for ii = setdiff(1:length(xx), unique(ind))%1 : length(xx)
    curPoint = [xx(ii) yy(ii)];
    curNormal = normalVector(ii, :);
    
	radialPoints = getPointsAlongNormalCubic(curPoint, curNormal, FREQUENCY, MAXLENGTH, [xx' yy']);

    %size of radialPoints is (2N + 1) x 2
    lengthOneSide = 0.5 * (size(radialPoints, 1) - 1);

    % if you dont even have 3 pixels on either side, dont fit sigmoid
    % on this line
    if(lengthOneSide < FREQUENCY * MINLENGTH)
        if OSD == 1, plot(xx(ii),yy(ii), 'rd'); end
        continue
    end

    if isfield(data, 'borders')
        % if has border, liver case
        test = inpolygon(radialPoints(:,1), radialPoints(:,2), data.borders.x, data.borders.y);
        if nnz(test) < length(test)*.90
            % ignore this point
            if OSD == 1, plot(xx(ii),yy(ii), 'rs'); end
            num_pts_on_border = num_pts_on_border + 1;
            continue
        end
    elseif strcmp(ORGAN, 'lung')==1 && OSD == 3
        % lung case, mask is generated
        test = inpolygon(radialPoints(:,1), radialPoints(:,2), bl(:,2), bl(:,1));
        if nnz(test) == length(test)
            plot(radialPoints(:,1), radialPoints(:,2), color_normal, 'LineWidth', 1); drawnow;            
        end
    end
    
    %if we have less than MAXLENGTH pixels on inside
    if(lengthOneSide < MAXLENGTH * FREQUENCY)
        reducedLength = round(lengthOneSide * 0.90);
        radialPoints = radialPoints( lengthOneSide + 1 - reducedLength : lengthOneSide + 1 + reducedLength, :);
    end

    curPixelValues = interpolateImage(image, radialPoints);
    currentParams = fitSigmoid(curPixelValues);
    currentParams(2) = abs(currentParams(2));       % window should be always positive

    if OSD == 1
        color = color_normal;
        x = currentParams;
        if  ~(curMin(2) < x(:,2) && x(:,2)< curMax(2) && curMin(3) < x(:,3) && x(:,3)< curMax(3)) 
            num2str([x(2:3)], '%12.2f')   % print bad fitting parameters
            color = color_normal_bad_fitting;  
        end
        if (DEBUG && strcmp(color, color_normal_bad_fitting)) || SUPERDEBUG == 1
            tmp = gcf;
            figure; subplot(121); imshow(data.image, [c_low c_high]);
            hold on; plot(radialPoints(:,1), radialPoints(:,2), 'r'); hold off;
            subplot(122);
            f = @(p,x) p(4) + p(3) ./ (1 + exp(-(x-p(1))/p(2)));
            fitted = f(currentParams, 1:length(curPixelValues));
            plot(curPixelValues,'b.'); hold on; plot(fitted, 'g'); hold off;
            title(num2str([x(2:3)], '%12.2f'));
            figure(tmp);
        end
        if size(radialPoints, 1) > 0
            plot(radialPoints(:,1), radialPoints(:,2), color); drawnow;
        else
            plot(xx(ii),yy(ii), 'go')
        end
    end
    
    params = [params ; currentParams];
    pixelValues{counter} = curPixelValues;
    counter = counter + 1;
    
end
if OSD> 0, hold off; end

sigmoidFeature.params = params;
sigmoidFeature.pixelValues = pixelValues;


end