% Speficy primary values for background
backgroundPrimaries = [.3 .3 .3]';

% Speficy LMS contrast vector
LMScontrastModulation = [.1 0 0];

angle = 45;

[stimSettingsLMSImage1] = generateChromaticGabor(backgroundPrimaries,LMScontrastModulation, angle);

angle = 45;
LMScontrastModulation = [.02 -.1 0];
[stimSettingsLMSImage2] = generateChromaticGabor(backgroundPrimaries,LMScontrastModulation, angle);
A= 0.2;
stimSettingsLMSImage3= (stimSettingsLMSImage1+A*stimSettingsLMSImage2) - ones(size(stimSettingsLMSImage1)).* .3;

hFig = figure;
set(hFig, 'Position', [800 10  400 500]);
image(stimSettingsLMSImage1); axis 'image'; axis 'ij'
set(gca, 'XColor', 'none', 'YColor', 'none', 'XTick', [], 'YTick', [], 'FontSize', 14);
box off
set(hFig, 'Color', lin2rgb(backgroundPrimaries));

hFig = figure;
set(hFig, 'Position', [800 10  400 500]);
image(stimSettingsLMSImage2); axis 'image'; axis 'ij'
set(gca, 'XColor', 'none', 'YColor', 'none', 'XTick', [], 'YTick', [], 'FontSize', 14);
box off
set(hFig, 'Color', lin2rgb(backgroundPrimaries));

hFig = figure;
set(hFig, 'Position', [800 10  400 500]);
image(stimSettingsLMSImage3); axis 'image'; axis 'ij'
set(gca, 'XColor', 'none', 'YColor', 'none', 'XTick', [], 'YTick', [], 'FontSize', 14);
box off
set(hFig, 'Color', lin2rgb(backgroundPrimaries));
