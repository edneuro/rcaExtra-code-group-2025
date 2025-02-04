% run_compareReshapeSubToSupersub.m
% ------------------------------------
% Blair - September 2020
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
% up the same except in one case you did not call the 
%   reshapeCellSubToSupersub function, and in the other case you did. In 
%   both cases, you should have FIRST reshaped the data so that bins 
%   rather than trials are on dimension 3. We'll indicate things as 
%   "sub" or "supersub".

% Specify the directories where the mat files live. Make sure there is an
% ending slash so it can be combined with the mat filename for loading.
dir_sub = '/Users/blair/Dropbox/Research/EdNeuro/Hackathon 20200416/FreqOut_20200825_reshape1/RCA/';
dir_supersub = '/Users/blair/Dropbox/Research/EdNeuro/Hackathon 20200416/FreqOut_supersub_20200923/RCA/';

% Specify the names of the mat files in each directory that you want to
% compare.
mat_sub = 'rcaResults_Freq_Condition 5.mat'; 
mat_supersub = mat_sub; % Do this if the actual mat files have same name inside dir.

% Specify a title to display in the figure
figTitle = 'Hackathon data, condition 5';

% Load each mat file into a variable
r_sub = load([dir_sub mat_sub])
r_supersub = load([dir_supersub mat_supersub])

% Call the function, inputting the two variables just created
compareReshapeSubToSupersub(r_sub, r_supersub, figTitle)

% Make the figure a bit larger
fPos = get(gcf, 'Position');
set(gcf, 'Position', fPos .* [1 1 1.2 1.2]);

% NEW: Compute correlations between columns of A
A_sub = r_sub.rcaResult.A;
A_supersub = r_supersub.rcaResult.A;

% Compute magnitude correlations
nRC = size(A_sub, 2);
topoCorrelations = nan(1, nRC)
disp('Magnitude correlations of corresponding RCs:')
for i = 1:nRC
    topoCorrelations(i) = corr(A_sub(:, i), A_supersub(:, i));
    disp(['RC ' num2str(i) ': ' sprintf('%.03f', abs(topoCorrelations(i)))]);
end