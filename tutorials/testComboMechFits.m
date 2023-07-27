%testComboMechFits
% Demo to test the combined mechanism fiting 

close all 
clear all

%% Load the data
subjID = 'KAS';

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
