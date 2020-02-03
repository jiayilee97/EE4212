echo off
clear all
home
echo on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Computer Vision (& Image Processing) with Matlab  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
%% Read in an image 
%
im1 = imread('flowers.tif');  %% Give full path name in the string

pause

%
%% Note that the image is class UINT8 rather than normal DOUBLEs
%  we've dealt with so far.
%

class(im1)

pause;

%
%% Get the size of the image
%
imSize = size(im1)
		      
pause;  
home;

%
%% Display the image with imshow
%%
%% (Check out 'imagesc' as well)
%
imshow(im1);  %% SEE 'help imshow'

pause

%
%% Convert the rgb image to a grayscale image 
%% NOTE: See other conversions under 'images' toolbox, 'help images'
%
grIm1 = rgb2gray(im1);

pause;
home;

%
%% Display as another image in a new figure
%
figure(2), imshow(grIm1);  %% NOTE: See 'help figure' for more options
                           %% on figure handles

pause;
home;

%
%% Close the second figure and display both images
%% in one figure using subplot
%
%  - subplot(rows, cols, current)
%
close(2)
figure(1)
subplot(1,2,1) % 'subplot 121' is also legal syntax
imshow(im1)
subplot 122, imshow(grIm1);

pause
home


%
%% Want to see the histogram of the image
%

clf % clear the current figure
imhist(grIm1);

pause;
home;

%
%% Threshold the image at a given level
%
thresh = 100;

pause;

%
% First, the wrong way to do this using loops (bad programming style in Matlab)
%
% [rows, cols] = size(grIm1);
%
% tIm1 = grIm1;
%
% for i = 1:rows, %%  for i = 1:1:rows (increments can be negative too)
%   for j = 1:cols,
%     if (grIm1(i,j)<=thresh),
%       tIm1(i,j) = 0;
%     end
%   end
% end
%
pause

echo off
disp('Working...')
[rows, cols] = size(grIm1);

tIm1 = grIm1;

for i = 1:rows, %%  for i = 1:1:rows (increments can be negative too)
  for j = 1:cols,
    if (grIm1(i,j)<=thresh),
      tIm1(i,j) = 0;
    end
  end
end
echo on

pause;

%
%% Display the thresholded image
%
imshow(tIm1);

pause;

clear tIm1;

home;

%
%% Second method of doing thresholding: Using matrix computations
%
tIm1 = grIm1;

index = find(grIm1<=thresh);  %% SEE 'help find'

pause;

tIm1(index) =  0;

pause;

imshow(tIm1);

pause;

clear tIm1;

home;

%%%%%% Third method of doing thresholding: Composite statement
%
% tImage = (grIm1>thresh) .* (grIm1); %% use of pointwise
%                                     % multiplication 
pause;

%
%%MAJOR PAIN 1: The arithmetic operations are not defined over uint8
% variables so first convert them into double
%

tIm1 = double(grIm1>thresh).*double(grIm1);  

pause;

%
%% Again display the image
%
imshow(tIm1);

%
% Oops!! Doesn't look like earlier thresholded images... 
% WHAT happened !!
%
pause;

%
% MAJOR PAIN 2: The image display assumes the doubles in an image to be
% between 0 and 1. If it is not, it chops the intensities outside
% this range... (This causes bigger problems with 'imagesc') 
%
% So, try casting the result to unit8 before displaying
%
tIm1 = uint8(tIm1);

pause;

imshow( tIm1 );

pause;
home;

%
%% Let's save our thresholded image in a file
%
imwrite(tIm1, 'threshImage.jpg');  %% Saved as 'jpg'

pause;
home;

%
%% I want to see the saved image without explicitly using imread
%
imshow('threshImage.jpg');

pause;
home;

%
% A very useful function: fspecial
%
% Make a gaussian:
%
gaussFilt = fspecial('gaussian',31,4); % SEE 'help fspecial' 

pause;

%
% Display it as a 3D surface:
%
surf(gaussFilt);  %% SEE 'help surf' or 'mesh'

pause;
home;


%
%% Want to convolve the gray level image with the gaussian 
%  'imfilter' performs 2D convolution and has nice 
%  boundary condition handling.
%
convIm = imfilter(grIm1, gaussFilt, 'symmetric'); 

pause;

%
% Now, show everything together on one plot, with titles:
%
subplot 131, imshow(grIm1); title('Grayscale Image')
subplot 132, surf(gaussFilt); title('Gaussian Filter')
subplot 133, imshow(convIm); title('Gaussian Filtered Image')

pause;
home

%
%% "Printing" the figure to a jpeg image
%
%  arguments: figure 1, jpeg quality 90, 150dpi resolution, filename
%
% print(1, '-djpeg90', '-r150', 'convolution.jpg');

pause;
home;

%
%% Displaying plots on top of images using 'hold'
%

clf
imshow(grIm1)
hold on
x_pts = cols*rand(1,100);
y_pts = rows*rand(1,100);
plot(x_pts, y_pts, 'rx', 'MarkerSize', 16)
hold off

pause
home;


%
%% Select a subimage, both in color and grayscale:
%
subIm=grIm1(100:225,50:175);
subIm_col = im1(100:225,50:175,:);  % note the extra ':'

pause;

subplot 121, imshow(subIm);
subplot 122, imshow(subIm_col);

pause;
home;

%
% Want to see the intensity plot of a single row in the Image
%
line = subIm(100, :);

pause;

clf
plot(line); %% SEE 'help plot' and 'help plot3'

pause;
home;


%
%%%%%%% MAJOR PAIN 3: THE COORDINATE SYSTEM IN MATLAB (X,Y)
%
%% X - Column,  Y - Row
%
%  View pixel information with 'pixval'

imshow(grIm1);
axis on
pixval;  

pause 
home;

%
%% Getting coordinates or image values
%
%  - 'ginput' gets coordinates selected with the mouse - IN X/Y!!
%  - 'impixel' can return values and/or coordinates (in ROW/COL)
%    using the mouse or for specified locations
%

[x,y] = ginput(1)

pause

[c, r, val] = impixel(grIm1)


%
%% A few more things:
%
%   - Another image display command you might want to try: 'imagesc'
%   - Image axes
%   - Grids
%   - Colormaps
%   - the Figure toolbar
%

clf
imagesc(grIm1)

pause

axis image

pause

grid on

pause

colormap('default')

pause;
home;

