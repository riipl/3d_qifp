function [res, offset, tmp]=GetLesionImgSz(I, poly, h, w)

[tmp.x tmp.y] = s_spline_interpolate(poly.x, poly.y);

extraMarginW = uint16(( w - floor(max(tmp.x)) + ceil(min(tmp.x)) )/2);
extraMarginH = uint16(( h - floor(max(tmp.y)) + ceil(min(tmp.y)) )/2);
[res,offset] = GetLesionImg(I, tmp, extraMarginW, extraMarginH);