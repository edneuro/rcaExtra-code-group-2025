%% load in rcaResult that trained on bins 1:10

load('/Volumes/GSE/K2/separategroup_readingscore/fre_carrier_lowmiddlehigh/RCA/rcaResult_Freq_Condition123_adjustWeights_recomputeaverages.mat')

load('/Volumes/GSE/K2followup_MW/K2_T1/GroupRCAOutput_carrier/RCA/rcaResult_Freq_Conds123_adjustweights_recomputeaverages.mat')
load('/Volumes/GSE/K2followup_MW/K2_T4/GroupRCAOutput_carrier/RCA/rcaResult_Freq_Conds123_adjustweights_recomputeaverages.mat')
%% Load bin 0 data because we need to project bin 0 data (given doesn't have nans in the data) through the weights that trained on bins 1:10
 
      experimentName = '2021_K2_MW';
    
    
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
    
    analysisStruct.domain = 'freq';
    
    % get load settings template structure
    loadSettings = rcaExtra_getDataLoadingSettings(analysisStruct);
   
    % fill structure with actual parameters
    loadSettings.useBins = 0; % load bin 0 
    %loadSettings.useFrequencies = {'1F2', '2F2', '3F2', '4F2', '5F2'}; % for K2 carrier
    loadSettings.useFrequencies = {'3F1', '6F1', '9F1'}; % for MS data carrier
  
    
    % read raw data     
    [subjList, sensorData, cellNoiseData1, cellNoiseData2, ~] = getRawData(loadSettings);
    
    % get the RC runtime settings template structure
    
    rcSettings = rcaExtra_getRCARunSettings(analysisStruct);
    % fill the RC runtime template structure with real parameters
    
    % Define subject names. Will be used to compare between
    % saved (stored) results and requested results
    rcSettings.subjList = subjList;
    
    % Define bin vector. Will be used to compare between
    % saved (stored) results and requested results
    rcSettings.useBins = loadSettings.useBins;
    
    % Define frequency list. Will be used to compare between
    % saved (stored) results and requested results
    rcSettings.useFrequencies = loadSettings.useFrequencies;
   
    % skipping this because bin 0 data is only 1 bin long
%     reshapeTrialToBin = 1;
%     if reshapeTrialToBin
%         
%         sensorData_tr = sensorData; % Move orig to new variable
%         sensorData = cellfun(@(x) reshapeTrialToBinForRCA(x, length(rcSettings.useBins)),...
%             sensorData_tr, 'UniformOutput', false);
%         
%         cellNoiseData1_tr = cellNoiseData1; % Move orig to new variable
%         cellNoiseData1 = cellfun(@(x) reshapeTrialToBinForRCA(x, length(rcSettings.useBins)),...
%             cellNoiseData1_tr, 'UniformOutput', false);
%         
%         cellNoiseData2_tr = cellNoiseData2; % Move orig to new variable
%         cellNoiseData2 = cellfun(@(x) reshapeTrialToBinForRCA(x, length(rcSettings.useBins)),...
%             cellNoiseData2_tr, 'UniformOutput', false);
%         
%         % Adjust rcSettings accordingly
%         rcSettings_tr = rcSettings; % Mover orig to new variable
%         rcSettings.useBins = 1; % Used to be 1:10
%         
%     end
    
    %% Project bin 0 data through weights learned on bins 1:10

    % sensorData is now the data from loadSettings.useBins = 0
   
    % sensorData has all 4 conditions but we want to only include cond 1-3
    sensorData = sensorData(:,1:3); %for carrier, because trained three conditions together
    sensorData = sensorData(:,4);
    sensorData = sensorData(:,3:5);% for magic word data, cond3 is learned MW-unlearned MW; cond4 is HFW-PW; cond5: MFW-PW
    % Project bin 0 (averaged) data through weights (learned from RCA trained on 1:10 and reshaped)
    % rcResultStruct_cnd_123 holds the weights trained on bins 1:10 (since loadSettings.useBins = 1:10)
    rcResultStruct_cnd_123_bin0 = rcaExtra_projectDataSubset(out, sensorData);
    rcResultStruct_cnd_4_bin0 = rcaExtra_projectDataSubset(rcaResult, sensorData);
    rcResultStruct_cnd_123_bin0 = rcaExtra_projectDataSubset(out_T4, sensorData);
    
    % Save rcaResults struct
    data_location = '/Volumes/CU_HD/research/results/EGI_validation/bin0/RCA';
    save(strcat(data_location,'rcaResults_Freq_Cond123_ProjectedBin0.mat'),'rcResultStruct_cnd_123_bin0','-v7.3')
    
   % Reshape a subject x condition cell array (as field of
%   input struct) and outputs a trial x condition cell array for each
%   subject (as field of elements in output struct array).

    rcResultStruct_cnd_123_bin0.rcaSettings.useFrequenciesHz = 3; % if line 27 loadSettings.useFrequencies = {'2Hz', '4Hz', '6Hz', '8Hz', '10Hz'}; then no need to run this line
    rcOut = convertProjectCellToSubCell(rcResultStruct_cnd_123_bin0); % this function is in edNeuro-eeg-dev, make sure to add in path
    
   
    %recompute projAvg for each subject because the original ones are
    %copied from results trained on bin1:10, now we recompute
    for n = 1:length(rcOut)
        n
        rcOut_recomputeProjAvg(n) = rcaExtra_computeAverages(rcOut(n));

    end
    
    
    % Calculating significant harmonics and getting latency values and
    % errors using those significant harmonics
    
    
    for n = 1:length(rcOut_recomputeProjAvg)
        statSubject(n) = rcaExtra_runStatsAnalysis(rcOut_recomputeProjAvg(n), []); % Calculate Statistics (sig diff one dataset vs 0)
        [carrier_rcOut(n).latencyVals, carrier_rcOut(n).latencyErrs] = rcaExtra_computeLatenciesWithSignificance(rcOut_recomputeProjAvg(n), statSubject(n))
    end
    
  % exract latency values - below you can save it after extracting
  for n = 1:length(carrier_rcOut)
      for c =1:3
        latencyMean_Comp1(n,c) = carrier_rcOut(n).latencyVals(1,c);
        latencyError_Comp1(n,c) = carrier_rcOut(n).latencyErrs(1,c);
      end   
  end

  for n = 1:length(carrier_rcOut)
      for c =1:3
          latencyMean_Comp2(n,c) = carrier_rcOut(n).latencyVals(2,c);
          latencyError_Comp2(n,c) = carrier_rcOut(n).latencyErrs(2,c);
      end
  end
    
    % count numer of significant harmonics for each condition and each
    % component
    
    for n = 1:length(rcOut_recomputeProjAvg)        
        for cond = 4
            for comp = 1
                NumberSig(n,cond,comp) = sum(statSubject(n).sig(:,comp,cond) == 1);
            end
        end
    end
    
    csvwrite('/Volumes/GSE/K2/excels/NumberofSignificantHarmoincs.csv', NumberSig)
    
    % for trang's data which want to turn 2 significant harmonics to 3
    % ones. for a new latency estimates
    
    for n = 1:length(statSubject)
        for h = 1:3
            for c = 1:3
                statSubject(n).sig(h,1,c) = 1;
            end
        end
       [carrier_rcOut(n).latencyVals, carrier_rcOut(n).latencyErrs] = rcaExtra_computeLatenciesWithSignificance(rcOut_recomputeProjAvg(n), statSubject(n))
    end
    
    
    % generate plots for each subject 
    
    for n = 1:length(rcOut_recomputeProjAvg)
        close all % close figs before rendering the next figs
        statSubject(n) = rcaExtra_runStatsAnalysis(rcOut_recomputeProjAvg(n), []); % Calculate Statistics (sig diff one dataset vs 0)
        if ~exist(rcOut_recomputeProjAvg(n).rcaSettings.destDataDir_FIG, 'dir'), mkdir(rcOut_recomputeProjAvg(n).rcaSettings.destDataDir_FIG); end % created subject-specific FIG folders to store graphs
        rcaExtra_plotSignificantResults_freq(rcOut_recomputeProjAvg(n),[],statSubject(n),[]) % Plot Significant Results
    end
    

    
    %% extracting latency values for components as needed
    % extract latency values for component 1
    for n = 1:length(carrier_rcOut)
        for c = 1:3 %loop over three conditions
            latencyMean_Comp1(n,c) = carrier_rcOut(n).latencyVals(1,c);% for latency values
            latencyError_Comp1(n,c) = carrier_rcOut(n).latencyErrs(1,c);% for latency errors
        end
    end
    csvwrite('/Volumes/GSE/2019_EdNeuro_MS/2019_EdNeuro_MS_included/LatencyIndividualSubj_comp1.csv',latencyMean_Comp1);
    csvwrite('/Volumes/GSE/2019_EdNeuro_MS/2019_EdNeuro_MS_included/LatencyErrorIndividualSubj_comp1.csv',latencyError_Comp1);
    
    % extract latency values for component 2
    for n = 1:length(carrier_rcOut) %n is subject
        for c = 1:3 %c is for condition
            latencyMean_Comp2(n,c) = carrier_rcOut(n).latencyVals(2,c);
            latencyError_Comp2(n,c) = carrier_rcOut(n).latencyErrs(2,c);% for latency errors
        end
    end
    csvwrite('/Volumes/GSE/2019_EdNeuro_MS/2019_EdNeuro_MS_included/LatencyIndividualSubj_comp2.csv',latencyMean_Comp2);
    csvwrite('/Volumes/GSE/2019_EdNeuro_MS/2019_EdNeuro_MS_included/LatencyErrorIndividualSubj_comp2.csv',latencyError_Comp2);
    % extract latency values for component 3
    for n = 1:length(carrier_rcOut)
        for c = 1:3
            latencyMean_Comp3(n,c) = carrier_rcOut(n).latencyVals(3,c);
            latencyError_Comp3(n,c) = carrier_rcOut(n).latencyErrs(3,c);% for latency errors
        end
    end
    csvwrite('/Volumes/GSE/2019_EdNeuro_MS/2019_EdNeuro_MS_included/LatencyIndividualSubj_comp3.csv',latencyMean_Comp3);
    csvwrite('/Volumes/GSE/2019_EdNeuro_MS/2019_EdNeuro_MS_included/LatencyErrorIndividualSubj_comp3.csv',latencyError_Comp3);
     % if there is only one condition, to extract values
    latency = extractfield(carrier_rcOut,'latencyVals')'; 
    latency_comp2 = latency(2:6:336); % take vernier data for example
    %% plots lolliplots for each individual subject 
    path = '/Volumes/GSE/K2/separategroup_readingscore/fre_carrier_individualsubjects';
    cd(path);
    files = dir('2*');
    
    
    for n = 1:length(rcOut_recomputeProjAvg)
        
        rcaExtra_plotLollipops_individual(rcOut_recomputeProjAvg(n), []);
        
    end
    