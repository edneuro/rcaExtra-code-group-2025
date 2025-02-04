% run_computeProportionReliabilityExplained.m
% --------------------------------------------
% Creator: Blair Kaneshiro, August 2020
% Maintainer: Blair Kaneshiro <blairbo@gmail.com>
%
% This script loads an RCA output .mat file and calls the function
%   computeProportionReliabilityExplained. It then plots the output of that
%   function alongside the dGen variable.

clear all; close all; clc

%%%%%%%%%%%%%%%%%%%%%%%% Edit here %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Path to .mat directory - make sure there's a slash at the end
dataDir = '/Users/blair/Dropbox/Research/EdNeuro/Hackathon 20200416/FreqOut_20200825_reshape1/RCA/';

% Name of .mat file in directory
matFn = 'rcaResults_Freq_Condition 1.mat';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load the .mat file
load([dataDir matFn])

%%% CALL THE FUNCTION
% If you look at the docstring of the function, you'll see it wants 4
%   inputs: dGen, Rxx, Ryy, Rxy. It returns the proportion of reliability
%   explained (a second output is the matrix rank used in the calculation,
%   but we generally don't need that).
PropRelExplained = computeProportionReliabilityExplained(...,
    rcaResult.covData.dGen,...
    rcaResult.covData.Rxx, rcaResult.covData.Ryy, rcaResult.covData.Rxy);

%%
%%% PLOT THE OUTPUT (propRelExpl and dGen)
% We can plot the output along with the dGen.
nCompUse = size(rcaResult.W, 2); % How many components are in the W matrix

figure()

% Subplot 1: dGen
subplot(1, 3, 1)
dGenSort = sort(rcaResult.covData.dGen, 'descend')
plot(dGenSort(1:nCompUse), '*-', 'linewidth', 2);
box off; grid on;
set(gca, 'xtick', 1:nCompUse, 'fontsize', 16)
xlim([0 nCompUse+1]); ylim([0 dGenSort(1) * 1.1])
title('dGen')

% Subplot 2: Proportion of reliability explained by individual dGen
subplot(1, 3, 2)
plot(PropRelExplained.individual(1:nCompUse), '*-', 'linewidth', 2);
box off; grid on
set(gca, 'xtick', 1:nCompUse, 'fontsize', 16)
xlim([0 nCompUse+1]); ylim([0 1])
title('Prop rel: Individ')

% Subplot 3: Cumulative proportion reliability explained
subplot(1, 3, 3)
plot(PropRelExplained.cumulative(1:nCompUse), '*-', 'linewidth', 2);
box off; grid on
set(gca, 'xtick', 1:nCompUse, 'fontsize', 16)
xlim([0 nCompUse+1]); ylim([0 1])
title('Prop rel: Cumul')

% Put title over subplots, or print filename
try
    sgtitle(matFn, 'interpreter', 'none');
catch
    subplot(1, 3, 3)
    % Print .mat file name
    text(nCompUse+1, 0, matFn, 'interpreter', 'none',...
        'horizontalalignment', 'right', 'verticalalignment', 'bottom')
end

% Adjust figure size
fPos = get(gcf, 'Position')
set(gcf, 'Position', fPos .* [1 1 1.2 .8])