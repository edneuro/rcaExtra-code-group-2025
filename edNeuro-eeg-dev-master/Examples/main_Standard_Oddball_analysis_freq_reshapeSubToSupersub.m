function main_Standard_Oddball_analysis_freq

%% define experimentInfo

experimentName = 'Exports_6Hz';

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
loadSettings.useFrequencies = {'1F1', '2F1', '3F1', '4F1'};

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
    
    % Adjust rcSettings accordingly
    rcSettings_tr = rcSettings; % Move orig to new variable
    rcSettings.useBins = 1; % Used to be 1:10
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%% NEW: Reshape data to 1 supersub per condition %%%%%%%%%%%%%%
reshapeSubToSupersub = 1;
if reshapeSubToSupersub
    
    sensorData = reshapeCellSubToSupersub(sensorData);
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% run analysis on all conditions
nConditions = size(sensorData, 2);
rcSettings_byCondition = cell(1, nConditions);
rcResultStruct_byCondition = cell(1, nConditions);
for nc = 1:nConditions
    rcSettings_byCondition{nc} = rcSettings;
    rcSettings_byCondition{nc}.label = analysisStruct.info.conditionLabels{nc};
    rcSettings_byCondition{nc}.useCnds = nc;
    
    rcResultStruct_byCondition{nc} = rcaExtra_runAnalysis(rcSettings_byCondition{nc}, sensorData, cellNoiseData1, cellNoiseData2);
end
end