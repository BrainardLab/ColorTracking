function stimGenerationTutorial
% Tutorial showing how to simulate the rendering of an sRGB image onto a
% particular display, given that display's calibration file

    %tbUse('BrainardLabBase')
    
    % Determine location of resourcesDir
    [rootDir,~] = fileparts(which(mfilename));
    resourcesDir = sprintf('%s/resources',rootDir);
    
    % Load a random image downloaded off the internet (sRGB format in 0-255 8-bit format)
    load(sprintf('%s/flower.mat',resourcesDir), 'flower');
    
    % Normalize to [0 1] and make it a double
    sRGBimage = double(flower)/255;
    
    % Select the calibration file for a particular display (here a ViewSonic display)
    displayCalFileName = sprintf('%s/ViewSonicProbe', resourcesDir);
    
    % Inspect the calibration data
    inspectDisplayCalibration(displayCalFileName);
    
    % Simulate presentation of the input sRGB image on the selected display
    [wavelengthAxis, radianceImage, XYZimage, LMSimage] = simulateSRGBimageOnDisplay(sRGBimage, displayCalFileName);
    
    % Visualize everything
    visualizeImageComponents(wavelengthAxis, radianceImage, XYZimage, LMSimage, flower);
end

% Method to compute the radiance map (and its XYZ, LMS representations) that is emitted by a display when it presents an sRGB image 
function [wavelengthAxis, radianceImage, XYZimage, LMSExcitationsImage] = simulateSRGBimageOnDisplay(sRGBimage, displayCalFile)
    % Load the calibration file
    load(displayCalFile, 'cals');
    
    % Construct a calStructOBJ from the latest calibration
    [calStructOBJ, ~] = ObjectToHandleCalOrCalStruct(cals{end}); 
    
    % Extract the wavelength sampling
    S = calStructOBJ.get('S');
    wavelengthAxis = SToWls(S);
    
    % Extract the spectral power distributions of the display's RGB primaries
    displaySPDs = calStructOBJ.get('P_device');

    % Transform the sRGB image [Rows x Cols x 3] into a [3 x N] matrix for faster computations
    [calFormatSRGBimage,nCols,mRows] = ImageToCalFormat(sRGBimage);

    % Compute the primary values - these are the actual modulations of the RGB guns given the settings image (sRGB image)
    calFormatRGBPrimariesImage = SettingsToPrimary(calStructOBJ,calFormatSRGBimage);
    
    % Compute the emmitted radiance image by multiplying the display SPDs
    % with the primary modulations
    % [N waves x 3 guns] * [3 guns x M pixels] = [N waves x Mpixels]
    calFormatRadianceImage  = displaySPDs * calFormatRGBPrimariesImage;
    
    % Compute the corresponding CIE'31 XYZ tristimulus image 
    % Load the '31 XYZ color matching functions
    load('T_xyz1931.mat')
    
    % Spline the XYZ '31 CMFs to match the wavelengthAxis
    XYZcolorMatchingFunctions = SplineCmf(S_xyz1931, 683*T_xyz1931, WlsToS(wavelengthAxis));

    % Compute the XYZ image by taking the dot product (along the wavelength axis)
    % of the XYZ functions with the radiance for each pixel
    % [3 x N waves] * [ N waves x M pixels] = [3 x M pixels]
    calFormatXYZimage = XYZcolorMatchingFunctions * calFormatRadianceImage;
    
    % Compute the corresponding S-S 2 deg LMS excitations image
    % Load the Smith-Pokorny 2 deg cone fundamentals
    load('T_cones_ss2.mat');
    
    % Spline the Smith-Pokorny 2 deg cone fundamentals to match the wavelengthAxis
    LMSconeFundamentals = SplineCmf(S_cones_ss2, T_cones_ss2, WlsToS(wavelengthAxis));
    
    % Compute the LMS image
    % [3 x N waves] * [ N waves x M pixels] = [3 x M pixels]
    calFormatLMSExcitationsImage = LMSconeFundamentals * calFormatRadianceImage;
     
    % Back to image format [Rows x Cols x N]
    radianceImage  = CalFormatToImage(calFormatRadianceImage, nCols,mRows);
    XYZimage  = CalFormatToImage(calFormatXYZimage, nCols,mRows);
    LMSExcitationsImage = CalFormatToImage(calFormatLMSExcitationsImage, nCols,mRows);
    
    showCMFs = ~false;
    if (showCMFs)
        figure(2); clf;
        subplot(1,2,1);
        plot(wavelengthAxis, XYZcolorMatchingFunctions(1,:), 'r-', 'LineWidth', 1.5); hold on
        plot(wavelengthAxis, XYZcolorMatchingFunctions(2,:), 'g-', 'LineWidth', 1.5);
        plot(wavelengthAxis, XYZcolorMatchingFunctions(3,:), 'b-', 'LineWidth', 1.5);
        legend({'X-', 'Y-', 'Z-'});

        subplot(1,2,2);
        plot(wavelengthAxis, LMSconeFundamentals(1,:), 'r-', 'LineWidth', 1.5); hold on
        plot(wavelengthAxis, LMSconeFundamentals(2,:), 'g-', 'LineWidth', 1.5);
        plot(wavelengthAxis, LMSconeFundamentals(3,:), 'b-', 'LineWidth', 1.5);
        legend({'L-', 'M-', 'S-'});
    end   
end

% Method to visualize key components of the calibration (gamma, SPDs)
function inspectDisplayCalibration(displayCalFile)
    % Load calibration file
    load(displayCalFile, 'cals');
    % Get a calStructOBJ from the latest calibration
    [calStructOBJ, ~] = ObjectToHandleCalOrCalStruct(cals{end}); 
    
    % Retrieve the display's gamma function
    settingsInput = calStructOBJ.get('gammaInput');
    gamma         = calStructOBJ.get('gammaTable');
    
    % Set gamma inversion parameters 
    gammaMethod = 1;
    SetGammaMethod(calStructOBJ, gammaMethod, numel(settingsInput));
    
    % Compute the inverse gamma
    inverseGamma  = calStructOBJ.get('iGammaTable');
    
    % Retrieve the spectral sampling and the primary SPDs
    S = calStructOBJ.get('S');
    wavelengthAxis = SToWls(S);
    displaySPDs = calStructOBJ.get('P_device');
    
    % Display stuff
    hFig = figure(1); clf;
    set(hFig, 'Position', [10 10 940 300]);
    
    % The gamma functions for the R,G,B guns
    subplot(1,3,1);
    % Plot the measured gamma functions - how settings are converted into
    % primary modulation values
    plot(settingsInput, gamma(:,1), 'r-', 'LineWidth', 1.5); hold on;
    plot(settingsInput, gamma(:,2), 'g-', 'LineWidth', 1.5);
    plot(settingsInput, gamma(:,3), 'b-', 'LineWidth', 1.5);
    axis 'square';
    set(gca, 'FontSize', 14, 'XTick', 0:0.2:1.0, 'YTick', 0:0.2:1.0);
    grid on;
    xlabel('settings value');
    ylabel('achieved primary modulation');
    
    % The inverse gamma functions for the R,G,B guns
    subplot(1,3,2);
    plot(settingsInput, inverseGamma(:,1), 'r-', 'LineWidth', 1.5); hold on
    plot(settingsInput, inverseGamma(:,2), 'g-', 'LineWidth', 1.5);
    plot(settingsInput, inverseGamma(:,3), 'b-', 'LineWidth', 1.5);
    axis 'square';
    set(gca, 'FontSize', 14, 'XTick', 0:0.2:1.0, 'YTick', 0:0.2:1.0);
    grid on;
    xlabel('desired primary modulation');
    ylabel('required settings value');
    
    % The SPDs for the R,G,B guns
    subplot(1,3,3);
    plot(wavelengthAxis,  displaySPDs(:,1), 'r-', 'LineWidth', 1.5); hold on
    plot(wavelengthAxis,  displaySPDs(:,2), 'g-', 'LineWidth', 1.5); 
    plot(wavelengthAxis,  displaySPDs(:,3), 'b-', 'LineWidth', 1.5); 
    set(gca, 'XLim', [wavelengthAxis(1) wavelengthAxis(end)], 'FontSize', 14);
    set(gca, 'XTick', 300:50:800);
    grid on;
    xlabel('wavelength (nm)');
    ylabel('energy');
    axis 'square';
end

% Method to visualize computed image components
function visualizeImageComponents(wavelengthAxis, radianceImage, XYZimage, LMSimage, flower)

    % Find ranges
    coneExcitationRange = [min(LMSimage(:)) max(LMSimage(:))];
    radianceRange = [min(radianceImage(:)) max(radianceImage(:))];
    
    hFig = figure(3); set(hFig, 'Position', [10 10 1600 650]);
    
    % The input image (sRGB)
    subplot(2,5,1);
    image(flower); axis 'image'; colorbar
    set(gca, 'FontSize', 14);
    title('sRGB image');
    
    % The luminance map of the image realized on the display.
    subplot(2,5,2);
    luminanceMap = squeeze(XYZimage(:,:,2));
    imagesc(luminanceMap); axis 'image'; colorbar;
    set(gca, 'FontSize', 14, 'XTick', [], 'YTick', []);
    title(sprintf('Luminance map\n(meanLum: %2.2f cd/m2)', mean(luminanceMap(:))));
    cmap = gray(1024);  %brewermap(1024, 'RdBu');
    colormap(cmap);
    colorbar
    
    % The L-cone excitation map of the image realized on the display.
    subplot(2,5,3);
    imagesc(squeeze(LMSimage(:,:,1))); axis 'image'; colorbar;
    set(gca, 'FontSize', 14, 'XTick', [], 'YTick', []);
    set(gca, 'CLim', coneExcitationRange);
    title('L-cone excitation map');
    
    % The M-cone excitation map of the image realized on the  display.
    subplot(2,5,4);
    imagesc(squeeze(LMSimage(:,:,2))); axis 'image'; colorbar;
    set(gca, 'FontSize', 14, 'XTick', [], 'YTick', []);
    set(gca, 'CLim', coneExcitationRange);
    title('M-cone excitation map');
    
    % The S-cone excitation map of the image realized on the  display.
    subplot(2,5,5);
    imagesc(squeeze(LMSimage(:,:,3))); axis 'image'; colorbar;
    set(gca, 'FontSize', 14, 'XTick', [], 'YTick', []);
    set(gca, 'CLim', coneExcitationRange);
    title('S-cone excitation map');
    
    % The radiance map at 5 select wavelengths of the image realized on the  display.
    targetWavelenghts = [450 500 550 600 650];
    for k = 1:5
        subplot(2,5,5+k);
        [~,targetWavelengthIndex] = min(abs(wavelengthAxis-targetWavelenghts(k)));
        imagesc(squeeze(radianceImage(:,:,targetWavelengthIndex))); axis 'image'; colorbar
        set(gca, 'FontSize', 14, 'XTick', [], 'YTick', []);
        set(gca, 'CLim', radianceRange);
        title(sprintf('radiance map @%2.0f nm', wavelengthAxis(targetWavelengthIndex)));
    end 
end