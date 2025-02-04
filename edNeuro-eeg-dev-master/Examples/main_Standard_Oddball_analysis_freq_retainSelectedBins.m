function main_Standard_Oddball_analysis_freq_retainSelectedBins

%% define experimentInfo

git_folder = '/Users/fangwang/Documents/code';
   
   addpath(genpath(fullfile(git_folder, 'svndl_code-master')),'-end');
   %addpath(genpath(fullfile(git_folder, 'rcaExtra_main')),'-end');
   addpath(genpath(fullfile(git_folder, 'rcaExtra-dev')),'-end');
   addpath(genpath(fullfile(git_folder, 'rcaExtra-dev_fang')),'-end');
   addpath(genpath(fullfile(git_folder, 'mrC')),'-end');
   addpath(genpath(fullfile(git_folder, 'rcaBase')),'-end');
   %addpath(genpath(fullfile(git_folder, 'Lochy_CND1-3')),'-end');
   addpath(genpath(fullfile(git_folder, 'edNeuro-eeg-dev-master')),'-end');
   
   
experimentName = 'Vernier';

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
loadSettings.useFrequencies = {'2F1', '4F1', '6F1'};

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

%%%%%%%%%%%% NEW: Reshape data so that dim 3 is single bins %%%%%%%%%%%%%%
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
    rcSettings_tr = rcSettings; % Move orig to new variable
    rcSettings.useBins = 1; % Used to be 1:10
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%%%%%%%%%%% NEW: Retain only selected bins from each trial %%%%%%%%%%%%%%
binsToRetain = 7:10; % Vector of bin #s to retain; else 0
nBinsPerTrial = 10;
if binsToRetain
    
    disp(['Retaining bins ' mat2str(binsToRetain) ' (' num2str(nBinsPerTrial)...
        ' bins per trial).'])

    sensorData_allBins = sensorData;
    cellNoiseData1_allBins =  cellNoiseData1;
    cellNoiseData2_allBins =  cellNoiseData2; 
    [sensorData, binIdx] = retainSelectedBins(sensorData_allBins, binsToRetain, nBinsPerTrial);
   [cellNoiseData1, binIdx] = retainSelectedBins(cellNoiseData1_allBins, binsToRetain, nBinsPerTrial);
    [cellNoiseData2, binIdx] = retainSelectedBins(cellNoiseData2_allBins, binsToRetain, nBinsPerTrial);
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% run analysis on all conditions
nConditions = size(sensorData, 2);
rcSettings_byCondition = cell(1, nConditions);
rcResultStruct_byCondition = cell(1, nConditions);
for nc = 1:nConditions
    rcSettings_byCondition{nc} = rcSettings;
    rcSettings_byCondition{nc}.label = analysisStruct.info.conditionLabels{nc};
    rcSettings_byCondition{nc}.useCnds = nc;
    
    rcResultStruct_byCondition{nc} = rcaExtra_runAnalysis(rcSettings_byCondition{nc}, ... 
        sensorData, cellNoiseData1, cellNoiseData2);
    
    order = [1 -2 -3 4 5 6];
    
    %adjust weights
    out = rcaExtra_adjustRCWeights(rcResultStruct_byCondition{nc}, order);
    %out = rcaExtra_adjustRCWeights(rcaResult, order);
    
    %recompute averages after adjusting weights
    out = rcaExtra_computeAverages(out); 
end
end