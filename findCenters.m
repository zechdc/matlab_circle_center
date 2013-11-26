%this function will find all edges and attempt to find the center of an
%object by assuming it is a circle.
% USAGE:
%       findCenter(img, mask, numberOfObjects, smallestAreaAllowed, plotPoints)
%           img = the image you would like to search for edges on
%           mask = is a binary image, it will mask out parts of the image that
%               should not be processed. Must be a mask object created by
%               the "createMask.m" class included with my scripts. This is
%               not a normal function of Matlab but a script I created.
%           numberOfObjects = (must be at least 1) how many objects do you want to detect. It
%               will then average the center of these objects to find an
%               estimated center of all objects.
%           smallestAreaAllowed = (must be at least 0), this is the number
%               of pixels in an area that should exists before being considered
%               an object. For example, if an object is detected but only 10
%               pixels are in the object, you can ignore this small object by
%               setting this variable to 11;
%           imageThreshold = it is used in creating binary images. You may
%               need to adjust this to get the desired results. Must be an
%               integer. used in: image = img > imageThreshold#
%           plotPoints = true or false. It will tell the script to plot points
%               and draw lines for the detected edge or not
% RETURNS:
%       reutrns an array of object properties that include:
%           objectCenters.center = an array of [x y] points for all the
%               centers found.
%           objectCenters.averageCenter = the average of all centers found
%       

function [objectCenters] = findCenters(img, mask, numberOfObjects, smallestAreaAllowed, imageThreshold, plotPoints)

%% Apply the mask to the new image

%convert img to binary image
%img = rgb2gray(img);
img = img > imageThreshold;

% apply the mask
img(mask.outer==0) = 1;
img=1-img;

%label objects found
%label = bwlabel(img);
label = edge(img);

%apply the smaller mask(inner mask) to edge image

%subtract every pixel of the image from 10 (arbitrary number, no real meaning)
%we just need a number other an 1 or 0 so we can tell the difference from
%the lines we detected in the last step from what we are about to do in the
%next step.
label = 10-label;
%label(label==1) = 0;
%apply the inner, smaller mask 
label(mask.inner==0) = 0;
%convert all 10s that are inside the unmasked area, this will leave use
%with just the lines we detected earlier, but most importantly, they will
%be single curves and not connected curves like before. 
label(label==10) = 0;

%label everything again so we can begin processing
label = bwlabel(label);

%h = imdistline;

S4 = regionprops(label,'Area');

%clear a variable
clearvars circles;
sumX = 0;
sumY = 0;
nextObj = 0;

hold on
numObj = numel(S4);
for obj = 1 : numObj
    
    if(S4(obj).Area >= smallestAreaAllowed)
        %create lines array that stores every point on each line detected
        [y, x] = find(label==obj);
        lines(obj).points = [x, y];

        maxPoints = S4(obj).Area;

        %get end point
        x1 = lines(obj).points(1, 1);
        y1 = lines(obj).points(1, 2);

        %get midpoint
        midPoint = round(maxPoints / 2);
        x2 = lines(obj).points(midPoint, 1);
        y2 = lines(obj).points(midPoint, 2);

        %get other end point
        x3 = lines(obj).points(maxPoints, 1);
        y3 = lines(obj).points(maxPoints, 2);

        %plot all lines

        lineOneProp = getLineProperties([x1 y1], [x2 y2]);
        lineTwoProp = getLineProperties([x2 y2], [x3 y3]);
        %[~, yIntercept1, xIntercept1, slopePerp1, midPointAB] = getLineProperties(x1, y1, x2, y2);
        %[~, yIntercept2, xIntercept2, slopePerp2, midPointBC] = getLineProperties(x2, y2, x3, y3);
        
        %if the two lines never intersect, break this loop to avoid running
        %the formulas below which will break the script
        if(abs(lineOneProp.yIntercept) == Inf)
            break; 
        end
        if(abs(lineTwoProp.yIntercept) == Inf)
            break; 
        end
        if(abs(lineOneProp.xIntercept) == Inf)
            break; 
        end
        if(abs(lineTwoProp.xIntercept) == Inf)
            break; 
        end
        
        %plot lines for visual
        %plot line between AB and BC
        if(plotPoints == 1)
            plot([x1 x2],[y1 y2]);
            plot([x2 x3],[y2 y3]);
            %plot lines perpendicular to the midpoint of AB and BC
            plot([lineOneProp.midPoint(1) lineOneProp.xIntercept],[lineOneProp.midPoint(2) 0]);
            plot([lineTwoProp.midPoint(1) lineTwoProp.xIntercept],[lineTwoProp.midPoint(2) 0]);
        end

        %find where the two lines intersect, this is the center of the circle
        %http://en.wikipedia.org/wiki/Line-line_intersection
        %look at the section on wikipedia called 'X and Y values of intersection on a linear
        %curve' and use that equation
        circleCenterX = ((lineTwoProp.yIntercept - lineOneProp.yIntercept) / (lineOneProp.inverseSlope - lineTwoProp.inverseSlope));
        %old solution, works but slower
        %syms x;
        %circleCenterX = solve(slopePerp1*x + yIntercept1 == slopePerp2*x + yIntercept2, x); 
        %circleCenterX = double(circleCenterX); %convert the matlab sym into a number
        
        
        circleCenterY = lineOneProp.inverseSlope * circleCenterX + lineOneProp.yIntercept;

        %store in array
        nextObj = nextObj + 1;
        objectCenters.centers(nextObj, 1) = circleCenterX;
        objectCenters.centers(nextObj, 2) = circleCenterY;

        sumX = sumX + circleCenterX;
        sumY = sumY + circleCenterY;
    end
    
    %limit the number of objects (circles) processed and compared in the process of finding the averaged center
    if(nextObj >= numberOfObjects)
        break;
    end
end
hold off

if(nextObj >= 1)
    %determine average cirlce center
    objectCenters.averageCenter(1, 1) = (sumX / nextObj);
    objectCenters.averageCenter(1, 2) = (sumY / nextObj);
end

if(exist('objectCenters', 'var') == 0)
    objectCenters.centers = [];
    objectCenters.averageCenter = [];
end

end
