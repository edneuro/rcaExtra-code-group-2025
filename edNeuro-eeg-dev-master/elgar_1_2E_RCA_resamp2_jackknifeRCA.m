% function elgar_1_2E_RCA_jackknifeRCA(stimUse, doPerm, permIdx)
% elgar_1_2E_RCA_jackknifeRCA.m
% -------------------------------------------------------------------------
% Blair - March 19, 2021
%
% Perform bootstrap RCA with resampling (no phase scrambling)
%
% Adapted from elgar_1_2E_RCA_analysis_computeRCs.m Blair - February 14, 2021
% eng_1_2N_RCAISC_1_computeRCs_v2_RCAonly.m Blair - July 20, 2017
% Adapted from eng_1_2N_RCAISC_1_computeRCsISC_v1_parpool.m, Blair - May 9, 2017
% eng_1_2_RCA_1_computeRCs.m - Blair - July 7, 2015, Jacek - April 13, 2015
% This script loads a number of songs, pools across both listens, computes
% RCA, and saves the outputs.
%
% New for this version: RCA only, saving a lot of outputs. Will load and
% aggregate later to do ISC computations. ALSO, we are starting off with
% the imputed data frames, so no longer need to impute and DC correct as
% part of the loading process.
%
% Output variables of interest: RCA output data, dGen

ccc
% tic
rng('shuffle');
songStructDir = '/usr/ccrma/media/projects/jordan/Experiments/Elgar1.2EEGPaper/SDR_cleanEEG';
rcaFigDir = '/usr/ccrma/media/projects/jordan/Experiments/Elgar1.2EEGPaper/RCABootstrapFigs';
rcaOutDir = '/usr/ccrma/media/projects/jordan/Experiments/Elgar1.2EEGPaper/RCABootstrapOut';

%%%%%%%%%% Edit / debug stuff %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Jackknife iteration specification vector
jackIter = 1:23;

% Whether to save figures (e.g., for dev) and output
saveFig = 1;

% Specify output mode: 'full' will save all RCA output, 'light' will save
%   everything except dataOut, 'none' will skip saving.
saveOutputMode = 'light'; % 'full', 'light', or 'none'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% RCA stuff -- same params as NeuroImage paper
nReg=7; % number of PCs to keep in eigenvalue problem (usually 5-10)
nRC = 5; % How many RCs to compute and return (was nComp)
fs = 125; % Sampling rate of the EEG (always 125)

%% Load the data and change dimensions

cd(songStructDir) % This is the clean EEG (song struct) directory

load song22.mat; disp(['Loaded song 22.mat'])
load song23.mat; disp(['Loaded song 23.mat'])

xIn22 = permute(eeg22, [2 1 3]); clear eeg22;
xIn23 = permute(eeg23, [2 1 3]); clear eeg23;

[nTime, nElectrode, nSub] = size(xIn22); % Data sizes

%% Run RCA and compute ISCs

%%% Create the parpool OUTSIDE of the iteration loop
delete(gcp('nocreate'));
try
    matlabpool
    closePool=1;
catch
    parpool
    closePool=0;
end

%%% Compute and store RCA for however many iteration indices
for i = jackIter
    
    disp(['-*-*-* Jackknife iteration: Exclude trial ' mat2str(i) '. *-*-*-'])
    
    % Explicitly specify the vector of included trials so that we can save it
    jackIdx = 1:nSub; jackIdx(i) = []; jackIdx(:)
    
    %%% Do RCA stuff for stim 22
    
    % Select included trials
    xJack22 = xIn22(:, :, jackIdx); 
    
    % Run RCA
    [dataOut,W,A,Rxx,Ryy,Rxy,dGen] = rcaRun125_parpoolAlreadyCreated(...
        xJack22, nReg, nRC);
    
    if saveFig
        cd(rcaFigDir)
        set(gcf, 'PaperPosition', [0 0 14 8]);
        fnOut = ['rcaFig_stim22_jack_rmTr' sprintf('%03d', i) ...
            '_' datestr(now, 'yyyymmdd_HHMMSS') '.png'];
        saveas(gcf, fnOut)
        disp(['Saved figure ' fnOut])
    end
    close all
    
    switch saveOutputMode
        case 'full'
            cd(rcaOutDir)
            fnOut = ['rcaOut_stim22_jack_rmTr' sprintf('%03d', i)...
                '_' saveOutputMode '_' datestr(now, 'yyyymmdd_HHMMSS') '.mat'];
            save(fnOut, 'A', 'dataOut', 'dGen', 'songStructDir', 'R*', 'W',...
                'nReg', 'nRC', 'fs', 'jackIdx');
            disp(['Saved .mat file (full) ' fnOut])
        case 'light'
            cd(rcaOutDir)
            fnOut = ['rcaOut_stim22_jack_rmTr' sprintf('%03d', i)...
                '_' saveOutputMode '_' datestr(now, 'yyyymmdd_HHMMSS') '.mat'];
            save(fnOut, 'A', 'dGen', 'songStructDir', 'R*', 'W',...
                'nReg', 'nRC', 'fs', 'jackIdx');
            disp(['Saved .mat file (light) ' fnOut])
        case 'none'
            disp('Not saving an output .mat file.')
        otherwise
            warning(['Not sure what to do with saveOutputMode = ''' ...
                saveOutputMode '''.'])
    end
    
    clear dataOut W A Rxx Ryy Rxy dGen
    
    %%% Do RCA stuff for stim 23
    
    % Select included trials
    xJack23 = xIn23(:, :, jackIdx); 
    
    % Run RCA
    [dataOut,W,A,Rxx,Ryy,Rxy,dGen] = rcaRun125_parpoolAlreadyCreated(...
        xJack23, nReg, nRC);
    
    if saveFig
        cd(rcaFigDir)
        set(gcf, 'PaperPosition', [0 0 14 8]);
        fnOut = ['rcaFig_stim23_jack_rmTr' sprintf('%03d', i) ...
            '_' datestr(now, 'yyyymmdd_HHMMSS') '.png'];
        saveas(gcf, fnOut)
        disp(['Saved figure ' fnOut])
    end
    close all
    
    switch saveOutputMode
        case 'full'
            cd(rcaOutDir)
            fnOut = ['rcaOut_stim23_jack_rmTr' sprintf('%03d', i)...
                '_' saveOutputMode '_' datestr(now, 'yyyymmdd_HHMMSS') '.mat'];
            save(fnOut, 'A', 'dataOut', 'dGen', 'songStructDir', 'R*', 'W',...
                'nReg', 'nRC', 'fs', 'jackIdx');
            disp(['Saved .mat file (full) ' fnOut])
        case 'light'
            cd(rcaOutDir)
            fnOut = ['rcaOut_stim23_jack_rmTr' sprintf('%03d', i)...
                '_' saveOutputMode '_' datestr(now, 'yyyymmdd_HHMMSS') '.mat'];
            save(fnOut, 'A', 'dGen', 'songStructDir', 'R*', 'W',...
                'nReg', 'nRC', 'fs', 'jackIdx');
            disp(['Saved .mat file (light) ' fnOut])
        case 'none'
            disp('Not saving an output .mat file.')
        otherwise
            warning(['Not sure what to do with saveOutputMode = ' saveOutputMode])
    end
    
    clear dataOut W A Rxx Ryy Rxy dGen xJack* jackIdx
    
end

% After all iterations, close the parpool
if closePool
    matlabpool close
else
    delete(gcp('nocreate'));
end
disp(['-*-*-* Function call completed: ' datestr(now, 'yyyymmdd_HHMMSS') ' *-*-*-'])

% toc
