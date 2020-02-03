tlines=jiayi_getMatrix2('pts.txt');
tlines_prime=jiayi_getMatrix3('pts_prime.txt');

[U S V] = svd(tlines);
r = length(find(diag(S)));
Uhat = U(:,1:r);
Shat = S(1:r,1:r);

Uhat;
Shat;
V

z = Shat\Uhat'*tlines_prime;
c= V*z;

size(tlines)
size(tlines_prime)
c
% g=jiayi_getMatrix(1)

p1=[-0.791073 1.236363 3.874665];
p1=[p1,0,0,0,0,0,0,1,0,0;,0,0,0,p1,0,0,0,0,1,0;,0,0,0,0,0,0,p1,0,0,1];
size(p1)
size(c)
ans=(p1)*c

R=[c(1),c(2),c(3);c(4),c(5),c(6);c(7),c(8),c(9)]
det(R)