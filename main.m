close all
clc
[fn,pn,fi]=uigetfile('测试用图片\*.jpg','选择图片');
YuanShiTu=imread([pn fn]);  %输入原始图像,并保存在YuanShiTu中
figure(1),imshow(YuanShiTu);title('原图')
%车牌定位
% 调用函数1
plateImg1=license_plate_locate(YuanShiTu);
%调用函数2
plateImg2 = licensePlateCut(YuanShiTu);

figure;
subplot(121); imshow(plateImg1); title('定位结果1：形态学变换');
subplot(122); imshow(plateImg2); title('定位结果2：颜色空间分析法');

%结果选取

% 检查数组大小是否一致
if isequal(size(plateImg2), size(YuanShiTu))
    % 如果大小一致，再进行比较
    if isequal(plateImg2, YuanShiTu)
        plateImg = plateImg1;
        disp("选用方案一");
    else
        plateImg = plateImg2;
        disp("选用方案二");
    end
else
    % 如果大小不一致，直接选择方案二
    plateImg = plateImg2;
    disp("选用方案二（因大小不一致）");
end

%车牌校正
% 倾斜校正
correctedImg = correctLicensePlateTilt(plateImg);

% 显示结果
figure;
subplot(1, 2, 1), imshow(plateImg), title('校正前的图像');
subplot(1, 2, 2), imshow(correctedImg), title('校正后的图像');

%边界校正（去边框）
[y2,x2,~]=size(correctedImg);
py_y1=round(y2*8/140);
py_y2=y2-py_y1;
px_x1=round(x2*14/440);
px_x2=x2-px_x1;

I0=correctedImg(py_y1:py_y2,px_x1:px_x2,:);
figure;
imshow(I0);


%字符分割

%二值化并去除多余像素

I=im2bw(I0,graythresh(I0));
I2=bwareaopen(I,60);
figure;imshow(I2);
I21=imresize(I2,[140,440]);
figure;imshow(I21);

%固定值切割
% 示例参数
totalWidth = 440;          % 车牌总宽度 (mm)
charRegions = [60, 50, 225]; % 各区域宽度 (mm): 汉字区, 字母区, 序号区
margins = [10, 10];        % 左右边距 (mm)
targetSize = [140, 440];   % 目标图像尺寸 [高度, 宽度]
charCount = 7;             % 字符数量

% 调用函数
charCells = licensePlateProcessing(I2, totalWidth, charRegions, margins, targetSize, charCount);

% %垂直投影法




% 添加边界检查


% %文本匹配
liccode=char(['0':'9','A':'H','J':'N','P':'Z','京津冀晋蒙辽吉黑沪苏浙皖闽赣鲁豫鄂湘粤桂琼港渝川贵云藏陕甘青宁新']);
%缺“台”、“澳”
for m = 1:7
    ii = imread(strcat(int2str(m), ".bmp"));
    for j = 1:length(liccode)
        templatePath = fullfile('字符模板', [liccode(j), '.bmp']);

        % 检查文件是否存在
        if ~exist(templatePath, 'file')
            warning('模板文件不存在: %s', templatePath);
            continue;
        end

        jj = imread(templatePath);

        % 检查是否读取成功
        if isempty(jj)
            warning('无法读取模板文件: %s', templatePath);
            continue;
        end

        % 如果是 logical 类型，转换为数值类型
        if islogical(jj)
            jj = double(jj);  % 转换为 double 类型
        end

        % 如果是彩色图像，先转换为灰度图像
        if size(jj, 3) == 3
            jj = rgb2gray(jj);
        end

        tt2 = im2bw(jj, graythresh(jj));

        if m == 1 && j >= 35
            A(j) = corr2(ii, tt2);
        end
        if m == 2 && j >= 11 && j <= 34
            A(j) = corr2(ii, tt2);
        end
        if m >= 3 && j <= 34
            A(j) = corr2(ii, tt2);
        end
    end

    [~, findc] = max(A);
    B(m) = findc;
    A(:) = 0;
end

xlabel(liccode(B));