%%

clear;

%%

stm = generateStimContrastProfile([4 4],128,1,0,0,bandwidthOct2sigma(1,0.932));
rawMonochromeSineImage = MakeSineImage(0,4,512);
gaussianWindow = normpdf(MakeRadiusMat(512,512,256,256),0,0.15*512);
gaussianWindow = gaussianWindow/max(gaussianWindow(:));
desiredMonochromeContrastGaborImage = rawMonochromeSineImage.*gaussianWindow;

figure;
for i = 1:512
   if exist('h','var')
      delete(h);
   end
   h = subplot(1,1,1);
   plot(stm(i,:)); 
   hold on; 
   plot(desiredMonochromeContrastGaborImage(i,:)); 
   axis square;
   formatFigure('x','y',['Slice ' num2str(i)]);
   ylim([-1 1]);
   pause;
end