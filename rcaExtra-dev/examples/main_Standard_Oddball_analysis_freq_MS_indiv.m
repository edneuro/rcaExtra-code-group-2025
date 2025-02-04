function main_Standard_Oddball_analysis_freq_MS_indiv

   clear all;close all; clc;
    
    git_folder = '/Volumes/GSE/code';

addpath(genpath(fullfile(git_folder, 'svndl_code-master')),'-end');
addpath(genpath(fullfile(git_folder, 'rcaExtra-dev')),'-end');
addpath(genpath(fullfile(git_folder, 'rcaExtra_main')),'-end');
addpath(genpath(fullfile(git_folder, 'rcaExtra-dev_fang')),'-end');
addpath(genpath(fullfile(git_folder, 'mrC')),'-end');
addpath(genpath(fullfile(git_folder, 'rcaBase')),'-end');
addpath(genpath(fullfile(git_folder, 'edNeuro-eeg-dev-master')),'-end');  

%% define experimentInfo
    
  experimentName = '2019_MS_Data_indiv';
    
    path = '/Volumes/GSE/2019_EdNeuro_MS/IndividualRCAOutput_carrier/A_Exports_EdNeuro_MS_All'; % path with indiviudal folders with raw data
    
    cd(path);
    files = dir('BLC*');

    
    for subj = 1:length(files)
        
        sourcepath = fullfile(path, files(subj).name); % path for each individual subject
        
        %sourcepath = fullfile(path, 'BLC_213');
 
        outpath = '/Volumes/GSE/2019_EdNeuro_MS/IndividualRCAOutput_carrier/CarrierOutput'; % path for saving RCA out
        mkdir(outpath, files(subj).name); % create individual folders to save data
        destpath = fullfile(outpath, files(subj).name);
        % load up expriment info specified in loadExperimentInfo_experimentName
        % matlab file

        try
%             analysisStruct = feval(['loadExperimentInfo_' experimentName]);
            analysisStruct = loadExperimentInfo_2019_MS_Data_indiv(sourcepath,destpath);
            
        catch err
            % in case unable to load the designated file, load default file
            % (not implemented atm)
            disp('Unable to load specific expriment settings, loading default');
            analysisStruct = loadExperimentInfo_Default;
        end

    analysisStruct.domain = 'freq';
    loadSettings = rcaExtra_getDataLoadingSettings(analysisStruct);
    loadSettings.useBins = 1:10;
    loadSettings.useFrequencies = {'3F1', '6F1', '9F1'}; %carrier
 
    % read raw dat
    
    [subjList, sensorData, cellNoiseData1, cellNoiseData2, ~] = getRawData_fang(loadSettings);
    
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
  
    
    
    % run analysis on all conditions
   
    for nc = 1:nConditions
        rcSettings_byCondition{nc} = rcSettings;
        rcSettings_byCondition{nc}.label = analysisStruct.info.conditionLabels{nc};
        rcSettings_byCondition{nc}.useCnds = nc;
        
        rcResultStruct_byCondition{nc} = rcaExtra_runAnalysis(rcSettings_byCondition{nc}, sensorData, cellNoiseData1, cellNoiseData2);
        
        %plotSettings.conditionLabels = []; % see lines 267-280
        %plotSettings.RCsToPlot = 3;
        %rcaExtra_plotCompareConditions_freq_individual([], rcResultStruct_byCondition{nc});
        
    end
    % run analysis on three conditions together (carrier)
    
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
    
    end
    
    %% load in rcaResult output from each individual folder
    path = '/Volumes/GSE/K2/separategroup_readingscore/fre_carrier_individualsubjects';%for K2 study
   
    cd(path);
    files = dir('BLC*');
    
    rcResult = cell(70,1);
    for subj = 1:length(files)
        
        sourcepath = fullfile(path, files(subj).name, 'RCA');
        
        filename = 'rcaResults_Freq_Condition123.mat';
        File       = fullfile(sourcepath, filename);
        rcResult{subj} = load (File);
    end
    
    % plot RC1 topographies for each subject
    figure()
    for s = 1:70
       
            subplot(7, 10, s)
            plotOnEgi(rcResult{s,1}.rcaResult.A(:,1))
            subtitle(files(s).name)
            hold on
         
    end
   
    fname = '/Volumes/GSE/2019_EdNeuro_MS/IndividualRCAOutput_carrier';
  
   saveas(gca, fullfile(fname, 'RCAspace_41_48subjs_con123'), 'fig');
   
   % plot only one component for each subject after loading in rcaResult
   % first 15 subjects, subj 1-15
    figure()
    for s = 1:4%15
        
            subplot(1, 15, s)
            plotOnEgi(rcResult_T4{s,1}.rcaResult.A(:,1)) % for RC1, change rcResult_T4 to rcResult_T1
            hold on
      
    end
    for s = 5%15
        
        subplot(1, 15, s)
        plotOnEgi(rcResult_T4{s,1}.rcaResult.A(:,2)) % for RC1, change rcResult_T4 to rcResult_T1
        hold on
        
    end
    for s = 6:15
        
        subplot(1, 15, s)
        plotOnEgi(rcResult_T4{s,1}.rcaResult.A(:,1)) % for RC1, change rcResult_T4 to rcResult_T1
        hold on
        
    end
    
     % the other half subjects, subj 16-30
    figure()
    for s = 16:30
        
        subplot(1, 15, s-15)
        plotOnEgi(rcResult_T4{s,1}.rcaResult.A(:,1)) % for RC1, change rcResult_T4 to rcResult_T1
        hold on
        
    end
    
   
    
    %%% get carrier amplitude%%
% need to recompute averages first
path = '/Volumes/GSE/2019_EdNeuro_MS/IndividualRCAOutput_carrier/CarrierOutput';
    cd(path);
    files = dir('BLC*');
    
    rcResult = cell(70,1);
    for subj = 1:length(files)
        
        sourcepath = fullfile(path, files(subj).name, 'RCA');
        
        filename = 'rcaResults_Freq_Condition123.mat';
        File       = fullfile(sourcepath, filename);
        rcResult{subj} = load (File);
        rcResult{subj}.rcaResult = rcaExtra_computeAverages(rcResult{subj,1}.rcaResult);
    end

    %extract projected amplitude
    %condition 1
 for subj = 1:length(files)
     for c= 1:3
         for h = 1:3
     ProjAmp(subj,h, c) = squeeze(rcResult{subj,1}.rcaResult.subjProj.amp(h,1,c));
         end
     end
    
 end
   
    %% plot bar charts for amplitude comparison across both time points
    
    % First, calculate amplitude for each subject at each time point, RC1, use sum
    % of five harmonics' amplitude based on paper (Retter, Rossian, and Schiltz, 2021, JCN)
   
    for s = 1:length(rcResult_T1) %subject
        for c = 1:3 %condition
            sumSumAmplitude_T1{s,c} = sum(rcResult_T1{s,1}.rcaResult.projAvg.amp(:,1,c)); %only RC1
        end
    end
    
    
    for s = 1:length(rcResult_T4) %subject
        for c = 1:3 %condition
            sumSumAmplitude_T4{s,c} = sum(rcResult_T4{s,1}.rcaResult.projAvg.amp(:,1,c)); %only RC1
        end
    end
    
    
    % Second, plot each condition separately 
    figure;
    for c = 1:3
        for s = 1: 15%length(rcResult_T4)
            
            y{s,c} = [sumSumAmplitude_T1{s,c}, sumSumAmplitude_T4{s,c}];
            
            % for condition 1
            subplot(3,15,s);
            bar(y{s,1}, 0.5);
            set(gca, 'xtick', 1:2, 'XTickLabel', {'T1', 'T4'},...
                'fontsize', 10)
            
            % Label your axes!
            ylabel('Sum Amplitude'); xlabel('Time Point')
            
            % for condition 2
            subplot(3,15,s+15);
            bar(y{s,2}, 0.5);
            set(gca, 'xtick', 1:2, 'XTickLabel', {'T1', 'T4'},...
                'fontsize', 10)
            
            % Label your axes!
            ylabel('Sum Amplitude'); xlabel('Time Point')
            % for condition 3
            subplot(3,15,s+30);
            bar(y{s,3}, 0.5);
            set(gca, 'xtick', 1:2, 'XTickLabel', {'T1', 'T4'},...
                'fontsize', 10)
            
            % Label your axes!
            ylabel('Sum Amplitude'); xlabel('Time Point')
        end
    end
    
    figure;
    for c = 1:3
        for s = 16: length(rcResult_T4)
            
            y{s,c} = [sumSumAmplitude_T1{s,c}, sumSumAmplitude_T4{s,c}];
            
            % for condition 1
            subplot(3,15,s-15);
            bar(y{s,1}, 0.5);
            set(gca, 'xtick', 1:2, 'XTickLabel', {'T1', 'T4'},...
                'fontsize', 10)
            
            % Label your axes!
            ylabel('Sum Amplitude'); xlabel('Time Point')
            
            % for condition 2
            subplot(3,15,s);
            bar(y{s,2}, 0.5);
            set(gca, 'xtick', 1:2, 'XTickLabel', {'T1', 'T4'},...
                'fontsize', 10)
            
            % Label your axes!
            ylabel('Sum Amplitude'); xlabel('Time Point')
            % for condition 3
            subplot(3,15,s+15);
            bar(y{s,3}, 0.5);
            set(gca, 'xtick', 1:2, 'XTickLabel', {'T1', 'T4'},...
                'fontsize', 10)
            
            % Label your axes!
            ylabel('Sum Amplitude'); xlabel('Time Point')
        end
    end
    
        
    % correlation between carrier individual-level RCA A with group-level RCA A
     path = '/Volumes/GSE/K2/separategroup_readingscore/fre_carrier_individualsubjects';
      cd(path);
      files = dir('2*');
      
      rcResult = cell(48,1);
      for subj = 1:length(files)
          
          sourcepath = fullfile(path, files(subj).name, 'RCA');
          
          filename = 'rcaResults_Freq_OLNvsOIN.mat';
          File       = fullfile(sourcepath, filename);
          rcResult{subj} = load (File);
      end
    
      % organize data to matrix, note rcaResult.A(ch,2) the second
      % dimension is component, 2 means second component
    for s = 1:30
        for ch = 1:128
            A(ch, s) = rcResult{s,1}.rcaResult.A(ch,1);
        end
    end
    % load in group-level RCA result
    load('/Volumes/GSE/K2/separategroup_readingscore/fre_carrier_lowmiddlehigh/RCA/rcaResultS_Freq_OLNvsOIN.mat')
    for ch = 1:128
        B(ch) = rcaResult.A(ch,1);
    end
   
    % transpose B
    B = B';
    correlation = cell(30,1);
    for subj = 1:30
        correlation{subj}= corrcoef(A(:,subj), B(:,1));
        matrixC(subj) = abs(correlation{subj}(2,1));
    end
    
    figure;
    plot(matrixA,'*r');
    hold on
    plot(matrixB,'og');
    hold on
    plot(matrixC,'xb');
    
    % add in data label
    for subj = 1:30
      Subj_ID{subj}=files(subj).name;  
    end
    
    x = 1:30;
    dx = 0.1;
    dy = 0.001;
    for i=1:length(x)
        text(x(i)+dx,matrixC(i)+dy, Subj_ID{i})
    end

    legend({'WvsPF','WvsOLN', 'OLNvsOIN'},'Location','southeast','Orientation','vertical')
    title('correlation between individual-level map and group-level map')
    xlabel('subjects') 
    ylabel('correlation coefficients between individual A and group A')


    %% plots for each individual subject and each condition (individual-level RCA outputs plotting)
    path = '/Volumes/GSE/K2/separategroup_readingscore/fre_carrier_individualsubjects';
    cd(path);
    files = dir('2*');
    
    rcResult = cell(48,1);
    %for data trained on three conditions together
    for subj = 1:length(files)
        
        sourcepath = fullfile(path, files(subj).name, 'RCA');
        
        outpath = fullfile(path, files(subj).name, 'FIG');
        mkdir(outpath, 'condition3_OLNvsOIN'); % create individual folders to save data
        FIGpath = fullfile(outpath, 'condition3_OLNvsOIN');
        
        filename = 'rcaResults_Freq_OLNvsOIN.mat';
        File       = fullfile(sourcepath, filename);
        rcResult{subj} = load (File);
        %rcResult{subj}.rcaResult.rcaSettings.useFrequenciesHz = 2;% only evaluate when dping carrier analysis
        
        rcaExtra_plotCompareConditions_freq_individual([], rcResult{subj}.rcaResult);
    end
    
    % only plot lolliplots and compare subjects (e.g., 12 subjs per slide),
    % not done yet
    figure()
    for subj = 1:12%length(files)
        
        sourcepath = fullfile(path, files(subj).name, 'RCA');
        
        outpath = fullfile(path, files(subj).name, 'FIG');
        mkdir(outpath, 'condition123'); % create individual folders to save data
        FIGpath = fullfile(outpath, 'condition123');
        
        filename = 'rcaResults_Freq_OLNvsOIN.mat';
        File       = fullfile(sourcepath, filename);
        rcResult{subj} = load (File);
        rcResult{subj}.rcaResult.rcaSettings.useFrequenciesHz = 2;
        
       
        rcaExtra_plotLollipops_individual(rcResult{subj}.rcaResult, [])
        
    end
       % remove all old *F = 1* files
      path = '/Volumes/GSE/K2/separategroup_readingscore/fre_carrier_individualsubjects';
     for subj = 1:length(files)
         outpath = fullfile(path, files(subj).name, 'FIG');
        removefiles = fullfile(outpath, '*F =1*');
         delete(removefiles)
     end
     
     %for data trained on condition 1 or 2 or 3 separately
    for subj = 1:length(files)
        
        sourcepath = fullfile(path, files(subj).name, 'RCA');
        
        outpath = fullfile(path, files(subj).name, 'FIG');
        mkdir(outpath, 'condition3_OLNvsOIN'); % create individual folders to save data
        FIGpath = fullfile(outpath, 'condition3_OLNvsOIN');
        
        filename = 'rcaResults_Freq_OLNvsOIN.mat';
        File       = fullfile(sourcepath, filename);
        rcResult{subj} = load (File);
        rcResult{subj}.rcaResult.rcaSettings.useFrequenciesHz = 2;
        
        rcaExtra_plotCompareConditions_freq_individual([], rcResult{subj}.rcaResult);
    end
    
    
    
end