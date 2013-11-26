%%CONFIG
playSound = 1; %play sounds based on your distance from the center of a circle
drawImage = 1; %show the image live with dots and lines to show what is being calculated
drawMask = 1; %draws the inner mask on your output image, only works if drawImage = 1
drawPoints = 1; %draw the points detected and the lines connecting them, drawImage must = 1

cameraFocus = 18; %manually adjust based on your distance
cameraBrightness = 30; %manually adjust based on your lighting sitation
%cameraExposure = -6;  %manually adjust based on your lighting sitation

%adjust your video input device
vid = videoinput('winvideo', 1, 'MJPG_1280x720');

%the size of the circle to draw once found
radii = 10;

%% END OF CONFIG
%%

if(drawImage ~= 1)
    drawMask = 0;
    drawPoints = 0;
end
% Create video input object.

%properties for camera
src = getselectedsource(vid);
src.Brightness = cameraBrightness;
src.FocusMode = 'manual';
src.Focus = cameraFocus;
%src.ExposureMode = 'manual';
%src.Exposure = cameraExposure;
 
%number of frames to get each time the camera is triggered
vid.FramesPerTrigger = 1;
 
%return grayscale for one less thing to process
vid.ReturnedColorspace = 'grayscale';
 
%make the trigger type manual. This allows use to grab one frame at a time
triggerconfig(vid, 'manual');
 
% allow us to capture unlimited frames, with only starting the video once
vid.TriggerRepeat = Inf;

% Start acquiring frames.
start(vid);

%get user input to take ImageMask
preview(vid);
prompt = 'Calibrate camera: Make sure only white is visible, then press ENTER.';
str = input(prompt,'s');
%after enter is pressed, get image and set ImageMask var
trigger(vid);
imageMask = getdata(vid);
[imageMask] = createMask(imageMask, 3, 1, 100);
stoppreview(vid);
closepreview(vid);
 
while(true)
   
    trigger(vid);
   
    %get a single image frame
    image = getdata(vid);
       
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

    %make sure a circle on screen was found
    if(objectCenters.averageCenter)
        
        if(drawImage == 1)
            %draw circle found on screen
            viscircles(objectCenters.averageCenter, radii,'EdgeColor','b');
        end
   
        %calculate distance from center of the image and the center of the circle
        %x minus x; y minus y; then calc hypotenuse
        circleCenterX = objectCenters.averageCenter(1,1);
        circleCenterY = objectCenters.averageCenter(1,2);
 
        imageCenterX = imageCenter(1,1);
        imageCenterY = imageCenter(1,2);
 
        %calculate the di
        distanceX = circleCenterX - imageCenterX;  
        distanceY = circleCenterY - imageCenterY;
 
        %calculate the hypotenuse (b^2 + b^2 = c^2)
        hypotenuse = sqrt(distanceX^2 + distanceY^2);
        
        if(playSound == 1)
            inverseHy = 300-hypotenuse; %inverse so the sound is inverted
            lengthOfNote = 0.05; %seconds
            %create sound based on distance from the center of the image
            note=sin(2*pi*inverseHy*(0:0.000125:lengthOfNote));
            sound(note);

            %if you are X number of pixel from the center make a different beeping noise
            if(hypotenuse <= 15)

                note=sin(2*pi*500*(0:0.000125:lengthOfNote));
          
                sound(note);
                sound(note);
                sound(note);
            end
        end
 
        %show a measuring line to verfiy results
        %h = imdistline;
    end
   
    %clear memory after each frame to avoid memory leak
    flushdata(vid, 'triggers');
 
end

%%
%doesn't get run, but you can use these commands to clean up before running the
%script again
clear; %deletes all matlab variables
clc; %clears matlab console screen
imaqreset; %clears camera object
%h = imdistline(); %helpful for verifing results. 