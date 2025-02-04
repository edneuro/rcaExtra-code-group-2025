function main_Standard_Oddball_analysis_time_Lochy

    %% define experimentInfo
    clear all;
    close all;
    clc;
    
    git_folder = '/Users/fangwang/Documents/code';
    addpath(genpath(fullfile(git_folder, 'rcaExtra-dev')),'-end');
    addpath(genpath(fullfile(git_folder, 'rcaBase')),'-end');
    addpath(genpath(fullfile(git_folder, 'mrC')),'-end');
    addpath(genpath(fullfile(git_folder, 'svndl_code')),'-end');
    
    experimentName = 'LochyRep_oddball';
    
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
   
    % get rid of prelude and postlude: remove first and last 420 (check the number) samples
    % get rid of extra electrode
    
    cleanedEEG(:,1) = cellfun(@(x) x(421:1:5040-420, :, :), EEGData(:,1), 'uni', false);
    cleanedEEG(:,2) = cellfun(@(x) x(421:1:5040-420, :, :), EEGData(:,2), 'uni', false);
    cleanedEEG(:,3) = cellfun(@(x) x(421:1:5040-420, :, :), EEGData(:,3), 'uni', false);
    cleanedEEG(:,4) = cellfun(@(x) x(421:1:5040-420, :, :), EEGData(:,5), 'uni', false);
    
    % cleanedEEG = cellfun(@(x) x(421:1:5040-420, 1:128, :), EEGData, 'uni', false);
    % use cleanedEEG instead of EEGData 
    
    % selecting specific frequency (1 HZ) and corresponding sampling rate
    % and time course length to use for resampling, RC analysis and
    % plotting results
    
    % rcSettings has two resampling values and two timecourses
    
    
    % filter data
    frequenciesHz = [5];
    
    [nfData, filteredData] = rcaExtra_filterEpochs(cleanedEEG,frequenciesHz);
    
    
    runSettings_1hz = rcSettings;
    runSettings_1hz.samplingRate = rcSettings.samplingRate(1);
    runSettings_1hz.timecourseLen = rcSettings.timecourseLen(1);
    
    
    nConditions = size(cleanedEEG, 2);
    % allocate cell array to store individual condition RCA runtime settings 
    runSettings_1hz_condition = cell(nConditions, 1);
    
    % allocate cell array to store individual condition RCA runtime results     
    rcResult_condition = cell(nConditions, 1);
    
    % run RC analysis for each condition
    plotSettings = rcaExtra_getPlotSettings(analysisStruct);
    %statSettings = rcaExtra_getStatsSettings(rcSettings);
    plotSettings.plotType = 'exploratory';
    
    % oddball filtered data
    
    for nc = 1%1:3%nConditions
        % copy runtime settings from 1Hz template
        runSettings_1hz_condition{nc} = runSettings_1hz;
        runSettings_1hz_condition{nc}.useCnds = nc;
        % add condition-specific label 
        runSettings_1hz_condition{nc}.label = analysisStruct.info.conditionLabels{nc};
        
        % select subset of raw data        
        rcResult_condition{nc} = rcaExtra_runAnalysis(runSettings_1hz_condition{nc}, nfData);
        % plot results
    end
    
        % carrier filtered data
    
    for nc = 1:nConditions
        % copy runtime settings from 1Hz template
        runSettings_1hz_condition{nc} = runSettings_1hz;
        runSettings_1hz_condition{nc}.useCnds = nc;
        % add condition-specific label 
        runSettings_1hz_condition{nc}.label = analysisStruct.info.conditionLabels{nc};
        
        % select subset of raw data        
        rcResult_condition{nc} = rcaExtra_runAnalysis(runSettings_1hz_condition{nc}, filteredData);
        % plot results
    end
end
