% mean shiting an image demo
load('sampleLMS.mat')
figure
subplot(4, 1, 1);
imshow(LMSimage);
title('LMS Image')
% Compute stats.

bg = [mean(mean(LMSimage(:,:,1))), mean(mean(LMSimage(:,:,2))), mean(mean(LMSimage(:,:,3)))];

deltaLMSimage = cat(3,LMSimage(:,:,1)-bg(1),LMSimage(:,:,2)-bg(2),LMSimage(:,:,3)-bg(3));

[calFormatScaledLMSimage,nCols,mRows] = ImageToCalFormat(deltaLMSimage);

subplot(4, 1, 2);
imshow(deltaLMSimage, []);title('Delta LMS')

% 3. set up M raw 

Mraw = [ 1, 0, 0;...
         1, -bg(1)/bg(2), 0;...
        -1, -1, (bg(1)+bg(2))/bg(3)];

% 4. invert Mraw    
MrawInv = inv(Mraw);

% 5. get the 3 isolating mechanisms 
isochrom_raw = MrawInv(:,1);
rgisolum_raw = MrawInv(:,2);
sisolum_raw = MrawInv(:,3);

% 6. get pooled contrast per mechanism 
isochrom_raw_pooled = norm(isochrom_raw./bg);
rgisolum_raw_pooled = norm(rgisolum_raw./bg);
sisolum_raw_pooled  = norm(sisolum_raw./bg);

% 7. scale each mechanism by the pooled contrast to achieve unit length
isochrom_unit = isochrom_raw/isochrom_raw_pooled;
rgisolum_unit = rgisolum_raw/rgisolum_raw_pooled;
sisolum_unit  = sisolum_raw/sisolum_raw_pooled;

% 8. Compute the values of the normalizing contants by plugging in the unit
% iso 
lum_resp_raw = Mraw *isochrom_unit;
lminM_resp_raw = Mraw *rgisolum_unit;
SminLum_resp_raw = Mraw *sisolum_unit;

% Scaling the rows of Mraw to get unit response
D_scale = [1/lum_resp_raw(1), 0, 0;...
           0, 1/lminM_resp_raw(2), 0;...
           0, 0, 1/SminLum_resp_raw(3)];
M = D_scale*Mraw;

% get new M_inv 
M_inv = inv(M);

% DKL coords
DKL_coords = M*calFormatScaledLMSimage;

DKLimage  = CalFormatToImage(DKL_coords, nCols,mRows);
subplot(4, 1, 3);
imshow(DKLimage,[]); title('DKL image')


scaledDKLcoords = DKL_coords./max(abs(DKL_coords(:)));
scaledDKLimage  = CalFormatToImage(scaledDKLcoords, nCols,mRows);
subplot(4, 1, 4);
imshow(scaledDKLimage,[]); title('DKL image')

figure
scatter3(DKL_coords(1,:),DKL_coords(2,:),DKL_coords(3,:))

figure
scatter3(scaledDKLcoords(1,:),scaledDKLcoords(2,:),scaledDKLcoords(3,:))


%% go back 
lumImg = scaledDKLcoords;
lumImg(2:3,:) = zeros(size(lumImg(2:3,:)));
lumImg = lumImg./max(abs(lumImg(:)))*.5;

rgImg = scaledDKLcoords;
rgImg([1,3],:) = zeros(size(rgImg([1,3],:)));
rgImg = rgImg./max(abs(rgImg(:)))*.5;

blImg = scaledDKLcoords;
blImg(1:2,:) = zeros(size(blImg(1:2,:)));
blImg = rgImg./max(abs(blImg(:)))*.5;


lum_resp_scaled     = M_inv*lumImg;
lminM_resp_scaled   = M_inv*rgImg;
SminLum_resp_scaled = M_inv*blImg;


[backProjLumImage] = CalFormatToImage(scaledDKLcoords, nCols,mRows);
[backProjLMimage]  = CalFormatToImage(scaledDKLcoords, nCols,mRows);
[backProjSimage]   = CalFormatToImage(scaledDKLcoords, nCols,mRows);

figure 
subplot(3, 1, 1);
imshow(backProjLumImage,[]); title('Lum')
subplot(3, 1, 2);
imshow(backProjLMimage,[]); title('rg')
subplot(3, 1, 3);
imshow(backProjSimage,[]); title('bl')




% 
% % Shift to desired mean
% R2 = img2(:,:,1) .* (bg(1)/meanRGB(1));
% G2 = img2(:,:,2) .* (bg(2)/meanRGB(2));
% B2 = img2(:,:,3) .* (bg(3)/meanRGB(3));
% 
% img2(:,:,1) = LMSimage(:,:,1)./max(LMSimage(:,:,1));
% img2(:,:,2) = LMSimage(:,:,2)./max(LMSimage(:,:,2));
% img2(:,:,3) = LMSimage(:,:,3)./max(LMSimage(:,:,3));
% imshow(img2);title('unit max per channel')
