% av_computeSaveResponseBins.m 
% ----------------------------
% Blair and Lindsey - July 17, 2020

clear all; close all; clc

% navigate to directory where raw .mat files are saved
mainDir = '/Volumes/Seagate Backup Plus Drive/2020_AV_RCA/Exports';

% find all files
filelist = dir(fullfile(mainDir, '**/Raw*.mat'))

% load files, run detectResponseBins function, and save out new file with
% response bins removed
for i = 1:length(filelist)
    i
    % move into folder
    cd(filelist(i).folder);
    % load file
    in = load(filelist(i).name);
    R = detectResponseBins(in.RawTrial);
    fnOut = ['responseBins' filelist(i).name(4:end)];
    save(fnOut, 'R');
    clear in R fnOut;
end