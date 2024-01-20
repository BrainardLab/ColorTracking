function soundCorrect

% function soundCorrect
%
% sound to play for an correct response

freq = 0.73; 

sound(sin(freq.*[0:1439]).*cosWindowFlattop([1 1440],720,720,0));