Navigation
============
- [Overview](#overview)
- [How it Works](#how-it-works)
	- [Scenario](#scenario)
	- [Final Results](#final-result)
	- [Environment Constraints](#environment-constraints)
	- [Step By Step Tutorial](#step-by-step-tutorial)
- [Files](#files)

Overview
====================
This matlab script uses a live feed from a webcam to find the center of a target, then determine the distance from the target and play an audio tone that increases in frequency based on the distance from the center. The original purpose of this project was to make a rifle that blind people could use. It was designed as a class project at FHV - Fachhochschule Vorarlberg. It works in a very constrained environment as is described below. 

How it works
====================
I'll start with the scenario and show you the final results. Then I will go into detail about how the script works to achieve these results. 

Scenario
----------
I needed to programmatically find the center of a circle while only seeing the outer edge of the circle. I used matlab to prototype the idea.

This was a class project. We finished the project using matlabs imfindcircles() function, but it was to slow. It took about 2-3 seconds to process a single image. Also, once we placed the webcam behind a rifle scope, imfindcircles() could not see enough of the circle to find it accurately. I wanted to improve my programs speed. The initial assignment was to create a rifle that blind people could use.

Below is a test image:
![Initial Test Image](https://github.com/zechdc/matlab_circle_center/blob/master/testImages/a3.jpg?raw=true "Initial Test Image")

The black around the outer edge is there because the webcamera was placed behind a rifle scope. The black half circles are actually a target, so there are multiple rings nested inside each other.

Here are some related posts I made on stackoverflow to help solve this issue:
- [How do I find the center of a circle while only seeing outer edge? - Includes imfindcircles() original script.][1]
- [How do I find/predict the center of a circle while only seeing the outer edge? - Includes different mathematical approches to the problem.][2]

Final Result
-----------
Here is a static image of what the script would output. 
![Final Static Image][3]
- The **yellow circle** shows the area that is visible after the mask is applied. 
- Two **blue lines** show the lines being drawn between three points on the circles curve. 
- Two more **blue lines** show the perpendiculars of the lines on the curve. 
- The **blue circle** is the predicted center based on the intersect of the perpendicular lines.
- The **red dot** is the center of the mask, or rifle scope. This is used in calculating the distance from the center of the scope to the predicted circle center. 

Here is a video of the final result (click to go to youtube.com)

<a href="http://www.youtube.com/watch?feature=player_embedded&v=Ou_MzYFBXx0
" target="_blank"><img src="https://github.com/zechdc/matlab_circle_center/blob/master/stepsExample/hardware.JPG?raw=true" 
alt="Rifle for the Blind" width="240" height="180" border="10" /></a>

Environment Constraints
-----------
There are a number of constraints we had to set in order to complete the project on time.

	1. Target must be on a white background
	2. Target must only be black and white continuous rings, no text or lines breaking up the rings
	3. The lighting on the target must be at a constant level 
	4. The distance from the target must be at a contstant distance during testing

These contraints are relfected in the script through setting such as cameraBrightness and cameraFocus. 

Step By Step Tutorial
-----------

### 1) Generate Mask
First we need to generate an image mask that can be applied to all future images we capture. For this we use the 'createMask.m' script included in this repository. It will generate three masks.

- One mask that is just a binary image of the image passed in (called 'noErosion')
![No Erosion Mask](https://github.com/zechdc/matlab_circle_center/blob/master/stepsExample/noErosion.JPG?raw=true)

- One mask that has been eroded so it is smaller than the original mask and fills in any small pixels areas (called 'outer')
![Outer Mask](https://github.com/zechdc/matlab_circle_center/blob/master/stepsExample/outerMask.JPG?raw=true)

- One mask that has been eroded slight more than the 'outer' mask. This is applied to a picture of edges to cut off the outside edge. Hopefully this will make sense later. 
![Inner Mask](https://github.com/zechdc/matlab_circle_center/blob/master/stepsExample/innerMask.JPG?raw=true)

### 2) Convert to Binary
Then we convert the image we are going to process to binary. This happens in the findCenters.m script.

Our output would look something like this:
![Binary Image](https://github.com/zechdc/matlab_circle_center/blob/master/stepsExample/imgToBinary.JPG?raw=true)

### 3) Apply Mask and Invert
Then we apply the 'outer' mask that we generated in step 1 to the image we are going to process with this code:

    % apply the mask
    img(mask.outer==0) = 1;

This sets all 0s found in the outer mask to 1s. It does this to the 'img' variable, which is the binary image we created in step 2. This means that every zero found in the mask image will be set to 1 in the image to process. 

After that we invert the image with this code, changing all 0s to 1s and 1s to 0s
    
    img=1-img;

The output should look like this:
![Mask Applied](https://github.com/zechdc/matlab_circle_center/blob/master/stepsExample/object.JPG?raw=true)

### 4) Find edges
Then we find the edges with this code:

    img = edge(img);

It should output this:
![Edge Found](https://github.com/zechdc/matlab_circle_center/blob/master/stepsExample/oneline.JPG?raw=true)

### 5) Remove Edge Against Mask Edge
The next step is used to break this solid line into two separate curves. This is where our 'inner' mask comes into play. 

5.1) First we set every pixel to a value other than 1 or 0 so we don't loose the line we currently have while we are applying another mask. 

    img = 10-img;

5.2) Then we apply the 'inner' mask to our new image

    img(mask.inner==0) = 0;

5.3) Then we convert all the 10s created in step 5.1 back to 0s

    img(img==10) = 0;

The output should look like this:
![Lines Found](https://github.com/zechdc/matlab_circle_center/blob/master/stepsExample/lines.JPG?raw=true)


### 6) Apply Labels
We apply a label to our newly found lines so we know the difference between them.
    
    label = bwlabel(img);

### 7) Detect Point On Line
We use this code in a loop, which can be see in the 'findCenters.m' file around line 80:

    %create lines array that stores every point on each line detected
    [y, x] = find(label==obj);
    lines(obj).points = [x, y];

### 8) Select Three Points
Select three points on each line and plug them into the 'getLineProperties.m' function provided in this script. 

See lines 80 - 96 of 'findCenters.m' file for an example of how to select three points on the line.

After getting the line properties you can plot them to get this:
![Lines Plotted](https://github.com/zechdc/matlab_circle_center/blob/master/stepsExample/Capture.JPG?raw=true)

### 9) Finished
I tried to comment the code very well, for more information about how it works open up the scripts and read through them.

If you plot these lines on your image being processed you will get:
![Final](https://github.com/zechdc/matlab_circle_center/blob/master/stepsExample/final.JPG?raw=true)





Files
====================
Instructions on how to use each file have been included at the top of each file.

- **getLineProperties.m** - this is a simple file that accepts two [x y] points and calculates common line properties like slope, x and y intercept, and inverse slope. This could easily be used for other projects where you need the details of a line based on two points in matlab. 
- **findCenters.m** - takes an image and the mask images generated by 'createMask.m'. It uses the mask to black out parts of the image that we don't want to process. It then finds all objects, then find the objects lines, finally it uses the 'getLineProperties.m' function to get properties of each line found. 
- **createMask.m** - This file takes an image, converts it to a binary image, erodes the image a few times, then returns an array of these binary images it created. Not very useful outside of this script. 
- **videoImgProc.m** - this is the script to run if you want to process a live feed of video in matlab, find the center of the target, and output an audio tone based on distance
- **singleImgProc.m** - this is a simplification of the videoImgProc.m script used for testing. You must give it a single mask image and image to process. Then it will calculate the details and draw the predicted center on the image.
- **/testImages** - this folder contains some images I used to test my script. You can import these images into your matlab session, then change the 'image' and 'maskImage' variable names in the singleImgProce.m script to see how each set of images is processed. a1.jpg and z1.jpg are the images used to create a binary mask. All other images are images to be processed once you have the mask setup. 

[1]: http://stackoverflow.com/questions/20099259/how-do-i-find-the-center-of-a-circle-while-only-seeing-outer-edge
[2]: http://math.stackexchange.com/questions/574812/how-do-i-find-predict-the-center-of-a-circle-while-only-seeing-the-outer-edge
[3]: https://github.com/zechdc/matlab_circle_center/blob/master/stepsExample/final.JPG?raw=true
