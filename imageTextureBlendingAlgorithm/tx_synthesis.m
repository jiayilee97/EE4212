function output = tx_synthesis(texturefile, height)
width=height;
sigma=0.5;
kernel_size=5;
texture = im2double(imread(texturefile));
size(texture)
tx_height = size(texture, 1);
tx_width = size(texture, 2);
channels = size(texture, 3);
if height <= size(texture, 1) || width <= size(texture, 2)
    throw(MException('myComponent:inputError', 'Texture dim > output dim'))
end

pad = (kernel_size - 1) / 2;
output = zeros(height + kernel_size - 1, width + kernel_size - 1, channels);
output(pad + 1 : tx_height + pad,  pad + 1 : tx_width + pad, :) = texture(:,:,:);

count_canvas_neighbors = zeros(height + kernel_size - 1, width + kernel_size - 1);

canvas = zeros(height + kernel_size - 1, width + kernel_size - 1);
canvas(pad + 1 : tx_height + pad, pad + 1 : tx_width + pad) = 1;

valid = zeros(height + kernel_size - 1, width + kernel_size - 1);
valid(pad + 1 : height + pad, pad + 1 : width + pad) = 1;

kernel = fspecial('gaussian', [kernel_size kernel_size], sigma);

for i = pad + 1 : pad + tx_height
    for j = pad + 1 : pad + tx_width
        for k = -pad : pad
            for l = -pad : pad
                r = i + k;
                c = j + l;
                if canvas(r, c) == 0 && valid(r,c) == 1
                    count_canvas_neighbors(r, c) = count_canvas_neighbors(r, c) + 1;
                end
            end
        end
    end
end

while true
    [row, rowidx] = max(count_canvas_neighbors, [], 2);
    [m, colidx] = max(row);
    row = colidx;
    col = rowidx(row);
    
    if m == 0
        break;
    end
    
    optdist = 1e9;
    optr = 0;
    optc = 0;
    
    masktmp = canvas(row - pad : row + pad, col - pad : col + pad);
    mask = [];
    for i = 1 : channels
        mask = cat(3, mask, masktmp);
    end
    
    for i = pad + 1 : tx_height + pad
        for j = pad + 1 : tx_width + pad            
            dist = output(i - pad : i + pad, j - pad : j + pad) - output(row - pad : row + pad, col - pad : col + pad);
            dist = sum(sum(sum(dist .^ 2 .* mask .* kernel)));
            
            if dist < optdist
                optdist = dist;
                optr = i;
                optc = j;
            end
        end
    end
    
    output(row, col, :) = output(optr, optc, :);
    canvas(row, col) = 1;
    for i = -pad: pad
        for j = -pad : pad
            if canvas(row + i, col + j) == 0 && valid(row + i, col + j) == 1
                count_canvas_neighbors(row + i, col + j) = count_canvas_neighbors(row + i, col + j) + 1;
            end
        end
    end
    count_canvas_neighbors(row, col) = 0;
end

