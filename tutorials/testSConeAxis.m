%testComboMechFits
% Demo to test the combined mechanism fiting

close all
clear all

%% Load the data
subjID = 'KAS';


%% set up the grid search
minDev = -20;
maxDev = 20;
gridSteps = 2;
counter =0;

% search over lens density 
for gsL = minDev:gridSteps:maxDev

    % search over mecular pigment 
    for gsM = minDev:gridSteps:maxDev


    % make the fundamentals -- search lens density 
    
        % deviation in % from CIE computed peak lens density
        indDiffParams.dlens = [];

        % deviation in % from CIE peak macular pigment density
        indDiffParams.dmac  = [];
        
        [T_quantalAbsorptionsNormalized,T_quantalAbsorptions] = ComputeCIEConeFundamentals(S,2,32,3,...
            [],'StockmanSharpe',[],false,[],[],indDiffParams)


    %% Make the Tracking Task Packet
    thePacketTrack = makeTrackingPacket(subjID);

    %% Make the Detection Task Packet
    thePacketDetect = makeDetectionPacket(subjID);

    %% Make the fit objects
    theDimension= size(thePacketTrack.stimulus.values, 1);
    ctmOBJ= tfeCTMRotM('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

    theDimension= size(thePacketDetect.stimulus.values, 1);
    lsdOBJ = tfeLSD('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

    %% Fit individual
    fitErrorScalar = 1;

    [paramsTrack,fValsTrack,respTrack] = ctmOBJ.fitResponse(thePacketTrack,'defaultParamsInfo',ctmOBJ.defaultParams,...
        'initialParams',[], 'fitErrorScalar',fitErrorScalar,'searchMethod','fmincon');


    [paramsDetect,fValsDetect,respDetect] = lsdOBJ.fitResponse(thePacketDetect,'defaultParamsInfo',lsdOBJ.defaultParams,...
        'initialParams',[], 'fitErrorScalar',fitErrorScalar);
    end
end
