function main_Standard_Oddball_analysis_time_K2

    %% define experimentInfo
    clear all;
    close all;
    clc;
    
    git_folder = '/Volumes/GSE/code';
    addpath(genpath(fullfile(git_folder, 'rcaExtra-dev')),'-end');
    addpath(genpath(fullfile(git_folder, 'rcaBase')),'-end');
    addpath(genpath(fullfile(git_folder, 'mrC')),'-end');
    addpath(genpath(fullfile(git_folder, 'svndl_code')),'-end');
    
    experimentName = '2019_K2_Data';
    
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
    % K2 data cleaning
    
    cleanedEEG(:,1) = cellfun(@(x) x(421:1:5040-420, 1:128, [1,2,5:8,10,12]), EEGData(:,1), 'uni', false);
    cleanedEEG(:,2) = cellfun(@(x) x(421:1:5040-420, 1:128, [2,3,5,6,8:11]), EEGData(:,2), 'uni', false);
    cleanedEEG(:,3) = cellfun(@(x) x(421:1:5040-420, 1:128, [2,4:6,8:9,11:12]), EEGData(:,3), 'uni', false);
    
    %Mgic word project data cleaning
for i = 24
 EEGData(i,4) = cellfun(@(x) x(:, 1:128, [2,4:6,8:9,11:12]), EEGData(i,4), 'uni', false);   
end 

for i = 14:17
 EEGData(i,4) = cellfun(@(x) x(:, 1:128, [1:2,4:5,7,9,11:12]), EEGData(i,4), 'uni', false);   
end 

for i = 25
 EEGData(i,4) = cellfun(@(x) x(:, 1:128, [2:3,5,7:9,11:12]), EEGData(i,4), 'uni', false);   
end 

    % cleanedEEG = cellfun(@(x) x(421:1:5040-420, 1:128, :), EEGData, 'uni', false);
    % use cleanedEEG instead of EEGData 
    
    % selecting specific frequency (1 HZ) and corresponding sampling rate
    % and time course length to use for resampling, RC analysis and
    % plotting results
    
    % rcSettings has two resampling values and two timecourses
    
    
    % filter data
    frequenciesHz = [1 3 5 7 9]; % Which frequencies to exclude (very important here is using the filtered out data as input data
                                 %because the filtered out data are exactly 1 3 5 7 9, the filtered data still include 2.2, 2.3 etc.)
    n = size(subjList,2);
    fs = 420;
    datalocation = '/Volumes/GSE/K2Followup_MW/K2_T1/GroupRCAOutput_time_all_updateforpaper_noreshaping/';
    
    % load raw data
    for n = 1:size(subjList,2)
    
        % Filtering the rawdata
        %[nfData, filteredData] = rcaExtra_filterEpochs(cleanedEEG,frequenciesHz);
        [nfData, filteredData] = rcaExtra_filterEpochs(EEGData,frequenciesHz);

        subjEEG = nfData
        save(strcat(datalocation,'nfData/', subjList{1,n},'.mat'),'subjEEG','-v7.3','-nocompression')
        
        subjEEG = filteredData
        save(strcat(datalocation,'filteredData/', subjList{1,n},'.mat'),'subjEEG','-v7.3','-nocompression')
    end
    
    
    % for oddball settigs
    runSettings_1hz = rcSettings;
    runSettings_1hz.samplingRate = rcSettings.samplingRate(1);
    runSettings_1hz.timecourseLen = rcSettings.timecourseLen(1);
    
    % for carrier settigs
    runSettings_2hz = rcSettings;
    runSettings_2hz.samplingRate = rcSettings.samplingRate(2);
    runSettings_2hz.timecourseLen = rcSettings.timecourseLen(2); 
    
    % Choose the setting you'd like to use (runSettings_1hz or
    % runSettings_2hz)
    currSettings = runSettings_1hz;
    
    % Resampling time domain data so last dimension has bins and trials
    resampled_data = nfData;
    if (size(EEGData{1, 1}, 1) ~= currSettings.samplingRate)
        resampled_data = resampleData(nfData, currSettings.samplingRate);
    end
    if (~isempty(currSettings.useCnds))
        dataSlice = resampled_data(:, currSettings.useCnds);
    else
        dataSlice = resampled_data;
    end
    
    
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
    
    for nc = 1:nConditions
        % copy runtime settings from 1Hz template
        runSettings_1hz_condition{nc} = runSettings_1hz;
        runSettings_1hz_condition{nc}.useCnds = nc;
        % add condition-specific label
        runSettings_1hz_condition{nc}.label = analysisStruct.info.conditionLabels{nc};
        
        % select subset of raw data
        rcResult_condition{nc} = rcaExtra_runAnalysis(runSettings_1hz_condition{nc}, dataSlice);
        
        
        order = [-1 2 3 4 5 6];
        
        %adjust weights
        out = rcaExtra_adjustRCWeights(rcResult_condition{nc}, order);
        
        %recompute averages after adjusting weights
        out = rcaExtra_computeAverages(out); %save this out for plotting
        
        % plot results
    end  
    % project through frequency domain weights
        data_Out = rcaExtra_projectData(dataSlice, out.W);
     
    nConditions = 3; % for MS data only running 3 conditions. 
    % nConditions = size(dataSlice, 2) % for other studies.
    
    % allocate cell array to store individual condition RCA runtime settings 
    runSettings = cell(nConditions, 1);
    
    % allocate cell array to store individual condition RCA runtime results     
    rcResult_condition_FreqDomain = cell(nConditions, 1);
   
    for nc = 3:nConditions 
        % copy runtime settings from 3Hz template
        runSettings{nc} = currSettings;
        runSettings{nc}.useCnds = nc;
        % add condition-specific label 
        runSettings{nc}.label = analysisStruct.info.conditionLabels{nc};
        
        rcResult_condition_FreqDomain{nc}.W = out.W; % get W from freq domain output
        rcResult_condition_FreqDomain{nc}.A = out.A; % get A from freq domain output
        rcResult_condition_FreqDomain{nc}.sourceData = dataSlice(:,nc); 
        rcResult_condition_FreqDomain{nc}.projectedData = data_Out(:,nc); % this is from the projected data output
        rcResult_condition_FreqDomain{nc}.rcaSettings = runSettings{nc};
        rcResult_condition_FreqDomain{nc}.covData = out.covData; % from freq domain output
        rcResult_condition_FreqDomain{nc}.timecourse = linspace(0, runSettings{nc}.timecourseLen - 1, runSettings{nc}.samplingRate); % this calculation is from line 15 of runRCA_time.m
    
    
    end
    
    
    muData1 = rcResult_condition_FreqDomain{1,1}.mu_cnd{1,1}(:,1);
    semData1 = rcResult_condition_FreqDomain{1,1}.s_cnd{1,1}(:,1);
    muData2 = rcResult_condition_FreqDomain{2,1}.mu_cnd{1,1}(:,1);
    semData2 = rcResult_condition_FreqDomain{2,1}.s_cnd{1,1}(:,1);
    muData3 = rcResult_condition_FreqDomain{3,1}.mu_cnd{1,1}(:,1);
    semData3 = rcResult_condition_FreqDomain{3,1}.s_cnd{1,1}(:,1);
    figure()
    semData10 = zeros(420,1);
h = shadedErrorBar([0:1000/420:1000-1000/420],muData1(:),semData10(:),'k');
hold on
h = shadedErrorBar([0:1000/420:1000-1000/420],muData2(:),semData10(:),'r');
hold on
h = shadedErrorBar([0:1000/420:1000-1000/420],muData3(:),semData10(:),'b');
h = shadedErrorBar([0:1000/420:1000-1000/420],muData12(:),semData10(:),'r');
end
