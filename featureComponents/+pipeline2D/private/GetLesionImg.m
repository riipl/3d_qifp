function [res,offset] = GetLesionImg(I,poly,extraMarginW,extraMarginH)
if extraMarginW < 0 || extraMarginH < 0
    disp('extraMarginW < 0 || extraMarginH < 0');
end
extraMarginW = int16(extraMarginW);
extraMarginH = int16(extraMarginH);

if (extraMarginW == 0)
    extraMarginW = 10;
end
if (extraMarginH == 0)
    extraMarginH = 10;
end

I = single(I);
pad = 500;  %todo temp how to set pad big enough?
I = padarray(I,[pad,pad]);
bBox.left = int16(ceil(min(poly.x)));
bBox.right = int16(floor(max(poly.x)));
bBox.top = int16(ceil(min(poly.y)));
bBox.bottom = int16(floor(max(poly.y)));

bBox.left = bBox.left-extraMarginW;
bBox.right = bBox.right+extraMarginW;
bBox.top = bBox.top-extraMarginH;
bBox.bottom = bBox.bottom+extraMarginH;
res = I((bBox.top:bBox.bottom)+pad, (bBox.left:bBox.right)+pad);
offset.x = double(bBox.left);
offset.y = double(bBox.top);