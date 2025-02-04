% run_rcaReshapeTrialToBin.m
% ----------------------------
% Blair - August 11, 2020
%
% Getting frequency-domain pipeline to run with input data to RCA reshaped
% to have bins in dim 3.

clear all; close all; clc

% RCA code
addpath(genpath('/Users/blair/Dropbox/Research/EdNeuro/EdNeuroCodebase/rcaExtra'))
addpath(genpath('/Users/blair/Dropbox/Research/EdNeuro/EdNeuroCodebase/rcaBase'))
addpath(genpath('/Users/blair/Dropbox/Research/EdNeuro/EdNeuroCodebase/mrC'))
addpath(genpath('/Users/blair/Dropbox/Research/EdNeuro/EdNeuroCodebase/svndl_code'))

% Reshape function
addpath(genpath('/Users/blair/Dropbox/Research/EdNeuro/EdNeuroCodebase/edNeuro-eeg-dev'))

% Run function that is modified for bins on dim 3
main_Standard_Oddball_analysis_freq_reshapeTrialToBin

%% Plot RC1 results

dirUse = '/Users/blair/Dropbox/Research/EdNeuro/Hackathon 20200416/FreqDomainOut_test20200810/RCA';
close all
figure()

for i = 1:5
   
    % Load current file
    X = load([dirUse '/rcaResults_Freq_Condition ' num2str(i) '.mat'])
    
    % Topoplot in top row
    subplot(2, 5, i)
    plotOnEgi(X.rcaResult.A(:,1))
    
    % dGen in bottom row
    subplot(2, 5, i+5)
    plot(X.rcaResult.covData.dGen(end:-1:(end-5)), '*-', ...
        'linewidth', 2);
    box off
    title(['dGen condt ' num2str(i)])
    
end