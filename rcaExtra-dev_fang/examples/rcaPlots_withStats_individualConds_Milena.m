%% Plots and permutation tests against zero for individual conditions

clearvars; close all; clc;

% Add rcaExtra to matlab path before starting
addpath(genpath('/Volumes/Popov/AnalysisFolder/AlexandraTD_Plotting/2021_AttnTime_AlexandrasPipeline'));

% Load data assuming we are in the same WD as where the data are stored
load('rcResult_byCondition.mat');
load('runSettings_byCondition.mat');

%% Prepare the data

% Flip relative disparity RC1
flippedResults_rel = rcaExtra_adjustRCWeights(rcResult_byCondition{2}, [-1 2 3 4 5 6]);
savefig('Flipped_RC_rel.fig')
close

% Undo peg to zero
rcResultNoBaseline{1} = undoBaselining(rcResult_byCondition{1}); % Undo for abs
rcResultNoBaseline{2} = undoBaselining(flippedResults_rel); % Undo for rel

% rcResultNoBaseline{1} = rcResult_byCondition{1}; % Undo for abs
% rcResultNoBaseline{2} = flippedResults_rel; % Undo for rel


%% Prepare the plot colors and plot containers

load('colorbrewer');
colorMap = colorbrewer.div.BrBG{4}; % Diverging colour map with 4 colours

% Abs
plotContainer_abs = rcaExtra_initPlottingContainer(rcResultNoBaseline{1}); % The first one is abs disp
plotContainer_abs.rcsToPlot = 1; % just plot RC1 for now
plotContainer_abs.cndsToPlot = [1, 2];
plotContainer_abs.conditionLabels = {'attend nonius', 'attend stimulus'};
plotContainer_abs.conditionColors = cat(1, colorMap(2,:)./255, colorMap(1,:)./255); % Paler shade is used for attend nonius condition
[absNoniusContainer, absStimulusContainer] = rcaExtra_splitPlotDataByCondition(plotContainer_abs); % Split data by condition

% Rel
plotContainer_rel = rcaExtra_initPlottingContainer(rcResultNoBaseline{2});
plotContainer_rel.rcsToPlot = 1; % just plot RC1 for now
plotContainer_rel.cndsToPlot = [1, 2];
plotContainer_rel.conditionLabels = {'attend nonius', 'attend stimulus'};
plotContainer_rel.conditionColors = cat(1, colorMap(3,:)./255, colorMap(4,:)./255); % Paler shade is used for attend nonius condition
[relNoniusContainer, relStimulusContainer] = rcaExtra_splitPlotDataByCondition(plotContainer_rel); % Split data by condition


%% 1: Analysis for absolute disparity, attend nonius

abs_nonius_data = rcaExtra_selectConditionsSubset(rcResultNoBaseline{1}, 1);
findZeros = identifyZerosInProjectedData(abs_nonius_data.projectedData); % check for zeros
statResults_abs_nonius = rcaExtra_runStatsAnalysis(abs_nonius_data, []); % second struct is empty to test against 0

% Plotting:
% Add the results for the permutation test to the plot container
absNoniusContainer.statData.sig = statResults_abs_nonius.corrT; % significance of corrected t-test
absNoniusContainer.statData.pValues =  statResults_abs_nonius.pValues;

absFigure = rcaExtra_plotWaveforms(absNoniusContainer);
yline(0, '--')
absFigure.Position = [0.4278 0.5022 0.3924 0.2844];
absFigure.Color = [1 1 1];
absFigure.CurrentAxes.XLim = [0, abs_nonius_data.rcaSettings.timecourseLen];

figfolder = '/Volumes/Popov/AnalysisFolder/AlexandraTD_Plotting/2021_AttnTime_AlexandrasPipeline/figs/Abs';
savefig(sprintf('%s/AbsDispAttendNonius_withStats_runtimeCorrected.fig', figfolder))

%% 2: Analysis for absolute disparity, attend stimulus

abs_stimulus_data = rcaExtra_selectConditionsSubset(rcResultNoBaseline{1}, 2);
findZeros = identifyZerosInProjectedData(abs_stimulus_data.projectedData); % check for zeros
statResults_abs_stimulus = rcaExtra_runStatsAnalysis(abs_stimulus_data, []);

% Plotting:
% Add the results for the permutation test to the plot container
absStimulusContainer.statData.sig = statResults_abs_stimulus.corrT;
absStimulusContainer.statData.pValues =  statResults_abs_stimulus.pValues;

absFigure = rcaExtra_plotWaveforms(absStimulusContainer);
yline(0, '--')
absFigure.Position = [0.4278 0.5022 0.3924 0.2844];
absFigure.Color = [1 1 1];
absFigure.CurrentAxes.XLim = [0, abs_stimulus_data.rcaSettings.timecourseLen];

figfolder = '/Volumes/Popov/AnalysisFolder/AlexandraTD_Plotting/2021_AttnTime_AlexandrasPipeline/figs/Abs';
savefig(sprintf('%s/AbsDispAttendStimulus_withStats_runtimeCorrected.fig', figfolder))

%% 3: Analysis for relative disparity, attend nonius

rel_nonius_data = rcaExtra_selectConditionsSubset(rcResultNoBaseline{2}, 1);
findZeros = identifyZerosInProjectedData(rel_nonius_data.projectedData); % check for zeros
statResults_rel_nonius = rcaExtra_runStatsAnalysis(rel_nonius_data, []);

% Plotting:
% Add the results for the permutation test to the plot container
relNoniusContainer.statData.sig = statResults_rel_nonius.corrT;
relNoniusContainer.statData.pValues =  statResults_rel_nonius.pValues;

relFigure = rcaExtra_plotWaveforms(relNoniusContainer);
yline(0, '--')
relFigure.Position = [0.4278 0.5022 0.3924 0.2844];
relFigure.Color = [1 1 1];
relFigure.CurrentAxes.XLim = [0, rel_nonius_data.rcaSettings.timecourseLen];

figfolder = '/Volumes/Popov/AnalysisFolder/AlexandraTD_Plotting/2021_AttnTime_AlexandrasPipeline/figs/Rel';
savefig(sprintf('%s/RelDispAttendNonius_withStats_runtimeCorrected.fig', figfolder))

%% 4: Analysis for relative disparity, attend nonius

rel_stimulus_data = rcaExtra_selectConditionsSubset(rcResultNoBaseline{2}, 2);
findZeros = identifyZerosInProjectedData(rel_stimulus_data.projectedData); % check for zeros
statResults_rel_stimulus = rcaExtra_runStatsAnalysis(rel_stimulus_data, []);

% Plotting:
% Add the results for the permutation test to the plot container
relStimulusContainer.statData.sig = statResults_rel_stimulus.corrT;
relStimulusContainer.statData.pValues =  statResults_rel_stimulus.pValues;

relFigure = rcaExtra_plotWaveforms(relStimulusContainer);
yline(0, '--')
relFigure.Position = [0.4278 0.5022 0.3924 0.2844];
relFigure.Color = [1 1 1];
relFigure.CurrentAxes.XLim = [0, rel_stimulus_data.rcaSettings.timecourseLen];

figfolder = '/Volumes/Popov/AnalysisFolder/AlexandraTD_Plotting/2021_AttnTime_AlexandrasPipeline/figs/Rel';
savefig(sprintf('%s/RelDispAttendStimulus_withStats_runtimeCorrected.fig', figfolder))
