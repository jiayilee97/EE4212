function [outIm, offset] = patchmatch(imAname, imBname)
patchSize=17;
imA = im2double(imread(imAname));
imB = im2double(imread(imBname));

height = size(imA, 1);
width = size(imA, 2);

padx = (patchSize - 1) / 2;

imA = padarray(imA, [padx padx], 0, 'both');
imB = padarray(imB, [padx padx], 0, 'both');
outIm = zeros(height + 2 * padx, width + 2 * padx, 3);

initRow = randi(height, height, width);
initCol = randi(width, height, width);
offset = zeros(height, width, 3);
for i = 1 : height
    for j = 1 : width
        offset(i, j, 1) = initRow(i, j) - i;
        offset(i, j, 2) = initCol(i, j) - j;
    end
end

offset = padarray(offset, [padx padx], 0, 'both');
for i = padx + 1 : height + padx
    for j = padx + 1 : width + padx
        offset(i, j, 3) = loss(imA(i - padx : i + padx, j - padx : j + padx), ...
            imB(offset(i, j, 1) + i - padx : offset(i, j, 1) + i + padx, ...
            offset(i, j, 2) + j - padx : offset(i, j, 2) + j + padx));
    end
end



for k = 1 : 5
    pix_motion = 0;
    if mod(k, 2) == 1
        for i = padx + 1 : height + padx
            for j = padx + 1 : width + padx
                shifted = 0;

%                 disp([i, j, offset(i - 1, j, 1), offset(i - 1, j, 2)]);
                if offset(i - 1, j, 1) + i > padx && offset(i - 1, j, 1) + i <= padx + height ...
                        && offset(i - 1, j, 2) + j > padx && offset(i - 1, j, 2) + j <= padx + width
                    dist = loss(imA(i - padx : i + padx, j - padx : j + padx), ...
                        imB(offset(i - 1, j, 1) + i - padx : offset(i - 1, j, 1) + i + padx, ...
                        offset(i - 1, j, 2) + j - padx : offset(i - 1, j , 2) + j + padx));
                    if dist < offset(i, j, 3)
                        offset(i, j, 1 : 2) = offset(i - 1, j, 1 : 2);
                        offset(i, j, 3) = dist;
                        shifted = 1;
                    end
                end
                
                if offset(i, j - 1, 1) + i > padx && offset(i, j - 1, 1) + i <= padx + height ...
                        && offset(i, j - 1, 2) + j > padx && offset(i, j - 1, 2) + j <= padx + width
                    dist = loss(imA(i - padx : i + padx, j - padx : j + padx), ...
                        imB(offset(i, j - 1, 1) + i - padx : offset(i, j - 1, 1) + i + padx, ...
                        offset(i, j - 1, 2) + j - padx : offset(i, j - 1, 2) + j + padx));
                    if dist < offset(i, j, 3)
                        offset(i, j, 1 : 2) = offset(i, j - 1, 1 : 2);
                        offset(i, j, 3) = dist;
                        shifted = 1;
                    end
                end
                
                pix_motion = pix_motion + shifted;
            end
        end
    
    else
        for i = height + padx : -1 : height + 1
            for j = width + padx : -1 : width + 1
                shifted = 0;
                
                if offset(i + 1, j, 1) + i > padx && offset(i + 1, j, 1) + i <= padx + height ...
                        && offset(i + 1, j, 2) + j > padx && offset(i + 1, j, 2) + j <= padx + width
                    dist = loss(imA(i - padx : i + padx, j - padx : j + padx), ...
                        imB(offset(i + 1, j, 1) + i - padx : offset(i + 1, j, 1) + i + padx, ...
                        offset(i + 1, j, 2) + j - padx : offset(i + 1, j, 2) + j + padx));
                    if dist < offset(i, j, 3)
                        offset(i, j, 1 : 2) = offset(i + 1, j, 1 : 2);
                        offset(i, j, 3) = dist;
                        shifted = 1;
                    end
                end
                
                if offset(i, j + 1, 1) + i > padx && offset(i, j + 1, 1) + i <= padx + height ...
                        && offset(i, j + 1, 2) + j > padx && offset(i, j + 1, 2) + j <= padx + width
                    dist = loss(imA(i - padx : i + padx, j - padx : j + padx), ...
                        imB(offset(i, j + 1, 1) + i - padx : offset(i, j + 1, 1) + i + padx, ...
                        offset(i, j + 1, 2) + j - padx : offset(i, j + 1, 2) + j + padx));
                    if dist < offset(i, j, 3)
                        offset(i, j, 1 : 2) = offset(i, j + 1, 1 : 2);
                        offset(i, j, 3) = dist;
                        shifted = 1;
                    end
                end
                
                pix_motion = pix_motion + shifted;
            end
        end
    end
end

for i = padx + 1 : padx + height
    for j = padx + 1 : padx + width
        outIm(i, j, :) = imB(offset(i, j, 1) + i, offset(i, j, 2) + j, :);
    end
end

offset(:, :, 3) = 0;
for i = padx + 1 : padx + height
    for j = padx + 1 : padx + width
        offset(i, j, 1) = (offset(i, j, 1) + height) / height / 2;
        offset(i, j, 2) = (offset(i, j, 2) + width) / width / 2;
    end
end