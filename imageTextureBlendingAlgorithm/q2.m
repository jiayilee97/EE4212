[output, offset] = patchmatch('flowerA.jpg','flowerB.jpg')
%imwrite(output,'flowerX.jpg')
imwrite(offset,'offsetX2.jpg')