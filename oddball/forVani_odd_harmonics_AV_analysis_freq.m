function odd_harmonics_AV_analysis_freq

  git_folder = '/Users/lrhasak/code/Git';
    addpath(genpath(fullfile(git_folder, 'rcaExtra')),'-end');
    addpath(genpath(fullfile(git_folder, 'rcaBase')),'-end');
    addpath(genpath(fullfile(git_folder, 'mrC')),'-end');
    addpath(genpath(fullfile(git_folder, 'svndl_code')),'-end');
    addpath(genpath(fullfile(git_folder, 'edNeuro-eeg-dev')),'-end');
    addpath(genpath(fullfile(git_folder, '2022_AV_Analysis')),'-end');
    addpath(genpath('/Users/lrhasak/Volumes/Seagate Backup Plus Drive//Volumes/Seagate Backup Plus Drive/2022_AV_Final_Analysis/'))

    clear all; close all; clc
    %% Loading sensor-space data
    
    % You'll need to create 'loadExperimentInfo_ + experimentName.m file
    % that is going to contain details about your source data:
    
    % first few letters or numbers of all filenames, like nl*, BLC*, etc
    % if data exports are in subdirectory (nl*/time/RawTrials)
    % what frequencies are present in the dataset (for reverse-engineeering epoch length) 
    % see loadExperimentInfo_Lochy_Oddball.m
     
    clear all;
    experimentName = 'Exports_AV';
    
    % load up expriment info specified in loadExperimentInfo_experimentName
    % matlab file. Lines 21-28 are generic and can be copy-pasted  
    % analysisStruct contains info about data location and data properties
    
    try
        analysisStruct = feval(['loadExperimentInfo_' experimentName]);
    catch err
        % in case unable to load the designated file, load default file
        % (not implemented atm)
        disp('Unable to load specific expriment settings, loading default');
        analysisStruct = loadExperimentInfo_Default;
    end
    
    
    % analysisStruct.domain will be propagated to rcaSetting, stats, plotting and needs to
    % be defined for the use of any high-level function 
    analysisStruct.domain = 'freq';
    
    loadSettings_f = rcaExtra_getDataLoadingSettings(analysisStruct);
    
    % print available frequenciesfor each condition/subject
    % this excel sheet is saved in the MAT folder
    % 59 looks to be a particularly messy subject
    rcaExtra_analyzeFrequencyDataset(loadSettings_f.destDataDir_MAT);
    
    % loading: specify what frequencies and bins to load
    loadSettings_f1 = loadSettings_f;
    loadSettings_f1.useBins = 1:10; 
    %loadSettings_f1.useFrequencies = {'1F1', '3F1', '5F1', '7F1','9F1'};
    loadSettings.useFrequencies = {'1F1', '2F1', '4F1', '5F1','7F1','8F1'};
    %loadSettings_f1.useFrequencies = {'1F1'};
    
    
    % read raw data 
    [subjList, EEGData_f1, Noise1_f1, Noise2_f1, ~] = getRawData(loadSettings_f1);
   
    
    %% RCA 
    % get generic template for RCA settings
    rcSettings = rcaExtra_getRCARunSettings(analysisStruct);
    
    %Filling out the template with subjects list:
    rcSettings.subjList = subjList;
        
    %copy settings template to 2hz analysis template 
    runSettings_nF1 = rcSettings;
    
    % use all bins
    runSettings_nF1.useBins = loadSettings_f1.useBins;
    
    % use all harmonics
    runSettings_nF1.useFrequencies = {'1F1', '3F1', '5F1','7F1','9F1'};
    %runSettings_nF1.useFrequencies = {'1F1'};
    % the name under which RCA result will be saved inyour output/RCA directory
    
    runSettings_nF1.label = 'audioOnly_oddball';
    runSettings_nF1.computeStats = 1;
    runSettings_nF1.useCnds = [3];
  

%    audioOnly_oddball_nf1 = rcaExtra_runAnalysis(runSettings_nF1, EEGData_f1, Noise1_f1, Noise2_f1);
    %% re-binning    
    % re-bin the data and run the analysis again using 1 bin in settings:
    nFreqs = length(loadSettings_f1.useFrequencies);

    EEGData_f1_1bin = cellfun(@(x) rcaExtra_reshapeBinsToTrials(x, nFreqs),...
        EEGData_f1, 'UniformOutput', false);
    noise_LO_f1_1bin = cellfun(@(x) rcaExtra_reshapeBinsToTrials(x, nFreqs),...
        Noise1_f1, 'UniformOutput', false);
    noise_HI_f1_1bin = cellfun(@(x) rcaExtra_reshapeBinsToTrials(x, nFreqs),...
        Noise2_f1, 'UniformOutput', false);
    
    runSettings_nF1_1bin = runSettings_nF1;
    runSettings_nF1_1bin.useBins = 1;
    runSettings_nF1_1bin.label = 'audioOnly_oddball_nF1_1bin';

 %audioOnly_oddball_1bin = rcaExtra_runAnalysis(runSettings_nF1_1bin, EEGData_f1_1bin, noise_LO_f1_1bin, noise_HI_f1_1bin);
    
    
    %%  Weight Flipping (match with xDiva waveform polarity)
    
    % function will use command line prompt:
    % do you want to save the rewsults? 
    % (Y) Do you want to save results as new matfile?
    % Vector specifies both desired order and polarity: [-1 2 3 4 5 6]
    % To change order [-2 1 3 4 5 6]
    
    % all bins
    %rcResult_c2_nF1_clean = rcaExtra_adjustRCWeights(rcResult_c2_nF1, [-1 2 -3 -4 -5 -6]);
   
    % 1 bin 
  %  audioOnly_oddball_1bin_flip = rcaExtra_adjustRCWeights(audioOnly_oddball_1bin, [1 -2 -3 4 5 6]);
   
   % save as rcaResult
   %rcaResult=audioOnly_oddball_1bin_flip;
   %save([analysisStruct.path.destDataDir_RCA,'/rcResult_audioOnly_oddball_1bin_flip'],'rcaResult');
   
   %% A matrix for Adi
   %rcaResult=visualOnly_oddball_1bin_flip.A;
   %save([analysisStruct.path.destDataDir_RCA,'/visualOnly_oddball_1bin_flip_A_matrix'],'rcaResult');
    
    %% Run RCA on merged conditions 
    
    % Hi Vani! This is where you'll do the merging. You only need to run 
    % your script through re-binning your raw EEG data and noise to 1 bin 
    % before doing this. In other words, this can be the first
    % rcaExtra_runAnalysis that you run
   
    % the call is rcaExtra_mergeDatasetConditions(data, [conditions])
    
    % set up analysis
    EEGData_f1_merged = rcaExtra_mergeDatasetConditions(EEGData_f1_1bin, [2 4 6]);
    noise_LO_f1_merged = rcaExtra_mergeDatasetConditions(noise_LO_f1_1bin, [2 4 6]);
    noise_HI_f1_merged = rcaExtra_mergeDatasetConditions(noise_HI_f1_1bin, [2 4 6]);
    runSettings_1hz_c246_nF1clean = runSettings_nF1_1bin;
    runSettings_1hz_c246_nF1clean.label = 'merged_246_1Hz_1bin';
    % keep this as 1 because you want it to consider the data 1 condition
    runSettings_1hz_c246_nF1clean.useCnds = 1;
    
    % run merged RCA 
    rcResult_1hz_c246_nF1clean = rcaExtra_runAnalysis(runSettings_1hz_c246_nF1clean, EEGData_f1_merged, noise_LO_f1_merged, noise_HI_f1_merged);
  
%     SAME PROCESS FOR NON-RESHAPED DATA (if you're not reshaping to 1bin)
%     EEGData_f1_merged = rcaExtra_mergeDatasetConditions(EEGData_f1, [2, 4]);
%     noise_LO_f1_merged = rcaExtra_mergeDatasetConditions(Noise1_f1, [2, 4]);
%     noise_HI_f1_merged = rcaExtra_mergeDatasetConditions(Noise2_f1, [2, 4]);
%     runSettings_1hz_c24_nF1clean = runSettings_nF1;
%     runSettings_1hz_c24_nF1clean.label = 'Conditions_merged_2-4_nF1_1Hz_allBins';
%     runSettings_1hz_c24_nF1clean.useCnds = 1;
%     rcResult_merge_c24_allBin = rcaExtra_runAnalysis(runSettings_1hz_c24_nF1clean, EEGData_f1_merged, noise_LO_f1_merged, noise_HI_f1_merged);
    
    % plot on EGI for nice topography
    plotOnEgi(rcResult_1hz_c246_nF1clean.A(:, 1))% plots first component
    
%% Projecting merged data through learned weights
% This is for if you want to project individual conditions through the
% weights trained on the merged data, which I don't think you want to do. 
    
%     %% Project through learned weights
%    1% projecting conditions 3, 4 through weights learned on combined [1, 2]
%     % 2 Hz cycle duration = 1000
      % cycle length = 420
      
     %rcResult_1hz_c24_nF1clean.rcaSettings.cycleLength = 420;
     %rcResult_1hz_c24_nF1clean.rcaSettings.cycleDuration = 1000;

     [projected_c2_1Hz, projected_c4_1Hz, projected_c6_1Hz] = ...
         rcaExtra_projectDataSubset(rcResult_1hz_c246_nF1clean, EEGData_f1_1bin(:, 2), EEGData_f1_1bin(:, 4),...
                                   EEGData_f1_1bin(:, 6));
                                
%% save projected RC data

rcaResult=projected_c2_1Hz;
    save([analysisStruct.path.destDataDir_RCA,'/rcaResults_Freq_Projected_Cond2_RC_2-4_1Hz_1bin'],'rcaResult');
    rcaResult=projected_c4_1Hz;
    save([analysisStruct.path.destDataDir_RCA,'/rcaResults_Freq_Projected_Cond4_RC_2-4_1Hz_1bin'],'rcaResult');
    rcaResult=projected_c5_1Hz;
    save([analysisStruct.path.destDataDir_RCA,'/rcaResults_Freq_Projected_Cond5_RC_2-4_1Hz_1bin'],'rcaResult');
    rcaResult=projected_c6_1Hz;
    save([analysisStruct.path.destDataDir_RCA,'/rcaResults_Freq_Projected_Cond6_RC_2-4_1Hz_1bin'],'rcaResult');
    
    %% Plot
    % package with colors, make sure to have enough for each condition
    load('colorbrewer');
    % Rows = colors, columns = RGB values in 1-255 range (need to be normalized by /255) 
    colors_to_use = colorbrewer.qual.Set1{8};
        
    %% plotting all rcResult_nF1_1bin
    visualOnly_oddball_1bin_flip.rcaSettings.computeStats = 1;

    
    plot_nF1_1bin = rcaExtra_initPlottingContainer(visualOnly_oddball_1bin_flip);
    plot_nF1_1bin.conditionLabels = analysisStruct.info.conditionLabels;
    plot_nF1_1bin.rcsToPlot = 1:3;
    %plot_nF1_1bin.cndsToPlot = [1 2 3];
    plot_nF1_1bin.cndsToPlot = arrayfun(@(x)...
                                        find(visualOnly_oddball_1bin_flip.rcaSettings.useCnds...
                                        == x), visualOnly_oddball_1bin_flip.rcaSettings.useCnds);
    plot_nF1_1bin.conditionColors = colors_to_use./255;
    
    % plots groups, each condition in separate window
    KB_rcaExtra_plotAmplitudes(plot_nF1_1bin);
    KB_rcaExtra_plotLollipops(plot_nF1_1bin);
    % error happening with plotLatencies (mismatch in axes?)
    rcaExtra_plotLatencies(plot_nF1_1bin);

    % split conditions, plot separately
  %  [c1_rc, c2_rc, c3_rc, c4_rc, c5_rc, c6_rc, c7_rc, c8_rc, c9_rc, c10_rc, c_11_rc]  = rcaExtra_splitPlotDataByCondition(plot_nF1_1bin);
    %[c2, c4, c6]  = KB_rcaExtra_splitPlotDataByCondition(plot_nF1_1bin);
    
    c2.dataLabel = {'Alternating Visual'};
    c4.dataLabel = {'Alternating AV'};
    c7.dataLabel = {'Congruent'};
    c10.dataLabel = {'Incongruent'};
    
    % plot on EGI for nice topography
    plotOnEgi(visualOnly_oddball_1bin_flip.A(:, 1))% change value depending on component
   
    
    %% plot projected data
    projected_c2_1Hz.rcaSettings.computeStats = 1;
    projected_c4_1Hz.rcaSettings.computeStats = 1;
    projected_c5_1Hz.rcaSettings.computeStats = 1;
    projected_c6_1Hz.rcaSettings.computeStats = 1;


    %rcaResult_avg = rcaExtra_computeAverages(projected_c2_1Hz);


    % projected c2 data
    plot_proj_c2_1bin = rcaExtra_initPlottingContainer(projected_c2_1Hz);
    %plot_proj_c2_1bin.conditionLabels = analysisStruct.info.conditionLabels;
    plot_proj_c2_1bin.conditionLabels = {'Alt-Attend Visual Projected'};
    plot_proj_c2_1bin.rcsToPlot = 1:2;
    %plot_nF1_1bin.cndsToPlot = [1 2 3];
    plot_proj_c2_1bin.cndsToPlot = arrayfun(@(x)...
                                        find(projected_c2_1Hz.rcaSettings.useCnds...
                                        == x), projected_c2_1Hz.rcaSettings.useCnds);
    plot_proj_c2_1bin.conditionColors = colors_to_use(1, :)./255;
   % KB_rcaExtra_plotAmplitudes(plot_proj_c2_1bin);
    
    
    plot_proj_c4_1bin = rcaExtra_initPlottingContainer(projected_c4_1Hz);
    %plot_proj_c4_1bin.conditionLabels = analysisStruct.info.conditionLabels;
    plot_proj_c4_1bin.conditionLabels = {'Alt-Attend AV Projected'};
    plot_proj_c4_1bin.rcsToPlot = 1:2;
    %plot_nF1_1bin.cndsToPlot = [1 2 3];
    plot_proj_c4_1bin.cndsToPlot = arrayfun(@(x)...
                                        find(projected_c4_1Hz.rcaSettings.useCnds...
                                        == x), projected_c4_1Hz.rcaSettings.useCnds);
    plot_proj_c4_1bin.conditionColors = colors_to_use(2, :)./255;
    
%     plot_proj_c5_1bin = rcaExtra_initPlottingContainer(projected_c5_1Hz);
%     %plot_proj_c7_1bin.conditionLabels = analysisStruct.info.conditionLabels;
%     plot_proj_c5_1bin.conditionLabels = {'Blink Projected'};
%     plot_proj_c5_1bin.rcsToPlot = 1:2;
%     %plot_nF1_1bin.cndsToPlot = [1 2 3];
%     plot_proj_c5_1bin.cndsToPlot = arrayfun(@(x)...
%                                         find(projected_c5_1Hz.rcaSettings.useCnds...
%                                         == x), projected_c5_1Hz.rcaSettings.useCnds);
%     plot_proj_c5_1bin.conditionColors = colors_to_use(3, :)./255;

    plot_proj_c6_1bin = rcaExtra_initPlottingContainer(projected_c6_1Hz);
    %plot_proj_c10_1bin.conditionLabels = analysisStruct.info.conditionLabels;
    plot_proj_c6_1bin.conditionLabels = {'No Motion Projected'};
    plot_proj_c6_1bin.rcsToPlot = 1:2;
    %plot_nF1_1bin.cndsToPlot = [1 2 3];
    plot_proj_c6_1bin.cndsToPlot = arrayfun(@(x)...
                                        find(projected_c6_1Hz.rcaSettings.useCnds...
                                        == x), projected_c6_1Hz.rcaSettings.useCnds);
    plot_proj_c6_1bin.conditionColors = colors_to_use(4, :)./255;

    
  % plot projected data
    KB_rcaExtra_plotAmplitudes(plot_proj_c2_1bin, plot_proj_c4_1bin, plot_proj_c6_1bin);
    KB_rcaExtra_plotLollipops(plot_proj_c2_1bin, plot_proj_c4_1bin, plot_proj_c6_1bin);
    
    plotOnEgi(projected_c6_1Hz.A(:, 1))% change value depending on component
    %%  plot separate conditions
    % this is actually plotting different conditions together!  
    KB_rcaExtra_plotAmplitudes(c2, c4, c6);
    KB_rcaExtra_plotLollipops(c2, c4, c6);
    rcaExtra_plotLatencies(c2, c4);
    
    
    % let's do 2, 7, 10, and 2/4
    rcaExtra_plotAmplitudes(c2_rc, c7_rc, c10_rc);
    rcaExtra_plotAmplitudes(c2_rc, c4_rc);
    rcaExtra_plotLollipops(c1_rc, c2_rc, c3_rc, c4_rc);
    rcaExtra_plotLatencies(c2_rc, c7_rc, c10_rc);
    %% split rcResults
    rc_1 = rcaExtra_selectConditionsSubset(rcResult_c210_nF1_1bin_flipped, 1);
    rc_2 = rcaExtra_selectConditionsSubset(rcResult_c210_nF1_1bin_flipped, 2);    
    rc_3 = rcaExtra_selectConditionsSubset(c24_1Hz_flip, 1);
    rc_4 = rcaExtra_selectConditionsSubset(c24_1Hz_flip, 2);    

    %% Stats
    
    rcaExtra_plotAmplitudeWithStats(c2, c4, rc_1, rc_2)
    % let's add stats computing 
    %c24_stats = rcaExtra_runStatsAnalysis(rc_1, rc_2, 1);
    c5_stats = rcaExtra_runStatsAnalysis(c24_1Hz_flip, []);

    % specify plotting
    %% Compare Topo Maps?
    rcaExtra_compareTopoMaps(rcResult_c210_nF1_1bin_flipped.A);

end