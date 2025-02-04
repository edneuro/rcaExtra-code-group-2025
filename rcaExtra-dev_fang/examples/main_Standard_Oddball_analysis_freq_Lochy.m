function main_Standard_Oddball_analysis_freq_Lochy
    
   close all;
   clear all;
   clc;

   
   git_folder = '/Volumes/GSE/code';
   
   addpath(genpath(fullfile(git_folder, 'svndl_code-master')),'-end');
   addpath(genpath(fullfile(git_folder, 'rcaExtra_main')),'-end');
   addpath(genpath(fullfile(git_folder, 'rcaExtra-dev')),'-end');
   addpath(genpath(fullfile(git_folder, 'rcaExtra-dev_fang')),'-end');
   addpath(genpath(fullfile(git_folder, 'mrC')),'-end');
   addpath(genpath(fullfile(git_folder, 'rcaBase')),'-end');
   %addpath(genpath(fullfile(git_folder, 'Lochy_CND1-3')),'-end');
   addpath(genpath(fullfile(git_folder, 'edNeuro-eeg-dev-master')),'-end');

     experimentName = 'LochyRep';
     experimentName = 'Exports_6Hz';
    
    % load up expriment info specified in loadExperimentInfo_experimentName
    % matlab file
    
    try
        analysisStruct = feval(['loadExperimentInfo_' experimentName]);
    catch err
        % in case unable to load the designated file, load default file
        % (not implemented atm)
        rcaExtra_displayError(err);
        disp('Unable to load specific expriment settings, loading default');
        analysisStruct = loadExperimentInfo_Default;
    end
    
    
    % read raw data    
    
    analysisStruct.domain = 'freq';
    loadSettings = rcaExtra_getDataLoadingSettings(analysisStruct);
    loadSettings.subjTag = 'BLC*';
    loadSettings.experiment = 'LochyRep';
    loadSettings.experiment = '';
    loadSettings.useBins = 1:10; 
    %loadSettings.useBins = 0;
    loadSettings.useFrequencies = {'1F1','2F1','3F1','4F1'};
%     loadSettings.useFrequencies = {'5F1'};
     [subjList, EEGData, CN1, CN2, info] = getRawData(loadSettings); 
    [subjList, EEGData_Con1, CN1_Con1, CN2_Con1, info] = getRawData(loadSettings);
 
    %% select part of trials
for i = 1:size(EEGData,1)
    EEGData{i,1} = EEGData{i,1}(:,:,1:15);
    CN1{i,1} = EEGData{i,1}(:,:,1:15);
    CN2{i,1} = EEGData{i,1}(:,:,1:15);
end


%% get real and imaginary raw data

for i = 1:size(EEGData,1)
    for c = 1:size(EEGData,2)
    EEGDataRe{i,c} = EEGData{i,c}(1:40,:,:);
    CN1Re{i,c} = CN1{i,c}(1:40,:,:);
    CN2Re{i,c} = CN2{i,c}(1:40,:,:);
    end
end

for i = 1:size(EEGData,1)
    for c = 1:size(EEGData,2)
    EEGDataIm{i,c} = EEGData{i,c}(41:80,:,:);
    CN1Im{i,c} = CN1{i,c}(41:80,:,:);
    CN2Im{i,c} = CN2{i,c}(41:80,:,:);
    end
end

%% concatenate real and imaginary signal and noise

%     EEGDataReIm = cat(2, EEGDataRe, EEGDataIm);
%     CN1ReIm = cat(2, CN1Re, CN1Im);
%     CN2ReIm = cat(2, CN2Re, CN2Im);


%% reshape: move bins to third dimension

[nFeature, nElectrode, nTrial] = size(EEGData{1,1});

nFreqs = 4;

nBins = (nFeature / 2) / nFreqs;

% Initialize the output data matrix
% binData = nan([nFreqs * 2, nElectrode, nTrial * nBins]);
% assert(numel(EEGData{1,1}) == numel(binData), 'Mismatched input and output data sizes.')

% Outer loop: Iterate through the trials
for i = 1:size(EEGData,1)
    for c = 1:size(EEGData,2)
        for t = 1:nTrial
            
            % Inner loop: Iterate through the bins
            for b = 1:nBins
                
                % Dim 3 idx of current single-bin output
                outIdx = (t - 1) * nBins + b;
                
                % Move the current nFreq*2 x channel matrix to the output
                binData{i,c}(:, :, outIdx) = squeeze(EEGData{i,c}(b:nBins:end, :, t));
            end
        end
    end
end

% Outer loop: Iterate through the trials, do the same for noise data
for i = 1:size(CN1,1)
    for c = 1:size(CN1,2)
        for t = 1:nTrial
            
            % Inner loop: Iterate through the bins
            for b = 1:nBins
                
                % Dim 3 idx of current single-bin output
                outIdx = (t - 1) * nBins + b;
                
                % Move the current nFreq*2 x channel matrix to the output
                CN1binData{i,c}(:, :, outIdx) = squeeze(CN1{i,c}(b:nBins:end, :, t));
            end
        end
    end
end

for i = 1:size(CN2,1)
    for c = 1:size(CN2,2)
        for t = 1:nTrial
            
            % Inner loop: Iterate through the bins
            for b = 1:nBins
                
                % Dim 3 idx of current single-bin output
                outIdx = (t - 1) * nBins + b;
                
                % Move the current nFreq*2 x channel matrix to the output
                CN2binData{i,c}(:, :, outIdx) = squeeze(CN2{i,c}(b:nBins:end, :, t));
            end
        end
    end
end


%% get real and imaginary magnitude and noise data after reshaping

for i = 1:size(binData,1)
    for c = 1:size(binData,2)
    EEGDataRe{i,c} = binData{i,c}(1:4,:,:);
    CN1Re{i,c} = CN1binData{i,c}(1:4,:,:);
    CN2Re{i,c} = CN2binData{i,c}(1:4,:,:);
    end
end

for i = 1:size(binData,1)
    for c = 1:size(binData,2)
    EEGDataIm{i,c} = binData{i,c}(5:8,:,:);
    CN1Im{i,c} = CN1binData{i,c}(5:8,:,:);
    CN2Im{i,c} = CN2binData{i,c}(5:8,:,:);
    end
end

%% average the last dimension (trials*bins) for both magnitude and noise data

% real data

for i = 1:size(EEGDataRe,1)
    for c = 1:size(EEGDataRe,2)
    EEGDataReAvg{i,c} = squeeze(nanmean(EEGDataRe{i,c}, 3));
    CN1ReAvg{i,c} = squeeze(nanmean(CN1Re{i,c}, 3));
    CN2ReAvg{i,c} = squeeze(nanmean(CN2Re{i,c}, 3));
    end
end


% imaginary data

for i = 1:size(EEGDataIm,1)
    for c = 1:size(EEGDataIm,2)
    EEGDataImAvg{i,c} = squeeze(nanmean(EEGDataIm{i,c}, 3));
    CN1ImAvg{i,c} = squeeze(nanmean(CN1Im{i,c}, 3));
    CN2ImAvg{i,c} = squeeze(nanmean(CN2Im{i,c}, 3));
    end
end


%% compute magnitude and noise using real and imaginary data


for i = 1:size(EEGData,1)
    for c = 1:size(EEGData,2)
        magnitude{i,c} = abs(EEGDataReAvg{i,c} + j*EEGDataImAvg{i,c});
        noise1{i,c} = abs(CN1ReAvg{i,c} + j*CN1ImAvg{i,c});
        noise2{i,c} = abs(CN2ReAvg{i,c} + j*CN2ImAvg{i,c});
        noise{i,c} = (noise1{i,c}+noise2{i,c})./2;
    end
end

%% average magnitude and noise across subjects
    
for numbercol = 1:size(magnitude,2)
    summation = 0; % Reset summation value to 0 for next element
    for numbermats = 1:size(magnitude,1) % Loop through all matrices in first column
        summation = summation + magnitude{numbermats,numbercol}; % Add next matrix element
    end % Numbermats for
    magnitudeAvg{1,numbercol} = summation/numbermats; % save avarage of each column of the cell in the cell resultcell
    
end

for numbercol = 1:size(noise,2)
    summation = 0; % Reset summation value to 0 for next element
    for numbermats = 1:size(noise,1) % Loop through all matrices in first column
        summation = summation + noise{numbermats,numbercol}; % Add next matrix element
    end
    noiseAvg{1,numbercol} = summation/numbermats; % save avarage of each column of the cell X in the cell resultcell
    
end
        
%% compute SNR separately for each harmonics and each condition (channel space choose 65 and 95)
 
for c = 1:size(magnitudeAvg,2) %conditions
    for h = 1:4 % 4 harmonics
        SNR{h,c} = magnitudeAvg{1,c}(h,65)./noiseAvg{1,c}(h,65);
    end
end


%% remove bad channels ch 119, 126 in condition 2
for i = 1:size(EEGData,1)
    EEGData{i,2}(:,[119,126],:) = NaN;
    CN1{i,2}(:,[119,126],:) = NaN;
    CN2{i,2}(:,[119,126],:) = NaN;
end

%% remove ch 119,120,125,126,127 in condition 2
for i = 1:size(EEGData,1)
    EEGData{i,2}(:,[119,120,125,126,127],:) = NaN;
    CN1{i,2}(:,[119,120,125,126,127],:) = NaN;
    CN2{i,2}(:,[119,120,125,126,127],:) = NaN;
end

%% remove ch 43, 48,128 in condition 3
for i = 1:size(EEGData,1)
    EEGData{i,3}(:,[43,48,128],:) = NaN;
    CN1{i,3}(:,[43,48,128],:) = NaN;
    CN2{i,3}(:,[43,48, 128],:) = NaN;
end

%% remove ch 32, 38, 43, 48,128 in condition 3
for i = 1:size(EEGData,1)
    EEGData{i,3}(:,[32, 38, 43,48,128],:) = NaN;
    CN1{i,3}(:,[32, 38, 43,48,128],:) = NaN;
    CN2{i,3}(:,[32, 38, 43,48, 128],:) = NaN;
end

    loadSettings.useFrequencies = {'1F1','3F1','5F1','7F1'};
%     loadSettings.useFrequencies = {'5F1'};
%     [subjList, EEGData, CN1, CN2, info] = getRawData(loadSettings); 
    [subjList, EEGData_Con5, CN1_Con5, CN2_Con5, info] = getRawData(loadSettings);
   
    
    %% select part of trials
    
        %% select part of trials
for i = 1:size(EEGData,1)
    EEGData{i,5} = EEGData{i,5}(:,:,1:10);
    CN1{i,5} = EEGData{i,5}(:,:,1:10);
    CN2{i,5} = EEGData{i,5}(:,:,1:10);
end

    %% concatenate EEGData from different conditions

    EEGData = cat(2, EEGData_Con1, EEGData_Con5);
    CN1 = cat(2, CN1_Con1, CN1_Con5);
    CN2 = cat(2, CN2_Con1, CN2_Con5);
    
    
    
                              
    % rc settings
    rcSettings = rcaExtra_getRCARunSettings(analysisStruct);
    rcSettings.subjList = subjList;
    rcSettings.binsToUse = 1:10; 
    %rcSettings.binsToUse = 0; 
    rcSettings.freqsUsed = 2; % oddball condition change to 2, evenball condition change to 3
    rcSettings.freqsToUse = {'1F1','2F1','3F1','4F1'};
    rcSettings.freqsToUse = {'1F1','3F1','5F1','7F1'};
         rcSettings.freqsToUse = {'1','2','3','4'};
%     rcSettings.freqsToUse = {'5F1'};
    rcSettings.nComp = 6;
    rcResult = cell(1, 3);
    
    %colorScheme_gray = 0.65*ones(1, 3);
    colorScheme_black = 0.15*ones(1, 3);

    plotSettings.groupLabel = 'Lochy Rep';
    plotSettings.colorMode = 'groupsconditions';
    plotSettings.colorOrder = 1;
    plotSettings.colorSceme = [];
    plotSettings.Markers = 'o';
    plotSettings.colorScheme = cat(1, colorScheme_black, colorScheme_black);
    
    for nc = 1%1:3
        % copy RC template settings for each condition and modify if needed
        
        rcaSettings_cnd = rcSettings;
        rcaSettings_cnd.condsToUse = nc;
                
        rcaSettings_cnd.label = strcat('Condition', num2str(nc)) ;
        rcaSettings_cnd.useCnds = nc;
%         rcResult{nc} = rcaExtra_runAnalysis(rcaSettings_cnd, EEGData, CN1, CN2);
        rcResult{nc} = rcaExtra_runAnalysis(rcaSettings_cnd, binData, CN1binData, CN2binData);
        
        plotSettings.conditionLabels = [];
        plotSettings.RCsToPlot = 3;
        rcaExtra_plotCompareConditions_freq([], rcResult{nc}); 
        
    end  
end


%% train on all conditions together
    rcSettings_cnd_123 = rcSettings;
    rcSettings_cnd_123.saveFile = [analysisStruct.path.destDataDir_RCA filesep 'rcaResults_freq_cnd123.mat'];

    cData = sensorData(:, [1 2 3]);
    cNoise1 = cellNoiseData1(:, [1 2 3]);
    cNoise2 = cellNoiseData2(:, [1 2 3]);
    rcSettings_cnd_123.condsToUse = [1 2 3];
    rcSettings_cnd_123.label = 'Condition123';

    rcResultStruct_cnd_123 = rcaExtra_runAnalysis(rcSettings_cnd_123, cData, cNoise1, cNoise2);
    
    
    
    plotSettings.groupLabel = 'Lochy Rep';
    plotSettings.colorMode = 'groupsconditions';
    plotSettings.colorOrder = 1;
    plotSettings.colorSceme = [];
    plotSettings.Markers = 'o';
    plotSettings.colorScheme = cat(1, [1 0 0], [0 1 0], [0 0 1]);
    
    
    plotSettings.conditionLabels = [];
    plotSettings.RCsToPlot = 3;
    rcaExtra_plotCompareConditions_freq([], rcResultStruct_cnd_123);
    
    
    %% train on 1st and 4th conditions together
    rcSettings_cnd_14 = rcSettings;
    rcSettings_cnd_14.saveFile = [analysisStruct.path.destDataDir_RCA filesep 'rcaResults_freq_cnd14.mat'];

    cData = sensorData(:, [1 4]);
    cNoise1 = cellNoiseData1(:, [1 4]);
    cNoise2 = cellNoiseData2(:, [1 4]);
    rcSettings_cnd_14.condsToUse = [1 4];
    rcSettings_cnd_14.label = 'Condition14';

    rcResultStruct_cnd_14 = rcaExtra_runAnalysis(rcSettings_cnd_14, cData, cNoise1, cNoise2);
    
    
    
    plotSettings.groupLabel = 'Lochy Rep';
    plotSettings.colorMode = 'groupsconditions';
    plotSettings.colorOrder = 1;
    plotSettings.colorSceme = [];
    plotSettings.Markers = 'o';
    plotSettings.colorScheme = cat(1, [1 0 0], [0 1 0]);
    
    
    plotSettings.conditionLabels = [];
    plotSettings.RCsToPlot = 3;
    rcaExtra_plotCompareConditions_freq([], rcResultStruct_cnd_14);
    
    %%train on condition 2&3 together
    
    
    rcSettings_cnd_23 = rcSettings;
    rcSettings_cnd_23.saveFile = [analysisStruct.path.destDataDir_RCA filesep 'rcaResults_freq_cnd23.mat'];

    cData = sensorData(:, [2 3]);
    cNoise1 = cellNoiseData1(:, [2 3]);
    cNoise2 = cellNoiseData2(:, [2 3]);
    rcSettings_cnd_23.condsToUse = [2 3];
    rcSettings_cnd_23.label = 'Condition23';

    rcResultStruct_cnd_23 = rcaExtra_runAnalysis(rcSettings_cnd_23, cData, cNoise1, cNoise2);
    
    plotSettings.conditionLabels = [];
    plotSettings.RCsToPlot = 3;
    rcaExtra_plotCompareConditions_freq([], rcResultStruct_cnd_23);
    
    %% train on oddball evenball conditions together
    rcSettings_cnd_15 = rcSettings;
    rcSettings_cnd_15.saveFile = [analysisStruct.path.destDataDir_RCA filesep 'rcaResults_freq_cnd15.mat'];

    cData = EEGData(:, [1 10]);
    cNoise1 = CN1(:, [1 10]);
    cNoise2 = CN2(:, [1 10]);
    rcSettings_cnd_15.condsToUse = [1 10];
    rcSettings_cnd_15.label = 'Condition15';

    rcResultStruct_cnd_15 = rcaExtra_runAnalysis(rcSettings_cnd_15, cData, cNoise1, cNoise2);
    
%     rcResultStruct_cnd1Projected.projectedData(1, :) = rcaExtra_projectData(EEGData(:, 1), rcResultStruct_cnd_15.W);
%     rcResultStruct_cnd5Projected.projectedData(1, :) = rcaExtra_projectData(EEGData(:, 10), rcResultStruct_cnd_15.W);
    
    rcResult_Cond1.projectedData = rcResultStruct_cnd_15.projectedData(1,:); %rcaResult change to rcResultStruct_cnd_15
    rcResult_Cond1.W = rcResultStruct_cnd_15.W;
    rcResult_Cond1.A = rcResultStruct_cnd_15.A;
    rcResult_Cond1.covData = rcResultStruct_cnd_15.covData;
    rcResult_Cond1.noiseData.lowerSideBand = rcResultStruct_cnd_15.noiseData.lowerSideBand(:,1);
    rcResult_Cond1.noiseData.higherSideBand = rcResultStruct_cnd_15.noiseData.higherSideBand(:,1);
    rcResult_Cond1.projAvg.amp = rcResultStruct_cnd_15.projAvg.amp(:,:,1);
    rcResult_Cond1.projAvg.phase = rcResultStruct_cnd_15.projAvg.phase(:,:,1);
    rcResult_Cond1.projAvg.errA = rcResultStruct_cnd_15.projAvg.errA(:,:,:, 1);
    rcResult_Cond1.projAvg.errP = rcResultStruct_cnd_15.projAvg.errP(:,:,:, 1);
    rcResult_Cond1.projAvg.ellipseErr = rcResultStruct_cnd_15.projAvg.ellipseErr(1);
    rcResult_Cond1.projAvg.subjsRe = rcResultStruct_cnd_15.projAvg.subjsRe(:, 1);
    rcResult_Cond1.projAvg.subjsIm = rcResultStruct_cnd_15.projAvg.subjsIm(:, 1);
    rcResult_Cond1.rcaSettings = rcResultStruct_cnd_15.rcaSettings;
    rcResult_Cond1.rcaSettings.freqsUsed = 2;
    rcResult_Cond1.rcaSettings.saveFile = [analysisStruct.path.destDataDir_RCA filesep 'rcaResults_freq_cnd1pro.mat'];
    
    
%     rcSettings_cnd_1 = rcSettings;
%     rcSettings_cnd_1.saveFile = [analysisStruct.path.destDataDir_RCA filesep 'rcaResult_Cond1.mat'];
    
    
    colorScheme_black = 0.15*ones(1, 3);

    plotSettings.groupLabel = 'Lochy Rep';
    plotSettings.colorMode = 'groupsconditions';
    plotSettings.colorOrder = 1;
    plotSettings.colorSceme = [];
    plotSettings.Markers = 'o';
    plotSettings.colorScheme = cat(1, colorScheme_black, colorScheme_black);
    
    
    plotSettings.conditionLabels = [];
    plotSettings.RCsToPlot = 3;
    rcaExtra_plotCompareConditions_freq(plotSettings, rcResult_Cond1);
    
    
    rcResult_Cond5.projectedData = rcResultStruct_cnd_15.projectedData(2,:); %rcaResult change to rcResultStruct_cnd_15
    rcResult_Cond5.W = rcResultStruct_cnd_15.W;
    rcResult_Cond5.A = rcResultStruct_cnd_15.A;
    rcResult_Cond5.covData = rcResultStruct_cnd_15.covData;
    rcResult_Cond5.noiseData.lowerSideBand = rcResultStruct_cnd_15.noiseData.lowerSideBand(:,2);
    rcResult_Cond5.noiseData.higherSideBand = rcResultStruct_cnd_15.noiseData.higherSideBand(:,2);
    rcResult_Cond5.projAvg.amp = rcResultStruct_cnd_15.projAvg.amp(:,:,2);
    rcResult_Cond5.projAvg.phase = rcResultStruct_cnd_15.projAvg.phase(:,:,2);
    rcResult_Cond5.projAvg.errA = rcResultStruct_cnd_15.projAvg.errA(:,:,:, 2);
    rcResult_Cond5.projAvg.errP = rcResultStruct_cnd_15.projAvg.errP(:,:,:, 2);
    rcResult_Cond5.projAvg.ellipseErr = rcResultStruct_cnd_15.projAvg.ellipseErr(2);
    rcResult_Cond5.projAvg.subjsRe = rcResultStruct_cnd_15.projAvg.subjsRe(:, 2);
    rcResult_Cond5.projAvg.subjsIm = rcResultStruct_cnd_15.projAvg.subjsIm(:, 2);
    rcResult_Cond5.rcaSettings = rcResultStruct_cnd_15.rcaSettings;
    rcResult_Cond5.rcaSettings.freqsUsed = 3;
    rcResult_Cond5.rcaSettings.saveFile = [analysisStruct.path.destDataDir_RCA filesep 'rcaResults_freq_cnd5pro.mat'];
    
    plotSettings.conditionLabels = [];
    plotSettings.RCsToPlot = 3;
    rcaExtra_plotCompareConditions_freq(plotSettings, rcResult_Cond5);
    
%% project seperate condition data through global w
for nc = 1:3
        Cond_SensorData(:, nc)= EEGData(:,nc);
        DataOut_Cond(:, nc) = rcaExtra_projectData(Cond_SensorData(:, nc), rcResultStruct_cnd_123.W);
end


dataDir = '/Volumes/GSE/RCAonERP/baselinecorrection/trainonWandS/RCA/';

% project condition5 data through condition1 W.

Cond5_SensorData(:, 1)= sensorData(:,5);
DataOut_Cond5(:, 1) = rcaExtra_projectData(Cond5_SensorData(:, 1), rcResultStruct_byCondition{1}.W);

% Name of .mat file in directory
matFn = 'OUT_WandS_C.mat';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load the .mat file
load([dataDir matFn])

%%% CALL THE FUNCTION
% If you look at the docstring of the function, you'll see it wants 4
%   inputs: dGen, Rxx, Ryy, Rxy. It returns the proportion of reliability
%   explained (a second output is the matrix rank used in the calculation,
%   but we generally don't need that).
propRelExpl = computeProportionReliabilityExplained(...,
    OUT.dGen,...
    OUT.Rxx, OUT.Ryy, OUT.Rxy);

%%% PLOT THE OUTPUT (propRelExpl and dGen)
% We can plot the output along with the dGen.
compUse = size(OUT.W, 2); % How many components are in the W matrix

figure()

% Subplot 1: dGen
subplot(1, 2, 1)
dGenSort = sort(OUT.dGen, 'descend')
plot(dGenSort(1:compUse), '*-', 'linewidth', 2);
box off; grid on;
set(gca, 'xtick', 1:compUse, 'fontsize', 16)
xlim([0 compUse+1]); ylim([0 dGenSort(1) * 1.1])
title('dGen')

% Subplot 2: Proportion reliability explained
subplot(1, 2, 2)
plot(propRelExpl(1:compUse), '*-', 'linewidth', 2);
box off; grid on
set(gca, 'xtick', 1:compUse, 'fontsize', 16)
xlim([0 compUse+1]); ylim([0 1])
title('Prop reliability explained')

% Put title over subplots, or print filename
try
    sgtitle(matFn, 'interpreter', 'none');
catch
    subplot(1, 2, 2)
    % Print .mat file name
    text(compUse+1, 0, matFn, 'interpreter', 'none',...
        'horizontalalignment', 'right', 'verticalalignment', 'bottom')
end

% Adjust figure size
fPos = get(gcf, 'Position')
set(gcf, 'Position', fPos .* [1 1 1.2 .8])


% extract amplitude (projected through mean amplitude) for each condition
 % from rcaResult trained on condition 123 together
 
 for nCond = 1:3
     rcaResult_amp_Cond{nCond,1} = rcaResult.subjAvg.amp(:,:,:,nCond);
 end
 
%% sum up (add average) four harmonics of the projected data in each subject 

summation = 0;
for numberrow = 1:4
summation = summation + rcaResult_amp_Cond{3}(numberrow,:,:);
end


Mean = summation ./4;

rcaResult_amp_Cond_averagehar{3,1} = Mean;


% average across subjects
for n = 1:3
rcaResult_amp_Cond_averagehar_avgsub(n,:) = mean(rcaResult_amp_Cond_averagehar{n}, 3);
end



for n = 1:3
rcaResult_amp_SEM(n,:) = std(rcaResult_amp_Cond_averagehar{n},[], 3) ./ sqrt(16);
end


%% One bar at a time

barSpace = 0.5; % spacing between groups of bars

% Programmatically get the number of harmonics and conditions based on the
% size of the dta
%[nHarm, nCondt] = size(rca_K_Mean);
[nCompt, nCondt] = size(rcaResult_amp_SEM_transpose);

% % Colors - can be matlab defaults or RGB triplets
%  harmColor = {'r', 'b', 'g'};
 condtColor = {'r', 'b', 'g'};

% Initialize a variable we'll use to store positions of where we want x 
% tick to go for each group of bars
allXTick = nan(1, nCompt);

% whether to print debug text
printDB = 0

% whether to plot individual points
plotIndivid = 1

% Whether to jitter the y values of individual points as well (we'll always
% jitter the x values) -- turn this on if the y-values represent integer
% responses; not necessary if y-values are continuous
addYJitter = 0

close
figure(2)
hold on;

s = {}; % initializing cell array storing legend data
% Iterate through the harmonics
for h = 1:nCompt
    
    
    % Each harmonic has 3 condition values that we want to plot
    
    % X-values where current bars will go
    % This is a vector of length 3
    thisX = (h-1)*nCompt + (h-1)*barSpace + (1:nCompt)
    
    % Current mean values (bar heights) -- vector of length 2
    %thisMean = rca_1grade_Mean(h, :)
     thisMean = rcaResult_amp_Cond_averagehar_avgsub_transpose(h, :)
    
    % Current SEM values (2x will be error bar heights) -- vect of len 2
    % thisSEM = rca_1grade_SEM(h, :)
     thisSEM = rcaResult_amp_SEM_transpose(h, :)
    % Y-value of where debugging text will go. We want it to go above the
    % error bar (which itself is thisSEM much above thisMean), and we add
    % 0.5 for a little extra space so it's not right on the top of the
    % error bar.
    thisDebugY = thisMean + thisSEM + 0.5
    
    % Location of current group's x tick. thisX is the current x-positions
    % of the current harmonic, so we're just finding where the midpoint of
    % that is.
    allXTick(h) = mean(thisX)
    
    % Now we iterate through to place the individual bars and error bars
    % Note that we have renamed this index variable from 'eb' to 'c' so
    % it's more interpretable as iterating through conditions
    for c = 1:nCondt
        
        % Make bar blot and save to handle. 
        % We need to also set 'FaceColor' to 'flat' in order to be able to
        % change it later.
        thisB = bar(thisX(c), thisMean(c), 'FaceColor', 'flat')
        
        % The next two lines are two possible ways to color the current
        % individual bar.
         thisB.FaceColor = condtColor{c} % Color according to condition
%         thisB.FaceColor = 'none'; % Don't color (e.g., if using colored dots)
        
        
%         %%%% NEW: Plot individual points %%%%
%         % Plot individual points if requested - squeeze to vector. We use
%         % squeeze because if we just subsetted xAll(h, c, :), it would be a
%         % 3D matrix of size 1 x 1 x nSubs. Squeeze gets rid of those stray
%         % dimensions of length 1 (singleton dimensions), returning a vector
%         % in this case.
%         %thisSub = squeeze(rca_1grade_tmp(h, c, :))
%         thisSub = squeeze(Harm(h, c, :))
         % Here's a vector of noise that we'll add to the x-coordinate of
         % individual points so that they're not all exactly at the
        % x-coordinate. rand gives random numbers between 0 and 1, so we
        % subtract 0.5 to zero-center it, and then scale the result based
         % on eyeballing and multiple attempts
%          thisXJitter = (rand(size(thisSub)) - 0.5) * 0.6
%          
%          % In case we wanted jitter the y-values as well, make a similar
%          % vector for y values
%          if addYJitter
%              thisYJitter = (rand(size(thisSub)) - 0.5) * 0.25
%              
%          % Otherwise, just make it zero so we can add thisYJitter to the
%          % y-coordinate no matter what and in this case it won't make a
%          % difference
%          else, thisYJitter = 0
%          end
%         
%         % Add the individual points for this bar using the 'scatter'
%         % function. Note that we add the jitter values to the coordinates
%         % of each point: First input is the x-value (the same for every
%         % point, aside from each point's jitter), second input is the
%         % y-value (individual subject values + jitter). We make the points
%         % larger, with a black outline and colored according to condition.
%         % We also adjust the line width.
%         
%         %if h == 1
%        
%         s{c} = scatter(thisX(c)+thisXJitter, thisSub + thisYJitter, 10,...
%             'MarkerEdgeColor', 'k',...
%             'MarkerFaceColor', condtColor{c},...
%             'LineWidth', 0.5)
%         %end 
        % Place error bars: Function will center around specified y-value
        % and by default make the ebar height 2x what is input. We want the
        % error bar to be black ('k') and to be a bit thicker line width
        % than the default.
        errorbar(thisX(c), thisMean(c), thisSEM(c), 'k',...
            'LineWidth', 1, 'HandleVisibility','off')
       
        
        % If we previously specified that we want to print the debugging
        % text, add it here. It'll print the mean and standard deviation
        % with the text rotated to go up, and we left-align it (otherwise
        % it will center around the specified y-value and would be partly
        % in the error bar and bar).
        if printDB
            text(thisX(c), thisDebugY(c),...
                ['mean: ' sprintf('%.3f', thisMean(c)) ...
                ', SEM: ' sprintf('%.3f', thisSEM(c))],...
                'fontsize', 10, 'rotation', 90,...
                'horizontalalignment', 'left')
        end
        
    end
end



 % Calculate Statistics (one dataset vs 0)
        statData = rcaExtra_runStatsAnalysis(rcResultStruct_byCondition{nc}, []);
        % Plot Significant Results
        rcaExtra_plotSignificantResults_freq(rcResultStruct_byCondition{nc},[],statData,[]);
  
% Compare two conditions
rcResultA = rcaExtra_selectConditionsSubset(rcaResult,1);
rcResultB = rcaExtra_selectConditionsSubset(rcaResult,2);
statDataAB = rcaExtra_runStatsAnalysis(rcResultA, rcResultB);
% Plot Significant Results
  rcaExtra_plotSignificantResults_freq(rcResultA,rcResultB,statDataAB,[])
  
  
 