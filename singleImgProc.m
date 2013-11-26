%%CONFIG
drawImage = 1; %show the image live with dots and lines to show what is being calculated
drawMask = 1; %draws the inner mask on your output image, only works if drawImage = 1
drawPoints = 1; %draw the points detected and the lines connecting them, drawImage must = 1

%the size of the circle to draw once found
radii = 10;

%set these vars to the name of some image files you have imported to matlab
%as vars. In this case, a3 is a var setup in matlab for an image I
%imported. 
image = a3;
imageMask = a1;

%% CODE

image = rgb2gray(image);
imageMask = rgb2gray(imageMask);

[imageMask] = createMask(imageMask, 10, 10, 100);
figure;

%draw the image on screen
if(drawImage == 1)
    imshow(image);

    if(drawMask == 1)
        hold on
        viscircles(imageMask.centroid, imageMask.radius,'EdgeColor','y');
        hold off
    end
end

%set the center of the image. This is used as an additional way to
%calibrate the score, camera, and laser. You can change where the "center" of
%the camera image is by adjusting these values.
% [x, y]
imageCenter = imageMask.centroid;
if(drawImage == 1)
    viscircles(imageCenter, 5,'EdgeColor','r');
end

%find circles (the target) in the image and draw a circle around it
numOfCirlces = 1;
smallestAreaAllowed = 90;
imageThreshold = 100;
objectCenters = findCenters(image, imageMask, numOfCirlces, smallestAreaAllowed, imageThreshold, drawPoints);

if(drawImage == 1)
    %draw circle found on screen
    viscircles(objectCenters.averageCenter, radii,'EdgeColor','b');
end