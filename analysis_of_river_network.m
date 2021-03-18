% topological measures of the river network;
% input: connectivity matrix of the river network;
connectivity_matrix=dlmread('connectivity_matrix.txt');
[I,I]=size(connectivity_matrix);
sum_degree=0;
kmax=0;
data_degree=zeros(I,2);
for i=1:I
    ki=0;
    for j=1:I
        if connectivity_matrix(i,j)>0
            ki=ki+connectivity_matrix(i,j);
        end
    end
    data_degree(i,1)=ki;
    if ki>kmax
        kmax=ki;
    end
    sum_degree=sum_degree+ki;
end
ave_degree=sum_degree/I;
data_degree(1,2)=ave_degree;
%xlswrite(strcat('output_property_',int2str(year),'.xlsx'),data_degree,1)

% the average degree of neighbors
data_degree_neighbor=zeros(I,1);
ave_neighbordegree=0;
for i=1:I
    sum_degree_neighbor=0;
    for j=1:I
        if connectivity_matrix(i,j)>0
            sum_degree_neighbor=sum_degree_neighbor+data_degree(j,1);
        end
    end
    data_degree_neighbor(i,1)=sum_degree_neighbor/data_degree(i,1);
    ave_neighbordegree=ave_neighbordegree+sum_degree_neighbor/data_degree(i,1);
end
data_degree_neighbor(1,2)=ave_neighbordegree/I;
%xlswrite(strcat('output_property_',int2str(year),'.xlsx'),data_degree_neighbor,4);

% the lacal and global clustering coefficient
for x=1:I
    connectivity_matrix(x,x)=0;
end
triple=0;
triangle=0;
data_clustering_coefficient=zeros(I,2);
data_clustering_1=connectivity_matrix*connectivity_matrix*connectivity_matrix;
for i=1:I
    if data_degree(i,1)>1
    data_clustering_coefficient(i,1)=data_clustering_1(i,i)/2/nchoosek(data_degree(i,1),2);
     triple=triple+nchoosek(data_degree(i,1),2);
    end
    triangle=triangle+data_clustering_1(i,i);
end
data_clustering_coefficient(1,2)=triangle/triple;


% the characteristic path length of the river network;
data_distance=zeros(I,I);
data_path=zeros(I,I);
for i=1:I
    for j=1:I
        if connectivity_matrix(i,j)==0
            data_distance(i,j)=inf;
        else
            data_distance(i,j)=1;
        end
    end
end
for i=1:I
    data_distance(i,i)=0;
end
for i=1:I
    for j=1:I
        data_path(i,j)=j;
    end
end
for k=1:I
    for i=1:I
        for j=1:I
            if data_distance(i,k)+data_distance(k,j)<data_distance(i,j)
                data_distance(i,j)=data_distance(i,k)+data_distance(k,j);
                data_path(i,j)=data_path(i,k);
            end
        end
    end
end
sum_distance=0;
distance_distance=0;
a_distance=0;
for i=1:I
    for j=1:I
        if data_distance(i,j)==inf || data_distance(i,j)==0
            reciprocal_distance=0;
        else
            reciprocal_distance=1/data_distance(i,j);
            distance_distance=distance_distance+data_distance(i,j);
            a_distance=a_distance+1;
        end
        sum_distance=sum_distance+reciprocal_distance;
    end
end
reciprocal_l=1/(I*I)*sum_distance;
data_distance(I+1,1)=reciprocal_l;
data_distance(I+1,2)=distance_distance/a_distance;
dlmwrite('distance.txt',data_distance);
dlmwrite('path.txt',data_path);

% Centerline of the river network;
waterbody=imread('waterbody.tif');
[X,Y]=size(waterbody);
for x=2:X
    ymin=Y;
    ymax=0;
    for y=1:Y
        if waterbody(x,y)<100 && y<ymin
            ymin=y;
        end
        if waterbody(x,y)<100 && y>ymax
            ymax=y;
        end
    end
    if ~(ymax==0) && ~(ymin==Y)
        boundary_left(x,1)=ymin;
        boundary_right(x,1)=ymax;
        width(x,1)=ymax-ymin;
        center(x,1)=round((boundary_right(x,1)+boundary_left(x,1))/2);
    end
end
RGB=imread('I2.tif');
[X,Y]=size(center);
b=1;
for x=1:X-1
    if ~(center(x,1)==0)
    centernew(b,1)=x;
    centernew(b,2)=center(x,1);
    centernew(b,3)=1;
    b=b+1;
    if abs(center(x+1,1)-center(x,1))>1
        for a=1:abs(center(x+1,1)-center(x,1))-1
            centernew(b,1)=x;
            centernew(b,2)=center(x,1)+(center(x+1,1)-center(x,1))/abs(center(x+1,1)-center(x,1))*a;
            centernew(b,3)=2;
            b=b+1;
        end
    end
    end
end
[X,Y]=size(boundary_left);
for x=1:X
    if ~(boundary_left(x,1)==0) && ~(boundary_left(x,1)==Y) && ~(boundary_right(x,1)==0) && ~(boundary_right(x,1)==Y)
        RGB(x,boundary_left(x,1),1)=255;
        RGB(x,boundary_left(x,1),2)=0;
        RGB(x,boundary_left(x,1),3)=0;
        RGB(x,boundary_right(x,1),1)=255;
        RGB(x,boundary_right(x,1),2)=0;
        RGB(x,boundary_right(x,1),3)=0;
    end
end
[X,Y]=size(centernew);
for x=1:X
    if ~(centernew(x,2)==0) 
  RGB(centernew(x,1),centernew(x,2),1)=255;
  RGB(centernew(x,1),centernew(x,2),2)=255;
  RGB(centernew(x,1),centernew(x,2),3)=0;
    end
end
figure
imshow(RGB)
dlmwrite('centerline.txt',centernew)

% local topologiacal mesure distribution of the river network using a circle raster
data_RGB=imread('Indus_RGBband453_1.tif');
[X,Y,Z]=size(data_RGB);
for x=1:X
    for y=1:Y
             data_RGB(x,y,1)=255;
             data_RGB(x,y,2)=255;
             data_RGB(x,y,3)=255;
    end
end
data1=dlmread('centerline.txt');
[X,Y1]=size(data1);
data2=dlmread('data_node_measures.txt');
distance=0;
for x=1:X
    if x>1
        distance=distance+(((data1(x,1)-data1(x-1,1))^2+(data1(x,2)-data1(x-1,2))^2)^0.5)*30/1000;
    end
    if ~(data1(x,2)==0)
    degree=0;
    clu=0;
    nei=0;
    a=0;
    b=0;
    c=0;
    for i=1:I
    if ~(((data2(i,1)-data1(x,1))^2+(data2(i,2)-data1(x,2))^2)^0.5>150)
        if ~(data2(i,3)<0)
        degree=degree+data2(i,3);
        a=a+1;
        end
        if ~(data2(i,4)<0)
        clu=clu+data2(i,4);
        b=b+1;
        end
        if ~(data2(i,5)<0)
        nei=nei+data2(i,5);
        c=c+1;
        end
        data_degree(x,1)=degree/a;
        data_clu(x,1)=clu/b;
        data_nei(x,1)=nei/c;
        local_distribution1(x,1)=distance;
        local_distribution1(x,2)=data_degree(x,1);
        local_distribution1(x,3)=data_clu(x,1);
        local_distribution1(x,4)=data_nei(x,1);   
    end
    end    
    end
    local_distribution1(x,1)=distance;
end

% local topologiacal mesure distribution of the river network using a square raster
data_connectivity=dlmread('connectivity.txt');
data=dlmread('2009low.txt');
[N,N]=size(data_connectivity);
data_RGB=imread('Indus_RGBband453_1.tif');
d1=1200;
d2=900;
d3=600;
[X,Y]=size(data_RGB);
for x=1:X
    for y=1:Y
             data_RGB(x,y,1)=255;
             data_RGB(x,y,2)=255;
             data_RGB(x,y,3)=255;
    end
end
for x=50:X-50
    degree=0;
    clu=0;
    nei=0;
    a=0;
    b=0;
    c=0;
    for i=1:I
    if data(i,1)>x-25 && data(i,1)<x+25
        if ~(data(i,3)<0)
        degree=degree+data(i,3);
        a=a+1;
        end
        if ~(data(i,4)<0)
        clu=clu+data(i,4);
        b=b+1;
        end
        if ~(data(i,5)<0)
        nei=nei+data(i,5);
        c=c+1;
        end
        data_degree(x,1)=degree/a;
        data_clu(x,1)=clu/b;
        data_nei(x,1)=nei/c;
        for j=-100:100
            if ~(data_degree(x,1)>2)
                data_RGB(x,Y-d1+j,1)=0;
                data_RGB(x,Y-d1+j,2)=0;
                data_RGB(x,Y-d1+j,3)=0;
            end
            if data_degree(x,1)>2 && ~(data_degree(x,1)>2.15)
                data_RGB(x,Y-d1+j,1)=176;
                data_RGB(x,Y-d1+j,2)=224;
                data_RGB(x,Y-d1+j,3)=230;
            end
            if data_degree(x,1)>2.15 && ~(data_degree(x,1)>2.3)
                data_RGB(x,Y-d1+j,1)=65;
                data_RGB(x,Y-d1+j,2)=105;
                data_RGB(x,Y-d1+j,3)=225;
            end
            if data_degree(x,1)>2.3 && ~(data_degree(x,1)>2.45)
                data_RGB(x,Y-d1+j,1)=0;
                data_RGB(x,Y-d1+j,2)=0;
                data_RGB(x,Y-d1+j,3)=255;
            end
            if data_degree(x,1)>2.45 && ~(data_degree(x,1)>2.6)
                data_RGB(x,Y-d1+j,1)=124;
                data_RGB(x,Y-d1+j,2)=252;
                data_RGB(x,Y-d1+j,3)=0;
            end
            if data_degree(x,1)>2.6 && ~(data_degree(x,1)>2.75)
                data_RGB(x,Y-d1+j,1)=0;
                data_RGB(x,Y-d1+j,2)=255;
                data_RGB(x,Y-d1+j,3)=0;
            end
            if data_degree(x,1)>2.75 && ~(data_degree(x,1)>2.9)
                data_RGB(x,Y-d1+j,1)=0;
                data_RGB(x,Y-d1+j,2)=201;
                data_RGB(x,Y-d1+j,3)=87;
            end
            if data_degree(x,1)>2.9 && ~(data_degree(x,1)>3)
                data_RGB(x,Y-d1+j,1)=255;
                data_RGB(x,Y-d1+j,2)=97;
                data_RGB(x,Y-d1+j,3)=0;
            end
            if data_degree(x,1)>3
                data_RGB(x,Y-d1+j,1)=255;
                data_RGB(x,Y-d1+j,2)=0;
                data_RGB(x,Y-d1+j,3)=0;
            end
            if ~(data_nei(x,1)>2)
                data_RGB(x,Y-d2+j,1)=0;
                data_RGB(x,Y-d2+j,2)=0;
                data_RGB(x,Y-d2+j,3)=0;
            end
            if data_nei(x,1)>2 && ~(data_nei(x,1)>2.15)
                data_RGB(x,Y-d2+j,1)=176;
                data_RGB(x,Y-d2+j,2)=224;
                data_RGB(x,Y-d2+j,3)=230;
            end
            if data_nei(x,1)>2.15 && ~(data_nei(x,1)>2.3)
                data_RGB(x,Y-d2+j,1)=65;
                data_RGB(x,Y-d2+j,2)=105;
                data_RGB(x,Y-10+j,3)=225;
            end
            if data_nei(x,1)>2.3 && ~(data_nei(x,1)>2.45)
                data_RGB(x,Y-d2+j,1)=0;
                data_RGB(x,Y-d2+j,2)=0;
                data_RGB(x,Y-d2+j,3)=255;
            end
            if data_nei(x,1)>2.45 && ~(data_nei(x,1)>2.6)
                data_RGB(x,Y-d2+j,1)=124;
                data_RGB(x,Y-d2+j,2)=252;
                data_RGB(x,Y-d2+j,3)=0;
            end
            if data_nei(x,1)>2.6 && ~(data_nei(x,1)>2.75)
                data_RGB(x,Y-d2+j,1)=0;
                data_RGB(x,Y-d2+j,2)=255;
                data_RGB(x,Y-d2+j,3)=0;
            end
            if data_nei(x,1)>2.75 && ~(data_nei(x,1)>2.9)
                data_RGB(x,Y-d2+j,1)=0;
                data_RGB(x,Y-d2+j,2)=201;
                data_RGB(x,Y-d2+j,3)=87;
            end
            if data_nei(x,1)>2.9 && ~(data_nei(x,1)>3)
                data_RGB(x,Y-d2+j,1)=255;
                data_RGB(x,Y-d2+j,2)=97;
                data_RGB(x,Y-d2+j,3)=0;
            end
            if data_nei(x,1)>3
                data_RGB(x,Y-d2+j,1)=255;
                data_RGB(x,Y-d2+j,2)=0;
                data_RGB(x,Y-d2+j,3)=0;
            end
            if ~(data_clu(x,1)>0)
                data_RGB(x,Y-d3+j,1)=0;
                data_RGB(x,Y-d3+j,2)=0;
                data_RGB(x,Y-d3+j,3)=0;
            end
            if data_clu(x,1)>0 && ~(data_clu(x,1)>0.02)
                data_RGB(x,Y-d3+j,1)=176;
                data_RGB(x,Y-d3+j,2)=224;
                data_RGB(x,Y-d3+j,3)=230;
            end
            if data_clu(x,1)>0.02 && ~(data_clu(x,1)>0.04)
                data_RGB(x,Y-d3+j,1)=65;
                data_RGB(x,Y-d3+j,2)=105;
                data_RGB(x,Y-10+j,3)=225;
            end
            if data_clu(x,1)>0.04 && ~(data_clu(x,1)>0.06)
                data_RGB(x,Y-d3+j,1)=0;
                data_RGB(x,Y-d3+j,2)=0;
                data_RGB(x,Y-d3+j,3)=255;
            end
            if data_clu(x,1)>0.06 && ~(data_clu(x,1)>0.08)
                data_RGB(x,Y-d3+j,1)=124;
                data_RGB(x,Y-d3+j,2)=252;
                data_RGB(x,Y-d3+j,3)=0;
            end
            if data_clu(x,1)>0.08 && ~(data_clu(x,1)>0.1)
                data_RGB(x,Y-d3+j,1)=0;
                data_RGB(x,Y-d3+j,2)=255;
                data_RGB(x,Y-d3+j,3)=0;
            end
            if data_clu(x,1)>0.1 && ~(data_clu(x,1)>0.2)
                data_RGB(x,Y-d3+j,1)=0;
                data_RGB(x,Y-d3+j,2)=201;
                data_RGB(x,Y-d3+j,3)=87;
            end
            if data_clu(x,1)>0.2 && ~(data_clu(x,1)>0.3)
                data_RGB(x,Y-d3+j,1)=255;
                data_RGB(x,Y-d3+j,2)=97;
                data_RGB(x,Y-d3+j,3)=0;
            end
            if data_clu(x,1)>0.3
                data_RGB(x,Y-d3+j,1)=255;
                data_RGB(x,Y-d3+j,2)=0;
                data_RGB(x,Y-d3+j,3)=0;
            end
    end
    end
    end    
end
figure
imshow(data_RGB)
for x=1:X
    degree=1;
    clu=0;
    nei=3;
    a=1;
    b=0;
    c=1;
    for i=1:I
    if ~(data(i,1)>x)
        if ~(data(i,3)<0)
        degree=degree+data(i,3);
        a=a+1;
        end
        if ~(data(i,4)<0)
        clu=clu+data(i,4);
        b=b+1;
        end
        if ~(data(i,5)<0)
        nei=nei+data(i,5);
        c=c+1;
        end
        data_degree1(x,1)=degree/a;
        data_clu1(x,1)=clu/b;
        data_nei1(x,1)=nei/c;
    end
    end
 end    
