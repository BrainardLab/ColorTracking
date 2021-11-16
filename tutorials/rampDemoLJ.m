%%

% Instantiate a LabJack object to handle communication with the device
labjackOBJ = LabJackU6('verbosity', 1);

% Set up sampling parameters
samplingParams = struct(...
    'channelIDs', [1], ...         % list of  channels to aquire from (AIN1, AIN2, AIN3)
    'frequencyInHz', 5*1000 ...    % using an 7 KHz sampling rate
    );

% Configure analog input sampling
labjackOBJ.configureAnalogDataStream(samplingParams.channelIDs, samplingParams.frequencyInHz);

durationInSeconds = 10;

% Aquire the data
labjackOBJ.startDataStreamingForSpecifiedDuration(durationInSeconds);

% Close-up shop
labjackOBJ.shutdown();

figure; 
plot(labjackOBJ.timeAxis,labjackOBJ.data); 
axis square;