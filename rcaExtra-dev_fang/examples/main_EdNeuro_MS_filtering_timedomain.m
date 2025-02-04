function main_EdNeuro_MS_filtering_timedomain
    git_folder = '/Users/nhqtrang/Desktop/Synapse_MiddleSchool/code/git';
    addpath(genpath(fullfile(git_folder, 'rcaExtra-dev')),'-end');
    addpath(genpath(fullfile(git_folder, 'rcaBase')),'-end');
    addpath(genpath(fullfile(git_folder, 'mrC')),'-end');
    addpath(genpath(fullfile(git_folder, 'svndl_code')),'-end');
 
    %% define experimentInfo
          
    experimentName = 'EdNeuro_MS';
    
    % load up expriment info specified in loadExperimentInfo_experimentName
    % matlab file
    
    try
        analysisStruct = feval(['loadExperimentInfo_' experimentName]);
    catch err
        % in case unable to load the designated file, load default file
        % (not implemented atm)
        disp('Unable to load specific expriment settings, loading default');
        analysisStruct = loadExperimentInfo_Default;
    end
    
    % specified for general data loader and plotting, currently not used
    analysisStruct.domain = 'time';
    loadSettings = rcaExtra_getDataLoadingSettings(analysisStruct);
    
    % read raw data 
    [subjList, EEGData] = getRawData(loadSettings);
    rcSettings = rcaExtra_getRCARunSettings(analysisStruct);
    rcSettings.subjList = subjList;
    
  %% Filtering the rawdata: Only need to do this once 
    
    % Set up
    datalocation = '/Volumes/Backup Plus/Synapse_MiddleSchool/B_Output_TimeDomain_';
    freqRemove = [1 2 4 5 7 8]; % Which frequencies to exclude
    fs = 420; % Specify the sampling rate of the EEG
    n = size(subjList,2);

    % load raw data
    for n = 1:size(subjList,2)
        raw_EEGData = load(strcat(datalocation,'Raw/MAT/', subjList{1,n},'.mat'),'subjEEG')
        raw_EEGData = raw_EEGData.subjEEG % 4 cells for 4 conditions, each cell: time x chan x trial --> 5040 x 128 x 10
    
        % Trim the raw data: length of time dimension has 12 seconds, so
        % I am trimming off the first and last second.

        c = size(raw_EEGData,2);
        trimmed_EEGData = cell(1, c);
    
        for i = 1:c
           xIn = raw_EEGData{1,i};
           trimmed_EEGData{1,i} = xIn((fs+1) : (11*fs), :, :); % 4200 x 128 x 10
        end
    
        % Filtering the rawdata
        [nfData, filteredData] = rcaExtra_filterEpochs(trimmed_EEGData, freqRemove);

        subjEEG = nfData
        save(strcat(datalocation,'124578/nfData/', subjList{1,n},'.mat'),'subjEEG')
        
        subjEEG = filteredData
        save(strcat(datalocation,'124578/filteredData/', subjList{1,n},'.mat'),'subjEEG')
    end
    
end
