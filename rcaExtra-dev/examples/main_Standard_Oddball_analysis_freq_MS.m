function main_Standard_Oddball_analysis_freq_MS

%% define experimentInfo
clear all; close all;

 git_folder = '/Users/fangwang/Documents/code';

addpath(genpath(fullfile(git_folder, 'svndl_code-master')),'-end');
addpath(genpath(fullfile(git_folder, 'rcaExtra-dev')),'-end');
addpath(genpath(fullfile(git_folder, 'rcaExtra_main')),'-end');
addpath(genpath(fullfile(git_folder, 'rcaExtra-dev_fang')),'-end');
addpath(genpath(fullfile(git_folder, 'mrC')),'-end');
addpath(genpath(fullfile(git_folder, 'rcaBase')),'-end');
addpath(genpath(fullfile(git_folder, 'edNeuro-eeg-dev-master')),'-end');  

experimentName = 'MS';


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

%% get load settings template structure
loadSettings = rcaExtra_getDataLoadingSettings(analysisStruct);

%% fill structure with actual parameters
loadSettings.useBins = 1:10;
loadSettings.useFrequencies = {'1F1', '2F1', '4F1','5F1','7F1','8F1'}; %oddball
%loadSettings.useFrequencies = {'3F1','6F1','9F1'}; %carrier
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

for nc = 1:nConditions
    rcSettings_byCondition{nc} = rcSettings;
    rcSettings_byCondition{nc}.label = analysisStruct.info.conditionLabels{nc};
    rcSettings_byCondition{nc}.useCnds = nc;
    
    rcResultStruct_byCondition{nc} = rcaExtra_runAnalysis(rcSettings_byCondition{nc}, sensorData, cellNoiseData1, cellNoiseData2);
    
    %for flipping
    order = [1 -2 3 4 5 6];
    
    %adjust weights
    rcaResult = rcaExtra_adjustRCWeights(rcResultStruct_byCondition{nc}, order);
    %out = rcaExtra_adjustRCWeights(rcaResult, order);
    
    %recompute averages after adjusting weights
    out = rcaExtra_computeAverages(rcaResult); %save this out for plotting
    
 
    
    plotSettings.conditionLabels = [];
    plotSettings.rcsToPlot = 3;
    rcaExtra_plotCompareConditions_freq([], rcResultStruct_byCondition{nc}); % for first time running rca
    
    
    % Calculate Statistics (one dataset vs 0)
    statData = rcaExtra_runStatsAnalysis(rcResultStruct_byCondition{nc}, []);

    % Plot Significant Results
    rcaExtra_plotSignificantResults_freq(rcResultStruct_byCondition{nc},[],statData,[]);


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
    
      rcaExtra_plotCompareConditions_freq([], rcResultStruct_cnd_123); 

      
end