function dw=license_plate_locate(I)

    I1=rgb2gray(I);%功能是将真彩色图像转换为灰度图像，即灰度化处理,使图像占用空间减少
    figure(2),subplot(1,2,1),imshow(I1);title('灰度图');
    figure(2),subplot(1,2,2),imhist(I1);title('灰度图直方图');

    %% 边缘检测  进行特征提取和形状分析
    I2=edge(I1,'Prewitt',0.15,'both');%间距:0.15：敏感度阀值,both 两个方向（水平、垂直）
    %功能是采用I作为它的输入，并返回一个与I相同大小的二值化图像BW，在函数检测到边缘的地方为1，其他地方为0
    figure(3),imshow(I2);title(' Prewitt算子边缘检测')

    %% 腐蚀  减少除车牌外的干扰点
    se=[1;1;1];
    I3=imerode(I2,se);%腐蚀
    figure(4),imshow(I3);title('腐蚀后图像');

    %% 平滑
    se=strel('rectangle',[25,25]);%矩形结构：25*25
    I4=imclose(I3,se);%对图像实现闭运算，平滑图像的轮廓，一般融合榨的缺口，去掉，填补轮廓上的细缝
    figure(5),imshow(I4);title('平滑图像的轮廓');

    %% 从对象中移除小对象
    I5=bwareaopen(I4,2000);%作用是删除二值图像BW中面积小于2000的对象
    figure(6),imshow(I5);title('从对象中移除小对象');

    %% 扫描 切割出车牌
    [y,x]=size(I5);%二维尺寸
    myI=double(I5);%double类型
    Blue_y=zeros(y,1);%产生一个y*1的零针
    for i=1:y
        for j=1:x
            if(myI(i,j,1)==1)%如果myI图像坐标为（i，j）点值为1，即背景颜色为蓝色，blue加一
                Blue_y(i,1)=Blue_y(i,1)+1;%蓝色像素点统计
            end
        end
    end
    [~, MaxY]=max(Blue_y);
    %横方向车牌区域确定
    %temp为向量Blue_y的元素中的最大值，MaxY为该值得索引
    PY1=MaxY;
    while((Blue_y(PY1,1)>=5)&&(PY1>1)) %找车牌最上端
        PY1=PY1-5;
    end
    PY2=MaxY;
    while((Blue_y(PY2,1)>=5)&&(PY2<y)) %找车牌最下端
        PY2=PY2+5;
    end
    IY=I(PY1:PY2,:,:);%获取车牌纵坐标的范围部分
    %竖方向车牌区域确定
    Blue_x=zeros(1,x);%进一步确认x方向的车牌区域
    for j=1:x
        for i=PY1:PY2
            if(myI(i,j,1)==1)
                Blue_x(1,j)=Blue_x(1,j)+5;
            end
        end
    end
    PX1=1;
    while((Blue_x(1,PX1)<3)&&(PX1<x)) %找车牌x方向的最小值
        PX1=PX1+1;
    end
    PX2=x;
    while((Blue_x(1,PX2)<3)&&(PX2>PX1))%找车牌x方向的最大值
        PX2=PX2-1;
    end

    PX1=PX1-1;%对车牌区域的矫正
    PX2=PX2+1;
    dw=I(PY1:PY2,PX1:PX2,:);%裁剪车牌图像
    %figure(7),imshow(dw),title('定位剪切后的彩色车牌图像')

end



