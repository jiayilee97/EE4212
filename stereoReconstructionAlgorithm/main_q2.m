I=im2double(imread('time-lapse_video/image001.png'));
[U S V]=svd(I);
%plot(diag(S),'b');
K=40;
Sk=S(1:K,1:K);
Uk=U(:,1:K);
Vk=V(:,1:K);
Imk=Uk*Sk*Vk';
imshow(Imk);
