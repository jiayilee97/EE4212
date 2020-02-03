imgs=dir('time-lapse_video/*.png');
imgs3=dir('time-lapse_video/*.png');

imgs(1).name;
imgs(150).name;
%imgs(151).name
imgs4=strings(150,1);
%length(imgs3)
size(imgs4);
I_flat=[];

for idx=1:150
    %imgs4(idx)=imgs(idx).name;
    imgs(idx).name;
    idx;
    imgs4(idx)=['time-lapse_video/' imgs(idx).name];

    
    I=imread(char(imgs4(idx)));
    if idx==1
        I_flat=reshape(I,[],1);
    else
        I_flat=[I_flat reshape(I,[],1)];
    end
    %I_flat(idx)=reshape(I,[],1);
    
end

I_mean=mean(I_flat,2);
I_mean=repmat(I_mean,[1 150]);
class(uint8(I_mean(1,1)))
class(I_flat(1,1))

I_norm=double(I_flat)-I_mean;
% I_norm=int16(I_norm);
% I_norm=single(I_norm);
size(I_flat)
%disp(imgs4);

size(I_norm)
I_norm;

%SVD
[U S V]=svd(I_norm);
Sk=S(1:K,1:K);
Uk=U(:,1:K);
Vk=V(:,1:K);
Imk=Uk*Sk*Vk';


%%MISCELLANEOUS
%a = [1 2 3 4;5 6 7 8]'
%a(end)
%repmat(a, [2 10])
%reshape(a,2,4)
%a = [1 2 3 4;5 6 7 8]
%reshape(a,1,[])

