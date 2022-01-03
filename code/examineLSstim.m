function [directions, contrasts] = examineLSstim()

% function [directions, contrasts] = examineLSstim()
%
% interactive function for examining different color directions

directions = [];
contrasts = [];

while 1
   promptDir = 'Enter color direction: ';
   promptContrast = 'Enter contrast: ';
   directionLS = input(promptDir);
   contrastLS = input(promptContrast);
   if strcmp(directionLS,'q') || strcmp(contrastLS,'q')
       break;
   end
   directions(end+1) = directionLS;
   contrasts(end+1) = contrastLS;
   MaxContrastLMS = contrastLS.*[1/sqrt(tand(directionLS)^2+1) 0 tand(directionLS)/sqrt(tand(directionLS)^2+1)];
   [stm,~] = LMSstimulusGeneration(1,MaxContrastLMS,1,0,0,0.932);
end

end