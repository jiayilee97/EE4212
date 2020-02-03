function F=estimateF(x1,x2);
set1=x1';
set2=x2';
set1_mean=mean(set1,1)
set1_mean=repmat(set1_mean,[8 1]);
set1_norm=set1-set1_mean;
std1=std(set1_norm,1)
T1=[1/std1(1,1) 0 -set1_mean(1,1)/std1(1,1); 0 1/std1(1,2) -set1_mean(1,2)/std1(1,2); 0 0 1] ;


set2_mean=mean(set2,1);
set2_mean=repmat(set2_mean,[8 1]);
set2_norm=set2-set2_mean;
std2=std(set2_norm,1);
T2=[1/std2(1,1) 0 -set2_mean(1,1)/std2(1,1); 0 1/std2(1,2) -set2_mean(1,2)/std2(1,2); 0 0 1] ;

set1=[set1 repmat(1, [8 1])];
set2=[set2 repmat(1, [8 1])];

set1_ready=T1*set1'
set2_ready=T2*set2'
T1
T2
T1_inv=inv(T1)
T2_inv=inv(T2)
set1_ready
set2_ready
mean(abs(set1_ready),2)
mean(set1_ready,2)
std(set1_ready')

A=zeros(8,9);

for idx=1:8
    x1=set1_ready(1,idx);
    y1=set1_ready(2,idx);
    x2=set2_ready(1,idx);
    y2=set2_ready(2,idx);
    A(idx,:)=[x2*x1 x2*y1 x2 y2*x1 y2*y1 y2 x1 y1 1];
end

[U S V]=svd(A) %rank=7, first two singular values are 6.0532 and 4.7350; two smallest singular values are 0.7588 and 0.0418
diag(S)
f=V(:,end) 
U*S*V'
size(S)
size(diag([6.0532,4.7350,0,0,0,0,0,0,0]))
S2=diag([6.0532,4.7350,0]) 
size(S2)
Uk=U(6:8,6:8)
Vk=V(6:8,6:8)
F2=Uk*S2*Vk'
size(F2)
size(T2)
size(T1)
F_denorm=T2'*F2*T1
F=F_denorm
end