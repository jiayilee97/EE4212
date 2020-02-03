function norm_matrix=jiayi_getMatrix(txt);
x=zeros(200,200);
size(x);
fid=fopen(txt);
% tline=fgetl(fid);
% size(tline);
% %tlines = cell(3,1);
% tlines=tline;
% size(tline) == 27;
% b=size(tline);
% disp(b(1,1));
tline='initialise';
tlines=0;

while ischar(tline);
    tline=fgetl(fid);
    %disp(tline);
    size2=size(tline);
    %size2(1,2);
    
    
    if size2(1,2)>=20
        tmp=0;
        class(tline);
        elements=strsplit(tline,' ');
        %class(elements(1))
        %tmp=string(elements(1,1))
        %tmp=str2double(elements(1,1))
        elements=str2double(elements);
        tmp=[elements(1,1); elements(1,2)];
        tmp=[tmp; elements(1,3)];
        
        
        
        tmp2=[tmp; tmp];
        [tmp2;tmp];
        if tlines==0
            tlines=tmp;
        else
            tlines=[tlines;tmp];
            
        end
        
        %tlines
        %disp(size(tlines));
    end
    %tlines=[tlines;tline]
end

% size(tlines), class(tlines)

%tlines=[tlines;tline]
% size(tline);

% if size(tline)~=1 
%     disp("e");
% end

% tlines

% t1=[0 1 1; 2 3 2 ;0 1 1; 2 3 2];
% mean(t1,1)

%normalisation
centroid=mean(tlines,1);
length=(size(tlines));

for idx=1:length
    
    tlines(idx,:);
    norm1=tlines(idx,:)-centroid;
    norm1(4)=1;
    if idx ==1
       tlines_norm=norm1 ;
    else
        tlines_norm=[tlines_norm;norm1];
    end
end


%non-normalised
norm_matrix=tlines

%normalised
%norm_matrix=tlines_norm;

end

