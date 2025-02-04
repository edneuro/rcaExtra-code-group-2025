% run_adjustDBLevelOfWav.m
% ----------------------------
% Blair - July 30, 2021
%
% This script enables a user to adjust the amplitude of a .wav file by
% specifying the desired dB change. 
%
% Required repo: https://github.com/blairkan/BKanMatEEGToolbox
% - Uses scaleWavBySpecifiedDBShift.m function, which calls 
%   convertDBShiftToAmplScale.m function.
%
% User should specify the following in the script: 
% - Input directory (full path)
% - Output directory (full path)
% - Input filename
% - Desired dB shift. Example: To shift from 65.6 to 60.0, the desierd dB
%   shift would be -5.6.
%
% The function will read in the input file from the input directory, apply
% the appropriate dB shift, and write out the output in the output
% directory. For input filename inputFn.wav, the output filename will be
% inputFn_scaled.wav.

clear all; close all; clc

%%%%%%%%%% User specifies values in this section %%%%%%%%%%

% Input and output directory (full path)
dirIn = '/Users/blair/Desktop/';
dirOut = '/Users/blair/Desktop/';

% Input filename
fnIn = '32_Malang-phaseScram.wav';

% Desired dB shift
dbShift = -2.5;

%%%%%%%%%%%%%%%%% End user-edited section %%%%%%%%%%%%%%%%%%

% This line loads and scales the input stimulus, and waves the output in a
% new .wav file.
scaleWavBySpecifiedDBShift(dirIn, dirOut, fnIn, dbShift);