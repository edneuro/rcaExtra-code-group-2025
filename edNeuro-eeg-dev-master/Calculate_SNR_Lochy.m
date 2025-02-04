%%%%% channle space SNR computation for Lochy replication study

% Fang - August 2020


close all;
clear all;
clc;

   
   git_folder = '/Users/fangwang/Documents/code';
   
   addpath(genpath(fullfile(git_folder, 'svndl_code-master')),'-end');
   addpath(genpath(fullfile(git_folder, 'rcaExtra-dev')),'-end');
   addpath(genpath(fullfile(git_folder, 'mrC')),'-end');
   addpath(genpath(fullfile(git_folder, 'rcaBase')),'-end');
   addpath(genpath(fullfile(git_folder, 'Lochy_CND1-3')),'-end');
   addpath(genpath(fullfile(git_folder, 'edNeuro-eeg-dev')),'-end');

     experimentName = 'LochyRep';
    
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
    loadSettings.subjTag = 'nl*';
    loadSettings.experiment = 'LochyRep';
    loadSettings.useBins = 1:10; 
    %loadSettings.useBins = 0;
    loadSettings.useFrequencies = {'1F1','2F1','3F1','4F1'};
%     loadSettings.useFrequencies = {'5F1'};
     [subjList, EEGData, CN1, CN2, info] = getRawData(loadSettings); 
     
     
     %% reshape: move bins to third dimension

[nFeature, nElectrode, nTrial] = size(sensorData{1,1});

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

for i = 1:size(sensorData,1)
    for c = 1:size(sensorData,2)
    EEGDataRe{i,c} = sensorData{i,c}(1:5,:,:);
    CN1Re{i,c} = cellNoiseData1{i,c}(1:5,:,:);
    CN2Re{i,c} = cellNoiseData2{i,c}(1:5,:,:);
    end
end

for i = 1:size(sensorData,1)
    for c = 1:size(sensorData,2)
    EEGDataIm{i,c} = sensorData{i,c}(6:10,:,:);
    CN1Im{i,c} = cellNoiseData1{i,c}(6:10,:,:);
    CN2Im{i,c} = cellNoiseData2{i,c}(6:10,:,:);
    end
end

%% average the last dimension (trials*bins) for noise data
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


%% compute noise using real and imaginary data 


for i = 1:size(EEGDataIm,1)
    for c = 1:size(EEGDataIm,2)
        noise1{i,c} = abs(CN1ReAvg{i,c} + j*CN1ImAvg{i,c});
        noise2{i,c} = abs(CN2ReAvg{i,c} + j*CN2ImAvg{i,c});
        noise{i,c} = (noise1{i,c}+noise2{i,c})./2;
    end
end

%% compute amplitude using real and imaginary data

for i = 1:size(EEGDataRe,1)
    for c = 1:size(EEGDataRe,2)
        EEGDataAmp{i,c} = abs(EEGDataReAvg{i,c} + j*EEGDataImAvg{i,c});
    end
end

%% extract one electrode amplitude (e.g., electrode 65)

%% compute SNR for each harmonic and each subject
for i = 1:size(EEGDataRe,1)
    for c = 1:size(EEGDataRe,2)
        SNR{i,c} = EEGDataAmp{i,c}./noise{i,c}
    end
end


%% average magnitude and noise across subjects
    
for numbercol = 1:size(EEGDataAmp,2)
    summation = 0; % Reset summation value to 0 for next element
    for numbermats = 1:size(EEGDataAmp,1) % Loop through all matrices in first column
        summation = summation + EEGDataAmp{numbermats,numbercol}; % Add next matrix element
    end % Numbermats for
    EEGDataAmpAvg{1,numbercol} = summation/numbermats; % save avarage of each column of the cell in the cell resultcell
    
end

for numbercol = 1:size(noise,2)
    summation = 0; % Reset summation value to 0 for next element
    for numbermats = 1:size(noise,1) % Loop through all matrices in first column
        summation = summation + noise{numbermats,numbercol}; % Add next matrix element
    end
    noiseAvg{1,numbercol} = summation/numbermats; % save avarage of each column of the cell X in the cell resultcell
    
end
        
%% compute SNR separately for each harmonic and each condition (channel space choose 65 and 95)
 
for c = 1:size(EEGDataAmpAvg,2) %conditions
    SNR{c} = EEGDataAmpAvg{1,c}./noiseAvg{1,c};  
end


for c = 1:size(SNR,2)
    SNR_averageharmonics{c} = mean(SNR{1,c},1);
end


 

%% plot SNR 

for c = 5%1:size(SNR,2)
    for h = 1:4
        figure()
        plotOnEgi(SNR{1,c}(h,:))
        hold on
    end
end 

figure()
for c = 1:4%size(SNR,2)
  for h = 1:4
    subplot(4, 4, (c-1)*4 + h)
    plotOnEgi(SNR{1,c}(h,:))
    colorbar
     caxis([-1.5, 2]);
     title([ num2str(h), 'F1'])
  end
end

figure()
plotOnEgi(SNR_averageharmonics{1,4}(:,:))
colorbar
caxis([-2, 2]);
%% RC Space

% get projected data
for i = 1:16
    for c = 1:3%size(rcResultStruct_byCondition,2)
        Magnitude{i,c} = rcResultStruct_byCondition{1,c}.projectedData{1,i};
    end
end

% get projected data out of individual RCA 
for i = 1:30
    for c = 1:3%size(rcResultStruct_byCondition,2)
        Magnitude{i,c} = rcResult{i,1}.rcaResult.projectedData{1,c};
    end
end

% average the third dimension

for i = 1:size(Magnitude,1)
    for c = 1:size(Magnitude,2)
    MagnitudeAvg{i,c} = squeeze(nanmean(Magnitude{i,c}, 3));
    end
end

% get real and imaginary magnitude data


for i = 1:size(Magnitude,1)
    for c = 1:size(Magnitude,2)
        MagnitudeAvgRe{i,c} = MagnitudeAvg{i,c}(1:5,:);
        MagnitudeAvgIm{i,c} = MagnitudeAvg{i,c}(6:10,:);
    end
end

for i = 1:size(MagnitudeAvg,1)
    for c = 1:size(MagnitudeAvg,2)
        Amplitude{i,c} = abs(MagnitudeAvgRe{i,c} + j*MagnitudeAvgIm{i,c});
    end
end
% average across subjects
for numbercol = 1:size(Amplitude,2)
    summation = 0; % Reset summation value to 0 for next element
    for numbermats = 1:size(Amplitude,1) % Loop through all matrices in first column
        summation = summation + Amplitude{numbermats,numbercol}; % Add next matrix element
    end
    AmplitudeAvg{1,numbercol} = summation/numbermats; % save avarage of each column of the cell X in the cell resultcell
    
end
%% double check whether noise data are correct by manusally projecting noise data through W
 % here only use one condition to test
for nc = 1%:3
        CN1_test(:, nc)= cellNoiseData1(:,nc);
        CN1_test_project(:, nc) = rcaExtra_projectData(CN1_test(:, nc), rcResultStruct_byCondition{1,nc}.W);
end

%checked, yes
%% get noise data
 for i = 1:size(cellNoiseData1,1)
    for c = 1:4%size(cellNoiseData1,2)
        CN1{i,c} = rcResultStruct_byCondition{1,c}.noiseData.lowerSideBand{i,1};
        CN2{i,c} = rcResultStruct_byCondition{1,c}.noiseData.higherSideBand{i,1};
    end
 end

 % the noiseData automatically rendered out RCA has dimension issue, so
 % have to manually project noiseData as following
 
for i =1:size(cellNoiseData1,1) 
for c = 1:size(cellNoiseData1,2) 
    noiseData_ind.lowerSideBand{i,c} = rcaProject(cellNoiseData1{i,1}{1,c}, rcResult_T1{i,1}.rcaResult.W);
    noiseData_ind.higherSideBand{i,c} = rcaProject(cellNoiseData2{i,1}{1,c}, rcResult_T1{i,1}.rcaResult.W);
end
end

    
 % get noise data for individual level RCA out
 
 for i = 1:30
     for c = 1:3%size(cellNoiseData1,2)
         CN1_ind{i,c} = noiseData_ind.lowerSideBand{i,c};
         CN2_ind{i,c} = noiseData_ind.higherSideBand{i,c};
     end
 end
% average across the third dimension

for i = 1:size(Magnitude,1)
    for c = 1:size(Magnitude,2)
    CN1Avg{i,c} = squeeze(nanmean(CN1{i,c}, 3));
    CN2Avg{i,c} = squeeze(nanmean(CN2{i,c}, 3));
    end
end

% get real and imaginary noise data


for i = 1:size(Magnitude,1)
    for c = 1:size(Magnitude,2)
        CN1AvgRe{i,c} = CN1Avg{i,c}(1:5,:);
        CN1AvgIm{i,c} = CN1Avg{i,c}(6:10,:);
        CN2AvgRe{i,c} = CN2Avg{i,c}(1:5,:);
        CN2AvgIm{i,c} = CN2Avg{i,c}(6:10,:);
    end
end


%% compute noise and magnitude using real and imaginary data 


for i = 1:size(CN1,1)
    for c = 1:size(CN1,2)
        noise1{i,c} = abs(CN1AvgRe{i,c} + j*CN1AvgIm{i,c});
        noise2{i,c} = abs(CN2AvgRe{i,c} + j*CN2AvgIm{i,c});
        noise{i,c} = (noise1{i,c}+noise2{i,c})./2;
    end
end
% average across subjects

for numbercol = 1:size(noise,2)
    summation = 0; % Reset summation value to 0 for next element
    for numbermats = 1:size(noise,1) % Loop through all matrices in first column
        summation = summation + noise{numbermats,numbercol}; % Add next matrix element
    end
    noiseAvg{1,numbercol} = summation/numbermats; % save avarage of each column of the cell X in the cell resultcell
    
end

% get amplitud directly from rca output

for c = 1:4%size(rcResultStruct_byCondition,2)
    Amplitude{1,c} = rcResultStruct_byCondition{1,c}.projAvg.amp;
end

%average across subject
for numbercol = 1:size(Amplitude,2)
    summation = 0; % Reset summation value to 0 for next element
    for numbermats = 1:size(Amplitude,1) % Loop through all matrices in first column
        summation = summation + Amplitude{numbermats,numbercol}; % Add next matrix element
    end
    AmplitudeAvg{1,numbercol} = summation/numbermats; % save avarage of each column of the cell X in the cell resultcell
    
end
%% compute SNR separately for each harmonics and each condition (channel space choose 65 and 95)
 
for c = 1:size(Amplitude,2) %conditions
    SNR{c} = Amplitude{c}./noiseAvg{c};  
end

%% plot SNR
figure()
for c = 1:size(SNR,2)
  for h = 1:4
    subplot(size(SNR,2), 4, (c-1)*4 + h)
    plotOnEgi(SNR{1,c}(h,:))
    colorbar
  end
end

%% channle space amplitude

for i = 1:size(sensorData,1)
    for c = 1:size(sensorData,2)
    EEGDataRe{i,c} = sensorData{i,c}(1:4,:,:);
    end
end

for i = 1:size(sensorData,1)
    for c = 1:size(sensorData,2)
    EEGDataIm{i,c} = sensorData{i,c}(5:8,:,:);
    end
end

%% average the last dimension (trials*bins)

for i = 1:size(sensorData,1)
    for c = 1:size(sensorData,2)
    EEGDataReAvg{i,c} = squeeze(nanmean(EEGDataRe{i,c}, 3));
    EEGDataImAvg{i,c} = squeeze(nanmean(EEGDataIm{i,c}, 3));
    end
end

%% compute amplitude using real and imaginary

for s = 1:size(sensorData,1)
    for c = 1:size(sensorData,2)
        amplitude{s,c} = abs(EEGDataReAvg{s,c} + i*EEGDataImAvg{s,c});
    end
end

%% average across subjects

for numbercol = 1:size(amplitude,2)
    summation = 0; % Reset summation value to 0 for next element
    for numbermats = 1:size(amplitude,1) % Loop through all matrices in first column
        summation = summation + amplitude{numbermats,numbercol}; % Add next matrix element
    end % Numbermats for
    amplitudeAvg{1,numbercol} = summation/numbermats; % save avarage of each column of the cell in the cell resultcell
    
end

%% average across the first four harmonics (should try first three)

for c = 1:size(amplitudeAvg,2)
    amplitudeAvg_harmonics{c} = mean(amplitudeAvg{1,c},1);
end

for c = 1:size(amplitudeAvg,2)
    amplitudeAvg_harmonics{c} = mean(amplitudeAvg{1,c}(1:3,:));
end

figure()
for c = 1:size(amplitude,2)
    subplot(1, 4)
    plotOnEgi(amplitudeAvg_harmonics{1,c}(:,:))
    colorbar
end