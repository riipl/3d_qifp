function area = calculateSurfaceArea(segVOI, xSpacing, ySpacing, zSpacing)
%CALCULATESURFACEAREA Summary of this function goes here
%   Detailed explanation goes here
    
    [faces,verts] = isosurface(segVOI, 0.5);
    
    % Scale the vertices of the triangles to reflect real-world coordinates
    % (the mass might not be isometric)
    verts = verts .* ...
        repmat([ySpacing, xSpacing, zSpacing], [size(verts,1), 1]);    

    a = verts(faces(:, 2), :) - verts(faces(:, 1), :);
    b = verts(faces(:, 3), :) - verts(faces(:, 1), :);
    c = cross(a, b, 2);
    area = 1/2 * sum(sqrt(sum(c.^2, 2)));
    
end

