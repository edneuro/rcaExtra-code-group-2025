function h = plotDGen(dGen, nToPlot)
% h = plotDGen(dGen, nToPlot)
% --------------------------------------------------
% May 2020
% Author: Blair Kaneshiro, blairbo@gmail.com
%
% This function takes in the vector of RCA coefficients (dGen) and plots
% the specified number of them. 
%
% INPUTS
% - dGen (required): nChannels x 1 vector of RCA coefficients as output by
%   rcaRun.
% - nToPlot (optional): How many components to plot. Must be less than or
%   equal to the length of dGen. If not specified, defaults to 7.
%
% OUTPUTS
% - h: Plotting object.

%% For live function, skip during development

% Make sure the user input at least the dGen vector
assert(nargin >= 1, 'dGen vector of RCA coefficients is a required input.');

% If the user didn't specify how many to plot, print a warning and set to
%   the default value.
defaultNToPlot = 7;
if nargin < 2
    warning(['Number of components not specified. Setting to ' num2str(defaultNToPlot) '.']);
    nToPlot = defaultNToPlot;
end

%% For development, comment out when running as function

% clear; close all; clc
% % Create testing dGen
% dGen = exp(sort(rand([128 1]))); % Small to big
% dGen = dGen / max(dGen) * 0.4;
% nToPlot = 7;

%% Check inputs in preparation for plot

% Make sure the dGen input is a vector
assert(isvector(dGen), 'dGen input should be a vector.')

% If nToPlot is greater than length of dGen, print a warning and change to
%   length(dGen).
if nToPlot > length(dGen)
    warning(['Requested number of coefficients to plot (',...
        num2str(nToPlot) ') exceeds length of coefficient vector. ',...
        'Will plot ' num2str(length(dGen)) ' coefficients available ',...
        'in the coefficient vector.']);
    nToPlot = length(dGen);
end

%% Make the plot

dGenPlot = sort(dGen, 'descend');
h = plot(1:nToPlot, dGenPlot(1:nToPlot), '*-', 'linewidth', 2);