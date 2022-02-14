% Batch rename folder name for the hard drive to handle mismatch with the
% dropbox account
projectName = 'ColorTracking';
basePath = getpref(projectName,'dropboxPath');

subjs = {'BMC','KAS','MAB'};


%% loop over subjects
for curr_subj = 1:length(subjs)
    
    subjectDir = fullfile(basePath,'CNSC_data','ColorTrackingTask','LS1',subjs{curr_subj});
    
    dataFileName = dir(subjectDir);
    dataFileIndx = find(contains({dataFileName(:).name},'LMS'));
    
    for ii = 1:length(dataFileIndx)
        oldFileName = fullfile(subjectDir,dataFileName(dataFileIndx(ii)).name);
        newFileName = strrep(fullfile(subjectDir,dataFileName(dataFileIndx(ii)).name),'LMS','LS1');
        
        
        str = ['mv ' oldFileName ' ' newFileName];
        
        unix(str)
    end
end