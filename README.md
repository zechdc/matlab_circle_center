Navigation
============
- [Overview](#files)
- [How it Works](#files)
	- [Scenario](#files)
	- [Final Results](#files)
	- [Environment Constraints](#files)
	- [Step By Step Tutorial](#files)
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
The we convert the image we are going to process to binary. This happens in the findCenters.m script.

Our output would look something like this:
![Binary Image](https://github.com/zechdc/matlab_circle_center/blob/master/stepsExample/innerMask.JPG?raw=true)

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
