
for (idx=10:11)
    idx=num2str(idx)
    %disp('doing'+idx);
    imname=strcat('texture', idx ,'.jpg');
    outimg=tx_synthesis(imname,134);
    size(outimg)
    imname=strcat('texture', idx ,'_syn.jpg');
    imwrite(outimg,imname)
end
% imshow(outimg)
%imwrite(outimg,'texture3_syn.jpg')