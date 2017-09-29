function [xx yy normalVector] = getPointsAndNormalsCubic(pointsX, pointsY, T_FREQUENCY)


    %every segment b/w two consecutive pts is sampled T_FREQUENCY times
    %T_FREQUENCY = 4;
    
    
    numOfPoints = length(pointsX);
    
    t = 0 : numOfPoints - 1;
    splineStruct.x = spline(t, pointsX);
    splineStruct.y = spline(t, pointsY);

    xx = ppval(splineStruct.x, 0 : 1/T_FREQUENCY : numOfPoints - 1);
    yy = ppval(splineStruct.y, 0 : 1/T_FREQUENCY : numOfPoints - 1);
    
    sampledNumOfPoints = length(xx);
    
    d_splineStruct.x.form = 'pp';
    d_splineStruct.x.breaks = splineStruct.x.breaks;
    d_splineStruct.x.pieces = splineStruct.x.pieces;
    d_splineStruct.x.order = 3;
    d_splineStruct.x.dim = 1;
    d_splineStruct.x.coefs = repmat([3 2 1], [size(splineStruct.x.coefs, 1) 1]) .* splineStruct.x.coefs(:, 1:3);


    d_splineStruct.y.form = 'pp';
    d_splineStruct.y.breaks = splineStruct.y.breaks;
    d_splineStruct.y.pieces = splineStruct.y.pieces;
    d_splineStruct.y.order = 3;
    d_splineStruct.y.dim = 1;
    d_splineStruct.y.coefs = repmat([3 2 1], [size(splineStruct.y.coefs, 1) 1]) .* splineStruct.y.coefs(:, 1:3);

    
    %compute dy and dx
	d_xx = ppval(d_splineStruct.x, 0 : 1/T_FREQUENCY : numOfPoints - 1);
    d_yy = ppval(d_splineStruct.y, 0 : 1/T_FREQUENCY : numOfPoints - 1);
    
    
    %when line is // to y axis, vector is [1 0]
    normalVector = zeros(sampledNumOfPoints, 2);
    normalVector(:, 1) = 1;
    
    idx = find(d_xx ~= 0);
    normalVector(idx, 2) = 1;
    normalVector(idx, 1) = -d_yy(idx) ./ d_xx(idx);

    norm = sqrt(sum(normalVector .* normalVector, 2));
    normalVector = normalVector ./ [norm norm];
    

    
    %To compute normal : 
    %special case: when line is // to y axis
%     if(dx == 0)
%         vector = [1 0];
%     else
%     
%         vy = 1.0;
%         vx = -vy * dy / dx;
%         vector = [vx vy];
%     end
%     vector = vector / sqrt (sum (vector .* vector ) );
    
    
    

end