% dev_compareGroupAndSingleSubStats.m
% --------------------------------------
% Blair - Nov 2, 2020
% Adapted from TN_calculateLatencies_Group_and_Subject.m (Trang)

clear all; close all; clc

% bin0 data projected through RC weights
load rcaResults_Freq_Conditions123_ProjectedBin0
% projectedData: {56 x 3} subjects x conditions cell array

% Prepare all subs data
rcOut_allSubs = rcResultStruct_cnd_123_bin0;
rcOut_allSubs.rcaSettings.destDataDir_FIG = '/Users/blair/Dropbox/Research/EdNeuro/EdNeuroCodebase/EdNeuroDevData/Trang single sub data/FIG';
rcOut_allSubs.rcaSettings.destDataDir_RCA = '/Users/blair/Dropbox/Research/EdNeuro/EdNeuroCodebase/EdNeuroDevData/Trang single sub data/MAT';

%% All subjects %%%
% 1a. Use pipeline stats
stats_allSubs = rcaExtra_runStatsAnalysis(rcOut_allSubs, [])
% 1b. Plot the results
rcaExtra_plotSignificantResults_freq(rcOut_allSubs, [], stats_allSubs, [])
% Latencies from plots (RC x condition)
% 165.29    161.72  163.71
% 162.41    153.50  155.94
% 137.12    NA      141.55


% 2. Use standalone function
[latencies_allSubs, errors_allSubs] = rcaExtra_computeLatenciesWithSignificance(rcOut_allSubs, stats_allSubs)
% latencies_allSubs =
% 
%   165.2938  161.7403  163.7089
%   162.4079  153.4960  155.9408
%   137.1225       NaN  141.5469
%        NaN  345.6812       NaN
%   219.5586  207.7981  193.5340
%   220.9245  246.5854       NaN

%% Single subject %%%

rcOut_individSubs = convertProjectCellToSubCell(rcOut_allSubs);

for n = 1
   close all
   % 1a. Use pipeline stats
   stats_indSubs(n) = rcaExtra_runStatsAnalysis(rcOut_individSubs(n), [])
   
   % 1bi. Create output figure directory if it doesn't exist
   if ~exist(rcOut_individSubs(n).rcaSettings.destDataDir_FIG, 'dir'),... 
           mkdir(rcOut_individSubs(n).rcaSettings.destDataDir_FIG); end % created subject-specific FIG folders to store graphs
    
   % 1bii. Plot results for this subject
   rcaExtra_plotSignificantResults_freq(rcOut_individSubs(n),[],stats_indSubs(n),[]) % Plot Significant Results
   % Latencies from plots (RC x condition)
   % 177.34   182.09    169.34
   % NA       133.12    NA
   % 191.24   203.45    221.07
   
   % 2. Use standalone function
   [latencies_indSubs(:, :, n), errors_indSubs(:, :, n)] = rcaExtra_computeLatenciesWithSignificance(rcOut_individSubs(n), stats_indSubs(n))
%    latencies_indSubs =   xxxx Similar to group-level, above
% 
%   165.2938  161.7403  163.7089
%        NaN   89.8077       NaN
%   184.7801  191.9086  152.9127
%   163.7433  285.5365       NaN
%        NaN       NaN       NaN
%   191.1856       NaN       NaN
end