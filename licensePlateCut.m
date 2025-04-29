%% 优化后的车牌定位代码
function dw = licensePlateCut(I)
% 参数说明：
% I - 原始彩色图像矩阵
% dw - 输出的车牌区域图像


% 1. 颜色空间转换与通道选择优化
hsv = rgb2hsv(I);  % 转HSV颜色空间更适合颜色分析[4]()
blueMask = (hsv(:,:,1) > 0.55 & hsv(:,:,1) < 0.65) & ...  % 蓝色Hue范围
    (hsv(:,:,2) > 0.3) & ...                       % 饱和度阈值
    (hsv(:,:,3) > 0.3);                            % 明度阈值

% 2. 形态学优化处理（连接断裂区域）
se = strel('rectangle', [5, 7]);  % 根据车牌字符间距调整形态学参数
morphImg = imclose(blueMask, se);
morphImg = bwareaopen(morphImg, 500);  % 去除小面积干扰[4]()

% 3. 投影分析优化（向量化运算提升效率）
% 垂直投影
verticalProj = sum(morphImg, 2);  % 替代原双重循环
[~, MaxY] = max(verticalProj);

% 动态阈值计算（改进固定阈值问题）
dynamicThreshold = 0.3 * max(verticalProj);  % 自适应阈值[4]()

% 垂直边界搜索
PY1 = find(verticalProj(1:MaxY) < dynamicThreshold, 1, 'last') + 1;
PY2 = find(verticalProj(MaxY:end) < dynamicThreshold, 1, 'first') + MaxY - 2;
if isempty(PY1), PY1 = 1; end  % 边界保护
if isempty(PY2), PY2 = size(I,1); end

% 水平投影
horizontalProj = sum(morphImg(PY1:PY2,:), 1);
dynamicThresholdH = 0.3 * max(horizontalProj);

% 水平边界搜索
PX1 = find(horizontalProj > dynamicThresholdH, 1, 'first');
PX2 = find(horizontalProj > dynamicThresholdH, 1, 'last');

% 4. 边界安全处理（防止越界）
PX1 = max(PX1-5, 1);    % 向左扩展5像素
PX2 = min(PX2+5, size(I,2));  % 向右扩展5像素
PY1 = max(PY1-2, 1);    % 向上扩展2像素
PY2 = min(PY2+2, size(I,1));  % 向下扩展2像素

% 5. 最终裁剪与校验
try
    dw = I(PY1:PY2, PX1:PX2, :);
    % 长宽比校验（中国车牌标准3.14:1）
    [h, w, ~] = size(dw);
    aspectRatio = w/h;
    if aspectRatio < 2.5 || aspectRatio > 4  % 允许一定误差[8]()
        error('Invalid aspect ratio');
    end
catch
    % 异常处理：返回原始图像并提示错误
    dw = I;
    disp('方案二车牌定位失败，请检查图像质量或调整参数');

end

% 调试可视化（可选）
% figure;
% subplot(121); plot(verticalProj); title('垂直投影曲线');
% subplot(122); plot(horizontalProj); title('水平投影曲线');
end
