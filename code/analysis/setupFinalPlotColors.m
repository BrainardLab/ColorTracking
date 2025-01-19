
% Clear
clear; close all;

% Setup full color table
controlAngles = [-45 0 45 90 135];
lowAngle = controlAngles(1);
highAngle = controlAngles(end);

controlColors = [ [231, 194, 135]' , [235 183 186]', [227 180 207]', [191 180 213]', [122, 191, 234]'] ;
fullAngles = lowAngle:1:highAngle;
for cc = 1:3
    fullColorTable(cc,:) = interp1(controlAngles,controlColors(cc,:),fullAngles);
end

% Set up our tracking angles
trackingAngles = [-45 -22.5 -1.9 0 22.5 45 75 78.75 82.5 86.2 87.1 88.1 89.1 90 -86.2+180 -82.5+180 -78.75+180 -75+180];

% The interp values
trackingInterpValues = round(linspace(lowAngle,highAngle,length(trackingAngles)));

% Tracking color table
for cc = 1:3
    trackingColorTable(cc,:) = round(interp1(fullAngles,fullColorTable(cc,:),trackingInterpValues));
end

% Make an image of the colors
nPixelsPerColor = 32;
for ii = 1:length(trackingAngles)
    for jj = 1:nPixelsPerColor
        for cc = 1:3
            trackingOutImage(1:nPixelsPerColor,(ii-1)*nPixelsPerColor+jj,cc) = trackingColorTable(cc,ii);
            trackingOutImage(1:nPixelsPerColor,ii*nPixelsPerColor,cc) = 0;
        end
    end
end
trackingOutImage = uint8(trackingOutImage);

% Show the thing
trackingAnglesDisplay = trackingAngles;
trackingAnglesDisplay(trackingAnglesDisplay > 90) = trackingAnglesDisplay(trackingAnglesDisplay > 90) - 180;
[~,trackingIndex] = sort(trackingAnglesDisplay,'descend');
figure; clf;
imshow(trackingOutImage(:,:,:));
[trackingAnglesDisplay(trackingIndex)' trackingColorTable(:,trackingIndex)']
[trackingAnglesDisplay' trackingColorTable']

% Setup our discrimination angles. These are the tracking equivalents
discriminationAngles = [-45 0 45 75 78.75 82.5 86.2 90 -86.2+180 -82.5+180 -78.75+180 -75+180];

% The interp values
discriminationInterpValues = round(linspace(lowAngle,highAngle,length(discriminationAngles)));

% Discrimination color table
for cc = 1:3
    discriminationColorTable(cc,:) = round(interp1(fullAngles,fullColorTable(cc,:),discriminationInterpValues));
end

% Make an image of the colors
nPixelsPerColor = 32;
for ii = 1:length(discriminationAngles)
    for jj = 1:nPixelsPerColor
        for cc = 1:3
            discriminationOutImage(1:nPixelsPerColor,(ii-1)*nPixelsPerColor+jj,cc) = discriminationColorTable(cc,ii);
            discriminationOutImage(1:nPixelsPerColor,ii*nPixelsPerColor,cc) = 0;
        end
    end
end
discriminationOutImage = uint8(discriminationOutImage);

% Show the thing
figure; clf;
imshow(discriminationOutImage);
discriminationAnglesDisplay = discriminationAngles;
discriminationAnglesDisplay(discriminationAnglesDisplay > 90) = discriminationAnglesDisplay(discriminationAnglesDisplay > 90) - 180;
[~,discriminationIndex] = sort(discriminationAnglesDisplay,'descend');
[discriminationAnglesDisplay(discriminationIndex)' discriminationColorTable(:,discriminationIndex)']
[discriminationAnglesDisplay' discriminationColorTable']