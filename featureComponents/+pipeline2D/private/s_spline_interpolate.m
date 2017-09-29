function [newPtx newPty] = s_spline_interpolate(Ptx, Pty)

% Ptx Pty have to be row vectors
if size(Ptx, 2)==1
    Ptx = Ptx';
end
if size(Pty, 2)==1
    Pty = Pty';
end

% if input doesn't repeat the start point, we do it for you
if ~(Ptx(1)==Ptx(end) && Pty(1)==Pty(end))
    Ptx = [Ptx Ptx(1)];
    Pty = [Pty Pty(1)];
end

% find duplicate indices
ind = logical([1 (diff(Ptx)+diff(Pty)~=0)]);
if nnz(ind) < 2
    error('no unique points');
end
Ptx = Ptx(ind);
Pty = Pty(ind);

tot = length(Ptx);

% 	double aax, bbx, ccx, ddx, aay, bby, ccy, ddy; // coef of spline

% 	if( scale > 5) scale = 5;
scale = 5;
method1 = 1;
% 
% 	// function spline S(x) = a x3 + bx2 + cx + d
% 	// with S continue, S1 continue, S2 continue.
% 	// smoothing of a closed polygon given by a list of points (x,y)
% 	// we compute a spline for x and a spline for y
% 	// where x and y are function of d where t is the distance between points
% 
% 	// compute tridiag matrix
% 	//   | b1 c1 0 ...                   |   |  u1 |   |  r1 |
% 	//   | a2 b2 c2 0 ...                |   |  u2 |   |  r2 |
% 	//   |  0 a3 b3 c3 0 ...             | * | ... | = | ... |
% 	//   |                  ...          |   | ... |   | ... |
% 	//   |                an-1 bn-1 cn-1 |   | ... |   | ... |
% 	//   |                 0    an   bn  |   |  un |   |  rn |
% 	// bi = 4
% 	// resolution algorithm is taken from the book : Numerical recipes in C
% 
% 	// initialization of different vectors
% 	// element number 0 is not used (except h[0])
% 	nb  = tot + 2;
nb = tot + 2;

% 	a, c, cx, cy, d, g, gam, h, px, py  = malloc(nb*sizeof(double));	
% 	BOOL failed = NO;
% 	
% 	//initialisation
% 	for (i=0; i<nb; i++)
% 		h[i] = a[i] = cx[i] = d[i] = c[i] = cy[i] = g[i] = gam[i] = 0.0;
a = zeros(1, nb);
h = a; c = a; d = a;
cx = a; cy = a;
g = a; gam = a;

% 
% 	// as a spline starts and ends with a line one adds two points
% 	// in order to have continuity in starting point
% 	for (i=0; i<tot; i++)
% 	{
% 		px[i+1] = Pt[i].x;// * fZoom / 100;
% 		py[i+1] = Pt[i].y;// * fZoom / 100;
% 	}
px = zeros(1, nb); py = px;
px(2:nb-1) = Ptx;
py(2:nb-1) = Pty;
px(1) = px(nb-2);   % 	px[0] = px[nb-3]; py[0] = py[nb-3];
py(1) = py(nb-2);
px(nb) = px(3);     % 	px[nb-1] = px[2]; py[nb-1] = py[2];
py(nb) = py(3);

% 
% 	// check all points are separate, if not do not smooth
% 	// this happens when the zoom factor is too small
% 	// so in this case the smooth is not useful
% 			 
% 	// define hi (distance between points) h0 distance between 0 and 1.
% 	// di distance of point i from start point
% 	for (i = 0; i<nb-1; i++)
% 	{
% 		xi = px[i+1] - px[i];
% 		yi = py[i+1] - py[i];
% 		h[i] = (double) sqrt(xi*xi + yi*yi) * scale;
% 		d[i+1] = d[i] + h[i];
% 	}
tmpx = px(2:end) - px(1:end-1);
tmpy = py(2:end) - py(1:end-1);
h = scale * sqrt(tmpx.^2 + tmpy.^2);
d(2:end) = cumsum(h);

% 
% 	// define ai and ci
for i = 3:nb-1  % (i=2; i<nb-1; i++) 
    a(i) = 2.0 * h(i-1) / (h(i) + h(i-1));
end
% a(3:nb-1) = 2.0 * h(2:nb-2) ./ (h(3:nb-1) + h(2:nb-2));

for i = 2:nb-2  %(i=1; i<nb-2; i++) 
    c(i) = 2.0 * h(i) / (h(i) + h(i-1));
end

% 
% 	// define gi in function of x
% 	// gi+1 = 6 * Y[hi, hi+1, hi+2], 
% 	// Y[hi, hi+1, hi+2] = [(yi - yi+1)/(di - di+1) - (yi+1 - yi+2)/(di+1 - di+2)]
% 	//                      / (di - di+2)
% 	for (i=1; i<nb-1; i++) 
% 		g[i] = 6.0 * ( ((px[i-1] - px[i]) / (d[i-1] - d[i])) - ((px[i] - px[i+1]) / (d[i] - d[i+1])) ) / (d[i-1]-d[i+1]);
for i = 2:nb-1  %(i=1; i<nb-1; i++) 
        g(i) = 6.0 * ( ((px(i-1) - px(i)) / (d(i-1) - d(i))) - ((px(i) - px(i+1)) / (d(i) - d(i+1))) ) / (d(i-1)-d(i+1));
end


% 	// compute cx vector
% 	b=4; bet=4;
% 	cx[1] = g[1]/b;
% 	for (j=2; j<nb-1; j++)
% 	{
% 		gam[j] = c[j-1] / bet;
% 		bet = b - a[j] * gam[j];
% 		cx[j] = (g[j] - a[j] * cx[j-1]) / bet;
% 	}
% 	for (j=(nb-2); j>=1; j--) cx[j] -= gam[j+1] * cx[j+1];
b = 4; bet = 4;
cx(2) = g(2)/b;
for j = 3:nb-1   % (j=2; j<nb-1; j++)
    gam(j) = c(j-1) / bet;
    bet = b - a(j) * gam(j);
    cx(j) = (g(j) - a(j) * cx(j-1)) / bet;
end
for j = nb-1:-1:2   % (j=(nb-2); j>=1; j--)
    cx(j) = cx(j) - gam(j+1) * cx(j+1);
end
    
% 
% 	// define gi in function of y
% 	// gi+1 = 6 * Y[hi, hi+1, hi+2], 
% 	// Y[hi, hi+1, hi+2] = [(yi - yi+1)/(hi - hi+1) - (yi+1 - yi+2)/(hi+1 - hi+2)]
% 	//                      / (hi - hi+2)
% 	for (i=1; i<nb-1; i++)
% 		g[i] = 6.0 * ( ((py[i-1] - py[i]) / (d[i-1] - d[i])) - ((py[i] - py[i+1]) / (d[i] - d[i+1])) ) / (d[i-1]-d[i+1]);
for i = 2:nb-1  %(i=1; i<nb-1; i++)
    g(i) = 6.0 * ( ((py(i-1) - py(i)) / (d(i-1) - d(i))) - ((py(i) - py(i+1)) / (d(i) - d(i+1))) ) / (d(i-1)-d(i+1));
end

% 
% 	// compute cy vector
% 	b = 4.0; bet = 4.0;
% 	cy[1] = g[1] / b;
% 	for (j=2; j<nb-1; j++)
% 	{
% 		gam[j] = c[j-1] / bet;
% 		bet = b - a[j] * gam[j];
% 		cy[j] = (g[j] - a[j] * cy[j-1]) / bet;
% 	}
% 	for (j=(nb-2); j>=1; j--) cy[j] -= gam[j+1] * cy[j+1];
b = 4.0; bet = 4.0;
cy(2) = g(2) / b;
for j = 3:nb-1      % (j=2; j<nb-1; j++)
    gam(j) = c(j-1) / bet;
    bet = b - a(j) * gam(j);
    cy(j) = (g(j) - a(j) * cy(j-1)) / bet;
end
for j = nb-1:-1:2       % (j=(nb-2); j>=1; j--)
    cy(j) = cy(j) - gam(j+1) * cy(j+1);
end


    
% 
% 	// OK we have the cx and cy vectors, from that we can compute the
% 	// coeff of the polynoms for x and y and for each interval
% 	// S(x) (xi, xi+1)  = ai + bi (x-xi) + ci (x-xi)2 + di (x-xi)3
% 	// di = (ci+1 - ci) / 3 hi
% 	// ai = yi
% 	// bi = ((ai+1 - ai) / hi) - (hi/3) (ci+1 + 2 ci)

% 
% 	int tt = 0;
% 	// for each interval
% 	for (i=1; i<nb-2; i++)
% 	{
% 		// compute coef for x polynom
% 		ccx = cx[i];
% 		aax = px[i];
% 		ddx = (cx[i+1] - cx[i]) / (3.0 * h[i]);
% 		bbx = ((px[i+1] - px[i]) / h[i]) - (h[i] / 3.0) * (cx[i+1] + 2.0 * cx[i]);
% 
% 		// compute coef for y polynom
% 		ccy = cy[i];
% 		aay = py[i];
% 		ddy = (cy[i+1] - cy[i]) / (3.0 * h[i]);
% 		bby = ((py[i+1] - py[i]) / h[i]) - (h[i] / 3.0) * (cy[i+1] + 2.0 * cy[i]);
% 
% 		// compute points in this interval and display
% 		p1.x = aax;
% 		p1.y = aay;
% 
% 		(*newPt)[tt]=p1;
% 		tt++;
% 		
% 		for (j = 1; j <= h[i]; j++)
% 		{
% 			p2.x = (aax + bbx * (double)j + ccx * (double)(j * j) + ddx * (double)(j * j * j));
% 			p2.y = (aay + bby * (double)j + ccy * (double)(j * j) + ddy * (double)(j * j * j));
% 			(*newPt)[tt]=p2;
% 			tt++;
% 		}//endfor points in 1 interval
% 	}//endfor each interval

% *newPt = calloc(totNewPt, sizeof(NSPoint));
 
tt = 1;
newPtx = [];
newPty = [];
% // for each interval
for i = 2:nb-2   %  (i=1; i<nb-2; i++)
    % // compute coef for x polynom
    ccx = cx(i);
    aax = px(i);
    ddx = (cx(i+1) - cx(i)) / (3.0 * h(i));
    bbx = ((px(i+1) - px(i)) / h(i)) - (h(i) / 3.0) * (cx(i+1) + 2.0 * cx(i));

    % // compute coef for y polynom
    ccy = cy(i);
    aay = py(i);
    ddy = (cy(i+1) - cy(i)) / (3.0 * h(i));
    bby = ((py(i+1) - py(i)) / h(i)) - (h(i) / 3.0) * (cy(i+1) + 2.0 * cy(i));

    %     // compute points in this interval and display
    p1.x = aax;
    p1.y = aay;
    
    if method1
        newPtx(tt) = p1.x;
        newPty(tt) = p1.y;
        tt = tt + 1;
    else
        newPtx = [newPtx; p1.x];
        newPty = [newPty; p1.y];
    end
    
    %     tic
    if method1
        for j = 1:h(i)      % (j = 1; j <= h(i); j++)
            p2.x = (aax + bbx * j + ccx * (j * j) + ddx * (j * j * j));
            p2.y = (aay + bby * j + ccy * (j * j) + ddy * (j * j * j));
            newPtx(tt) = p2.x;
            newPty(tt) = p2.y;
            tt = tt + 1;
        end %//endfor points in 1 interval
        %     toc
    else
        %     tic
        H = floor(h(i));
        x = [1:H]';
        tmpx = [ones(H,1) x x.^2 x.^3] * [aax; bbx; ccx; ddx];
        tmpy = [ones(H,1) x x.^2 x.^3] * [aay; bby; ccy; ddy];
        newPtx = [newPtx; tmpx];
        newPty = [newPty; tmpy];
    end
    
%     toc
end %//endfor each interval

% fprintf('Expected: %d, actual %d.\n', totNewPt, tt)

