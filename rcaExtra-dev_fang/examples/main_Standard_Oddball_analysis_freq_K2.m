function main_Standard_Oddball_analysis_freq_K2

    %% define experimentInfo
    clear all;close all; clc;
    
    git_folder = '/Volumes/GSE/code';

addpath(genpath(fullfile(git_folder, 'svndl_code-master')),'-end');
addpath(genpath(fullfile(git_folder, 'rcaExtra-dev')),'-end');
addpath(genpath(fullfile(git_folder, 'rcaExtra_main')),'-end');
addpath(genpath(fullfile(git_folder, 'rcaExtra-dev_fang')),'-end');
addpath(genpath(fullfile(git_folder, 'mrC')),'-end');
addpath(genpath(fullfile(git_folder, 'rcaBase')),'-end');
addpath(genpath(fullfile(git_folder, 'edNeuro-eeg-dev-master')),'-end');    
    
    experimentName = '2019_K2_Data';
    experimentName = '2021_K2_MW';
    experimentName = '2019_K2_Data_indiv';
    
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
    analysisStruct.domain = 'freq';
    loadSettings = rcaExtra_getDataLoadingSettings(analysisStruct);
    loadSettings.useBins = 1:10;
    loadSettings.useFrequencies = {'1F1', '3F1', '5F1', '7F1', '9F1'}; %oddball
    loadSettings.useFrequencies = {'1F1', '2F1', '3F1', '4F1', '5F1', '6F1', '7F1', '8F1', '9F1'}; %oddball
    loadSettings.useFrequencies = {'1F1', '2F1', '4F1', '5F1', '7F1', '8F1'};% for 3Hz conditions 3, 4, 5
    loadSettings.useFrequencies = {'3F1', '6F1', '9F1'}; %carrier
    loadSettings.useFrequencies = {'1F2', '2F2', '3F2'}; %carrier
    % read raw dat
    [subjList, sensorData, cellNoiseData1, cellNoiseData2, ~] = getRawData(loadSettings);
    
    %% get the RC runtime settings template structure
    
    rcSettings = rcaExtra_getRCARunSettings(analysisStruct);
    %% fill the RC runtime template structure with real parameters
    
    % Define subject names. Will be used to compare between
    % saved (stored) results and requested results
    rcSettings.subjList = subjList;
    
    % Define bin vector. Will be used to compare between
    % saved (stored) results and requested results
    rcSettings.useBins = loadSettings.useBins;
    
    % Define frequency list. Will be used to compare between
    % saved (stored) results and requested results
    rcSettings.useFrequencies = loadSettings.useFrequencies;
    

    reshapeTrialToBin = 1;
    if reshapeTrialToBin
        
        sensorData_tr = sensorData; % Move orig to new variable, this is for reshaping without permutation test
        
        sensorData = cellfun(@(x) reshapeTrialToBinForRCA(x, length(rcSettings.useBins)),...
            sensorData_tr, 'UniformOutput', false);
        
        cellNoiseData1_tr = cellNoiseData1; % Move orig to new variable
        cellNoiseData1 = cellfun(@(x) reshapeTrialToBinForRCA(x, length(rcSettings.useBins)),...
            cellNoiseData1_tr, 'UniformOutput', false);
        
        cellNoiseData2_tr = cellNoiseData2; % Move orig to new variable
        cellNoiseData2 = cellfun(@(x) reshapeTrialToBinForRCA(x, length(rcSettings.useBins)),...
            cellNoiseData2_tr, 'UniformOutput', false);
        
        % Adjust rcSettings accordingly
        rcSettings_tr = rcSettings; % Mover orig to new variable
        rcSettings.useBins = 1; % Used to be 1:10
        
    end
    
   
    nConditions = size(sensorData, 2);
rcSettings_byCondition = cell(1, nConditions);
rcResultStruct_byCondition = cell(1, nConditions);

colorScheme_black = 0.15*ones(1, 3);

plotSettings.groupLabel = 'Lochy Rep';
plotSettings.colorMode = 'groupsconditions';
plotSettings.colorOrder = 1;
plotSettings.colorSceme = [];
plotSettings.Markers = 'o';
plotSettings.colorScheme = cat(1, colorScheme_black, colorScheme_black);
  
    
    
    % run analysis on all conditions
   
    for nc = 5:nConditions
        rcSettings_byCondition{nc} = rcSettings;
        rcSettings_byCondition{nc}.label = analysisStruct.info.conditionLabels{nc};
        rcSettings_byCondition{nc}.useCnds = nc;
        
        rcResultStruct_byCondition{nc} = rcaExtra_runAnalysis(rcSettings_byCondition{nc}, sensorData, cellNoiseData1, cellNoiseData2);
    
        plotSettings.conditionLabels = [];
        plotSettings.RCsToPlot = 6;
        rcaExtra_plotCompareConditions_freq(plotSettings, rcResultStruct_byCondition{nc});  
    
    end
    

    
     % flip component
    
    for nc =1:nConditions
        rcResult = rcResultStruct_byCondition;
        [corr_list{nc}, flip_list{nc}] = rcaExtra_adjustRCSigns(rcResult{nc}); %need to change parameters in the function script
    end
    
    % run analysis on combination of conditions
    rcSettings_cnd_123 = rcSettings;
    rcSettings_cnd_123.saveFile = [analysisStruct.path.destDataDir_RCA filesep 'rcaResults_freq_cnd123.mat'];
    
    cData = sensorData(:, [1 2 3]);
    cNoise1 = cellNoiseData1(:, [1 2 3]);
    cNoise2 = cellNoiseData1(:, [1 2 3]);
    rcSettings_cnd_123.condsToUse = [1 2 3];
    rcSettings_cnd_123.label = 'Conditions123';
    
    rcResultStruct_cnd_123 = rcaExtra_runAnalysis(rcSettings_cnd_123, cData, cNoise1, cNoise2);
    
     order = [1 -2 -3 4 5 6]; % for flippig weights/components
    rcaResult = rcaExtra_adjustRCWeights(rcResultStruct_cnd_123, order);
     out = rcaExtra_computeAverages(rcaResult); 
     %% define different groups
%     data_location = '/Users/fangwang/Desktop';
    data_location = '/Volumes/GSE/K2/excels';
    
    reader_file = fullfile(data_location, 'combined_oddballandcarrier_allconds_allcomps_RSS.csv');
    reader_data = readtable(reader_file);
   
    % convert swe_raw2 in numbers
%     nan_idx = strcmp(reader_data.swe_raw2, 'N/A');
%     reader_data{nan_idx, 'swe_raw2'} = {NaN};
%     reader_data.swe_raw2 = str2double(reader_data.swe_raw2);
   
    %reader_data(:, 'swe_raw2') = str2double(reader_data.swe_raw2);
    %group_idx = reader_data.ms_b_twre_swe_rawfinal < median(reader_data.ms_b_twre_swe_rawfinal);
    %group_idx = reader_data.grade;
    
%     group_K_idx = strcmp(reader_data.k2_grade, 'K');
%     group_1_idx = strcmp(reader_data.k2_grade, '1');
%     group_2_idx = strcmp(reader_data.k2_grade, '2');
    
    
    group_1_idx = strcmp(reader_data.group3, 'l');
    group_2_idx = strcmp(reader_data.group3, 'm');
    group_3_idx = strcmp(reader_data.group3, 'h');
    % run analysis on different groups
    
    reader_data.grade = string(reader_data.grade);
    group_1_idx = strcmp(reader_data.grade, '1');
    group_0_idx = strcmp(reader_data.grade, '0');
    group_2_idx = strcmp(reader_data.grade, '2');

   for nc = 3:%nConditions
        cData_low = sensorData(group_1_idx, nc);
        cNoise1 = cellNoiseData1(group_1_idx, nc);
        cNoise2 = cellNoiseData1(group_1_idx, nc);
        
        rcaSettings_cnd = rcSettings;
        rcaSettings_cnd.condsToUse = nc;
                
        rcaSettings_cnd.label = analysisStruct.info.conditionLabels{nc};
        

        rcResultStruct_byCondition{nc} = rcaExtra_runAnalysis(rcaSettings_cnd, cData_low, cNoise1, cNoise2);
   end
   
    rcSettings_cnd_123 = rcSettings;
    rcSettings_cnd_123.saveFile = [analysisStruct.path.destDataDir_RCA filesep 'rcaResults_freq_cnd123.mat'];
   
   cData123 = sensorData(group_1_idx, [1 2 3]);
    cNoise1123 = cellNoiseData1(group_1_idx, [1 2 3]);
    cNoise2123 = cellNoiseData2(group_1_idx, [1 2 3]);
    rcSettings_cnd_123.condsToUse = [1 2 3];
    rcSettings_cnd_123.label = 'Condition123';

    rcResultStruct_cnd_123 = rcaExtra_runAnalysis(rcSettings_cnd_123, cData123, cNoise1123, cNoise2123);
   
   
   for nc = 1:3%nConditions
        cData = sensorData(group_2_idx, nc);
        cNoise1 = cellNoiseData1(group_2_idx, nc);
        cNoise2 = cellNoiseData1(group_2_idx, nc);
        
        rcaSettings_cnd = rcSettings;
        rcaSettings_cnd.condsToUse = nc;
                
        rcaSettings_cnd.label = analysisStruct.info.conditionLabels{nc};
        

        rcResultStruct_byCondition{nc} = rcaExtra_runAnalysis(rcaSettings_cnd, cData, cNoise1, cNoise2);
        
        
        %colorScheme_gray = 0.65*ones(1, 3);
        colorScheme_black = 0.15*ones(1, 3);
        
        plotSettings.groupLabel = 'K2';
        plotSettings.colorMode = 'groupsconditions';
        plotSettings.colorOrder = 1;
        plotSettings.colorSceme = [];
        plotSettings.Markers = 'o';
        plotSettings.colorScheme = cat(1, colorScheme_black, colorScheme_black);
        
        plotSettings.conditionLabels = [];
        plotSettings.RCsToPlot = 3;
        rcaExtra_plotCompareConditions_freq(plotSettings, rcResultStruct_byCondition{nc});
   end
   
   rcSettings_cnd_123 = rcSettings;
    rcSettings_cnd_123.saveFile = [analysisStruct.path.destDataDir_RCA filesep 'rcaResults_freq_cnd123.mat']; 
    
   cData123 = sensorData(group_2_idx, [1 2 3]);
    cNoise1123 = cellNoiseData1(group_2_idx, [1 2 3]);
    cNoise2123 = cellNoiseData2(group_2_idx, [1 2 3]);
    rcSettings_cnd_123.condsToUse = [1 2 3];
    rcSettings_cnd_123.label = 'Condition123';

    rcResultStruct_cnd_123 = rcaExtra_runAnalysis(rcSettings_cnd_123, cData123, cNoise1123, cNoise2123);
   
end

%% testing whether the first component in conditions 2 and 3 are the same thing

% first get the original sensor data of condition 3
cond3_sensorData(:,1) = sensorData(:,3);

% load in condition 2 weight
load('/Volumes/GSE/K2/separategroup_readingscore/fre_oddball_lowmiddlehigh/RCA/rcaResults_Freq_WvsOLN.mat') %load in condition 2 RCA result

%project condition 3 sensordata through condition 2 weight
DataOut_Cond3(:, 1) = rcaExtra_projectData(cond3_sensorData(:,1), rcaResult.W); % projected condition 3 data through condition 2 weights

%load in condition 3 original weight and projected data through it's own
%weight
load('/Volumes/GSE/K2/separategroup_readingscore/fre_oddball_lowmiddlehigh/RCA/rcaResult_Freq_OLNvsOIN_adjustWeights_recomputeaverages.mat') % condition 3 RCA result, for comparing with projected throug W data

% put the projected data through condition 2 weight together with projected
% data through own weight
for s = 1:48
out.projectedData{s,2} = DataOut_Cond3{s,1};
end

% recompute verages
out = rcaExtra_computeAverages(out);

% plot lolliplots
rcaExtra_plotCompareConditions_freq([], out);


%% test whether it's different if try the other way around--project cond2 data through cond3 weight
cond2_sensorData(:,1) = sensorData(:,2);

load('/Volumes/GSE/K2/separategroup_readingscore/fre_oddball_lowmiddlehigh/RCA/rcaResult_Freq_OLNvsOIN_adjustWeights_recomputeaverages.mat') % cond3 weights

DataOut_Cond2(:, 1) = rcaExtra_projectData(cond2_sensorData(:,1), out.W);

load('/Volumes/GSE/K2/separategroup_readingscore/fre_oddball_lowmiddlehigh/RCA/rcaResults_Freq_WvsOLN.mat') 

for s = 1:48
rcaResult.projectedData{s,2} = DataOut_Cond2{s,1};
end

rcaResult = rcaExtra_computeAverages(rcaResult);

rcaExtra_plotCompareConditions_freq([], rcaResult);

%stats
out.projectedData = DataOut_Cond2;
statData = rcaExtra_runStatsAnalysis(rcaResult, out, []);



%% project K,1,2grade data through the weight that trained on all subjects together
% first load in K source data

 git_folder = '/Users/fangwang/Documents/code';

addpath(genpath(fullfile(git_folder, 'svndl_code-master')),'-end');
addpath(genpath(fullfile(git_folder, 'rcaExtra-dev')),'-end');
addpath(genpath(fullfile(git_folder, 'rcaExtra-dev_fang')),'-end');
addpath(genpath(fullfile(git_folder, 'mrC')),'-end');
addpath(genpath(fullfile(git_folder, 'rcaBase')),'-end');
    
    
    experimentName = '2019_K2_Data';
 
    
    % load up expriment info specified in loadExperimentInfo_experimentName
    % matlab file
    
    try
        analysisStruct = feval(['loadExperimentInfo_' experimentName]); %% load and save in different grade data
    catch err
        % in case unable to load the designated file, load default file
        % (not implemented atm)
        disp('Unable to load specific expriment settings, loading default');
        analysisStruct = loadExperimentInfo_Default;
    end
    
    % specified for general data loader and plotting, currently not used
    analysisStruct.domain = 'freq';
    loadSettings = rcaExtra_getDataLoadingSettings(analysisStruct);
    loadSettings.useBins = 1:10;
    loadSettings.useFrequencies = {'1F1', '3F1', '5F1', '7F1', '9F1'}; %oddball

    % read raw dat
    [subjList, sensorData, cellNoiseData1, cellNoiseData2, ~] = getRawData(loadSettings);
    
    %% get the RC runtime settings template structure
    
    rcSettings = rcaExtra_getRCARunSettings(analysisStruct);
    %% fill the RC runtime template structure with real parameters
    
    % Define subject names. Will be used to compare between
    % saved (stored) results and requested results
    rcSettings.subjList = subjList;
    
    % Define bin vector. Will be used to compare between
    % saved (stored) results and requested results
    rcSettings.useBins = loadSettings.useBins;
    
    % Define frequency list. Will be used to compare between
    % saved (stored) results and requested results
    rcSettings.useFrequencies = loadSettings.useFrequencies;
    
    reshapeTrialToBin = 1;
    if reshapeTrialToBin
        
        sensorData_tr = sensorData; % Move orig to new variable
        sensorData = cellfun(@(x) reshapeTrialToBinForRCA(x, length(rcSettings.useBins)),...
            sensorData_tr, 'UniformOutput', false);
        
        cellNoiseData1_tr = cellNoiseData1; % Move orig to new variable
        cellNoiseData1 = cellfun(@(x) reshapeTrialToBinForRCA(x, length(rcSettings.useBins)),...
            cellNoiseData1_tr, 'UniformOutput', false);
        
        cellNoiseData2_tr = cellNoiseData2; % Move orig to new variable
        cellNoiseData2 = cellfun(@(x) reshapeTrialToBinForRCA(x, length(rcSettings.useBins)),...
            cellNoiseData2_tr, 'UniformOutput', false);
        
        % Adjust rcSettings accordingly
        rcSettings_tr = rcSettings; % Mover orig to new variable
        rcSettings.useBins = 1; % Used to be 1:10
        
    end
   
    %% load in RCA weights trained on all subjects together condition 2
    load('/Volumes/GSE/K2/separategroup_readingscore/fre_oddball_lowmiddlehigh/RCA/rcaResult_Freq_WvsOLN.mat') % cond2 weights
 
    %% project K condition2 data through the weight loaded above
DataOut_Cond2_K(:, 1) = rcaExtra_projectData(sensorData(:,2), rcaResult.W);

DataOut_Cond2_1(:, 1) = rcaExtra_projectData(sensorData(:,2), rcaResult.W); %remember to load in 1grade source data using line 292-344
DataOut_Cond2_2(:, 1) = rcaExtra_projectData(sensorData(:,2), rcaResult.W); %remember to load in 2grade source data using line 292-344

%% load in RCA weights trained on all subjects together condition 3
load('/Volumes/GSE/K2/separategroup_readingscore/fre_oddball_lowmiddlehigh/RCA/rcaResult_Freq_OLNvsOIN_adjustWeights_recomputeaverages.mat') % cond3 weights

    %% project K condition3 data through the weight loaded above
DataOut_Cond3_K(:, 1) = rcaExtra_projectData(sensorData(:,3), out.W);

DataOut_Cond3_1(:, 1) = rcaExtra_projectData(sensorData(:,3), out.W); %remember to load in 1grade source data using line 292-344
DataOut_Cond3_2(:, 1) = rcaExtra_projectData(sensorData(:,3), out.W); %remember to load in 2grade source data using line 292-344


%replace projected in loaded rcaResult(or out) with the projected data
%above (DataOut_Cond2_K, DataOut_Cond2_1, DataOut_Cond2_2, DataOut_Cond3_K,
% DataOut_Cond3_1, DataOut_Cond2_K)

rcaResult.projectedData = DataOut_Cond2_2; % for example
out.projectedData = DataOut_Cond3_2; 

%recompute averages
rcaResult = rcaExtra_computeAverages(rcaResult);
out = rcaExtra_computeAverages(out);
%plotting
rcaExtra_plotCompareConditions_freq([], rcaResult);

%stats
out.projectedData = DataOut_Cond2;
statData = rcaExtra_runStatsAnalysis(rcaResult, out, []);

% Plot Significant Results
rcaExtra_plotSignificantResults_freq(out,[],statData,[]);
rcaExtra_plotSignificantResults_freq(rcaResult,[],statData,[]);

%% circular test for condition 2
load('/Volumes/GSE/K2/seperategroup_grade/fre_oddball_bin1_10_projectKthroughwholegroupweight/RCA/rcaResult_Cond3_K.mat')
K = out;
load('/Volumes/GSE/K2/seperategroup_grade/fre_oddball_bin1_10_project1gradethroughwholegroupweight/RCA/rcaResult_Cond3_1.mat')
grade1 = out;
load('/Volumes/GSE/K2/seperategroup_grade/fre_oddball_bin1_10_project2ndthroughwholegroupweight/RCA/rcaResult_Cond3_2.mat')
grade2 = out;
CurrentPhase_K = squeeze(K.subjAvg.phase); 
CurrentPhase_1 = squeeze(grade1.subjAvg.phase);
CurrentPhase_2 = squeeze(grade2.subjAvg.phase);
CurrentPhase_K_comp1_harm1 = squeeze(K.subjAvg.phase(1,1,:))';
CurrentPhase_K_comp1_harm1 = squeeze(K.subjAvg.phase(1,1,:));
CurrentPhase_1_comp1_harm1 = squeeze(grade1.subjAvg.phase(1,1,:));
CurrentPhase_2_comp1_harm1 = squeeze(grade2.subjAvg.phase(1,1,:));

CurrentPhase_K_comp1_harm1Mean = circ_mean(CurrentPhase_K_comp1_harm1(:,1));
CurrentPhase_1_comp1_harm1Mean = circ_mean(CurrentPhase_1_comp1_harm1(:,1));
CurrentPhase_2_comp1_harm1Mean = circ_mean(CurrentPhase_2_comp1_harm1(:,1));

figure()
    subplot(1,3,1)
    polarhistogram(CurrentPhase_K_comp1_harm1(:,1),8, 'DisplayStyle', 'stairs')
    rl = get(gca, 'rlim')
    hold on;
    polarplot(CurrentPhase_K_comp1_harm1Mean*ones(2,1), rl, '--r')
    title('RC1/k')
    
    subplot(1,3,2)
    polarhistogram(CurrentPhase_1_comp1_harm1(:,1),8,'DisplayStyle', 'stairs')
    rl = get(gca, 'rlim')
    hold on;
    polarplot(CurrentPhase_1_comp1_harm1Mean*ones(2,1), rl, '--r')
    title('RC1/1')
   
    
    subplot(1,3,3)
    polarhistogram(CurrentPhase_2_comp1_harm1(:,1),8,'DisplayStyle', 'stairs')
    rl = get(gca, 'rlim')
    hold on;
    polarplot(CurrentPhase_2_comp1_harm1Mean*ones(2,1), rl, '--r')
    title('RC1/2')
    sgtitle('SublexicalPhaseComparison','interpreter', 'none')
    

circ_wwtest(CurrentPhase_K_comp1_harm1(:,1), CurrentPhase_1_comp1_harm1(:,1));
circ_wwtest(CurrentPhase_1_comp1_harm1(:,1), CurrentPhase_2_comp1_harm1(:,1));