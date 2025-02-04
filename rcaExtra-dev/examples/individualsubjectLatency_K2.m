%% load in rcaResult that trained on bins 1:10

load('/Volumes/GSE/K2/separategroup_readingscore/fre_carrier_lowmiddlehigh/RCA/rcaResult_Freq_Condition123_adjustWeights_recomputeaverages.mat')

load('/Volumes/GSE/K2followup_MW/K2_T1/GroupRCAOutput_carrier/RCA/rcaResult_Freq_Conds123_adjustweights_recomputeaverages.mat')
load('/Volumes/GSE/K2followup_MW/K2_T4/GroupRCAOutput_carrier/RCA/rcaResult_Freq_Conds123_adjustweights_recomputeaverages.mat')
%% Load bin 0 data because we need to project bin 0 data (given doesn't have nans in the data) through the weights that trained on bins 1:10
 
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
    
    analysisStruct.domain = 'freq';
    
    % get load settings template structure
    loadSettings = rcaExtra_getDataLoadingSettings(analysisStruct);
   
    % fill structure with actual parameters
    loadSettings.useBins = 0; % load bin 0 
    loadSettings.useFrequencies = {'1F2', '2F2', '3F2', '4F2', '5F2'}; % for K2 carrier
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
   
    % sensorData has all 4 conditions so we want to only include cond 1-3
    sensorData = sensorData(:,1:3); %for carrier, because trained three conditions together
    sensorData = sensorData(:,4);
    sensorData = sensorData(:,3:5);% for magic word data, cond3 is learned MW-unlearned MW; cond4 is HFW-PW; cond5: MFW-PW
    % Project bin 0 (averaged) data through weights (learned from RCA trained on 1:10 and reshaped)
    % rcResultStruct_cnd_123 holds the weights trained on bins 1:10 (since loadSettings.useBins = 1:10)
    rcResultStruct_cnd_123_bin0 = rcaExtra_projectDataSubset(rcResultStruct_cnd_123, sensorData);
    rcResultStruct_cnd_4_bin0 = rcaExtra_projectDataSubset(rcaResult, sensorData);
    rcResultStruct_cnd_123_bin0 = rcaExtra_projectDataSubset(out_T4, sensorData);
    
    % Save rcaResults struct
    data_location = '/Users/fangwang/Dropbox (Personal)/MiddleSchool Analysis/IndividualLevel/';
    save(strcat(data_location,'rcaResults_Freq_Conds123_ProjectedBin0.mat'),'rcResultStruct_cnd_123_bin0','-v7.3')
    
   % Reshape a subject x condition cell array (as field of
%   input struct) and outputs a trial x condition cell array for each
%   subject (as field of elements in output struct array).

    rcResultStruct_cnd_123_bin0.rcaSettings.useFrequenciesHz = 1; % if line 27 loadSettings.useFrequencies = {'2Hz', '4Hz', '6Hz', '8Hz', '10Hz'}; then no need to run this line
    rcOut = convertProjectCellToSubCell(rcResultStruct_cnd_123_bin0); % this function is in edNeuro-eeg-dev, make sure to add in path
    
   
    %recompute projAvg for each subject because the original ones are
    %copied from results trained on bin1:10, now we recompute
    for n = 1:length(rcOut)
        rcOut_recomputeProjAvg(n) = rcaExtra_computeAverages(rcOut(n));
    end
    
    
    % Calculating significant harmonics and getting latency values and
    % errors using those significant harmonics
    
    
    for n = 1:length(rcOut_recomputeProjAvg)
        statSubject(n) = rcaExtra_runStatsAnalysis(rcOut_recomputeProjAvg(n), []); % Calculate Statistics (sig diff one dataset vs 0)
        [carrier_rcOut(n).latencyVals, carrier_rcOut(n).latencyErrs] = rcaExtra_computeLatenciesWithSignificance(rcOut_recomputeProjAvg(n), statSubject(n))
    end
    
  % exract latency values
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

    for n = 1:length(carrier_rcOut)
      for c =1:3
          latencyMean_Comp3(n,c) = carrier_rcOut(n).latencyVals(3,c);
          latencyError_Comp3(n,c) = carrier_rcOut(n).latencyErrs(3,c);
      end
  end
    
    % count numer of significant harmonics for each condition and each
    % component
    
    for n = 1:length(rcOut_recomputeProjAvg)        
        for cond = 3
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
    
    %% concatenate sensorData, so that will be 30 trials all together
    result = cell(size(sensorData, 1), 1);
    
    % Loop through each row of the cell array
    for i = 1:size(sensorData, 1)
        % Concatenate along the 3rd dimension for the 1x3 cell array in the row
        result{i} = cat(3, sensorData{i, 1}, sensorData{i, 2}, sensorData{i, 3});
    end

    
    % Assuming `result` is the 68x1 cell array from the previous step

    % Preallocate two new cell arrays for the splits
    selected15 = cell(size(result)); % Cell array for 15 randomly selected slices
    remaining15 = cell(size(result)); % Cell array for the rest of the slices

    % Loop through each cell
    for i = 1:length(result)
        % Get the 6x128x30 data from the current cell
        current_data = result{i};

        % Generate random indices for selection
        random_indices = randperm(30, 15); % Randomly select 15 indices out of 30
        remaining_indices = setdiff(1:30, random_indices); % The remaining 15 indices

        % Split the data into two parts
        selected15{i} = current_data(:, :, random_indices); % Select the 15 slices
        remaining15{i} = current_data(:, :, remaining_indices); % Select the remaining 15 slices
    end

     % Loop through each cell
    for i = 1:32
        % Get the 6x128x30 data from the current cell
        current_data = result{i};

        % Generate random indices for selection
        random_indices = randperm(30, 15); % Randomly select 15 indices out of 30
        remaining_indices = setdiff(1:30, random_indices); % The remaining 15 indices

        % Split the data into two parts
        selected15{i} = current_data(:, :, random_indices); % Select the 15 slices
        remaining15{i} = current_data(:, :, remaining_indices); % Select the remaining 15 slices
    end

    for i = 34:68
        % Get the 6x128x30 data from the current cell
        current_data = result{i};

        % Generate random indices for selection
        random_indices = randperm(30, 15); % Randomly select 15 indices out of 30
        remaining_indices = setdiff(1:30, random_indices); % The remaining 15 indices

        % Split the data into two parts
        selected15{i} = current_data(:, :, random_indices); % Select the 15 slices
        remaining15{i} = current_data(:, :, remaining_indices); % Select the remaining 15 slices
    end

    for i = 33
        % Get the 6x128x30 data from the current cell
        current_data = result{i};

        % Generate random indices for selection
        random_indices = randperm(29, 15); % Randomly select 15 indices out of 30
        remaining_indices = setdiff(1:29, random_indices); % The remaining 15 indices

        % Split the data into two parts
        selected15{i} = current_data(:, :, random_indices); % Select the 15 slices
        remaining15{i} = current_data(:, :, remaining_indices); % Select the remaining 15 slices
    end
%do latency calculation 
     rcResultStruct_cnd_123_bin0_selected15 = rcaExtra_projectDataSubset(rcResultStruct_cnd_123, selected15);

     % Save rcaResults struct
    data_location = '/Users/fangwang/Dropbox (Personal)/MiddleSchool Analysis/IndividualLevel/';
    save(strcat(data_location,'rcaResults_Freq_Conds123_selected15_ProjectedBin0.mat'),'rcResultStruct_cnd_123_bin0_selected15','-v7.3')
    
   % Reshape a subject x condition cell array (as field of
%   input struct) and outputs a trial x condition cell array for each
%   subject (as field of elements in output struct array).

    rcResultStruct_cnd_123_bin0_selected15.rcaSettings.useFrequenciesHz = 1; % if line 27 loadSettings.useFrequencies = {'2Hz', '4Hz', '6Hz', '8Hz', '10Hz'}; then no need to run this line
    rcOut = convertProjectCellToSubCell(rcResultStruct_cnd_123_bin0_selected15); % this function is in edNeuro-eeg-dev, make sure to add in path
    
   
    %recompute projAvg for each subject because the original ones are
    %copied from results trained on bin1:10, now we recompute
    for n = 1:length(rcOut)
        rcOut_recomputeProjAvg(n) = rcaExtra_computeAverages(rcOut(n));
    end
    
    
    % Calculating significant harmonics and getting latency values and
    % errors using those significant harmonics
    
    
    for n = 1:length(rcOut_recomputeProjAvg)
        statSubject(n) = rcaExtra_runStatsAnalysis(rcOut_recomputeProjAvg(n), []); % Calculate Statistics (sig diff one dataset vs 0)
        [carrier_rcOut(n).latencyVals, carrier_rcOut(n).latencyErrs] = rcaExtra_computeLatenciesWithSignificance(rcOut_recomputeProjAvg(n), statSubject(n))
    end

    % Preallocate a vector to store the first values
firstValues = nan(1, length(carrier_rcOut));

% Loop through the struct array
for i = 1:length(carrier_rcOut)
    % Extract the first value of latencyVals, handle NaN if it exists
    if ~isempty(carrier_rcOut(i).latencyVals)
        firstValues(i) = carrier_rcOut(i).latencyVals(1);
    else
        firstValues(i) = NaN; % Assign NaN if latencyVals is empty
    end
end

%do latency calculation 
     rcResultStruct_cnd_123_bin0_remaining15 = rcaExtra_projectDataSubset(rcResultStruct_cnd_123, remaining15);

     % Save rcaResults struct
    data_location = '/Users/fangwang/Dropbox (Personal)/MiddleSchool Analysis/IndividualLevel/';
    save(strcat(data_location,'rcaResults_Freq_Conds123_remaining15_ProjectedBin0.mat'),'rcResultStruct_cnd_123_bin0_remaining15','-v7.3')
    
   % Reshape a subject x condition cell array (as field of
%   input struct) and outputs a trial x condition cell array for each
%   subject (as field of elements in output struct array).

    rcResultStruct_cnd_123_bin0_remaining15.rcaSettings.useFrequenciesHz = 1; % if line 27 loadSettings.useFrequencies = {'2Hz', '4Hz', '6Hz', '8Hz', '10Hz'}; then no need to run this line
    rcOut = convertProjectCellToSubCell(rcResultStruct_cnd_123_bin0_remaining15); % this function is in edNeuro-eeg-dev, make sure to add in path
    
   
    %recompute projAvg for each subject because the original ones are
    %copied from results trained on bin1:10, now we recompute
    for n = 1:length(rcOut)
        rcOut_recomputeProjAvg(n) = rcaExtra_computeAverages(rcOut(n));
    end
    
    
    % Calculating significant harmonics and getting latency values and
    % errors using those significant harmonics
    
    
    for n = 1:length(rcOut_recomputeProjAvg)
        statSubject(n) = rcaExtra_runStatsAnalysis(rcOut_recomputeProjAvg(n), []); % Calculate Statistics (sig diff one dataset vs 0)
        [carrier_rcOut(n).latencyVals, carrier_rcOut(n).latencyErrs] = rcaExtra_computeLatenciesWithSignificance(rcOut_recomputeProjAvg(n), statSubject(n));
    end

    % Preallocate a vector to store the first values
firstValues = nan(1, length(carrier_rcOut));

% Loop through the struct array
for i = 1:length(carrier_rcOut)
    % Extract the first value of latencyVals, handle NaN if it exists
    if ~isempty(carrier_rcOut(i).latencyVals)
        firstValues(i) = carrier_rcOut(i).latencyVals(1);
    else
        firstValues(i) = NaN; % Assign NaN if latencyVals is empty
    end
end


%% all 30 trials concaternated

  rcResultStruct_cnd_123_bin0_all30 = rcaExtra_projectDataSubset(rcResultStruct_cnd_123, result);% code has problems, the updated code is better (the one i shared with Vani doesn't work, have to use Lindsey's)

rcResultStruct_cnd_123_bin0_all30.rcaSettings.useFrequenciesHz = 1; % if line 27 loadSettings.useFrequencies = {'2Hz', '4Hz', '6Hz', '8Hz', '10Hz'}; then no need to run this line
    rcOut = convertProjectCellToSubCell(rcResultStruct_cnd_123_bin0_all30); % this function is in edNeuro-eeg-dev, make sure to add in path
    
   
    %recompute projAvg for each subject because the original ones are
    %copied from results trained on bin1:10, now we recompute % okay here
    %have to remove path of lindsey's folder Re/ line 381 note
    for n = 46:68length(rcOut)
        rcOut_recomputeProjAvg(n) = rcaExtra_computeAverages(rcOut(n));
    end
    
    
    % Calculating significant harmonics and getting latency values and
    % errors using those significant harmonics
    
    
    for n = 1:length(rcOut_recomputeProjAvg)
        statSubject(n) = rcaExtra_runStatsAnalysis(rcOut_recomputeProjAvg(n), []); % Calculate Statistics (sig diff one dataset vs 0)
        [carrier_rcOut(n).latencyVals, carrier_rcOut(n).latencyErrs] = rcaExtra_computeLatenciesWithSignificance(rcOut_recomputeProjAvg(n), statSubject(n));
    end

    %% split trials into 2 halfs and then do 
  

     % Loop through each cell
    for i = 1:32
        for c = 1:3
        % Get the 6x128x30 data from the current cell
        current_data = sensorData{i,c};
        current_data_CN1 = cellNoiseData1{i,c};
        current_data_CN2 = cellNoiseData2{i,c};

        % Generate random indices for selection
        random_indices = randperm(10, 5); % Randomly select 15 indices out of 30
        remaining_indices = setdiff(1:10, random_indices); % The remaining 15 indices

        % Split the data into two parts
        selected15{i,c} = current_data(:, :, random_indices); % Select the 15 slices
        remaining15{i,c} = current_data(:, :, remaining_indices); % Select the remaining 15 slices % Split the data into two parts
        
        selected15_CN1{i,c} = current_data_CN1(:, :, random_indices); % Select the 15 slices
        remaining15_CN1{i,c} = current_data_CN1(:, :, remaining_indices); % Select the remaining 15 slices

        selected15_CN2{i,c} = current_data_CN2(:, :, random_indices); % Select the 15 slices
        remaining15_CN2{i,c} = current_data_CN2(:, :, remaining_indices); % Select the remaining 15 slices
        end
    end

    for i = 34:68
        for c = 1:3
        % Get the 6x128x30 data from the current cell
        current_data = sensorData{i,c};
        current_data_CN1 = cellNoiseData1{i,c};
        current_data_CN2 = cellNoiseData2{i,c};


        % Generate random indices for selection
        random_indices = randperm(10, 5); % Randomly select 15 indices out of 30
        remaining_indices = setdiff(1:10, random_indices); % The remaining 15 indices

        % Split the data into two parts
        selected15{i,c} = current_data(:, :, random_indices); % Select the 15 slices
        remaining15{i,c} = current_data(:, :, remaining_indices); % Select the remaining 15 slices

        selected15_CN1{i,c} = current_data_CN1(:, :, random_indices); % Select the 15 slices
        remaining15_CN1{i,c} = current_data_CN1(:, :, remaining_indices); % Select the remaining 15 slices

        selected15_CN2{i,c} = current_data_CN2(:, :, random_indices); % Select the 15 slices
        remaining15_CN2{i,c} = current_data_CN2(:, :, remaining_indices); % Select the remaining 15 slices
        end
    end

    for i = 33
        for c = 1:3
        % Get the 6x128x30 data from the current cell
        current_data = sensorData{i,c};
        current_data_CN1 = cellNoiseData1{i,c};
        current_data_CN2 = cellNoiseData2{i,c};

        % Generate random indices for selection
        random_indices = randperm(9, 5); % Randomly select 15 indices out of 30
        remaining_indices = setdiff(1:9, random_indices); % The remaining 15 indices

        % Split the data into two parts
        selected15{i,c} = current_data(:, :, random_indices); % Select the 15 slices
        remaining15{i,c} = current_data(:, :, remaining_indices); % Select the remaining 15 slices

        selected15_CN1{i,c} = current_data_CN1(:, :, random_indices); % Select the 15 slices
        remaining15_CN1{i,c} = current_data_CN1(:, :, remaining_indices); % Select the remaining 15 slices

        selected15_CN2{i,c} = current_data_CN2(:, :, random_indices); % Select the 15 slices
        remaining15_CN2{i,c} = current_data_CN2(:, :, remaining_indices); % Select the remaining 15 slices
        end
    end


   