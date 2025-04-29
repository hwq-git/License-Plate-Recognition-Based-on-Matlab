% 定义字符列表
char_list = [{'A','B','C','D','E','F','G','H','J','K','L','M','N','P','Q','R','S','T','U','V','W','X','Y','Z'}];

% 初始化模板结构体
templates = struct('image', {}, 'width', {});

% 读取模板图像并保存到结构体
for i = 1:length(char_list)
    % 假设模板图像文件名为 char_list{i}.bmp
    template_image = imread([char_list{i}, '.BMP']);
    % 确保图像为二值图像
    template_image = imbinarize(template_image);
    % 获取图像宽度
    template_width = size(template_image, 2);
    % 保存到结构体
    templates(i).image = template_image;
    templates(i).width = template_width;
end

% 保存结构体到 .mat 文件
save('char_templates.mat', 'templates');