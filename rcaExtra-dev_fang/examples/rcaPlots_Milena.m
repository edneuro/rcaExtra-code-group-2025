%% Plots for TD RCA data
% TODO : Fix peg to zero, add stats, fix transparency

clearvars; close all; clc;

% Add rcaExtra to matlab path before starting
addpath(genpath('~/Dropbox/YulanMilena/AlexandraTD_Plotting/2021_AttnTime_AlexandrasPipeline'));

% Load data assuming we are in the same WD as where the data are stored
load('rcResult_byCondition.mat');
load('runSettings_byCondition.mat');

%% Plot colors
load('colorbrewer');
colorMap = colorbrewer.div.BrBG{4}; % Diverging colour map with 4 colours

%% Make plot for absolute disparity results, RC1

plotContainer_abs = rcaExtra_initPlottingContainer(rcResult_byCondition{1}); % The first one is abs disp
plotContainer_abs.rcsToPlot = 1; % just plot RC1 for now
plotContainer_abs.cndsToPlot = [1, 2];
plotContainer_abs.conditionLabels = {'attend nonius', 'attend stimulus'};
plotContainer_abs.conditionColors = cat(1, colorMap(2,:)./255, colorMap(1,:)./255); % Paler shade is used for attend nonius condition

[absNoniusContainer, absStimulusContainer] = rcaExtra_splitPlotDataByCondition(plotContainer_abs); % Split data by condition

absFigure = rcaExtra_plotWaveforms(absNoniusContainer, absStimulusContainer);
absFigure.Position = [0.4278 0.5022 0.3924 0.2844];
absFigure.Color = [1 1 1];

savefig('AbsDispAttnEffect.fig')

%% Make plot for relative disparity results, RC1

% plotContainer_rel = rcaExtra_initPlottingContainer(rcResult_byCondition{2}); % The second one is rel disp

% % Flip RC1 polarity (brutally) by * -1
% plotContainer_rel.dataToPlot.mu(:,1,1) = squeeze(plotContainer_rel.dataToPlot.mu(:,1,1)) .* -1;
% plotContainer_rel.dataToPlot.mu(:,1,2) = squeeze(plotContainer_rel.dataToPlot.mu(:,1,2)) .* -1;

flippedResults_rel = rcaExtra_adjustRCWeights(rcResult_byCondition{2}, [-1 2 3 4 5 6]);
plotContainer_rel = rcaExtra_initPlottingContainer(flippedResults_rel);

plotContainer_rel.rcsToPlot = 1; % just plot RC1 for now
plotContainer_rel.cndsToPlot = [1, 2];
plotContainer_rel.conditionLabels = {'attend nonius', 'attend stimulus'};
plotContainer_rel.conditionColors = cat(1, colorMap(3,:)./255, colorMap(4,:)./255); % Paler shade is used for attend nonius condition

[relNoniusContainer, relStimulusContainer] = rcaExtra_splitPlotDataByCondition(plotContainer_rel); % Split data by condition

relFigure = rcaExtra_plotWaveforms(relNoniusContainer, relStimulusContainer);
relFigure.Position = [0.4278 0.5022 0.3924 0.2844];
relFigure.Color = [1 1 1];

savefig('RelDispAttnEffect.fig')

%% Plot attend nonius conditions on top of one another
% Hack the plot containers that we just made, replacing the relevant data
% and condition labels etc

plotContainer_attendNonius = plotContainer_abs;
plotContainer_attendNonius.dataToPlot.mu(:,:,2) = plotContainer_rel.dataToPlot.mu(:,:,1); % Sub in the attend nonius rel condition
plotContainer_attendNonius.dataToPlot.s(:,:,2) = plotContainer_rel.dataToPlot.s(:,:,1); % Do the same for the error
plotContainer_attendNonius.dataLabel = {'Attend nonius'};
plotContainer_attendNonius.conditionLabels = {'abs' 'rel'};
plotContainer_attendNonius.conditionColors = cat(1, colorMap(2,:)./255, colorMap(3,:)./255); % Paler shades are used for attend nonius condition

[absNoniusContainer, relNoniusContainer] = rcaExtra_splitPlotDataByCondition(plotContainer_attendNonius); % Split data by condition

noniusFigure = rcaExtra_plotWaveforms(absNoniusContainer, relNoniusContainer);
noniusFigure.Position = [0.4278 0.5022 0.3924 0.2844];
noniusFigure.Color = [1 1 1];

savefig('AbsRelAttendNonius.fig')

%% Plot attend stimulus conditions on top of one another
% Hack the plot containers that we just made, replacing the relevant data
% and condition labels etc

plotContainer_attendStimulus = plotContainer_rel;
plotContainer_attendStimulus.dataToPlot.mu(:,:,1) = plotContainer_abs.dataToPlot.mu(:,:,2); % Sub in the attend stim abs condition
plotContainer_attendStimulus.dataToPlot.s(:,:,1) = plotContainer_abs.dataToPlot.s(:,:,2); % Do the same for the error
plotContainer_attendStimulus.dataToPlot.mu(:,:,2) = plotContainer_rel.dataToPlot.mu(:,:,2); % Sub in the attend stim rel condition
plotContainer_attendStimulus.dataToPlot.s(:,:,2) = plotContainer_rel.dataToPlot.s(:,:,2); % Do the same for the error
plotContainer_attendStimulus.dataLabel = {'Attend stimulus'};
plotContainer_attendStimulus.conditionLabels = {'abs' 'rel'};
plotContainer_attendStimulus.conditionColors = cat(1, colorMap(1,:)./255, colorMap(4,:)./255); % Paler shades are used for attend nonius condition

[absStimulusContainer, relStimulusContainer] = rcaExtra_splitPlotDataByCondition(plotContainer_attendStimulus); % Split data by condition

stimulusFigure = rcaExtra_plotWaveforms(absStimulusContainer, relStimulusContainer);
stimulusFigure.Position = [0.4278 0.5022 0.3924 0.2844];
stimulusFigure.Color = [1 1 1];

savefig('AbsRelAttendStimulus.fig')
