function compareReshapeSubToSupersub(r0, r1, figTitle)
% compareReshapeSubToSupersub(r0, r1, figTitle)
% --------------------------------------------
% Blair - August 2020
%
% Comparing RCA outputs when combining subjects to a single super-subject
% for a given stimulus condition (versus not).
%
% REQUIRED INPUTS
% d0: RCA output for subject data. This variable should be a
%   struct whose single field is 'rcaResult'.
% d1: RCA output for supersubject. This varaible should also be a
%   struct whose single field is 'rcaResult'.
%
% OPTIONAL INPUTS
% figTitle: Descrioptive title for entire figure (e.g., 'MS condition 2').
%   It not entered or empty, the function will print a warning and display
%   the default title 'Comparing dim 3 reshape from trials to bins'.
%
% Example usage
%   d0 = load('/noReshapePath/rcaResults_Freq_Condition2.mat')
%   d1 = load('/reshapePath/rcaResults_Freq_Condition2.mat')
%   compareReahspeTrialToBinDGen(d0, d1)
%%
% % Prompt for reshape = 0
% [pn0, dn0] = uigetfile('*.mat')
% r0 = load([dn0 pn0])
% 
% % Prompt for reshape = 1
% [pn1, dn1] = uigetfile('*.mat')
% r1 = load([dn1 pn1])
% figTitle = ['Hackathon data, freq, meh']
%%

assert(nargin >= 2, 'Function requires 2 inputs.')
if nargin < 3 || isempty(figTitle)
    warning('Figure title not specified. Using default title');
    figTitle = 'Comparing dim 3 reshape from trials to bins';
end
%%
% How many RCs are we working with
nRC = size(r0.rcaResult.W, 2);

% Get the dGen
d0 = r0.rcaResult.covData.dGen(end:-1:(end-(nRC-1)));
d1 = r1.rcaResult.covData.dGen(end:-1:(end-(nRC-1)));
disp(['dGen, subject-level RCA: ' mat2str(round(d0, 4))])
disp(['dGen, supersubject-level RCA: ' mat2str(round(d1, 4))])

% How many RCs are we working with
nRC = size(r0.rcaResult.W, 2);

% close all
figure()
sgtitle(figTitle)

% Plot the RC topos
for i = 1:nRC
   subplot(4, nRC, i)
   plotOnEgi(r0.rcaResult.A(:,i));
   if i == 1, title('subject'); end
   
   subplot(4, nRC, nRC+i)
   plotOnEgi(r1.rcaResult.A(:,i));
   if i == 1, title('supersubject'); end
end

% Plot the dGen
yMax = max(max([d0 d1])) * 1.1;
subplot(4, 2, [5 7])
plot(d0, '*-', 'linewidth', 2); 
grid on; ylim([0 yMax])
title(['dGen, subject']); xlabel('RC')
set(gca, 'fontsize', 12)
xlim([0 nRC+1])

subplot(4, 2, [6 8])
plot(d1, '*-', 'linewidth', 2); 
grid on; ylim([0 yMax])
title(['dGen, supersubject']); xlabel('RC')
set(gca, 'fontsize', 12)
xlim([0 nRC+1])