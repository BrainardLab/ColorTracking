close all
clear all

%% LOAD DATA
subjIDcell  = {'MAB','BMC','KAS'};
expCell = {'LS1','LS2','LS3'};
theRuns = 1:20;

figSavePath = '/Users/michael/labDropbox/CNST_analysis/ColorTrackingTask/Results/';
for tt = 1:length(subjIDcell)
    for pp = 1:length(expCell)
        subjID  = subjIDcell{tt};
        expName = expCell{pp};
        
        if strcmp(expName,'LS1')
            expCode = 'Experiment1-Pos';
        elseif strcmp(expName,'LS2')
            expCode = 'Experiment2-Pos';
        elseif strcmp(expName,'LS3')
            expCode = ['Experiment3-' subjID '-Pos'];
        end
        
        if strcmp(subjID,'MAB')
            subjCode = 'Subject1';
        elseif strcmp(subjID,'BMC')
            subjCode = 'Subject2';
        elseif strcmp(subjID,'KAS')
            subjCode = 'Subject3';
        end
        
        Sall = loadPSYdataLMSall('TRK', subjID, expName, 'CGB', {theRuns}, 'jburge-hubel', 'local');
        
        % ************ NEW CODE FOR SPLITTING LEFT AND RIGHT *******************
        % INDICES FOR SPLITTING
        indLeft = (Sall.MaxContrastLMS(:,1)>=0 & Sall.MaxContrastLMS(:,3)>=0) | (Sall.MaxContrastLMS(:,1)>0 & Sall.MaxContrastLMS(:,3)<0);
        indRight = (Sall.MaxContrastLMS(:,1)<0 & Sall.MaxContrastLMS(:,3)<0) | (Sall.MaxContrastLMS(:,1)<=0 & Sall.MaxContrastLMS(:,3)>=0);
        % NEW STRUCTS SPLIT BETWEEN LEFT AND RIGHT
        SallLeft = structElementSelect(Sall,indLeft,size(Sall.MaxContrastLMS,1));
        SallRight = structElementSelect(Sall,indRight,size(Sall.MaxContrastLMS,1));
        % **********************************************************************
        
        %% SORT TRIALS BY COLOR ANGLE
        plotRawData = false;
        
        % Get the cone contrasts MaxContrastLMS
        MaxContrastLMS = LMSstimulusContrast('experiment',expCode);
        uniqColorDirs = unique(round(atand(MaxContrastLMS(:,3)./MaxContrastLMS(:,1)),2),'stable');
        
        %% Get the left lags
        for ii = 1:length(uniqColorDirs)
            
            % 0 DEG IN SL PLANE
            ind = abs(atand(SallLeft.MaxContrastLMS(:,3)./SallLeft.MaxContrastLMS(:,1))-uniqColorDirs(ii))<0.001;
            
            SLeft = structElementSelect(SallLeft,ind,size(SallLeft.tgtXmm,2));
            % LMS ANALYSIS TO ESTIMATE LAGS
            [~,~,rParamsLeft(:,:,ii)] = LMSxcorrAnalysis(SLeft,'LGS','bPLOTfitsAndRaw',plotRawData);
            
        end
        
        %% Get the right lags
        for ii = 1:length(uniqColorDirs)
            
            % 0 DEG IN SL PLANE
            ind = abs(atand(SallRight.MaxContrastLMS(:,3)./SallRight.MaxContrastLMS(:,1))-uniqColorDirs(ii))<0.001;
            
            SRight = structElementSelect(SallRight,ind,size(SallRight.tgtXmm,2));
            % LMS ANALYSIS TO ESTIMATE LAGS
            [~,~,rParamsRight(:,:,ii)] = LMSxcorrAnalysis(SRight,'LGS','bPLOTfitsAndRaw',plotRawData);
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%      Left vs Right
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % get the lags from rParams
        lagsLeft = flipud(squeeze(rParamsLeft(2,:,:)));
        lagsRight = flipud(squeeze(rParamsRight(2,:,:)));
        
        %lags = flipud((squeeze(rParams(3,:,:))-1).*squeeze(rParams(2,:,:))+ squeeze(rParams(4,:,:)));
        
        % Set the colors
        plotColors = [230 172 178; ...
            194  171  253; ...
            36   210  201; ...
            32   140  163; ...
            253  182    44; ...
            252  153  233;...
            ]./255;
        
        % Get the l2 norm of the cone contrasts
        vecContrast = sqrt(MaxContrastLMS(:,1).^2+MaxContrastLMS(:,3).^2);
        matrixContrasts = reshape(vecContrast,size(lagsLeft));
        
        % Names for plotting
        
        for jj = 1:length(uniqColorDirs)
            plotNames.legend{jj} = sprintf('%s°',num2str(uniqColorDirs(jj)));
        end
        % Plot it!
        tcHndl = figure; hold on;
        sz = 64;
        for ii = 1:size(lagsLeft,2)
            s{ii} = scatter(lagsLeft(:,ii),lagsRight(:,ii),sz,'MarkerEdgeColor',plotColors(ii,:)*0.7,...
                'MarkerFaceColor',plotColors(ii,:),...
                'LineWidth',1.5);
            
            s{ii}.AlphaData = linspace(1,.4,6);
            s{ii}.MarkerFaceAlpha = 'flat';
        end
        axis square
        ylim([0.3,0.8]);
        xlim([0.3,0.8]);
        plot([0.3,0.8],[0.3,0.8],'k--','LineWidth',1.5);
        hTitle  = title ('Lags Left Vs. Right Phase');
        hXLabel = xlabel('Left Lags (s)');
        hYLabel = ylabel('Right Lag (s)');
        legend([s{:}],plotNames.legend,'Location','northeastoutside');
        
        
        set(gca, ...
            'Box'         , 'off'     , ...
            'TickDir'     , 'out'     , ...
            'FontSize'    , 16        , ...
            'TickLength'  , [.02 .02] , ...
            'XMinorTick'  , 'on'      , ...
            'YMinorTick'  , 'on'      , ...
            'YGrid'       , 'on'      , ...
            'XColor'      , [.3 .3 .3], ...
            'YColor'      , [.3 .3 .3], ...
            'YTick'       , 0:.2:1, ...
            'XTick'       , 0:.2:1,...
            'LineWidth'   , 2         , ...
            'ActivePositionProperty', 'OuterPosition');
        
        set(gcf, 'Color', 'white' );
        
        % Save it!
        figureSizeInches = [11 8];
        set(tcHndl, 'PaperUnits', 'inches');
        set(tcHndl, 'PaperSize',figureSizeInches);
        set(tcHndl, 'PaperPosition', [0 0 figureSizeInches(1) figureSizeInches(2)]);
        % Full file name
        figNameTc =  fullfile(figSavePath,[subjCode, '_LagsLeftVsRight_' expName '.pdf']);
        % Save it
        print(tcHndl, figNameTc, '-dpdf', '-r300');
        
    end
end