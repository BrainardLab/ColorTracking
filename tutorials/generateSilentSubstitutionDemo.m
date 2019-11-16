function  generateConeContrastStimulus()

    % Determine location of resourcesDir
    [rootDir,~] = fileparts(which(mfilename));
    resourcesDir = sprintf('%s/resources',rootDir);
    
    % Select the calibration file for a particular display (here a ViewSonic display)
    displayCalFileName = sprintf('%s/ViewSonicProbe', resourcesDir);
    
    % Load the calibration file
    load(displayCalFileName, 'cals');
    
    % Construct a calStructOBJ from the latest calibration
    [calStructOBJ, ~] = ObjectToHandleCalOrCalStruct(cals{end}); 
    
    % Load displaySPDs and cone fundamentals sampled at the same spectral axis
    [displaySPDs, coneFundamentals] = loadDisplaySPDsAndConeFundamentals(calStructOBJ);

    % Speficy primary values for background
    backgroundPrimaries = [1 1 0.57]';
    
    % Speficy LMS contrast vector
    LMScontrastModulation = [0.2 0 0];
    
    backgroundSPD = ...
        backgroundPrimaries(1) * displaySPDs(1,:) + ...
        backgroundPrimaries(2) * displaySPDs(2,:) + ...
        backgroundPrimaries(3) * displaySPDs(3,:);
    
    backgroundConeExcitations = coneFundamentals * backgroundSPD';
    
  
    
    
    % Generate the spatial contrast profile of the stimulus
    type = 'sin';
    [contrastImage, sRGBimage] = generateStimContrastProfile(type, resourcesDir);
    
    % Generate stimulus settings
    stimSettingsLMSImage = stimSettingsFromContrastImageForDesiredConeContrastModulation(...
        contrastImage, LMScontrastModulation, backgroundConeExcitations, ...
        displaySPDs, calStructOBJ, coneFundamentals);
    
    plotInputAndCorrespondingLMSimage(sRGBimage, contrastImage, stimSettingsLMSImage, LMScontrastModulation, backgroundPrimaries)

end

function  stimSettingsImage = stimSettingsFromContrastImageForDesiredConeContrastModulation(stimContrastSpatialProfile, stimLMScontrast, backgroundConeExcitations, ...
        displaySPDs, calStructOBJ, coneFundamentals)
    % from image format to 1D
    rows = size(stimContrastSpatialProfile,1);
    cols = size(stimContrastSpatialProfile,2);
    stimContrastProfile1D = reshape(stimContrastSpatialProfile, [1 rows*cols]);
    
    coneContrasts = zeros(3, numel(stimContrastProfile1D));
    for pixel = 1:numel(stimContrastProfile1D)
      cL = stimContrastProfile1D(pixel) * stimLMScontrast(1);
      cM = stimContrastProfile1D(pixel) * stimLMScontrast(2);
      cS = stimContrastProfile1D(pixel) * stimLMScontrast(3);
      coneContrasts(:, pixel) = [cL  cM cS];
    end
    
    primaries = primariesForConeContrasts(displaySPDs, coneFundamentals, backgroundConeExcitations, coneContrasts);
    
    % check for gamut
    idx = find(primaries<0);
    if  (numel(idx)>0)
        fprintf(2,'Warning: %d pixels (%2.3f%%) have primary value < 0\n',  numel(idx), numel(idx)/numel(primaries)*100);
        primaries(idx) = 0;
    end
    idx = find(primaries>1);
    if  (numel(idx)>0)
        fprintf(2,'Warning: %d pixels (%2.3f%%) have primary value > 1\n',  numel(idx), numel(idx)/numel(primaries)*100);
        primaries(idx) = 1;
    end
    
    % To  settings
    gammaMethod = 1;
    SetGammaMethod(calStructOBJ, gammaMethod, 1024);
    settings = PrimaryToSettings(calStructOBJ,primaries);
    
    %  Back to image format
    stimSettingsImage = reshape(settings', [rows  cols 3]);
end

function  plotInputAndCorrespondingLMSimage(sRGBimage, contrastImage, stimSettingsLMSImage, stimLMScontrast, backgroundPrimaries)
    hFig = figure(1); clf;
    set(hFig, 'Position', [10 10  400 500]); 
    imagesc(sRGBimage); axis 'image'; axis 'ij'
    title('input image');
    set(gca, 'XColor', 'none', 'YColor', 'none', 'XTick', [], 'YTick', [], 'FontSize', 14);
    box off
    lRGBimage = rgb2lin(sRGBimage);
    meanColor = mean(mean(lRGBimage,1),2);
    set(hFig, 'Color', lin2rgb(meanColor));
    
    hFig = figure(2); clf;
    set(hFig, 'Position', [400 10  400 500]); 
    imagesc(contrastImage); axis 'image'; axis 'ij'
    title('contrast image');
    set(gca, 'XColor', 'none', 'YColor', 'none', 'XTick', [], 'YTick', [], 'CLim', [-1 1], 'FontSize', 14);
    box off
    hb = colorbar();
    hb.Label.String = 'contrast';
    cMap = brewermap(1024, '*RdBu');
    colormap(cMap);
    set(hFig, 'Color', [1 1 1]);
    
    hFig = figure(3); clf;
    set(hFig, 'Position', [800 10  400 500]); 
    image(stimSettingsLMSImage); axis 'image'; axis 'ij'
    title(sprintf('LMS cone contrast image\n(%2.2f, %2.2f, %2.2f)', stimLMScontrast(1), stimLMScontrast(2), stimLMScontrast(3)));
    set(gca, 'XColor', 'none', 'YColor', 'none', 'XTick', [], 'YTick', [], 'FontSize', 14);
    box off
    set(hFig, 'Color', lin2rgb(backgroundPrimaries));
end


function [stimContrastProfile, sRGBimage] = generateStimContrastProfile(type, resourcesDir)
    
    switch (type)
        case 'sin'
            stimHalfSize = 32;
            rows = (-stimHalfSize:stimHalfSize)/(2*stimHalfSize+1); 
            cols = rows;
            [x,y] = meshgrid(cols,rows);
            fx = 3.0;
            angle = 60;
            stimContrastProfile = sin(2*pi*(fx*cosd(angle)*x + fx*sind(angle)*y));
            sRGBimage = lin2rgb(stimContrastProfile);
            
            
        case 'flower'
            % Load a random image downloaded off the internet (sRGB format in 0-255 8-bit format)
            load(sprintf('%s/flower.mat',resourcesDir), 'flower');

            % Normalize to [0 1] and make it a double
            sRGBimage = double(flower)/255;
            
            % Undo gamma  correction
            linearRGBimage  = rgb2lin(sRGBimage);
            
            % Make it gray scale
            grayScaleImage = mean(linearRGBimage,3);
            
            % Compute contrast
            meanGray = mean(grayScaleImage(:));
            contrastImage = (grayScaleImage - meanGray)/meanGray;
            stimContrastProfile = contrastImage / max(abs(contrastImage(:)));
            
    end
end

function [displaySPDs, coneFundamentals] = loadDisplaySPDsAndConeFundamentals(calStructOBJ)
    % Extract the wavelength sampling
    S = calStructOBJ.get('S');
    wavelengthAxis = SToWls(S);
    
    % Extract the spectral power distributions of the display's RGB primaries
    displaySPDs = (calStructOBJ.get('P_device'))';
    
    % Load the Smith-Pokorny 2 deg cone fundamentals
    load('T_cones_ss2.mat');
    
    % Spline the Smith-Pokorny 2 deg cone fundamentals to match the wavelengthAxis
    coneFundamentals = SplineCmf(S_cones_ss2, T_cones_ss2, WlsToS(wavelengthAxis));
    
    % Check outputs for correctness
    assert(ndims(coneFundamentals) == 2, 'Cone fundamentals is not a 2D matrix');
    assert(ndims(displaySPDs) == 2, 'displaySPDs is not a 2D matrix');
    assert(size(coneFundamentals,1) == 3,'Cone fundamentals is not a [3 x N] matrix');
    assert(size(displaySPDs,1) == 3,'Display SPDs is not a [3 x N] matrix');
    assert(size(displaySPDs,2) == size(coneFundamentals,2),'Cone fundamental and display SPD  spectral entries do not match');
end
    
function coneExcitations = coneExcitationsForBackground(displaySPDs, coneFundamentals, backgroundPrimaries)
    
    backgroundSPD = ...
        backgroundPrimaries(1) * displaySPDs(1,:) + ...
        backgroundPrimaries(2) * displaySPDs(2,:) + ...
        backgroundPrimaries(3) * displaySPDs(3,:);
    
    coneExcitations = coneFundamentals * backgroundSPD';
end


function primaries = primariesForConeContrasts(displaySPDs, coneFundamentals, backgroundConeExcitations, coneContrasts)
    assert(size(coneContrasts,1) == 3, 'cone contrasts must be a [3 x N] matrix');
    assert((size(backgroundConeExcitations,1) == 3)  && (size(backgroundConeExcitations,2) == 1), 'background  cone excitations must be a [3 x 1] matrix');
    
    coneExcitations = repmat(backgroundConeExcitations, [1, size(coneContrasts,2)]) .* (1 + coneContrasts);
    primaries = primaryModulationsForConeExcitationsAndDisplaySPDs(coneExcitations, coneFundamentals, displaySPDs);
end



function primaries = primaryModulationsForConeExcitationsAndDisplaySPDs(coneExcitations, coneFundamentals, displaySPDs)

    assert(size(coneExcitations,1) == 3, 'Cone excitations must have 3 rows');
    
    computeMethod = 'educational';
    computeMethod = 'fast';
    
    if (strcmp(computeMethod, 'educational'))   
        LconeFundamental = squeeze(coneFundamentals(1,:));
        MconeFundamental = squeeze(coneFundamentals(2,:));
        SconeFundamental = squeeze(coneFundamentals(3,:));

        rSPD = displaySPDs(1,:);
        gSPD = displaySPDs(2,:);
        bSPD = displaySPDs(3,:);

        % L cone excitation by each gun at full modulation
        LconeRgun = dot(LconeFundamental, rSPD);
        LconeGgun = dot(LconeFundamental, gSPD);
        LconeBgun = dot(LconeFundamental, bSPD);

        % M cone excitation by each gun at full modulation
        MconeRgun = dot(MconeFundamental, rSPD);
        MconeGgun = dot(MconeFundamental, gSPD);
        MconeBgun = dot(MconeFundamental, bSPD);

        % S cone excitation by each gun at full modulation
        SconeRgun = dot(SconeFundamental, rSPD);
        SconeGgun = dot(SconeFundamental, gSPD);
        SconeBgun = dot(SconeFundamental, bSPD);

        % Total Lcone excitation from guns modulated by (r,g,b)
        % Lcone = r*LconeRgun + g*LconeGgun + b*LconeBgun;

        % Total Mcone excitation from guns modulated by (r,g,b)
        % Mcone = r*MconeRgun + g*MconeGgun + b*MconeBgun;

        % Total Scone excitation from guns modulated by (r,g,b)
        % Scone = r*SconeRgun + g*SconeGgun + b*SconeBgun;

        % Putting it all in matrix equation
        % [Lcone Mcone Scone]' = M * [r g b]';
        %  where M is

        M = [...
            LconeRgun LconeGgun LconeBgun; ...
            MconeRgun MconeGgun MconeBgun; ...
            SconeRgun SconeGgun SconeBgun];

        % So if we have a desired [Lcone Mcone Scone]  excitation vector
        % the required [r g b] primaries are given as
        % [r g b]' = inv(M) * [Lcone Mcone Scone]'

        primaries = inv(M) * coneExcitations;
    
    else
        % COMPACT WAY WAY OF DOING THE ABOVE
        M = coneFundamentals * displaySPDs';
        
        % Least squares solution to the system of linear equations M*primaries = [Lcone Mcone Scone]. 
        primaries = M\coneExcitations;
    end
    
end

