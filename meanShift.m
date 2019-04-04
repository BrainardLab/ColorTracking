% mean shiting an image demo

img = double(imread('image.png'));
subplot(3, 2, 1);
imshow(img./255);
title('original')
[mean(mean(img(:,:,1))),mean(mean(img(:,:,2))),mean(mean(img(:,:,3)))]./255
% Compute stats.
subplot(3, 2, 2);
img2(:,:,1) = img(:,:,1)./max(img(:,:,1));
img2(:,:,2) = img(:,:,2)./max(img(:,:,2));
img2(:,:,3) = img(:,:,3)./max(img(:,:,3));
imshow(img2);title('unit max per channel')

background = [1, 1, 1];
meanRGB = [mean(mean(img2(:,:,1))),mean(mean(img2(:,:,2))),mean(mean(img2(:,:,3)))]

% Make mean 0 and sd 0.005
R2 = img2(:,:,1) .* (background(1)/meanRGB(1));
G2 = img2(:,:,2) .* (background(2)/meanRGB(2));
B2 = img2(:,:,3) .* (background(3)/meanRGB(3));


img3 = cat(3,R2,G2,B2);

subplot(3, 2, 3);
imshow(img3, []);title('Mean shifted')
% Compute stats.
meanRGB2 = [mean(mean(img3(:,:,1))),mean(mean(img3(:,:,2))),mean(mean(img3(:,:,3)))]


rContrast = (R2-background(1))./(background(1));
gContrast = (G2-background(2))./(background(2));
bContrast = (B2-background(3))./(background(3));


subplot(3, 2, 4);
imshow(cat(3,rContrast,zeros(size(rContrast)),zeros(size(rContrast))),[]);
title('R contrast');

subplot(3, 2, 5);
imshow(cat(3,zeros(size(gContrast)),gContrast,zeros(size(gContrast))),[]);
title('G contrast');

subplot(3, 2, 6);
imshow(cat(3,zeros(size(bContrast)),zeros(size(bContrast)),bContrast),[]);
title('B contrast');
