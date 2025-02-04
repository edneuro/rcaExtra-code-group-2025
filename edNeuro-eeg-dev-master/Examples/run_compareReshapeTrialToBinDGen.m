% run_compareReshapeTrialToBinDGen.m
% ------------------------------------
% Blair - August 2020
%
% Example of how to load RCA output with trails reshaped to bins (or not)
%   and call the function that will visualize their topoplots and dGen.
%
% Make sure the following is in your path
% - rcaExtra repo (for topoplot)
% - mrC repo (for topoplot)
% - compareReshapeTrialToBinDGen function

clear all; close all; clc

% You should already have run RCA twice on a given dataset, everything set
% up the same except in one case you did not do any reshaping of the data
% prior to RCA, and in the other case you reshaped the third dimension from
% trials to single bins. We'll indicate things with no reshaping with "0"
% and things with reshaping with "1".

% Specify the directories where the mat files live. Make sure there is an
% ending slash so it can be combined with the mat filename for loading.
dir0 = '/Users/blair/Dropbox/Research/EdNeuro/Hackathon 20200416/FreqOut_20200825_reshape0/RCA/';
dir1 = '/Users/blair/Dropbox/Research/EdNeuro/Hackathon 20200416/freqOut_20200825_reshape1/RCA/';

% Specify the names of the mat files in each directory that you want to
% compare.
mat0 = 'rcaResults_Freq_Condition 1.mat'; 
mat1 = mat0; % Do this if the actual mat files have same name inside dir.

% Specify a title to display in the figure
figTitle = 'Hackathon data, condition 1';

% Load each mat file into a variable
r0 = load([dir0 mat0])
r1 = load([dir1 mat1])

% Call the function, inputting the two variables just created
compareReshapeTrialToBinDGen(r0, r1, figTitle)

% Make the figure a bit larger
fPos = get(gcf, 'Position')
set(gcf, 'Position', fPos .* [1 1 1.2 1.2])