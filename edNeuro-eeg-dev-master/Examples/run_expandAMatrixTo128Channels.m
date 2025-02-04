% run_expandAMatrixTo128Channels.m
% ------------------------------------------------------------------
% Creator: Blair Kaneshiro (May 2021)
% Maintainer: Blair Kaneshiro
%
% This script demonstrates how to call the run_expandAMatrixTo128Channels
% to convert a 7-channel A matrix to a 128-channel A matrix, and then call
% the plotOnEgi function.

clear all; close all; clc

%%%%%%%%%%%%%%% The following repos need to be in the path %%%%%%%%%%%%%%%

% Repo with the function
addpath(genpath('/Users/blair/Dropbox/Research/EdNeuro/EdNeuroCodebase/edNeuro-eeg-dev'))

% Repo with plotOnEgi function
addpath(genpath('/Users/blair/Dropbox/Research/EdNeuro/EdNeuroCodebase/rcaExtra'))

% Repo with helper functions for plotOnEgi
addpath(genpath('/Users/blair/Dropbox/Research/EdNeuro/EdNeuroCodebase/mrC'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Create a dummy A matrix. 

% This is the forward-model projection of the RCA weights, used for 
% plotting the scalp map of the component. 
% Electrodes are Fz, Pz, P3, P4, PO7, PO8, Oz
% https://wearablesensing.com/wp-content/uploads/2018/07/Wearable-Sensing-DSI-VR300-Specifications_2018.pdf
% For now, let's assign a negative weight to the frontal electrode (entry 
%   1) and positive weights to the other electrodes. 

A = [-1; 1; 1; 1; 1; 1; 1];

%% Call the function: Default values

% - A input is required; there are additional inputs to specify the montage
%   (only default montage for DSI-VR300 is currently implemented) and to
%   specify whether the filled-in values should be 0 (default) or NaN. 
%   Currently the topoplot function seems to work only with 0s filled in/
A128 = expandAMatrixTo128Channels(A);

%% Call the topoplot function
figure()
plotOnEgi(A128);
colorbar

%% Call the function: Set other values to NaN

% This is just to show that setting all other values to NaN doesn't work.

A128 = expandAMatrixTo128Channels(A, [], NaN);

% Call the topoplot function
figure()
plotOnEgi(A128);
colorbar
% Doesn't seem to work :( 

%% Call the function: Different values of input matrix

% Writing in some left occipital lateralization
A_1 = [-1; 1; 1; .7; 1.3; .7; 1];
A128_1 = expandAMatrixTo128Channels(A_1);

% Call the topoplot function
figure()
plotOnEgi(A128_1);
colorbar


