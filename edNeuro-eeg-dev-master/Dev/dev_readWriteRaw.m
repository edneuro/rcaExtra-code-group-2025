% dev_readWriteRaw.m
% -------------------
% Blair - June 2021
%
% Looking into reading and writing .raw exports using EEGLAB

clear all; close all; clc

% Add EEGLAB to the path
addpath(genpath('/Users/blair/Dropbox/Matlab/eeglab11_0_5_4b'))

% Input data directory
inDir = '/Users/blair/Downloads/Filemail.com files 2021-6-10 pxydxttgtmhdecg';

% Load a file?
cd(inDir)

X = pop_importdata('data', '104_20210512_104001.raw');