function main_EdNeuro_MS_Oddball_analysis_time_throughFreqRC
    %% Add paths
    git_folder = '/Users/nhqtrang/Desktop/Synapse_MiddleSchool/code/git';
    addpath(genpath(fullfile(git_folder, 'rcaExtra-dev')),'-end');
    addpath(genpath(fullfile(git_folder, 'rcaBase')),'-end');
    addpath(genpath(fullfile(git_folder, 'mrC')),'-end');
    addpath(genpath(fullfile(git_folder, 'svndl_code')),'-end');
    addpath(genpath('/Users/nhqtrang/Desktop/Synapse_MiddleSchool/A_Exports_EdNeuro_MS'))

    %% Load the weights (W) trained from Freq Domain 
    load('/Volumes/Backup Plus/Synapse_MiddleSchool/B_Output_FreqDomain_10bin_freq369/RCA/rcaResults_Freq_Conditions123.mat');
    rcaResult_FreqDomain = rcaResult;

    %% define experimentInfo and read raw data
          
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
       
    % selecting specific frequency and corresponding sampling rate
    % and time course length to use for resampling, RC analysis and
    % plotting results
    
    % rcSettings has two resampling values and two timecourses. (1) for
    % oddball and (2) for carrier frequency. 
    
    % for oddball analysis
    runSettings_1hz = rcSettings;
    runSettings_1hz.samplingRate = rcSettings.samplingRate(1);
    runSettings_1hz.timecourseLen = rcSettings.timecourseLen(1);
    
    % for carrier analysis
    runSettings_3hz = rcSettings;
    runSettings_3hz.samplingRate = rcSettings.samplingRate(2);
    runSettings_3hz.timecourseLen = rcSettings.timecourseLen(2);
    
    % Choose the setting you'd like to use (runSettings_1hz or
    % runSettings_3hz)
    currSettings = runSettings_3hz;
    
    % Resampling time domain data so last dimension has bins and trials
    resampled_data = nfData; %nfData or filteredData from filtering
    if (size(EEGData{1, 1}, 1) ~= currSettings.samplingRate)
        resampled_data = resampleData(nfData, currSettings.samplingRate);
    end
    if (~isempty(currSettings.useCnds))
        dataSlice = resampled_data(:, currSettings.useCnds);
    else
        dataSlice = resampled_data;
    end
    
    % Feed Time domain data through those W using rcaExtra_projectdata. 
    % This takes a few minutes for big datasets so please be patient.  
    data_Out = rcaExtra_projectData(dataSlice, rcaResult_FreqDomain.W);
    data_Out = rcaExtra_projectData(dataSlice, out.W);
     
    nConditions = 3; % for MS data only running 3 conditions. 
    % nConditions = size(dataSlice, 2) % for other studies.
    
    % allocate cell array to store individual condition RCA runtime settings 
    runSettings = cell(nConditions, 1);
    
    % allocate cell array to store individual condition RCA runtime results     
    rcResult_condition_FreqDomain = cell(nConditions, 1);
   
    for nc = 1:nConditions 
        % copy runtime settings from 3Hz template
        runSettings{nc} = currSettings;
        runSettings{nc}.useCnds = nc;
        % add condition-specific label 
        runSettings{nc}.label = analysisStruct.info.conditionLabels{nc};
        
        rcResult_condition_FreqDomain{nc}.W = rcaResult_FreqDomain.W; % get W from freq domain output
        rcResult_condition_FreqDomain{nc}.A = rcaResult_FreqDomain.A; % get A from freq domain output
        rcResult_condition_FreqDomain{nc}.sourceData = dataSlice(:,nc); 
        rcResult_condition_FreqDomain{nc}.projectedData = data_Out(:,nc); % this is from the projected data output
        rcResult_condition_FreqDomain{nc}.rcaSettings = runSettings{nc};
        rcResult_condition_FreqDomain{nc}.covData = rcaResult_FreqDomain.covData; % from freq domain output
        rcResult_condition_FreqDomain{nc}.timecourse = linspace(0, runSettings{nc}.timecourseLen - 1, runSettings{nc}.samplingRate); % this calculation is from line 15 of runRCA_time.m
    
    
    end
    
    % average each subject's response
    subjMean_cell = cellfun(@(x) nanmean(x, 3), data_Out', 'uni', false)';
    subjMean_bycnd = cell(1, nConditions);
    for nc = 3:nConditions % for 3 conditions
         cndData = cat(3, subjMean_cell{:, nc});
         % baseline
         subjMean_bycnd{nc} = cndData - repmat(cndData(1, :, :), [size(cndData, 1) 1 1]);
    end
        
    % for joint projection, compute mean/std
    for nc = 1:nConditions
    subjMean (nc) = squeeze(cat(3, subjMean_bycnd{nc}));
    end
    for nc = 3:nConditions
    rcResult_condition_FreqDomain{nc}.mu = nanmean(subjMean, 3);
    rcResult_condition_FreqDomain{nc}.s = nanstd(subjMean, [], 3)/(sqrt(size(subjMean, 3)));

    % for each condition, compute individual mean/std
    rcResult_condition_FreqDomain{nc}.mu_cnd{1,1} = nanmean(subjMean_bycnd{nc}, 3);
    rcResult_condition_FreqDomain{nc}.s_cnd{1,1} = nanstd(subjMean_bycnd{nc}, [], 3)/(sqrt(size(subjMean_bycnd{nc}, 3)));
    end     
    
    
  %  save(strcat('/Volumes/Backup Plus/Synapse_MiddleSchool/B_Output_TimeDomain_369/RCA/rcResult_condition.mat'),'rcResult_condition_FreqDomain','subjList','-v7.3')

   %% Compute Stats and plot RC results 
   plotSettings = rcaExtra_getPlotSettings(analysisStruct);
   plotSettings.plotType = 'exploratory';
   statSettings = rcaExtra_getStatsSettings(currSettings);
   
   for nc = 1:nConditions
       subjRCMean = rcaExtra_prepareDataArrayForStats(rcResult_condition_FreqDomain{nc}.projectedData, statSettings);
       sigResults = rcaExtra_testSignificance(subjRCMean, [], statSettings);
       rcResult_condition_FreqDomain{nc}.subjRCMean = subjRCMean;
       rcResult_condition_FreqDomain{nc}.sigResults = sigResults;
       try
           rcaExtra_plotRCSummary(rcResult_condition_FreqDomain{nc}, sigResults);
       catch err
           rcaExtra_displayError(err);
       end
   end
   
save(strcat('/Volumes/Backup Plus/Synapse_MiddleSchool/B_Output_TimeDomain_369/RCA/rcResult_condition.mat'),'rcResult_condition_FreqDomain','subjList','-v7.3')
   
