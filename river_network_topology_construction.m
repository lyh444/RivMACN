% Inputs
% I1: single-band image such as MNDWI image and the data format of the image is Double.
% I2: the river channel mask such as false color composite of Landsat TM images.
re=30; %resolution of images(m)


% water bodies extraction
data_grayimage=imread('I1.tif');
data_RGBimage=imread('I2.tif');
%figure
%imshow(data_grayimage)
%figure
%imshow(data_RGBimage)
[X,Y]=size(data_grayimage);
data_normalization=zeros(X,Y);
for x=1:X
    for y=1:Y
        if data_grayimage(x,y)>0
            data_normalization(x,y)=0;
        else data_normalization(x,y)=255;
        end
    end
end
%figure
%imshow(data_normalization)
% sigma: the size of the nosie removal window, sigma_1 is for water pixels, while sigma_2 is for background pixels.
sigma_1=250;
sigma_2=3;
for scale=1:1:sigma_1
    if sigma_1<6
        sigma=1;
    else
        sigma=2*scale+1;
    end
for x=scale+1:sigma:X-scale
  for y=scale+1:sigma:Y-scale
     if ~(x==scale+1)
      if ~(sum(sum(data_normalization(x-scale:1:x+scale,y-scale:1:y+scale)))==255*(2*scale+1)^2)
          m=0;
          if sum(data_normalization(x-scale:x+scale,y-scale))==255*(2*scale+1)
              m=m+1;
          end
           if sum(data_normalization(x-scale:x+scale,y+scale))==255*(2*scale+1)
              m=m+1;
           end
           if sum(data_normalization(x-scale,y-scale:y+scale))==255*(2*scale+1)
              m=m+1;
           end
           if sum(data_normalization(x+scale,y-scale:y+scale))==255*(2*scale+1)
              m=m+1;
           end
           if m==4  
             for a=x-scale:x+scale
              for b=y-scale:y+scale
                  data_normalization(a,b,1)=255;
              end
             end
           end 
      end
     else
         if ~(sum(sum(data_normalization(x-scale:1:x+scale,y-scale:1:y+scale)))==255*(2*scale+1)^2)
          m=0;
          if sum(data_normalization(x-scale:x+scale,y-scale))==255*(2*scale+1)
              m=m+1;
          end
           if sum(data_normalization(x-scale:x+scale,y+scale))==255*(2*scale+1)
              m=m+1;
           end
           if sum(data_normalization(x+scale,y-scale:y+scale))==255*(2*scale+1)
              m=m+1;
           end
           if m==3
             for a=x-scale:x+scale
              for b=y-scale:y+scale
                  data_normalization(a,b,1)=255;
              end
             end
           end 
         end
     end
  end
end
end 

for scale=1:1:sigma_2
for x=scale+1:1:X-scale
  for y=scale+1:1:Y-scale
     if ~(x==scale+1)
      if sum(sum(data_normalization(x-scale:1:x+scale,y-scale:1:y+scale)))>0
          m=0;
          if sum(data_normalization(x-scale:x+scale,y-scale))==0
              m=m+1;
          end
           if sum(data_normalization(x-scale:x+scale,y+scale))==0
              m=m+1;
           end
           if sum(data_normalization(x-scale,y-scale:y+scale))==0
              m=m+1;
           end
           if sum(data_normalization(x+scale,y-scale:y+scale))==0
              m=m+1;
           end
           if m==4  
             for a=x-scale:x+scale
              for b=y-scale:y+scale
                  data_normalization(a,b,1)=0;
              end
             end
           end 
      end
     else
         if sum(sum(data_normalization(x-scale:1:x+scale,y-scale:1:y+scale)))>0
          m=0;
          if sum(data_normalization(x-scale:x+scale,y-scale))==0
              m=m+1;
          end
           if sum(data_normalization(x-scale:x+scale,y+scale))==0
              m=m+1;
           end
           if sum(data_normalization(x+scale,y-scale:y+scale))==0
              m=m+1;
           end
           if m==3
             for a=x-scale:x+scale
              for b=y-scale:y+scale
                  data_normalization(a,b,1)=0;
              end
             end
           end 
         end
     end
  end
end
end 
figure
fig1=imshow(data_normalization);
saveas(fig1,'waterbody.fig');
xlswrite('output.xlsx',data_normalization,1)
imwrite(data_normalization,'waterbody.tif');
% data_binary: the binary image of the extracted water bodies
data_binary=data_normalization;
for x=1:X
    for y=1:Y
    if data_normalization(x,y)==255
        data_binary(x,y,1)=0;
    else data_binary(x,y,1)=1;
    end
    end    
end
xlswrite('output.xlsx',data_binary,2)  % binary image

% river channel delineate;
b=1;
while ~(b==0)
    a=0;
    for x=3:X-2
        for y=3:Y-2
            if data_binary(x,y)==1 && ~(sum(sum(data_binary(x-1:x+1,y-1:y+1)))-data_binary(x,y)==8)    
                if data_binary(x+1,y)+data_binary(x+2,y)==2 && data_binary(x,y-1)+data_binary(x-1,y-1)+data_binary(x-2,y-1)+data_binary(x-2,y)+data_binary(x-2,y+1)+data_binary(x-1,y+1)+data_binary(x,y+1)==0
                    if data_binary(x+1,y-1)+data_binary(x+2,y-1)==2 || data_binary(x+1,y+1)+data_binary(x+2,y+1)==2
                        data_binary(x,y)=0;
                        data_binary(x-1,y)=0;
                        a=a+1;
                    end
                end
                if data_binary(x,y-1)+data_binary(x,y-2)==2 && data_binary(x-1,y)+data_binary(x-1,y+1)+data_binary(x-1,y+2)+data_binary(x,y+2)+data_binary(x+1,y+2)+data_binary(x+1,y+1)+data_binary(x+1,y)==0
                    if data_binary(x-1,y-1)+data_binary(x-1,y-2)==2 || data_binary(x+1,y-1)+data_binary(x+1,y-2)==2
                       data_binary(x,y)=0;
                       data_binary(x,y+1)=0;
                       a=a+1;
                    end
                end
                if data_binary(x-1,y)+data_binary(x-2,y)==2 && data_binary(x,y-1)+data_binary(x+1,y-1)+data_binary(x+2,y-1)+data_binary(x+2,y)+data_binary(x+2,y+1)+data_binary(x+1,y+1)+data_binary(x,y+1)==0
                    if data_binary(x-1,y-1)+data_binary(x-2,y-1)==2 || data_binary(x-1,y+1)+data_binary(x-2,y+1)==2
                       data_binary(x,y)=0;
                       data_binary(x+1,y)=0;
                       a=a+1;
                    end
                end
                if data_binary(x,y+1)+data_binary(x,y+2)==2 && data_binary(x-1,y)+data_binary(x-1,y-1)+data_binary(x-1,y-2)+data_binary(x,y-2)+data_binary(x+1,y-2)+data_binary(x+1,y-1)+data_binary(x+1,y)==0
                    if data_binary(x-1,y+1)+data_binary(x-1,y+2)==2 || data_binary(x+1,y+1)+data_binary(x+1,y+2)==2
                       data_binary(x,y)=0;
                       data_binary(x,y-1)=0;
                       a=a+1;
                    end
                end
                if data_binary(x,y-1)+data_binary(x-1,y-1)+data_binary(x-1,y+1)+data_binary(x,y+1)==4 && data_binary(x-1,y)==0
                    data_binary(x-1,y)=1;
                    a=a+1;
                end
                if data_binary(x-1,y)+data_binary(x-1,y+1)+data_binary(x+1,y)+data_binary(x+1,y+1)==4 && data_binary(x,y+1)==0
                    data_binary(x,y+1)=1;
                    a=a+1;
                end
                if data_binary(x,y-1)+data_binary(x+1,y-1)+data_binary(x,y+1)+data_binary(x+1,y+1)==4 && data_binary(x+1,y)==0
                    data_binary(x+1,y)=1;
                    a=a+1;
                end
                if data_binary(x-1,y-1)+data_binary(x-1,y)+data_binary(x+1,y)+data_binary(x+1,y-1)==4 && data_binary(x,y-1)==0
                    data_binary(x,y-1)=1;
                    a=a+1;
                end
                if data_binary(x,y-1)+data_binary(x-1,y-1)+data_binary(x-1,y)+data_binary(x-1,y+1)+data_binary(x,y+1)==0 && data_binary(x+1,y+1)==1
                    data_binary(x,y)=0;
                    a=a+1;
                end
                if data_binary(x-1,y)+data_binary(x-1,y+1)+data_binary(x,y+1)+data_binary(x+1,y+1)+data_binary(x+1,y)==0 && data_binary(x+1,y-1)==1
                    data_binary(x,y)=0;
                    a=a+1;
                end
                if data_binary(x,y+1)+data_binary(x+1,y+1)+data_binary(x+1,y)+data_binary(x+1,y-1)+data_binary(x,y-1)==0 && data_binary(x-1,y-1)==1
                    data_binary(x,y)=0;
                    a=a+1;
                end
                if data_binary(x+1,y)+data_binary(x+1,y-1)+data_binary(x,y-1)+data_binary(x-1,y-1)+data_binary(x-1,y)==0 && data_binary(x-1,y+1)==1
                    data_binary(x,y)=0;
                    a=a+1;
                end
            end
        end
    end
    b=a;
end
b=1;
while ~(b==0)
    a=0;
    for x=2:X-2    
       for y=4:Y-1
          if data_binary(x,y)==1 && ~(sum(sum(data_binary(x-1:x+1,y-1:y+1)))-data_binary(x,y)==8)
              if sum(data_binary(x-1,y-2:y+1))+sum(data_binary(x,y-2:y+1))+data_binary(x+1,y)+data_binary(x+1,y+1)+data_binary(x+2,y+1)==11 && sum(data_binary(x-1:x+2,y-3))+sum(sum(data_binary(x+1:x+2,y-2:y-1)))==0
                  data_binary(x,y-2)=0;
              end
              if sum(data_binary(x-1,y-3:y))+sum(data_binary(x,y-3:y))+data_binary(x+1,y-3)+data_binary(x+1,y-2)+data_binary(x+2,y-3)==11 && sum(data_binary(x-1:x+2,y+1))+sum(sum(data_binary(x+1:x+2,y-1:y)))==0
                  data_binary(x,y)=0;
              end
          end
       end
    end
    b=a;
end
mm=2;
data_remove1=[13,97,22,208,67,88,52,133,141,99,54,216];
data_remove2=[65,5,20,80];
while ~(mm==1)
    b1=1;
    data_remove_xlable=zeros(X*Y,1);
    data_remove_ylable=zeros(X*Y,1);
    for x=2:X-1
        for y=2:Y-1
            if data_binary(x,y)==1 && ~(sum(sum(data_binary(x-1:x+1,y-1:y+1)))-9==0)
                a2=0;
                a33=1;
                if data_binary(x-1,y)==0 && data_binary(x-1,y+1)==1
                    a2=a2+1;
                end
                if data_binary(x-1,y+1)==0 && data_binary(x,y+1)==1
                    a2=a2+1;
                end
                if data_binary(x,y+1)==0 && data_binary(x+1,y+1)==1
                    a2=a2+1;
                end
                if data_binary(x+1,y+1)==0 && data_binary(x+1,y)==1
                    a2=a2+1;
                end
                if data_binary(x+1,y)==0 && data_binary(x+1,y-1)==1
                    a2=a2+1;
                end
                if data_binary(x+1,y-1)==0 && data_binary(x,y-1)==1
                    a2=a2+1;
                end
                if data_binary(x,y-1)==0 && data_binary(x-1,y-1)==1
                    a2=a2+1;
                end
                if data_binary(x-1,y-1)==0 && data_binary(x-1,y)==1
                    a2=a2+1;
                end
                a1=sum(sum(data_binary(x-1:x+1,y-1:y+1)))-data_binary(x,y);
                if ~(a1<2)&&~(a1>6)
                    if a2==1
                        if data_binary(x-1,y)*data_binary(x,y+1)*data_binary(x+1,y)==0 && data_binary(x,y+1)*data_binary(x+1,y)*data_binary(x,y-1)==0
                            data_remove_xlable(b1,1)=x;
                            data_remove_ylable(b1,1)=y;
                            b1=b1+1;
                        end
                    end
                end
            end
        end
    end
    if ~(b1==1)
        for xx=1:b1-1
            data_binary(data_remove_xlable(xx,1),data_remove_ylable(xx,1))=0;
        end
    end
    b2=1;
    data_remove_xxlable=zeros(X*Y,1);
    data_remove_yylable=zeros(X*Y,1);
    for x=2:X-1
        for y=2:Y-1
            if data_binary(x,y)==1 && ~(sum(sum(data_binary(x-1:x+1,y-1:y+1)))-9==0)  
            aa2=0;
            zhang_aa33=1;
            if data_binary(x-1,y)==0 && data_binary(x-1,y+1)==1
            aa2=aa2+1;
            end
            if data_binary(x-1,y+1)==0 && data_binary(x,y+1)==1
            aa2=aa2+1;
            end
            if data_binary(x,y+1)==0 && data_binary(x+1,y+1)==1
            aa2=aa2+1;
            end
            if data_binary(x+1,y+1)==0 && data_binary(x+1,y)==1
            aa2=aa2+1;
            end
            if data_binary(x+1,y)==0 && data_binary(x+1,y-1)==1
            aa2=aa2+1;
            end
            if data_binary(x+1,y-1)==0 && data_binary(x,y-1)==1
            aa2=aa2+1;
            end
            if data_binary(x,y-1)==0 && data_binary(x-1,y-1)==1
            aa2=aa2+1;
            end
            if data_binary(x-1,y-1)==0 && data_binary(x-1,y)==1
            aa2=aa2+1;
            end
            aa1=sum(sum(data_binary(x-1:x+1,y-1:y+1)))-data_binary(x,y);
            if ~(aa1<2)&&~(aa1>6)
                if aa2==1
                    if data_binary(x-1,y)*data_binary(x,y+1)*data_binary(x,y-1)==0 && data_binary(x-1,y)*data_binary(x+1,y)*data_binary(x,y-1)==0
                        data_remove_xxlable(b2,1)=x;
                        data_remove_yylable(b2,1)=y;
                        b2=b2+1;
                    end
                end
            end
            end
        end
    end
    if ~(b2==1)
        for xx=1:b2-1
            data_binary(data_remove_xxlable(xx,1),data_remove_yylable(xx,1))=0;
        end
    end
mm=b1*b2;
end
for x=2:X-1
    for y=2:Y-1
        if data_binary(x,y)==1
          zhang_a33=1;
          zhang_a31=data_binary(x-1,y)*1+data_binary(x-1,y+1)*2+data_binary(x,y+1)*4+data_binary(x+1,y+1)*8+data_binary(x+1,y)*16+data_binary(x+1,y-1)*32+data_binary(x,y-1)*64+data_binary(x-1,y-1)*128;
            for zhang_a32=1:12
              zhang_a33=zhang_a33*(zhang_a31-data_remove1(1,zhang_a32));
            end
            if zhang_a33==0
                data_binary(x,y)=0;
            end
        end
    end
end
for x=2:X-1
    for y=2:Y-1
        if data_binary(x,y)==1
            zhang_aa33=1;
          zhang_aa31=data_binary(x-1,y)*1+data_binary(x-1,y+1)*2+data_binary(x,y+1)*4+data_binary(x+1,y+1)*8+data_binary(x+1,y)*16+data_binary(x+1,y-1)*32+data_binary(x,y-1)*64+data_binary(x-1,y-1)*128;
            for zhang_aa32=1:4
              zhang_aa33=zhang_aa33*(zhang_aa31-data_remove2(1,zhang_aa32));
            end
            if zhang_aa33==0
                data_binary(x,y)=0;
            end
        end
    end
end
data_imshow_background=zeros(X,Y,3);
ID_regrownmap=zeros(X,Y);
for x=2:X-1
    for y=2:Y-1
        if data_normalization(x,y)==0
            if data_binary(x,y)==1
                  data_imshow_background(x,y,1)=255;
                  data_imshow_background(x,y,2)=0;
                  data_imshow_background(x,y,3)=0;
                  ID_regrownmap(x,y)=1;
            else
                  data_imshow_background(x,y,1)=0;
                  data_imshow_background(x,y,2)=0;
                  data_imshow_background(x,y,3)=0;
            end
        else
            data_imshow_background(x,y,1)=255;
            data_imshow_background(x,y,2)=255;
            data_imshow_background(x,y,3)=255;
        end
    end
end
figure
imshow(data_imshow_background)
fig2=imshow(data_imshow_background);
saveas(fig2,'thining2.fig');
hold on
xlswrite('output.xlsx',data_binary,3)

% node detection
%channel_num_d=1;
%channel_totalnum=0;
%data_channelnode_num=zeros(15000,5);
%for x=2:channel_num_d:X-1
    %channel_num=0;
    %for y=2:Y-1
        %if data_binary(x,y)==1 && ~(data_binary(x,y-1)==1)
            %channel_num=channel_num+1;
        %end
    %end
    %data_channelnode_num(x,1)=channel_num;
    %channel_totalnum=channel_totalnum+channel_num;
%end
%data_summary(year,10)=channel_totalnum/(X-2);
%figure
%plot(data_channelnode_num(:,1))
%xlabel('Distance')
%ylabel('Channel number')
%hold on
data_bifurcation_detectiona=[277,293,297,298,325,329,330,337,338,340,394,402,404,418,420,424,426,341];
data_bifurcation_detectionb=[257,258,260,264,272,288,320,384];
point_num=1;
data_node_RGB=data_RGBimage;
data_node=zeros(15000,3);
bifurcation_neighbor=zeros(X,Y,2);
node_4=0;
node_3=0;
for x=2:X-1
    for y=2:Y-1
         if data_binary(x,y)==1 && sum(sum(data_binary(x-1:x+1,y-1:y+1)))>3
             bd3=1;
             bd1=data_binary(x-1,y)*32+data_binary(x-1,y+1)*64+data_binary(x,y+1)*128+data_binary(x+1,y+1)*1+data_binary(x+1,y)*2+data_binary(x+1,y-1)*4+data_binary(x,y-1)*8+data_binary(x-1,y-1)*16+data_binary(x,y)*256;
             for bd2=1:18
                 bd3=bd3*(bd1-data_bifurcation_detectiona(1,bd2));
             end
             if bd3==0
                 %data_channelnode_num(point_num,3)=x;
                 %data_channelnode_num(point_num,4)=y;
                 %data_channelnode_num(point_num,5)=1;
                 data_node(point_num,1)=x;
                 data_node(point_num,2)=y;
                 data_node(point_num,3)=1;
                 point_num=point_num+1;
                 data_imshow_background(x,y,1)=0;
                 data_imshow_background(x,y,2)=0;
                 data_imshow_background(x,y,3)=255;
                 if bd1==426 || bd1==341
                     node_4=node_4+1;
                 else
                     node_3=node_3+1;
                 end
             end
         end
         if data_binary(x,y)==1 && sum(sum(data_binary(x-1:x+1,y-1:y+1)))==2
                 %data_channelnode_num(point_num,3)=x;
                 %data_channelnode_num(point_num,4)=y;
                 %data_channelnode_num(point_num,5)=2;
                 data_node(point_num,1)=x;
                 data_node(point_num,2)=y;
                 data_node(point_num,3)=2;
                 point_num=point_num+1;
                 data_imshow_background(x,y,1)=0;
                 data_imshow_background(x,y,2)=255;
                 data_imshow_background(x,y,3)=0;
         end
    end
end
for x=2:X-2
    for y=2:Y-2
        if data_binary(x,y)==1 && sum(sum(data_binary(x:x+1,y:y+1)))>2 && sum(sum(data_binary(x-1:x+2,y-1:y+2)))+sum(sum(data_binary(x:x+1,y:y+1)))>5
            if ~(data_imshow_background(x,y,3)==255) && ~(data_imshow_background(x+1,y,3)==255) && ~(data_imshow_background(x+1,y+1,3)==255) && ~(data_imshow_background(x,y+1,3)==255) 
                if ~(data_binary(x-1,y)+data_binary(x-1,y+1)==2) && ~(data_binary(x-1,y+1)+data_binary(x-1,y+2)==2) && ~(data_binary(x-1,y+2)+data_binary(x,y+2)==2) && ~(data_binary(x,y+2)+data_binary(x+1,y+2)==2) && ~(data_binary(x+1,y+2)+data_binary(x+2,y+2)==2) && ~(data_binary(x+2,y+2)+data_binary(x+2,y+1)==2) && ~(data_binary(x+2,y+1)+data_binary(x+2,y)==2) && ~(data_binary(x+2,y)+data_binary(x+2,y-1)==2) && ~(data_binary(x+2,y-1)+data_binary(x+1,y-1)==2) && ~(data_binary(x+1,y-1)+data_binary(x,y-1)==2) && ~(data_binary(x,y-1)+data_binary(x-1,y-1)==2) && ~(data_binary(x-1,y-1)+data_binary(x-1,y)==2) 
                 %data_channelnode_num(point_num,3)=x;
                 %data_channelnode_num(point_num,4)=y;
                 %data_channelnode_num(point_num,5)=3;
                 data_node(point_num,1)=x;
                 data_node(point_num,2)=y;
                 data_node(point_num,3)=3;
                 point_num=point_num+1;
                 data_imshow_background(x,y,1)=0;
                 data_imshow_background(x,y,2)=0;
                 data_imshow_background(x,y,3)=255;
                 bifurcation_neighbor(x,y+1,1)=x;
                 bifurcation_neighbor(x,y+1,2)=y;
                 bifurcation_neighbor(x+1,y+1,1)=x;
                 bifurcation_neighbor(x+1,y+1,2)=y;
                 bifurcation_neighbor(x+1,y,1)=x;
                 bifurcation_neighbor(x+1,y,2)=y;
               end
            end
        end
    end
end
for x=1:point_num-2
    for y=x+1:point_num-1
        if ~(data_node(y,1)==0)  
            if data_node(y,1)<data_node(x,1)
            flag1=data_node(x,1);
            flag2=data_node(x,2);
            flag3=data_node(x,3);
            %data_channelnode_num(x,3)=data_channelnode_num(y,3);
            %data_channelnode_num(x,4)=data_channelnode_num(y,4);
            %data_channelnode_num(x,5)=data_channelnode_num(y,5);
            data_node(x,1)=data_node(y,1);
            data_node(x,2)=data_node(y,2);
            data_node(x,3)=data_node(y,3);
            %data_channelnode_num(y,3)=flag1;
            %data_channelnode_num(y,4)=flag2;
            %data_channelnode_num(y,5)=flag3;
            data_node(y,1)=flag1;
            data_node(y,2)=flag2;
            data_node(y,3)=flag3;
            else
            if data_node(y,1)==data_node(x,1) && data_node(y,2)<data_node(x,2)
            flag1=data_node(x,1);
            flag2=data_node(x,2);
            flag3=data_node(x,3);
            %data_channelnode_num(x,3)=data_channelnode_num(y,3);
            %data_channelnode_num(x,4)=data_channelnode_num(y,4);
            %data_channelnode_num(x,5)=data_channelnode_num(y,5);
            data_node(x,1)=data_node(y,1);
            data_node(x,2)=data_node(y,2);
            data_node(x,3)=data_node(y,3);
            %data_channelnode_num(y,3)=flag1;
            %data_channelnode_num(y,4)=flag2;
            %data_channelnode_num(y,5)=flag3;
            data_node(y,1)=flag1;
            data_node(y,2)=flag2;
            data_node(y,3)=flag3;
            end
            end
        end
    end
end
%node_d=50;
%node_totalnum=0;
%for x=2:X-node_d
    %node_num=0;
    %for a=1:point_num-1
        %if ~(data_channelnode_num(a,3)<x) && ~(data_channelnode_num(a,3)>x+node_d-1)
            %node_num=node_num+1;
        %end
    %end
    %data_channelnode_num(x,2)=node_num/node_d;
    %node_totalnum=node_totalnum+node_num/node_d;
%end
%data_summary(year,9)=node_totalnum/(X-node_d-2+1);
%figure
%plot(data_channelnode_num(:,2))
%xlabel('Distance')
%ylabel('Bifucation number')
%hold on
%xlswrite(strcat('output_binary_',int2str(year),'.xlsx'), data_channelnode_num,6)
%data_practice_node=zeros(15000,5);
%data_practice_node=data_channelnode_num;

figure
imshow(data_imshow_background)
fig3=imshow(data_imshow_background);
saveas(fig3,'node detection.fig');

%derivation of river network connectivity matrix
gate_width=5;    % valus of the difference between the number of pixels one the left and right sections
macrochannel_width=zeros(X,1);
data_planeindex_RGB=data_RGBimage;
for x=2:X-1
    for y=2:Y-1
        if data_binary(x,y)==1
            data_planeindex_RGB(x,y,1)=255;
            data_planeindex_RGB(x,y,2)=255;
            data_planeindex_RGB(x,y,3)=255;
        end
    end
end

for x=1:point_num-1
    if data_node(x,3)==1
        data_planeindex_RGB(data_node(x,1),data_node(x,2),1)=255;
        data_planeindex_RGB(data_node(x,1),data_node(x,2),2)=0;
        data_planeindex_RGB(data_node(x,1),data_node(x,2),3)=0;
    else if data_node(x,3)==3
            data_planeindex_RGB(data_node(x,1),data_node(x,2),1)=255;
            data_planeindex_RGB(data_node(x,1),data_node(x,2),2)=0;
            data_planeindex_RGB(data_node(x,1),data_node(x,2),3)=0;
            data_planeindex_RGB(data_node(x,1),data_node(x,2)+1,1)=255;
            data_planeindex_RGB(data_node(x,1),data_node(x,2)+1,2)=0;
            data_planeindex_RGB(data_node(x,1),data_node(x,2)+1,3)=1;
            data_planeindex_RGB(data_node(x,1)+1,data_node(x,2)+1,1)=255;
            data_planeindex_RGB(data_node(x,1)+1,data_node(x,2)+1,2)=0;
            data_planeindex_RGB(data_node(x,1)+1,data_node(x,2)+1,3)=1;
            data_planeindex_RGB(data_node(x,1)+1,data_node(x,2),1)=255;
            data_planeindex_RGB(data_node(x,1)+1,data_node(x,2),2)=0;
            data_planeindex_RGB(data_node(x,1)+1,data_node(x,2),3)=1;
        else if data_node(x,3)==2
                  data_planeindex_RGB(data_node(x,1),data_node(x,2),1)=0;
                  data_planeindex_RGB(data_node(x,1),data_node(x,2),2)=255;
                  data_planeindex_RGB(data_node(x,1),data_node(x,2),3)=0;
             end
        end
    end
end
data_node_binary1=zeros(point_num,point_num);
data_node_binary2=zeros(point_num,point_num);
data_node_binary3=zeros(point_num,point_num);
data_node_binary4=zeros(point_num,point_num);
data_node_binary5=zeros(point_num,point_num);
singlechannel=zeros(X,(point_num-1)*5);
linknum=0;
for bx=1:point_num-1
    point_startnum=0;
    bifucation_x=data_node(bx,1);
    bifucation_y=data_node(bx,2);
    if data_node(bx,3)==1 || data_node(bx,3)==2
    if data_binary(bifucation_x-1,bifucation_y-1)==1
        point_startnum=point_startnum+1;
        singlechannel(point_startnum,5*bx-4)=bifucation_x-1;
        singlechannel(point_startnum,5*bx-3)=bifucation_y-1;
        singlechannel(point_startnum,5*bx-2)=point_startnum;
    end
    if data_binary(bifucation_x-1,bifucation_y)==1 
        point_startnum=point_startnum+1;
        singlechannel(point_startnum,5*bx-4)=bifucation_x-1;
        singlechannel(point_startnum,5*bx-3)=bifucation_y;
        singlechannel(point_startnum,5*bx-2)=point_startnum;
    end
    if data_binary(bifucation_x-1,bifucation_y+1)==1
        point_startnum=point_startnum+1;
        singlechannel(point_startnum,5*bx-4)=bifucation_x-1;
        singlechannel(point_startnum,5*bx-3)=bifucation_y+1;
        singlechannel(point_startnum,5*bx-2)=point_startnum;
    end
    if data_binary(bifucation_x,bifucation_y+1)==1
        point_startnum=point_startnum+1;
        singlechannel(point_startnum,5*bx-4)=bifucation_x;
        singlechannel(point_startnum,5*bx-3)=bifucation_y+1;
        singlechannel(point_startnum,5*bx-2)=point_startnum;
    end
    if data_binary(bifucation_x+1,bifucation_y+1)==1
        point_startnum=point_startnum+1;
        singlechannel(point_startnum,5*bx-4)=bifucation_x+1;
        singlechannel(point_startnum,5*bx-3)=bifucation_y+1;
        singlechannel(point_startnum,5*bx-2)=point_startnum;
    end
    if data_binary(bifucation_x+1,bifucation_y)==1
        point_startnum=point_startnum+1;
        singlechannel(point_startnum,5*bx-4)=bifucation_x+1;
        singlechannel(point_startnum,5*bx-3)=bifucation_y;
        singlechannel(point_startnum,5*bx-2)=point_startnum;
    end
    if data_binary(bifucation_x+1,bifucation_y-1)==1
        point_startnum=point_startnum+1;
        singlechannel(point_startnum,5*bx-4)=bifucation_x+1;
        singlechannel(point_startnum,5*bx-3)=bifucation_y-1;
        singlechannel(point_startnum,5*bx-2)=point_startnum;
    end
    if data_binary(bifucation_x,bifucation_y-1)==1
        point_startnum=point_startnum+1;
        singlechannel(point_startnum,5*bx-4)=bifucation_x;
        singlechannel(point_startnum,5*bx-3)=bifucation_y-1;
        singlechannel(point_startnum,5*bx-2)=point_startnum;
    end
    else if  data_node(bx,3)==3
          if data_binary(bifucation_x,bifucation_y-1)==1
               point_startnum=point_startnum+1;
               singlechannel(point_startnum,5*bx-4)=bifucation_x;
               singlechannel(point_startnum,5*bx-3)=bifucation_y-1;
               singlechannel(point_startnum,5*bx-2)=point_startnum;  
          end
          if data_binary(bifucation_x-1,bifucation_y-1)==1
               point_startnum=point_startnum+1;
               singlechannel(point_startnum,5*bx-4)=bifucation_x-1;
               singlechannel(point_startnum,5*bx-3)=bifucation_y-1;
               singlechannel(point_startnum,5*bx-2)=point_startnum;
          end
          if data_binary(bifucation_x-1,bifucation_y)==1
               point_startnum=point_startnum+1;
               singlechannel(point_startnum,5*bx-4)=bifucation_x-1;
               singlechannel(point_startnum,5*bx-3)=bifucation_y;
               singlechannel(point_startnum,5*bx-2)=point_startnum;
          end
          if data_binary(bifucation_x-1,bifucation_y+1)==1
               point_startnum=point_startnum+1;
               singlechannel(point_startnum,5*bx-4)=bifucation_x-1;
               singlechannel(point_startnum,5*bx-3)=bifucation_y+1;
               singlechannel(point_startnum,5*bx-2)=point_startnum;
          end
          if data_binary(bifucation_x-1,bifucation_y+2)==1
               point_startnum=point_startnum+1;
               singlechannel(point_startnum,5*bx-4)=bifucation_x-1;
               singlechannel(point_startnum,5*bx-3)=bifucation_y+2;
               singlechannel(point_startnum,5*bx-2)=point_startnum;
          end
          if data_binary(bifucation_x,bifucation_y+2)==1
               point_startnum=point_startnum+1;
               singlechannel(point_startnum,5*bx-4)=bifucation_x;
               singlechannel(point_startnum,5*bx-3)=bifucation_y+2;
               singlechannel(point_startnum,5*bx-2)=point_startnum;
          end
          if data_binary(bifucation_x+1,bifucation_y+2)==1
               point_startnum=point_startnum+1;
               singlechannel(point_startnum,5*bx-4)=bifucation_x+1;
               singlechannel(point_startnum,5*bx-3)=bifucation_y+2;
               singlechannel(point_startnum,5*bx-2)=point_startnum;
          end
          if data_binary(bifucation_x+2,bifucation_y+2)==1
               point_startnum=point_startnum+1;
               singlechannel(point_startnum,5*bx-4)=bifucation_x+2;
               singlechannel(point_startnum,5*bx-3)=bifucation_y+2;
               singlechannel(point_startnum,5*bx-2)=point_startnum;
          end
          if data_binary(bifucation_x+2,bifucation_y+1)==1
               point_startnum=point_startnum+1;
               singlechannel(point_startnum,5*bx-4)=bifucation_x+2;
               singlechannel(point_startnum,5*bx-3)=bifucation_y+1;
               singlechannel(point_startnum,5*bx-2)=point_startnum;
          end
          if data_binary(bifucation_x+2,bifucation_y)==1
               point_startnum=point_startnum+1;
               singlechannel(point_startnum,5*bx-4)=bifucation_x+2;
               singlechannel(point_startnum,5*bx-3)=bifucation_y;
               singlechannel(point_startnum,5*bx-2)=point_startnum;
          end
          if data_binary(bifucation_x+2,bifucation_y-1)==1
               point_startnum=point_startnum+1;
               singlechannel(point_startnum,5*bx-4)=bifucation_x+2;
               singlechannel(point_startnum,5*bx-3)=bifucation_y-1;
               singlechannel(point_startnum,5*bx-2)=point_startnum;
          end
          if data_binary(bifucation_x+1,bifucation_y-1)==1
               point_startnum=point_startnum+1;
               singlechannel(point_startnum,5*bx-4)=bifucation_x+1;
               singlechannel(point_startnum,5*bx-3)=bifucation_y-1;
               singlechannel(point_startnum,5*bx-2)=point_startnum;
          end
        end
    end
    n0=1;
    crosssection_d=1;
    for x=1:point_startnum
          length_curve_i=0;
          length_straight_i=0;
          width_num=0;
          sum_sectionb=0;
          xx=singlechannel(x,5*bx-4);
          yy=singlechannel(x,5*bx-3);
          if  ~(data_planeindex_RGB(xx,yy,1)==255) || ~(data_planeindex_RGB(xx,yy,2)==255)
            if data_planeindex_RGB(xx,yy,3)==0
               xx_jiance=xx;
               yy_jiance=yy;
            end
            if data_planeindex_RGB(xx,yy,3)==1
               xx_jiance=bifurcation_neighbor(xx,yy,1);
               yy_jiance=bifurcation_neighbor(xx,yy,2);
            end
              for x_end=1:point_num
                  if xx_jiance-data_node(x_end,1)==0 && yy_jiance-data_node(x_end,2)==0
                      if data_node(bx,3)==2 && data_node(x_end,3)==2
                          data_node(bx,3)=4;
                          data_node(x_end,3)=4;
                      else
                          data_node_binary1(bx,x_end,1)=data_node_binary1(bx,x_end,1)+1;
                          data_node_binary2(bx,x_end,1)=sqrt((bifucation_x-xx)^2+(bifucation_y-yy)^2)*re;
                          data_node_binary3(bx,x_end,1)=sqrt((bifucation_x-xx)^2+(bifucation_y-yy)^2)*re;
                          data_node_binary4(bx,x_end,1)=1;
                          linknum=linknum+1;
                          slop_y=xx-bifucation_x;
                          slop_x=yy-bifucation_y;
                          if slop_x==0
                             singlechannel(x,5*bx-1)=100;        %vertical
                          else if slop_y==0
                                  singlechannel(x,5*bx-1)=99;    %horizontal
                               else
                                  singlechannel(x,5*bx-1)=slop_y/slop_x;
                               end
                          end
                          section_b=0;
                          if singlechannel(x,5*bx-1)==100
                              section_x1=xx;
                              section_y1=yy;
                              while section_y1>2 && section_y1<Y-2 && data_normalization(section_x1,section_y1)==0 
                                    section_y1=section_y1-1;
                                    ID_regrownmap(section_x1,section_y1)=1;
                              end
                              section_b1=yy-section_y1;
                              section_x2=xx;
                              section_y2=yy;
                              while section_y2>2 && section_y2<Y-2 && data_normalization(section_x2,section_y2)==0 
                              section_y2=section_y2+1;
                              ID_regrownmap(section_x2,section_y2)=1;
                              end
                              section_b2=section_y2-yy;
                              if abs(section_b1-section_b2)<gate_width
                                  section_b=section_b1+section_b2;
                              end
                          end
                          if singlechannel(x,5*bx-1)==99
                              section_x1=xx;
                              section_y1=yy;
                              while section_x1>2 && section_x1<X-2 && data_normalization(section_x1,section_y1)==0
                              section_x1=section_x1-1;
                              ID_regrownmap(section_x1,section_y1)=1;
                              end
                              section_b1=xx-section_x1;
                              section_x2=xx;
                              section_y2=yy;
                              while section_x2>2 && section_x2<X-2 && data_normalization(section_x2,section_y2)==0 
                                   section_x2=section_x2+1;
                                   ID_regrownmap(section_x2,section_y2)=1;
                              end
                              section_b2=section_x2-xx;
                              if abs(section_b1-section_b2)<gate_width
                                   section_b=section_b1+section_b2;
                              end
                          end
                          if singlechannel(x,5*bx-1)==1
                              section_x1=xx;
                              section_y1=yy;
                              while section_x1>2 && section_x1<X-2 && section_y1>2 && section_y1<Y-2 && data_normalization(section_x1,section_y1)==0 
                                 section_y1=section_y1-1;
                                 section_x1=section_x1+1;
                                 ID_regrownmap(section_x1,section_y1)=1;
                              end
                              section_b1=sqrt((yy-section_y1)^2+(xx-section_x1)^2);
                              section_x2=xx;
                              section_y2=yy;
                              while section_x2>2 && section_x2<X-2 && section_y2>2 && section_y2<Y-2 && data_normalization(section_x2,section_y2)==0  
                                 section_y2=section_y2+1;
                                 section_x2=section_x2-1;
                                 ID_regrownmap(section_x2,section_y2)=1;
                              end
                              section_b2=sqrt((section_y2-yy)^2+(section_x2-xx)^2);
                              if abs(section_b1-section_b2)<gate_width
                                 section_b=section_b1+section_b2;
                              end
                          end
                          if singlechannel(x,5*bx-1)==-1
                              section_x1=xx;
                              section_y1=yy;
                              while section_x1>2 && section_x1<X-2 && section_y1>2 && section_y1<Y-2 && data_normalization(section_x1,section_y1)==0 
                                  section_y1=section_y1+1;
                                  section_x1=section_x1+1;
                                  ID_regrownmap(section_x1,section_y1)=1;
                              end
                             section_b1=sqrt((yy-section_y1)^2+(xx-section_x1)^2);
                             section_x2=xx;
                             section_y2=yy;
                             while section_x2>2 && section_x2<X-2 && section_y2>2 && section_y2<Y-2 && data_normalization(section_x2,section_y2)==0 
                                  section_y2=section_y2-1;
                                  section_x2=section_x2-1;
                                  ID_regrownmap(section_x2,section_y2)=1;
                             end
                             section_b2=sqrt((section_y2-yy)^2+(section_x2-xx)^2);
                             if abs(section_b1-section_b2)<gate_width
                                section_b=section_b1+section_b2;
                             end
                          end
                           singlechannel(x,5*bx)=section_b*re;
                           data_node_binary5(bx,x_end,1)=section_b*re;
                           if singlechannel(x,5*bx-1)==99
                               macrochannel_width(xx,1)=macrochannel_width(xx,1)+1;
                           else
                               macrochannel_width(xx,1)=macrochannel_width(xx,1)+section_b;
                           end
                      end
                  end
              end
          end
          if  data_planeindex_RGB(xx,yy,1)==255 && data_planeindex_RGB(xx,yy,2)==255
              tem_seed=zeros(8,2);
              if data_binary(xx-1,yy-1)==1
                  tem_seed(1,1)=xx-1;
                  tem_seed(1,2)=yy-1;
              end
              if data_binary(xx-1,yy)==1
                  tem_seed(2,1)=xx-1;
                  tem_seed(2,2)=yy;
              end
              if data_binary(xx-1,yy+1)==1
                  tem_seed(3,1)=xx-1;
                  tem_seed(3,2)=yy+1;
              end
              if data_binary(xx,yy+1)==1
                  tem_seed(4,1)=xx;
                  tem_seed(4,2)=yy+1;
              end
              if data_binary(xx+1,yy+1)==1
                  tem_seed(5,1)=xx+1;
                  tem_seed(5,2)=yy+1;
              end
              if data_binary(xx+1,yy)==1
                  tem_seed(6,1)=xx+1;
                  tem_seed(6,2)=yy;
              end
              if data_binary(xx+1,yy-1)==1
                  tem_seed(7,1)=xx+1;
                  tem_seed(7,2)=yy-1;
              end
              if data_binary(xx,yy-1)==1
                  tem_seed(8,1)=xx;
                  tem_seed(8,2)=yy-1;
              end
              xxx=0;
              yyy=0;
              onlytwo_xxx=0;
              onlytwo_yyy=0;
              data_onlytwo=zeros(8,2);
              jishujishu2=0;
              for seednum=1:8
                  if ~(tem_seed(seednum,1)==0)
                  a1=1;
                  a2=1;
                  four_a1=0;
                  four_a2=0;
                  four_a3=0;
                  four_a4=0;
                  four_a=0;
                  jishujishu1=1;
                      for ps=1:point_startnum
                          a1=a1*(tem_seed(seednum,1)-singlechannel(ps,5*bx-4));
                          a2=a2*(tem_seed(seednum,2)-singlechannel(ps,5*bx-3));
                      end
                      if data_node(bx,3)==3
                          four_a1=abs((tem_seed(seednum,1)-bifucation_x))+abs((tem_seed(seednum,2)-bifucation_y));
                          four_a2=abs((tem_seed(seednum,1)-bifucation_x))+abs((tem_seed(seednum,2)-(bifucation_y+1)));
                          four_a3=abs((tem_seed(seednum,1)-(bifucation_x+1)))+abs((tem_seed(seednum,2)-(bifucation_y+1)));
                          four_a4=abs((tem_seed(seednum,1)-(bifucation_x+1)))+abs((tem_seed(seednum,2)-bifucation_y));
                          four_a=four_a1*four_a2*four_a3*four_a4;
                      end
                      if data_node(bx,3)==1 || data_node(bx,3)==2
                          four_a=abs((tem_seed(seednum,1)-bifucation_x))+abs((tem_seed(seednum,2)-bifucation_y));
                      end
                      if ~(a1==0) || ~(a2==0) 
                        if ~(data_planeindex_RGB(tem_seed(seednum,1),tem_seed(seednum,2),1)==255) || ~(data_planeindex_RGB(tem_seed(seednum,1),tem_seed(seednum,2),2)==255)
                            if ~(four_a==0)
                                onlytwo_xxx=tem_seed(seednum,1);
                                onlytwo_yyy=tem_seed(seednum,2);
                                if data_planeindex_RGB(tem_seed(seednum,1),tem_seed(seednum,2),3)==0
                                    onlytwo_xxx_jiance=onlytwo_xxx;
                                    onlytwo_yyy_jiance=onlytwo_yyy;
                                end
                                if data_planeindex_RGB(tem_seed(seednum,1),tem_seed(seednum,2),3)==1 
                                    onlytwo_xxx_jiance=bifurcation_neighbor(onlytwo_xxx,onlytwo_yyy,1);
                                    onlytwo_yyy_jiance=bifurcation_neighbor(onlytwo_xxx,onlytwo_yyy,2);
                                end
                                for jishujishu=1:8
                                    if ~(data_onlytwo(jishujishu,1)==0)
                                    jishujishu1=jishujishu1*(abs((onlytwo_xxx_jiance-data_onlytwo(jishujishu,1)))+abs((onlytwo_yyy_jiance-data_onlytwo(jishujishu,2))));
                                    end
                                    if ~(jishujishu1==0)
                                        jishujishu2=jishujishu2+1;
                                        data_onlytwo(jishujishu2,1)=onlytwo_xxx_jiance;
                                        data_onlytwo(jishujishu2,2)=onlytwo_yyy_jiance;
                                    end
                                end
                            for x_end=1:point_num
                              if ~(jishujishu1==0)
                              if onlytwo_xxx_jiance-data_node(x_end,1)==0 && onlytwo_yyy_jiance-data_node(x_end,2)==0
                                  if data_node(bx,3)==2 && data_node(x_end,3)==2
                                      data_node(bx,3)=4;
                                      data_node(x_end,3)=4;
                                  else
                                  data_node_binary1(bx,x_end,1)=data_node_binary1(bx,x_end,1)+1;
                                  data_node_binary2(bx,x_end,1)=sqrt((bifucation_x-xx)^2+(bifucation_y-yy)^2)*30+sqrt((onlytwo_xxx-xx)^2+(onlytwo_yyy-yy)^2)*30;
                                  data_node_binary3(bx,x_end,1)=sqrt((bifucation_x-onlytwo_xxx)^2+(bifucation_y-onlytwo_xxx)^2)*30;
                                  data_node_binary4(bx,x_end,1)=1;
                                  linknum=linknum+1;
                                  slop_y=onlytwo_xxx-bifucation_x;
                                  slop_x=onlytwo_yyy-bifucation_y;
                                  if slop_x==0
                                      singlechannel(x,5*bx-1)=100;      %vertical
                                  else if slop_y==0
                                          singlechannel(x,5*bx-1)=99;   %horizontal
                                      else
                                           singlechannel(x,5*bx-1)=slop_y/slop_x;
                                      end
                                  end
                                  section_b=0;
                                  if singlechannel(x,5*bx-1)==100
                                     section_x1=xx;
                                     section_y1=yy;
                                     while section_y1>2 && section_y1<Y-2 && data_normalization(section_x1,section_y1)==0
                                        section_y1=section_y1-1;
                                        ID_regrownmap(section_x1,section_y1)=1;
                                     end
                                     section_b1=yy-section_y1;
                                     section_x2=xx;
                                     section_y2=yy;
                                     while section_y2>2 && section_y2<Y-2 && data_normalization(section_x2,section_y2)==0
                                        section_y2=section_y2+1;
                                        ID_regrownmap(section_x2,section_y2)=1;
                                     end
                                     section_b2=section_y2-yy;
                                     if abs(section_b1-section_b2)<gate_width
                                         section_b=section_b1+section_b2;
                                     end
                                  end
                                  if singlechannel(x,5*bx-1)==99
                                     section_x1=xx;
                                     section_y1=yy;
                                     while section_x1>2 && section_x1<X-2 && data_normalization(section_x1,section_y1)==0 
                                         section_x1=section_x1-1;
                                         ID_regrownmap(section_x1,section_y1)=1;
                                     end
                                     section_b1=xx-section_x1;
                                     section_x2=xx;
                                     section_y2=yy;
                                     while section_x2>2 && section_x2<X-2 && data_normalization(section_x2,section_y2)==0
                                           section_x2=section_x2+1;
                                           ID_regrownmap(section_x2,section_y2)=1;
                                     end
                                     section_b2=section_x2-xx;
                                     if abs(section_b1-section_b2)<gate_width
                                         section_b=section_b1+section_b2;
                                     end
                                  end
                                  if singlechannel(x,5*bx-1)==1
                                      section_x1=xx;
                                      section_y1=yy;
                                      while section_x1>2 && section_x1<X-2 && section_y1>2 && section_y1<Y-2 && data_normalization(section_x1,section_y1)==0 
                                           section_y1=section_y1-1;
                                           section_x1=section_x1+1;
                                           ID_regrownmap(section_x1,section_y1)=1;
                                      end
                                      section_b1=sqrt((yy-section_y1)^2+(xx-section_x1)^2);
                                      section_x2=xx;
                                      section_y2=yy;
                                      while section_x2>2 && section_x2<X-2 && section_y2>2 && section_y2<Y-2 && data_normalization(section_x2,section_y2)==0 
                                         section_y2=section_y2+1;
                                         section_x2=section_x2-1;
                                         ID_regrownmap(section_x2,section_y2)=1;
                                      end
                                      section_b2=sqrt((section_y2-yy)^2+(section_x2-xx)^2);
                                      if abs(section_b1-section_b2)<gate_width
                                          section_b=section_b1+section_b2;
                                      end
                                  end
                                  if singlechannel(x,5*bx-1)==-1
                                      section_x1=xx;
                                      section_y1=yy;
                                      while section_x1>2 && section_x1<X-2 && section_y1>2 && section_y1<Y-2 && data_normalization(section_x1,section_y1)==0 
                                         section_y1=section_y1+1;
                                         section_x1=section_x1+1;
                                         ID_regrownmap(section_x1,section_y1)=1;
                                      end
                                      section_b1=sqrt((yy-section_y1)^2+(xx-section_x1)^2);
                                      section_x2=xx;
                                      section_y2=yy;
                                      while section_x2>2 && section_x2<X-2 && section_y2>2 && section_y2<Y-2 && data_normalization(section_x2,section_y2)==0 
                                         section_y2=section_y2-1;
                                         section_x2=section_x2-1;
                                         ID_regrownmap(section_x2,section_y2)=1;
                                      end
                                      section_b2=sqrt((section_y2-yy)^2+(section_x2-xx)^2);
                                      if abs(section_b1-section_b2)<gate_width
                                         section_b=section_b1+section_b2;
                                      end
                                  end
                               if singlechannel(x,5*bx-1)==2
                                      section_x1=xx;
                                      section_y1=yy;
                                  while section_x1>2 && section_x1<X-2 && section_y1>2 && section_y1<Y-2 && data_normalization(section_x1,section_y1)==0 
                                      section_y1=section_y1+2;
                                      section_x1=section_x1-1;
                                      ID_regrownmap(section_x1,section_y1)=1;
                                  end
                                  section_b1=sqrt((yy-section_y1)^2+(xx-section_x1)^2);
                                  section_x2=xx;
                                  section_y2=yy;
                                  while section_x2>2 && section_x2<X-2 && section_y2>2 && section_y2<Y-2 && data_normalization(section_x2,section_y2)==0
                                     section_y2=section_y2-2;
                                     section_x2=section_x2+1;
                                     ID_regrownmap(section_x2,section_y2)=1;
                                  end
                                  section_b2=sqrt((section_y2-yy)^2+(section_x2-xx)^2);
                                  if abs(section_b1-section_b2)<gate_width
                                      section_b=section_b1+section_b2;
                                  end
                               end
                               if singlechannel(x,5*bx-1)==-2
                                  section_x1=xx;
                                  section_y1=yy; 
                                  while section_x1>2 && section_x1<X-2 && section_y1>2 && section_y1<Y-2 && data_normalization(section_x1,section_y1)==0 
                                     section_y1=section_y1-2;
                                     section_x1=section_x1-1;
                                     ID_regrownmap(section_x1,section_y1)=1;
                                  end
                                  section_b1=sqrt((yy-section_y1)^2+(xx-section_x1)^2);
                                  section_x2=xx;
                                  section_y2=yy;
                                  while section_x2>2 && section_x2<X-2 && section_y2>2 && section_y2<Y-2 && data_normalization(section_x2,section_y2)==0
                                      section_y2=section_y2+2;
                                      section_x2=section_x2+1;
                                      ID_regrownmap(section_x2,section_y2)=1;
                                  end
                                  section_b2=sqrt((section_y2-yy)^2+(section_x2-xx)^2);
                                  if abs(section_b1-section_b2)<gate_width
                                      section_b=section_b1+section_b2;
                                  end
                               end
                            if singlechannel(x,5*bx-1)==0.5
                                  section_x1=xx;
                                  section_y1=yy;
                                  while section_x1>2 && section_x1<X-2 && section_y1>2 && section_y1<Y-2 && data_normalization(section_x1,section_y1)==0  
                                     section_y1=section_y1-1;
                                     section_x1=section_x1+2;
                                     ID_regrownmap(section_x1,section_y1)=1;
                                  end
                                  section_b1=sqrt((yy-section_y1)^2+(xx-section_x1)^2);
                                  section_x2=xx;
                                  section_y2=yy;
                                  while section_x2>2 && section_x2<X-2 && section_y2>2 && section_y2<Y-2 && data_normalization(section_x2,section_y2)==0
                                     section_y2=section_y2+1;
                                     section_x2=section_x2-2;
                                     ID_regrownmap(section_x2,section_y2)=1;
                                  end
                                  section_b2=sqrt((section_y2-yy)^2+(section_x2-xx)^2);
                                  if abs(section_b1-section_b2)<10
                                      section_b=section_b1+section_b2;
                                  end
                            end
                            if singlechannel(x,5*bx-1)==-0.5
                                  section_x1=xx;
                                  section_y1=yy;
                                  while section_x1>2 && section_x1<X-2 && section_y1>2 && section_y1<Y-2 && data_normalization(section_x1,section_y1)==0
                                     section_y1=section_y1-1;
                                     section_x1=section_x1-2;
                                     ID_regrownmap(section_x1,section_y1)=1;
                                  end
                                  section_b1=sqrt((yy-section_y1)^2+(xx-section_x1)^2);
                                  section_x2=xx;
                                  section_y2=yy;
                                  while section_x2>2 && section_x2<X-2 && section_y2>2 && section_y2<Y-2 && data_normalization(section_x2,section_y2)==0
                                     section_y2=section_y2+1;
                                     section_x2=section_x2+2;
                                     ID_regrownmap(section_x2,section_y2)=1;
                                  end
                                  section_b2=sqrt((section_y2-yy)^2+(section_x2-xx)^2);
                                  if abs(section_b1-section_b2)<gate_width
                                      section_b=section_b1+section_b2;
                                  end        
                            end
                            singlechannel(x,5*bx)=section_b*re;
                            data_node_binary5(bx,x_end,1)=section_b*re;
                            if singlechannel(x,5*bx-1)==99
                               macrochannel_width(xx,1)=macrochannel_width(xx,1)+1;
                           else
                               macrochannel_width(xx,1)=macrochannel_width(xx,1)+section_b;
                            end
                                  end
                                  end
                              end
                            end
                            end
                        end
                      end
                  end
              end
              if onlytwo_xxx==0
                for seednum=1:8
                  if ~(tem_seed(seednum,1)==0)
                  a1=1;
                  a2=1;
                      for ps=1:point_startnum
                          a1=a1*(tem_seed(seednum,1)-singlechannel(ps,5*bx-4));
                          a2=a2*(tem_seed(seednum,2)-singlechannel(ps,5*bx-3));
                      end
                      if ~(a1==0) || ~(a2==0)
                        if data_planeindex_RGB(tem_seed(seednum,1),tem_seed(seednum,2),1)==255 && data_planeindex_RGB(tem_seed(seednum,1),tem_seed(seednum,2),2)==255
                               xxx=tem_seed(seednum,1);
                               yyy=tem_seed(seednum,2);
                        end
                      end
                  end
                end
              end
              if ~(xxx==0)
                 a3=2;
                 while a3<3 && a3>1 && n0<500 && xxx>2 && xxx<X-1 && yyy>2 && yyy<Y-1 
                    tem_seed1=zeros(8,2);
                    a3=0;
                    if data_binary(xxx-1,yyy-1)==1
                       tem_seed1(1,1)=xxx-1;
                       tem_seed1(1,2)=yyy-1;
                       a3=a3+1;
                    end
                    if data_binary(xxx-1,yyy)==1
                       tem_seed1(2,1)=xxx-1;
                       tem_seed1(2,2)=yyy;
                       a3=a3+1;
                    end
                    if yyy<Y-1 && data_binary(xxx-1,yyy+1)==1
                       tem_seed1(3,1)=xxx-1;
                       tem_seed1(3,2)=yyy+1;
                       a3=a3+1;
                    end
                   if yyy<Y-1 && data_binary(xxx,yyy+1)==1
                       tem_seed1(4,1)=xxx;
                       tem_seed1(4,2)=yyy+1;
                       a3=a3+1;
                   end
                   if yyy<Y-1 && data_binary(xxx+1,yyy+1)==1
                      tem_seed1(5,1)=xxx+1;
                      tem_seed1(5,2)=yyy+1;
                      a3=a3+1;
                   end
                   if data_binary(xxx+1,yyy)==1
                      tem_seed1(6,1)=xxx+1;
                      tem_seed1(6,2)=yyy;
                      a3=a3+1;
                   end
                   if data_binary(xxx+1,yyy-1)==1
                      tem_seed1(7,1)=xxx+1;
                      tem_seed1(7,2)=yyy-1;
                      a3=a3+1;
                   end
                   if data_binary(xxx,yyy-1)==1
                      tem_seed1(8,1)=xxx;
                      tem_seed1(8,2)=yyy-1;
                      a3=a3+1;
                   end
                   if a3==2
                      for seednum=1:8
                         if ~(tem_seed1(seednum,1)==0) && ~(tem_seed1(seednum,2)==0)
                           if ~(tem_seed1(seednum,1)==xx) || ~(tem_seed1(seednum,2)==yy)
                             C=tem_seed1(seednum,1);
                             D=tem_seed1(seednum,2);
                           end
                         end
                      end
                             length_curve_i=length_curve_i+sqrt((xxx-xx)^2+(yyy-yy)^2);
                             data_planeindex_RGB(xxx,yyy,1)=255;
                             data_planeindex_RGB(xxx,yyy,2)=255;
                             data_planeindex_RGB(xxx,yyy,3)=0;
                             slop_y=C-xx;
                             slop_x=D-yy;
                             if slop_x==0
                                  singlechannel(point_startnum+n0,5*bx-1)=100;  % vertical
                             else if slop_y==0
                                  singlechannel(point_startnum+n0,5*bx-1)=99;   % horizontal
                                  else
                                  singlechannel(point_startnum+n0,5*bx-1)=slop_y/slop_x;
                                  end
                             end
                             section_b=0;
                                 if singlechannel(point_startnum+n0,5*bx-1)==100
                                     section_x1=xxx;
                                     section_y1=yyy;
                                     while data_normalization(section_x1,section_y1)==0 && section_y1>2 && section_y1<Y-2
                                        section_y1=section_y1-1;
                                        ID_regrownmap(section_x1,section_y1)=1;
                                     end
                                     section_b1=yyy-section_y1;
                                     section_x2=xxx;
                                     section_y2=yyy;
                                     while data_normalization(section_x2,section_y2)==0 && section_y2>2 && section_y2<Y-2
                                        section_y2=section_y2+1;
                                        ID_regrownmap(section_x2,section_y2)=1;
                                     end
                                     section_b2=section_y2-yyy;
                                     if abs(section_b1-section_b2)<gate_width
                                         section_b=section_b1+section_b2;
                                         width_num=width_num+1;
                                     end
                                  end
                                  if singlechannel(point_startnum+n0,5*bx-1)==99
                                     section_x1=xxx;
                                     section_y1=yyy;
                                     while section_x1>2 && section_x1<X-2 && data_normalization(section_x1,section_y1)==0  
                                         section_x1=section_x1-1;
                                         ID_regrownmap(section_x1,section_y1)=1;
                                     end
                                     section_b1=xxx-section_x1;
                                     section_x2=xxx;
                                     section_y2=yyy;
                                     while section_x2>2 && section_x2<X-2 && data_normalization(section_x2,section_y2)==0 
                                           section_x2=section_x2+1;
                                           ID_regrownmap(section_x2,section_y2)=1;
                                     end
                                     section_b2=section_x2-xxx;
                                     if abs(section_b1-section_b2)<gate_width
                                         section_b=section_b1+section_b2;
                                         width_num=width_num+1;
                                     end
                                  end
                                  if singlechannel(point_startnum+n0,5*bx-1)==1
                                      section_x1=xxx;
                                      section_y1=yyy;
                                      while section_x1>2 && section_x1<X-2 && section_y1>2 && section_y1<Y-2 && data_normalization(section_x1,section_y1)==0 
                                           section_y1=section_y1-1;
                                           section_x1=section_x1+1;
                                           ID_regrownmap(section_x1,section_y1)=1;
                                      end
                                      section_b1=sqrt((yyy-section_y1)^2+(xxx-section_x1)^2);
                                      section_x2=xxx;
                                      section_y2=yyy;
                                      while section_x2>2 && section_x2<X-2 && section_y2>2 && section_y2<Y-2 && data_normalization(section_x2,section_y2)==0 
                                         section_y2=section_y2+1;
                                         section_x2=section_x2-1;
                                         ID_regrownmap(section_x2,section_y2)=1;
                                      end
                                      section_b2=sqrt((section_y2-yyy)^2+(section_x2-xxx)^2);
                                      if abs(section_b1-section_b2)<gate_width
                                          section_b=section_b1+section_b2;
                                          width_num=width_num+1;
                                      end
                                  end
                                  if singlechannel(point_startnum+n0,5*bx-1)==-1
                                      section_x1=xxx;
                                      section_y1=yyy;
                                      while section_x1>2 && section_x1<X-2 && section_y1>2 && section_y1<Y-2 && data_normalization(section_x1,section_y1)==0
                                         section_y1=section_y1+1;
                                         section_x1=section_x1+1;
                                         ID_regrownmap(section_x1,section_y1)=1;
                                      end
                                      section_b1=sqrt((yyy-section_y1)^2+(xxx-section_x1)^2);
                                      section_x2=xxx;
                                      section_y2=yyy;
                                      while section_x2>2 && section_x2<X-2 && section_y2>2 && section_y2<Y-2 && data_normalization(section_x2,section_y2)==0  
                                         section_y2=section_y2-1;
                                         section_x2=section_x2-1;
                                         ID_regrownmap(section_x2,section_y2)=1;
                                      end
                                      section_b2=sqrt((section_y2-yyy)^2+(section_x2-xxx)^2);
                                      if abs(section_b1-section_b2)<gate_width
                                         section_b=section_b1+section_b2;
                                         width_num=width_num+1;
                                      end
                                  end
                               if singlechannel(point_startnum+n0,5*bx-1)==2
                                      section_x1=xxx;
                                      section_y1=yyy;
                                  while section_x1>2 && section_x1<X-2 && section_y1>2 && section_y1<Y-2 && data_normalization(section_x1,section_y1)==0 
                                      section_y1=section_y1+2;
                                      section_x1=section_x1-1;
                                      ID_regrownmap(section_x1,section_y1)=1;
                                  end
                                  section_b1=sqrt((yyy-section_y1)^2+(xxx-section_x1)^2);
                                  section_x2=xxx;
                                  section_y2=yyy;
                                  while section_x2<X-2 && section_y2>2 && section_y2<Y-2 && section_x2>2 && data_normalization(section_x2,section_y2)==0 
                                     section_y2=section_y2-2;
                                     section_x2=section_x2+1;
                                     ID_regrownmap(section_x2,section_y2)=1;
                                  end
                                  section_b2=sqrt((section_y2-yyy)^2+(section_x2-xxx)^2);
                                  if abs(section_b1-section_b2)<gate_width
                                      section_b=section_b1+section_b2;
                                      width_num=width_num+1;
                                  end
                               end
                               if singlechannel(point_startnum+n0,5*bx-1)==-2
                                  section_x1=xxx;
                                  section_y1=yyy; 
                                  while section_x1>2 && section_x1<X-2 && section_y1>2 && section_y1<Y-2 && data_normalization(section_x1,section_y1)==0
                                     section_y1=section_y1-2;
                                     section_x1=section_x1-1;
                                     ID_regrownmap(section_x1,section_y1)=1;
                                  end
                                  section_b1=sqrt((yyy-section_y1)^2+(xxx-section_x1)^2);
                                  section_x2=xxx;
                                  section_y2=yyy;
                                  while section_x2>2 && section_x2<X-2 && section_y2>2 && section_y2<Y-2 && data_normalization(section_x2,section_y2)==0
                                      section_y2=section_y2+2;
                                      section_x2=section_x2+1;
                                      ID_regrownmap(section_x2,section_y2)=1;
                                  end
                                  section_b2=sqrt((section_y2-yyy)^2+(section_x2-xxx)^2);
                                  if abs(section_b1-section_b2)<gate_width
                                      section_b=section_b1+section_b2;
                                      width_num=width_num+1;
                                  end
                               end
                            if singlechannel(point_startnum+n0,5*bx-1)==0.5
                                  section_x1=xxx;
                                  section_y1=yyy;
                                  while section_x1<X-2 && section_y1>2 && section_y1<Y-2 && data_normalization(section_x1,section_y1)==0 && section_x1>1
                                     section_y1=section_y1-1;
                                     section_x1=section_x1+2;
                                     ID_regrownmap(section_x1,section_y1)=1;
                                  end
                                  section_b1=sqrt((yyy-section_y1)^2+(xxx-section_x1)^2);
                                  section_x2=xxx;
                                  section_y2=yyy;
                                  while section_x2>2 && section_x2<X-2 && section_y2>2 && section_y2<Y-2 && data_normalization(section_x2,section_y2)==0
                                     section_y2=section_y2+1;
                                     section_x2=section_x2-2;
                                     ID_regrownmap(section_x2,section_y2)=1;
                                  end
                                  section_b2=sqrt((section_y2-yyy)^2+(section_x2-xxx)^2);
                                  if abs(section_b1-section_b2)<10
                                      section_b=section_b1+section_b2;
                                      width_num=width_num+1;
                                  end
                            end
                            if singlechannel(point_startnum+n0,5*bx-1)==-0.5
                                  section_x1=xxx;
                                  section_y1=yyy;
                                  while section_x1>2 && section_x1<X-2 && section_y1>2 && section_y1<Y-1 && data_normalization(section_x1,section_y1)==0
                                     section_y1=section_y1-1;
                                     section_x1=section_x1-2;
                                     ID_regrownmap(section_x1,section_y1)=1;
                                  end
                                  section_b1=sqrt((yyy-section_y1)^2+(xxx-section_x1)^2);
                                  section_x2=xxx;
                                  section_y2=yyy;
                                  while section_x2>2 && section_x2<X-2 && section_y2>2 && section_y2<Y-2 && data_normalization(section_x2,section_y2)==0
                                     section_y2=section_y2+1;
                                     section_x2=section_x2+2;
                                     ID_regrownmap(section_x2,section_y2)=1;
                                  end
                                  section_b2=sqrt((section_y2-yyy)^2+(section_x2-xxx)^2);
                                  if abs(section_b1-section_b2)<gate_width
                                      section_b=section_b1+section_b2;
                                      width_num=width_num+1;
                                  end        
                            end
                            singlechannel(point_startnum+n0,5*bx)=section_b*re;
                            sum_sectionb=sum_sectionb+singlechannel(point_startnum+n0,5*bx);
                            if singlechannel(point_startnum+n0,5*bx-1)==99
                               macrochannel_width(xxx,1)=macrochannel_width(xxx,1)+1;
                           else
                               macrochannel_width(xxx,1)=macrochannel_width(xxx,1)+section_b;
                           end
                             xx=xxx;
                             yy=yyy;
                             singlechannel(point_startnum+n0,5*bx-4)=xxx;
                             singlechannel(point_startnum+n0,5*bx-3)=yyy;
                             singlechannel(point_startnum+n0,5*bx-2)=x;
                             xxx=C;
                             yyy=D;
                             n0=n0+1;
                   end
                   xxx_end=0;
                   yyy_end=0;
                   if ~(a3==2)
                       if ~(data_planeindex_RGB(xxx,yyy,1)==255) || ~(data_planeindex_RGB(xxx,yyy,2)==255)
                           if ~(data_planeindex_RGB(xxx,yyy,3)==1)
                           xxx_end=xxx;
                           yyy_end=yyy;
                           end
                           if data_planeindex_RGB(xxx,yyy,3)==1
                           xxx_end=bifurcation_neighbor(xxx,yyy,1);
                           yyy_end=bifurcation_neighbor(xxx,yyy,2);
                           end
                       else
                           for seednum=1:8
                               if ~(tem_seed1(seednum,1)==0) && data_planeindex_RGB(tem_seed1(seednum,1),tem_seed1(seednum,2),1)==255 && data_planeindex_RGB(tem_seed1(seednum,1),tem_seed1(seednum,2),2)==0 && data_planeindex_RGB(tem_seed1(seednum,1),tem_seed1(seednum,2),3)==0
                                   xxx_end=tem_seed1(seednum,1);
                                   yyy_end=tem_seed1(seednum,2);
                               end
                               if ~(tem_seed1(seednum,1)==0) && data_planeindex_RGB(tem_seed1(seednum,1),tem_seed1(seednum,2),1)==255 && data_planeindex_RGB(tem_seed1(seednum,1),tem_seed1(seednum,2),2)==0 && data_planeindex_RGB(tem_seed1(seednum,1),tem_seed1(seednum,2),3)==1
                                   xxx_end=bifurcation_neighbor(tem_seed1(seednum,1),tem_seed1(seednum,2),1);
                                   yyy_end=bifurcation_neighbor(tem_seed1(seednum,1),tem_seed1(seednum,2),2);
                               end
                           end
                       end
                       if ~(xxx_end==0)
                           length_straight_i=sqrt((singlechannel(x,5*bx-4)-xx)^2+(singlechannel(x,5*bx-3)-yy)^2);
                           qulv=length_curve_i/length_straight_i;
                           if width_num>0
                               mean_width_i=sum_sectionb/width_num;
                           else
                               mean_width_i=0;
                           end
                           for x_end=1:point_num
                               if xxx_end-data_node(x_end,1)==0 && yyy_end-data_node(x_end,2)==0
                                   if data_node(bx,3)==2 && data_node(x_end,3)==2
                                       data_node(bx,3)=4;
                                       data_node(x_end,3)=4;
                                   else
                                   data_node_binary1(bx,x_end,1)=data_node_binary1(bx,x_end,1)+1;
                                   data_node_binary2(bx,x_end,1)=length_curve_i*30+90;
                                   data_node_binary3(bx,x_end,1)=length_straight_i*30;
                                   data_node_binary4(bx,x_end,1)=qulv;
                                   data_node_binary5(bx,x_end,1)= mean_width_i;
                                   linknum=linknum+1;
                                   end
                               end
                           end
                       end
                   end
                 end
              end
          end
    end
end
figure
fig4=imshow(data_planeindex_RGB);
saveas(fig4,'nodeskeleton.fig');
data_regrownmap=zeros(X,Y,3);
for x=1:X
    for y=1:Y
        if  ID_regrownmap(x,y)==1
            data_regrownmap(x,y,1)=0;
            data_regrownmap(x,y,2)=0;
            data_regrownmap(x,y,3)=255;
        else
            data_regrownmap(x,y,1)=255;
            data_regrownmap(x,y,2)=255;
            data_regrownmap(x,y,3)=255;
        end
    end
end
figure
fig5=imshow(data_regrownmap);
saveas(fig5,'regrownmap.fig');
data_node_new=zeros(point_num,3);
nodenew_a=1;
nodenew_b=1;
for nodenew=1:point_num
    if data_node(nodenew,3)==4
        data_binarynode_remove(nodenew_b,1)=nodenew;
        nodenew_b=nodenew_b+1;
    else
        data_node_new(nodenew_a,1)=data_node(nodenew,1);
        data_node_new(nodenew_a,2)=data_node(nodenew,2);
        data_node_new(nodenew_a,3)=data_node(nodenew,3);
        nodenew_a=nodenew_a+1;
    end
end
nodenew1=1;
nodenew2=1;
nodenew_xx=1;
nodenew_yy=1;
for nodenew_x=1:point_num
    if nodenew1<nodenew_b && nodenew_x==data_binarynode_remove(nodenew1,1)
        nodenew1=nodenew1+1;
    else
        for nodenew_y=1:point_num
            data_node_binary1_new(nodenew_xx,nodenew_y)=data_node_binary1(nodenew_x,nodenew_y);
            data_node_binary2_new(nodenew_xx,nodenew_y)=data_node_binary2(nodenew_x,nodenew_y);
            data_node_binary3_new(nodenew_xx,nodenew_y)=data_node_binary3(nodenew_x,nodenew_y);
            data_node_binary4_new(nodenew_xx,nodenew_y)=data_node_binary4(nodenew_x,nodenew_y);
            data_node_binary5_new(nodenew_xx,nodenew_y)=data_node_binary5(nodenew_x,nodenew_y);
        end
        nodenew_xx=1+nodenew_xx; 
    end
end
for nodenew_y=1:point_num
    if nodenew2<nodenew_b && nodenew_y==data_binarynode_remove(nodenew2,1)
        nodenew2=nodenew2+1;
    else
        for nodenew_x=1:nodenew_xx-1
            data_node_binary1_new1(nodenew_x,nodenew_yy)=data_node_binary1_new(nodenew_x,nodenew_y);
            data_node_binary2_new2(nodenew_x,nodenew_yy)=data_node_binary2_new(nodenew_x,nodenew_y);
            data_node_binary3_new3(nodenew_x,nodenew_yy)=data_node_binary3_new(nodenew_x,nodenew_y);
            data_node_binary4_new4(nodenew_x,nodenew_yy)=data_node_binary4_new(nodenew_x,nodenew_y);
            data_node_binary5_new5(nodenew_x,nodenew_yy)=data_node_binary5_new(nodenew_x,nodenew_y);
        end
        nodenew_yy=nodenew_yy+1;
    end
end
%data_summary(year,3)=nodenew_xx-1;
%data_summary(year,4)=linknum;
fid1=fopen('connectivity_matrix.txt');
dlmwrite('connectivity_matrix.txt',data_node_binary1_new1);
fclose(fid1);
fid2=fopen('curve_length_matrix.txt');
dlmwrite('curve_length_matrix.txt',data_node_binary2_new2);
fclose(fid2);
fid3=fopen('sinuosity_matrix.txt');
dlmwrite('sinuosity_matrix.txt',data_node_binary4_new4);
fclose(fid3);
fid4=fopen('width_matrix.txt');
dlmwrite('width_matrix.txt',data_node_binary5_new5);
fclose(fid4);
totalnum_link=0;
for link_x=1:nodenew_xx-2
    for link_y=link_x+1:nodenew_xx-1
        totalnum_link=data_node_binary1_new1(link_x,link_y)+totalnum_link;
    end
end
totalnum_link1=0;
for link_x1=1:nodenew_xx-2
    for link_y1=link_x1+1:nodenew_xx-1
        if data_node_binary5_new5(link_x1,link_y1)>0
        totalnum_link1=totalnum_link1+1;
        end
    end
end
% connectivity matrix
[N,N]=size(data_node_binary1_new1);
figure
for i=0:N
    line([i i],[0 N],'color',[0.5,0.5,0.5])
    hold on
end
for i=0:N
    line([0 N],[i i],'color',[0.5,0.5,0.5])
    hold on
end
for i=1:N
    for j=1:N
        if data_node_binary1_new1(i,j)>0
            fill([j-1 j j j-1],[i i i-1 i-1],[0,0,0])
            hold on
        end
    end
end
% curve length matrix
figure
for i=0:N
    line([i i],[0 N],'color',[0.5,0.5,0.5])
    hold on
end
for i=0:N
    line([0 N],[i i],'color',[0.5,0.5,0.5])
    hold on
end
for i=1:N
    for j=1:N
        if data_node_binary2_new2(i,j)>4000
            fill([j-1 j j j-1],[i i i-1 i-1],[0,1,0])
            hold on
        end
        if data_node_binary2_new2(i,j)>3000 && ~(data_node_binary2_new2(i,j)>4000)
            fill([j-1 j j j-1],[i i i-1 i-1],[0,1,0.5])
            hold on
        end
        if data_node_binary2_new2(i,j)>2000 && ~(data_node_binary2_new2(i,j)>3000)
            fill([j-1 j j j-1],[i i i-1 i-1],[0,0,1])
            hold on
        end
        if data_node_binary2_new2(i,j)>1000 && ~(data_node_binary2_new2(i,j)>2000)
            fill([j-1 j j j-1],[i i i-1 i-1],[0.42,0.35,0.8])
            hold on
        end
        if data_node_binary2_new2(i,j)>0 && ~(data_node_binary2_new2(i,j)>1000)
            fill([j-1 j j j-1],[i i i-1 i-1],[0.53,0.81,0.92])
            hold on
        end
    end
end
% sinuousity matrix
figure
for i=0:N
    line([i i],[0 N],'color',[0.5,0.5,0.5])
    hold on
end
for i=0:N
    line([0 N],[i i],'color',[0.5,0.5,0.5])
    hold on
end
for i=1:N
    for j=1:N
        if data_node_binary4_new4(i,j)>1.2
            fill([j-1 j j j-1],[i i i-1 i-1],[0,1,0])
            hold on
        end
        if data_node_binary4_new4(i,j)>1.15 && ~(data_node_binary4_new4(i,j)>1.2)
            fill([j-1 j j j-1],[i i i-1 i-1],[0,1,0.5])
            hold on
        end
        if data_node_binary4_new4(i,j)>1.1 && ~(data_node_binary4_new4(i,j)>1.15)
            fill([j-1 j j j-1],[i i i-1 i-1],[0,0,1])
            hold on
        end
        if data_node_binary4_new4(i,j)>1.05 && ~(data_node_binary4_new4(i,j)>1.1)
            fill([j-1 j j j-1],[i i i-1 i-1],[0.42,0.35,0.8])
            hold on
        end
        if data_node_binary4_new4(i,j)>1 && ~(data_node_binary4_new4(i,j)>1.05)
            fill([j-1 j j j-1],[i i i-1 i-1],[0.53,0.81,0.92])
            hold on
        end
    end
end
% channel width matrix
figure
for i=0:N
    line([i i],[0 N],'color',[0.5,0.5,0.5])
    hold on
end
for i=0:N
    line([0 N],[i i],'color',[0.5,0.5,0.5])
    hold on
end
for i=1:N
    for j=1:N
        if data_node_binary5_new5(i,j)>2000
            fill([j-1 j j j-1],[i i i-1 i-1],[0,1,0])
            hold on
        end
        if data_node_binary5_new5(i,j)>1500 && ~(data_node_binary5_new5(i,j)>2000)
            fill([j-1 j j j-1],[i i i-1 i-1],[0,1,0.5])
            hold on
        end
        if data_node_binary5_new5(i,j)>1000 && ~(data_node_binary5_new5(i,j)>1500)
            fill([j-1 j j j-1],[i i i-1 i-1],[0,0,1])
            hold on
        end
        if data_node_binary5_new5(i,j)>500 && ~(data_node_binary5_new5(i,j)>1000)
            fill([j-1 j j j-1],[i i i-1 i-1],[0.42,0.35,0.8])
            hold on
        end
        if data_node_binary5_new5(i,j)>0 && ~(data_node_binary5_new5(i,j)>500)
            fill([j-1 j j j-1],[i i i-1 i-1],[0.53,0.81,0.92])
            hold on
        end
    end
end
%data_summary(year,5)= totalnum_link;
%xlswrite('output_summary.xlsx',data_summary)
%xlswrite('output_summary.xlsx',data_channelnode_num,1)
%xlswrite('output_summary.xlsx',data_node,2)
%xlswrite('output_summary.xlsx',data_node_new,3)
%xlswrite('output_summary.xlsx',data_summary,4)
%xlswrite('output_summary.xlsx',macrochannel_width,5)



