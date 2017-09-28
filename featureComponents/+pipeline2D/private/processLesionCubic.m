
function sigmoidFeature = processLesionCubic(data, OSD)


%data: DB{i}
%sigmoidFeature : struct containing all parameters

if ~exist('OSD','var'), OSD = 1; end

NUM_MAX_SAMPLE_PTS = 100;   % the max # of sigmoid fitting performed, regardless of number of ROI points,

params = [];
pixelValues = [];

image = double(data.image);

if isfield(data, 'offset')
    pointsX = data.roi.x - double(data.offset.x) + 1;
    pointsY = data.roi.y - double(data.offset.y) + 1;
else
    pointsX = data.roi.x;
    pointsY = data.roi.y;
end

pointsX = [pointsX ; pointsX(1)];
pointsY = [pointsY ; pointsY(1)];

%go at most 10 pixel units in each direction, and atleast 3 pixels
MAXLENGTH = 10;
MINLENGTH = 3;
T_FREQUENCY = 4; 
FREQUENCY = T_FREQUENCY;

counter = 1;

[xx yy normalVector] = getPointsAndNormalsCubic(pointsX, pointsY, T_FREQUENCY);
if OSD
    figure;
    imshow(data.image, [0 1240])
    hold on; plot(xx, yy, '.')
end

if length(xx) > 100
    ITR_LIST = round([1:100] * (length(xx)/100));
else
    ITR_LIST = 1:length(xx);
end
for i = ITR_LIST

    curPoint = [xx(i) yy(i)];
    curNormal = normalVector(i, :);
    
	radialPoints = getPointsAlongNormalCubic(curPoint, curNormal, FREQUENCY, MAXLENGTH, [xx' yy']);
    if OSD
        if size(radialPoints, 1) > 0
            plot(radialPoints(:,1), radialPoints(:,2),'r'); drawnow;
        else
            plot(xx(i),yy(i), 'go')
        end
    end
    
    %size of radialPoints is (2N + 1) x 2
    lengthOneSide = 0.5 * (size(radialPoints, 1) - 1);

    % if you dont even have 3 pixels on either side, dont fit sigmoid
    % on this line
    if(lengthOneSide < FREQUENCY * MINLENGTH)
        continue
    end

    %if we have less than MAXLENGTH pixels on inside
    if(lengthOneSide < MAXLENGTH * FREQUENCY)
        reducedLength = round(lengthOneSide * 0.90);
        radialPoints = radialPoints( lengthOneSide + 1 - reducedLength : lengthOneSide + 1 + reducedLength, :);
    end


    curPixelValues = interpolateImage(image, radialPoints);
    currentParams = fitSigmoid(curPixelValues);

    params = [params ; currentParams];
    pixelValues{counter} = curPixelValues;
    counter = counter + 1;
    
end
if OSD, hold off; end

sigmoidFeature.params = params;
sigmoidFeature.pixelValues = pixelValues;


end