close all;
   clear all;
   clc;

   
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
   
   analysisStruct = feval(['loadExperimentInfo_' experimentName]);
   
    
analysisStruct.domain = 'freq';

%% get load settings template structure
loadSettings = rcaExtra_getDataLoadingSettings(analysisStruct);

%% fill structure with actual parameters
loadSettings.useBins = 1:10;
loadSettings.subjTag = 'BLC*';
loadSettings.experiment = 'Vernier';
loadSettings.useFrequencies = {'1F1', '2F1', '3F1','4F1'}; 
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

sensorDatasubset = zeros(8,128,40);
NoiseData1subset = zeros(8,128,40);
NoiseData2subset = zeros(8,128,40);

m = 1;


for subj = 1:size(sensorData,1)
for n = 1:10:100
 sensorDatasubset(:,:,m:m+3) = sensorData{subj,4}(:,:,n+6:n+9);
 NoiseData1subset(:,:,m:m+3) = cellNoiseData1{subj,4}(:,:,n+6:n+9);
 NoiseData2subset(:,:,m:m+3) = cellNoiseData2{subj,4}(:,:,n+6:n+9);
 m = m + 4;
end
end

for nc = 1
    rcSettings_byCondition{nc} = rcSettings;
    rcSettings_byCondition{nc}.label = analysisStruct.info.conditionLabels{nc};
    rcSettings_byCondition{nc}.useCnds = nc;
    
    rcResultStruct_byCondition{nc} = rcaExtra_runAnalysis(rcSettings_byCondition{nc}, sensorData, cellNoiseData1, cellNoiseData2);
end
