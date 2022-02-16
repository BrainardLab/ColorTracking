function soundIncorrect

% function soundIncorrect
%
% sound to play for an incorrect response

freq = 0.73/2; 
sound(sin(freq.*[0:1439]).*cosWindowFlattop([1 1440],720,720,0));