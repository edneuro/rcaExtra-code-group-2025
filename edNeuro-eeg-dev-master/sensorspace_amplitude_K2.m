 experimentName = '2019_K2_Data';
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
    loadSettings.useFrequencies = {'1F2', '2F2', '3F2', '4F2', '5F2'}; %carrier
    loadSettings.useFrequencies = {'1F2', '2F2', '3F2', '4F2', '5F2', '6F2', '7F2', '8F2', '9F2'}; %carrier
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

%% average the last dimension (trials*bins) for signal and noise data

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

%% compute amplitude using real and imaginary data

for i = 1:size(EEGDataRe,1)
    for c = 1:size(EEGDataRe,2)
        EEGDataAmp{i,c} = abs(EEGDataReAvg{i,c} + j*EEGDataImAvg{i,c});
    end
end

%% extract sensor space amplitude for each harmonic and each condition

%% plot sensor space amplitude 
figure()
for s = 1:30%size(EEGDataAmp,1)
    for h = 1%:5
        subplot(6, 5, (s-1)*5 + h)
        plotOnEgi(EEGDataAmp{s,2}(h,:))
        hold on
    end
end 

figure()
for s = 1:30%size(EEGDataAmp,1)
    for h = 1
        subplot(6, 5, s)
        plotOnEgi(EEGDataAmp{s,2}(h,:))
        title('sub', num2str(s))
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