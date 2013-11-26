% erode a binary image to make it better at detecting only the real parts and not
% accidentally an edge of the scope. And to fill any holes in the mask.
%
% USAGE: 
%       createMask(image, outerErosion, innerErosion, imageThreshold)
%       image = Simply pass in an image. This will be converted to a binary image
%           and shrunk to a few different sizes to make comparison easier.
%       outerErosion = amount of erosion to perform to the image. Higher
%           value means more erosion (must be an integer)
%       innerErosion = amount of erosion to perform to the outerEroded image. Higher
%           value means more erosion (must be an integer)
%       imageThreshold = used in creating the binary image. Might need to
%           adjust for better results depending on your image contrast. 
%           used in: image = img > imageThreshold#
% RETURN:
%       returns a mask object that stores properties of the mask image
%       
%       mask.noErosion = this is a simple binary image of the image that
%           was passed in, no errsion has been done to this image
%       mask.outer = this is a binary image of the image passed in with
%           minor erosion.
%       mask.inner = this is a binary image of the image passed in with
%           minor erosion done to the mask.outer image.
%       mask.area = the area of the mask
%       mask.centroid = center of mask object
%       mask.radius = this is only useful if the mask object is a circle

function [mask] = createMask(imageMask, outerErosion, innerErosion, imageThreshold)
%% Create the mask

imageMask = imageMask > imageThreshold;
mask.noErosion = imageMask;
imshow(mask.noErosion);

%outerErosion Image
se = strel('disk',outerErosion);        
mask.outer = imerode(mask.noErosion,se);
figure, imshow(mask.outer);

%innerErosion Image
se = strel('disk',innerErosion);        
mask.inner = imerode(mask.outer,se);
figure, imshow(mask.inner);

%get basic properties of the mask
maskProperties = regionprops(mask.inner,'Area','Centroid');
mask.area = maskProperties.Area;
mask.centroid = maskProperties.Centroid;

%calculate radius r=sqrt(area/pi)
mask.radius = sqrt(mask.area/pi);

end