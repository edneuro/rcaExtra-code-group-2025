% eng_1_2N_coherence_analysis_cpsdStats_SRCoh.m
% ----------------------------------------
% Blair - March 27, 2018
%
% This script performs some statistics on the cpsd output (for ISCoh or
% SRCoh):
% - ANOVA: Across all 4 conditions at once (circ_wwtest)
% - Pairwise analyses: Compare ISCoh angles to zero-radian distribution.
%   Compare SRCoh angles to one another by all pairs of stimulus condition.
%
% This script uses the Circular Statistics Toolbox (Berens, 2009).

% Adapted from eng_1_2N_coherence_analysis_cpsdStats.m Blair - March 27, 2018

clear all; close all; clc

disp('Doing SRCoh.')
inDir = '/Users/blair/Desktop/TODO/EdNeuro circ stats';
fnIn = 'eng_1_2N_srCoherOut_aggregatedCoherence_v3d_RC1_20180704.mat';

cd(inDir)
disp(['Loading ' fnIn])
load(fnIn)

cpsdAngles = angle(intactFreqCpsd); % 24 x 16

%% Do stuff by song
anovaLabels = repmat([1 2 4], 24, 1)
condtStr = {'Orig', 'Rev', 'Meas'};
for song = 1:4
    currStimNumbers = song:4:16;
    currStimNumbers(3) = []; % Remove phase number
    currAngles = cpsdAngles(:, currStimNumbers); % 24 x 3
    disp(' ')
    disp(['Song ' num2str(song)])
    % Print mean angle in radians of each category
    for condt = 1:3
        % It'll be a value between 0 and 2pi
        thisMean = wrapTo2Pi(circ_mean(currAngles(:, condt))); 
        disp([condtStr{condt} ' mean = ' sprintf('%.2f', thisMean/pi) 'pi radians'])
    end
    
    % Anova: Inputs are data, group assignments labels
    pval_anova(song) = circ_wwtest(currAngles(:), anovaLabels(:));
    disp(['Song ' num2str(song) ' ANOVA (3 conditions) p=' num2str(pval_anova(song))])
    
    % Compare all pairwise means
    disp(['Song ' num2str(song) ' pairwise t-tests (3 pairs):'])
    for m = 1:2
       for n = (m+1):3
          
          thisP = circ_wwtest(currAngles(:, m), currAngles(:, n));
          disp(['Song ' num2str(song) ' ' condtStr{m} ' vs ' condtStr{n} ':'...
              ' p = ' num2str(thisP)])
          disp('---------------------------------------------')
       end
    end
    
end

%% Correct for multiple comparisons using FDR.
% [Did this in R]

%% Get out all the mean values and get into msec units

% peakFreq0 = fAx(peakIdx);
% peakFreq16 = repmat(peakFreq0, 4, 1); % 16 x 1 vector of freqs
% 
% % Here is the msec time corresponding to one 2pi revolution for each
% % stimulus
% peakCycleMsec16 = 1./peakFreq16
% 
% meanAngleOver2Pi = nan(16, 1);
% 
% % Get the mean angle for each stimulus
% for i = [1:4 5:8 13:16]
%    thisAngle = cpsdAngles(:, i);
%    thisMean = wrapTo2Pi(circ_mean(thisAngle));
%    meanAngleOver2Pi(i) = thisMean / (2*pi);
% end
% 
% % Here's the mean angle, in radians, expressed in msec
% oneCycleMsec = meanAngleOver2Pi .* peakCycleMsec16;
% 
% % Here's if we do a second cycle
% twoCycleMsec = oneCycleMsec + peakCycleMsec16;
% 
% [oneCycleMsec twoCycleMsec]
