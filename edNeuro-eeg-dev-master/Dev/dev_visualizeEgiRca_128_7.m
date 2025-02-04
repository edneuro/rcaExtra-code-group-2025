% dev_visualizeEgiRca_128_7.m
% -------------------------------
% Blair - June 2, 2021
%
% This script loads RCA outputs run on EGI 128-channel and EGI 7-channel
% data and visualizes the topoplots and dGen.

clear all; close all; clc

addpath(genpath('/Users/blair/Dropbox/Codebase/BKanMatEEGToolbox'))

nChannels = 7; % 128 or 7
nCondition = 5; % Hackathon data has 5 conditions

inDir = ['/Users/blair/Dropbox/Research/EdNeuro/Hackathon 20200416/EGI' ... 
    num2str(nChannels) '_20210602'];

for i = 1:nCondition
    
    % Load current condition data
    cd([inDir '/RCA'])
    this = load(['rcaResults_Freq_Condition ' num2str(i) '.mat'])
    
%     this.rcaResult
% 
%     projectedData: {8×1 cell}
%                 W: [128×5 double]
%                 A: [128×5 double]
%           covData: [1×1 struct]
%         noiseData: [1×1 struct]
%       rcaSettings: [1×1 struct]

    thisA = this.rcaResult.A;
    [thisNChan, thisNComp] = size(thisA);
    thisDGen = flip(this.rcaResult.covData.dGen); % High to low
    thisDGen = thisDGen(1:thisNComp);
    
    % Expand A matrix if not 128 channels
    if thisNChan < 128
        thisA = expandAMatrixTo128Channels(thisA);
    end
    
    % Plot all the RCs for the current condition
    figure()
    for j = 1:thisNComp
       subplot(2, 3, j)
       plotOnEgi(thisA(:, j))
       title(['RC' num2str(j)])
    end
    subplot(2, 3, 6)
    
    % Plot the dGen for the current condition
    plot(thisDGen, '-*', 'linewidth', 2); xlim([0.5 thisNComp+.5]);
    box off; grid on; set(gca, 'fontsize', 12)
    sgtitle(['EGI ' num2str(nChannels) ', Condition ' num2str(i)])
    xlabel('RC number'); ylabel('Coefficient'); title('dGen')
    ylim([0 0.2])
    
    % Save the output for the current condition
    cd([inDir '/BKFig_20210602'])
    saveas(gcf, ['EGI_' num2str(nChannels) '_condt' num2str(i) '.png'])
    
end