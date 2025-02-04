% dev_runRCAOnERP.m
% -------------------------
% Blair - June 4, 2020
%
% This script is an example on how to run RCA on ERP (or other) data by
% calling the core RCA function.
%
% You need the following repo in your path: https://github.com/dmochow/rca
%
% To run this example, you need the IN.mat data file (downloaded and added
%   to path) from the Data folder from hands-on RCA tutorial folder:
% https://www.dropbox.com/sh/dku359ox7fz6hgx/AAC7SN2RC-nxA-HHrBcfdUC8a?dl=0

clear all; close all; clc

%%%%%%%%%%%%%% Dev: Add paths %%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath('/Users/blair/Dropbox/Research/EdNeuro/EdNeuroCodebase/edNeuro-eeg-dev'))
addpath(genpath('/Users/blair/Dropbox/Research/EdNeuro/Tutorials Seminars/20200410 TUTORIAL Blair RCA 1 DONE/Code and data'))
addpath(genpath('/Users/blair/Dropbox/Research/EdNeuro/EdNeuroCodebase/rca'))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load IN.mat

%                X: [124×40×5184 double]
%     blCorrectIdx: [1 2 3 4 5 6 7 8 9 10 11 12]
%               fs: 62.5000
%          labels6: [5184×1 double]
%         labels72: [5184×1 double]
%            subID: '06'
%                t: [1×40 double]

% Separate out the trials by category

% We know there are 6 classes, but here is how to get it programmatically
%   from the labels vector.
nClass = length(unique(IN.labels6));

% Separate out the trials from each class in a cell array.
% While doing so, switch the first two dimensions for input to RCA.
for i = 1:nClass
    temp = IN.X(:, :, IN.labels6==i);
    xIn{i} = permute(temp, [2 1 3]);
end



%% RCA parameters

%%%%%%%%%%%%%% Dev: Edit params %%%%%%%%%%%%%%%%%%%%%%%%%%
nReg = 7;
nComp = 5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Prepare data for RCA: 1 condition

dataIn = xIn{2};

%% Prepare data for RCA: Multiple conditions

dataIn = xIn([2, 6]);

%% Run RCA: Multiple conditions

% Get the data dimensions
if iscell(xIn)
    [nTime, nSpace, nTrial] = size(xIn{1});
else
    [nTime, nSpace, nTrial] = size(xIn);
end

close all
if nSpace < 128
    [OUT.dataOut, OUT.W, OUT.A, OUT.Rxx, OUT.Ryy, OUT.Rxy, OUT.dGen] = rcaRun125(dataIn, nReg, nComp);
else
    [OUT.dataOut, OUT.W, OUT.A, OUT.Rxx, OUT.Ryy, OUT.Rxy, OUT.dGen] = rcaRun(dataIn, nReg, nComp);
end

%% Prepare data for RCA: Temporal subsets (class 2 only)

%%% Currently implemented for Blair's data -- need to update for sample
%%% numbers more generally.

% These are in sample numbers. Later we can discuss msec-to-sample
% conversion if needed.
timeWin_P1 = find(IN.t >= 80 & IN.t <= 144);
timeWin_N170 = find(IN.t > 144 & IN.t <= 224);

% Prepare the input data by subsetting along the time dimension according
% to the sample ranges defined above.
dataIn_P1 = dataIn{2}(timeWin_P1, :, :);
dataIn_N170 = dataIn{2}(timeWin_N170, :, :);
if nSpace < 128
    [OUT_P1.dataOut, OUT_P1.W, OUT_P1.A, OUT_P1.Rxx, OUT_P1.Ryy, OUT_P1.Rxy, OUT_P1.dGen] = rcaRun125(dataIn_P1, nReg, nComp);
else
    [OUT_P1.dataOut, OUT_P1.W, OUT_P1.A, OUT_P1.Rxx, OUT_P1.Ryy, OUT_P1.Rxy, OUT_P1.dGen] = rcaRun(dataIn_P1, nReg, nComp);
end
%%

if nSpace < 128
    [OUT_N170.dataOut, OUT_N170.W, OUT_N170.A, OUT_N170.Rxx, OUT_N170.Ryy, OUT_N170.Rxy, OUT_N170.dGen] = rcaRun125(dataIn_N170, nReg, nComp);
else
    [OUT_N170.dataOut, OUT_N170.W, OUT_N170.A, OUT_N170.Rxx, OUT_N170.Ryy, OUT_N170.Rxy, OUT_N170.dGen] = rcaRun(dataIn_N170, nReg, nComp);
end