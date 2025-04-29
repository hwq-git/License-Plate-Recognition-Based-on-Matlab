function correctedImg = correctLicensePlateTilt(I)

    I1 = rgb2gray(I);
    I2 = wiener2(I1, [5, 5]);
    I3 = edge(I2, 'sobel', 'horizontal'); % 使用Sobel算子提取水平边缘
    [m, n] = size(I3);
    rou = round(sqrt(m^2 + n^2));
    thetaMax = 180;
    countMatrix = zeros(rou, thetaMax);
    
    for i = 1:m
        for j = 1:n
            if I3(i, j) == 1
                for theta = 1:thetaMax
                    ru = floor(abs(i * cos(theta * pi / 180) + j * sin(theta * pi / 180)));
                    countMatrix(ru + 1, theta) = countMatrix(ru + 1, theta) + 1;
                end
            end
        end
    end
    
    r_max = countMatrix(1, 1);
    for i = 1:rou
        for j = 1:thetaMax
            if countMatrix(i, j) > r_max
                r_max = countMatrix(i, j);
                angle = j;
            end
        end
    end
    
    if angle <= 90
        rot_theta = -angle;
    else
        rot_theta = 180 - angle;
    end
    
    I4 = imrotate(I, rot_theta, 'crop'); % 根据计算出的角度旋转图像
    correctedImg=I4;
    
    % figure;
    % subplot(121), imshow(I);
    % subplot(122), imshow(I4);
end