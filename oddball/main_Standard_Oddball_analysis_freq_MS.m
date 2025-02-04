function main_Standard_Oddball_analysis_freq_MS

%% define experimentInfo
clear all; close all;

%addpath('/Volumes/VANI HARD DRIVE/L2_DSS_2023DATA/')

 code_folder = '/Users/vanid/Desktop/code/';

 %getting paths for all of the needed folders
    addpath(genpath(fullfile(code_folder, 'oddball')),'-end');
    addpath(genpath(fullfile(code_folder, 'svndl_code-master')),'-end');
    addpath(genpath(fullfile(code_folder, 'rcaExtra-dev')),'-end');
    addpath(genpath(fullfile(code_folder, 'rcaExtra-dev_fang')),'-end');
    addpath(genpath(fullfile(code_folder, 'mrC')),'-end');
    addpath(genpath(fullfile(code_folder, 'rcaBase')),'-end');
    addpath(genpath(fullfile(code_folder, 'edNeuro-eeg-dev-master')),'-end');
    %addpath(genpath(fullfile(code_folder, 'MatClassRSA-master')),'-end');

experimentName = 'DSS_EEG_2023'; %change experiment name


% load up expriment info specified in loadExperimentInfo_experimentName
% matlab file

try
    analysisStruct = feval(['loadExperimentInfo_' experimentName]); %if this doesnt work, do catch error but if it deos then run line 33
catch err
    % in case unable to load the designated file, load default file
    % (not implemented atm)
    disp('Unable to load specific expriment settings, loading default');
    analysisStruct = loadExperimentInfo_Default;
end

analysisStruct.domain = 'freq';

%% get load settings template structure
loadSettings = rcaExtra_getDataLoadingSettings(analysisStruct);

%% fill structure with actual parameters
loadSettings.useBins = 1:10; %if latency, change to 0 in order to project, for group 1:10
loadSettings.useFrequencies = {'1F1', '2F1', '4F1', '5F1','7F1','8F1'}; %oddball - 1,2,4,5,7,8
%loadSettings.useFrequencies = {'1F2', '2F2', '3F2'}; %carrier
%% read raw data
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
% run analysis on all conditions
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


% not loop for each condition
for nc = 3
    rcSettings_byCondition{nc} = rcSettings;
    rcSettings_byCondition{nc}.label = analysisStruct.info.conditionLabels{nc};
    rcSettings_byCondition{nc}.useCnds = nc;
    
    rcResultStruct_byCondition{nc} = rcaExtra_runAnalysis(rcSettings_byCondition{nc}, sensorData, cellNoiseData1, cellNoiseData2);
    
% pop out figure; from that figure, decide which components to flip

    %for flipping
    order = [1 -2 3 -4 -5 -6];
    
    %adjust weights
    rcaResult = rcaExtra_adjustRCWeights(rcResultStruct_byCondition{nc}, order);
    %out = rcaExtra_adjustRCWeights(rcaResult, order);
    
    %recompute averages after adjusting weights
 out = rcaExtra_computeAverages(rcaResult); %save this out for plotting
    
    % if it's two conditions
    
%     rcResultA = rcaExtra_selectConditionsSubset(out,1);
%     rcResultB = rcaExtra_selectConditionsSubset(out,2);
%     statDataAB = rcaExtra_runStatsAnalysis(rcResultA, rcResultB);
%     % Plot Significant Results
%     rcaExtra_plotSignificantResults_freq(rcResultA,rcResultB,statDataAB,[])
    
    plotSettings.conditionLabels = [];
    plotSettings.rcsToPlot = 3;
    rcaExtra_plotCompareConditions_freq([], rcResultStruct_byCondition{nc}); % use this - for first time running rca
    
    rcaExtra_plotCompareConditions_freq([], out);% for results saved as out
    
    rcaExtra_plotCompareConditions_freq([], rcaResult); %for results saved as rcaResult
    
    % Calculate Statistics (one dataset vs 0)
    statData = rcaExtra_runStatsAnalysis(rcResultStruct_byCondition{nc}, []);% use for first time
    
    statData = rcaExtra_runStatsAnalysis(out, []); % use if saved
    
    statData = rcaExtra_runStatsAnalysis(rcaResult, []); % use if saved
    
    % Plot Significant Results
    rcaExtra_plotSignificantResults_freq(rcResultStruct_byCondition{nc},[],statData,[]);
    
    rcaExtra_plotSignificantResults_freq(out,[],statData,[]);
    
    rcaExtra_plotSignificantResults_freq(rcaResult,[],statData,[]);   
    
    % run analysis on combination of conditions
    rcSettings_cnd_123 = rcSettings;
    rcSettings_cnd_123.saveFile = [analysisStruct.path.destDataDir_RCA filesep 'rcaResults_freq_cnd123.mat'];
    
    cData = sensorData(:, [1 2 3]);
    cNoise1 = cellNoiseData1(:, [1 2 3]);
    cNoise2 = cellNoiseData1(:, [1 2 3]);
    rcSettings_cnd_123.condsToUse = [1 2 3];
    rcSettings_cnd_123.label = 'Conditions123';
    
    rcResultStruct_cnd_123 = rcaExtra_runAnalysis(rcSettings_cnd_123, cData, cNoise1, cNoise2);
    %get all 3 in one figure

      rcaExtra_plotCompareConditions_freq([], rcResultStruct_cnd_123); 

       order = [-1 2 -3 4 -5 6];

       %adjust weights
    rcaResult = rcaExtra_adjustRCWeights(rcResultStruct_cnd_123, order);
    %out = rcaExtra_adjustRCWeights(rcaResult, order);
    
    %recompute averages after adjusting weights
    out = rcaExtra_computeAverages(rcaResult); %save this out for plotting
      
    %statData = rcaExtra_runStatsAnalysis(rcResultStruct_cnd_123, []);
       %rcaExtra_plotSignificantResults_freq(rcResultStruct_cnd_123,[],statData,[]);

       conditionLabels = {'Cond1', 'Cond2', 'Cond3'};
       rcSettings_all = rcSettings;
 rcSettings_all.label = 'all conditions';
    rcSettings_all.useCnds = 1:nConditions;
cndsToPlot = rcSettings_all.useCnds;
    rcsToPlot = 1:3;
 load('colorbrewer');
    colorsToUse = colorbrewer.qual.Set1{4}./255;
  %rcResultStruct_all = rcResultStruct_cnd_123;
  rcResultStruct_all = rcaResult;
 plot_all = rcaExtra_initPlottingContainer(rcResultStruct_all);
    plot_all.conditionLabels = conditionLabels;
 plot_all.rcsToPlot = rcsToPlot;
    plot_all.cndsToPlot = cndsToPlot;
 plot_all.dataLabel = {'combined'};

  plot_all.conditionColors = 0.65.*colorsToUse;
 [c12, c13, c23] = rcaExtra_splitPlotDataByCondition(plot_all);
    rcaExtra_plotAmplitudes(c12, c13, c23);
end

save subjList subjList
save rcResultStruct_byCondition rcResultStruct_byCondition
save cellNoiseData1 cellNoiseData1
save cellNoiseData1_tr cellNoiseData1_tr
save cellNoiseData2 cellNoiseData2
save cellNoiseData2_tr cellNoiseData2_tr
save rcSettings_byCondition rcSettings_byCondition
save sensorData sensorData
save sensorData_tr sensorData_tr
save subjList subjList