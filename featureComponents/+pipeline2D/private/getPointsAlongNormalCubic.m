function points = getPointsAlongNormalCubic(pt, vector, frequency, maxLength, boundary)


%boundary : n x 2 vector that defines the boundary of the lesion

%pt : (1 x 2) point on the boundary

%vector : unit length normal vector along the boundary (not necessarily
%outward)

%frequency: smapling frequency
%maxLength: at most maxLength pixel units along each direction

%returns:
%points along the normal line

theta = 1/frequency : 1/frequency : maxLength;
theta = repmat(theta', [1 2]);

N = size(theta, 1);
pt = repmat(pt, [N 1]);
vector = repmat(vector, [N 1]);

%any point along the line in 1 direction: r = pt + theta * vector
ptsOutside = pt + theta .* vector;

%any point along the line in opp direction: r = pt - theta * vector
ptsInside = pt - theta .* vector;


%swap inside and outside if the vector was an inward normal
%returns true if on the polygon or inside the polygon
test = inpolygon(ptsOutside(2,1), ptsOutside(2,2), boundary(:,1), boundary(:,2));
if (test > 0)
    temp = ptsOutside;
    ptsOutside = ptsInside;
    ptsInside = temp;
end


test = inpolygon(ptsOutside(2,1), ptsOutside(2,2), boundary(:,1), boundary(:,2));
if (test > 0)
    disp('Error .... got an inside point when moving along outside direction');
    disp(ptsOutside(2,:))
    points = [];
    return
end



test = inpolygon(ptsInside(:,1), ptsInside(:,2), boundary(:,1), boundary(:,2));


idx = 1;
while (idx <= size(test,1) && test(idx) == 1)
    idx = idx + 1;
end


ptsInside = ptsInside(1:idx - 1, :);
ptsOutside = ptsOutside(1:idx - 1, :);

points = [ptsInside(end:-1:1, :) ; pt(1,:) ; ptsOutside];


end