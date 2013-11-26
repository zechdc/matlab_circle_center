% USAGE: 
% pass in 2 points in the following format [x y]
%           getLineProperties([x1 y1], [x2 y2])
% it has been formatted this way because many matlab matrix store points in
% this format so the following could also work
%           getLineProperties(point1, point2)    
% 
% RETURNS:
% It returns an array of lineProperties that have the following attributes
% available to you
%       lineProperties.slope
%       lineProperties.inverseSlope (aka, perpendicular slope)
%       lineProperties.xIntercept
%       lineProperties.yIntercept
%       lineProperties.midPoint (this is an array with points [x y])
%           access it like so: lineProperties.midPoint(1) is equal to the X
%           midpoint. midPoint(2) is equal to the Y midpoint.

function [lineProperties] = getLineProperties(point1, point2)

%set var names for easier readibility
x1 = point1(1);
y1 = point1(2);

x2 = point2(1);
y2 = point2(2);

slope = (y2 - y1) / (x2 - x1);

%find the negative reciprocal (perpendicular) of the slope
%http://www.mathsisfun.com/algebra/line-parallel-perpendicular.html
inverseSlope = -(1/slope);


midPoint(1) =  ((x1 + x2) / 2);
midPoint(2) =  ((y1 + y2) / 2);

%calculate y intercept (b) of the perpendicular line
%Equation: b = y1 - mx1
%http://www.wikihow.com/Find-the-Equation-of-a-Line
yIntercept = midPoint(2) - inverseSlope*midPoint(1);

%old solution, takes longer to process
%syms b;
%yIntercept = solve(midPoint(2) == slopePerp*midPoint(1) + b, b);
%yIntercept = double(yIntercept);

%
%calculate x intercept of the perpendicular line
%Equation y = mx+b... set y to 0
%Equation x = (y-b) / m
%y = 0
xIntercept = (-yIntercept / inverseSlope);
%Old solution, this takes longer to process but works the same as the above
%code.
%syms x;
%xIntercept = solve(0 == slopePerp*x + yIntercept, x);
%xIntercept = double(xIntercept);

%set the array that will be passed back
lineProperties.slope = slope;
lineProperties.inverseSlope = inverseSlope;
lineProperties.midPoint = midPoint;
lineProperties.yIntercept = yIntercept;
lineProperties.xIntercept = xIntercept;
lineProperties.midPoint = midPoint;

end