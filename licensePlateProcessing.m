function charCells = licensePlateProcessing(binaryImg, totalWidth, charRegions, margins, targetSize, charCount)
    % 输入：
    % binaryImg - 二值化车牌图像（逻辑矩阵）
    % totalWidth - 车牌总宽度（毫米）
    % charRegions - 各区域宽度（毫米），例如：[汉字区, 字母区, 序号区]
    % margins - 左右边距（毫米），例如：[左边距, 右边距]
    % targetSize - 目标图像尺寸，例如：[高度, 宽度]
    % charCount - 字符数量
    % 输出：
    % charCells - 切割后的字符区域（cell数组）
    
    %% 图像归一化处理
    resizedImg = imresize(binaryImg, targetSize, 'bilinear');
    
    %% 计算固定切割位置（像素）
    pixelPositions = cumsum([margins(1), charRegions]) / totalWidth * targetSize(2);
    pixelPositions = round(pixelPositions);
    
    %% 字符区域切割
    charCells = cell(1, charCount); % 根据charCount设置字符区域数量
    % 前两个字符（汉字和字母）
    if charCount >= 2
        charCells{1} = resizedImg(:, pixelPositions(1):pixelPositions(2)-1);
        charCells{2} = resizedImg(:, pixelPositions(2):pixelPositions(3)-1);
    end
    
    % 剩余字符（序号区）
    % 3. 序号区切割（5位字符）
    startPos = pixelPositions(3)+30;
    charWidth = round((targetSize(2)-startPos)/5); % 固定字符宽度
    for i = 3:7
        charCells{i} = resizedImg(:, startPos:startPos+charWidth-1);
        startPos = startPos + charWidth;
    end
    
    %% 可视化验证
    figure;
    for i = 1:charCount
        subplot(1, charCount, i);
        imshow(charCells{i});
        title(['字符', num2str(i)]);
        % 保存为 BMP 文件
        charImg = imresize(charCells{i}, [40, 20]);
        imwrite(charImg, [ num2str(i) '.bmp']);
    end
end