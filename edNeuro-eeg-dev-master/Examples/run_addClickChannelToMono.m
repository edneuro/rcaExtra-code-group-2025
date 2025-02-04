% run_addClickChannelToMono.m
% ----------------------------------
% Blair - June 14, 2021
%
% Example call to the function addClickChannelToMono.

clear all; close all; clc
load handel.mat % This loads variables y, Fs

% Change loaded variables to those used in function documentation
fs = Fs; clear Fs;
xMono = y; clear y;

%% Call function with required two inputs only

% The function requires a minimum of two inputs (mono audio variable and 
% sampling rate). If only two inputs are provided, the function will assign 
% default values to the other inputs:
% - Click start times will be once per second, starting at 1 second.
% - Click amplitude will be 0.9.
% - Click length will be 20 msec.

xStereo = addClickChannelToMono(xMono, fs);

% Plot the output
figure()
plot(((1:length(xMono))-1) / fs, xStereo); grid on
xlabel('Time (sec)'); ylabel('Amplitude')
set(gca, 'fontsize', 12)
legend('Channel 1: Audio', 'Channel 2: Clicks', 'location', 'southwest')
title('Default: 20-msec click (ampl 0.9) every sec starting at 1 sec')

%% Call function with additional inputs

% The user can customize the click start times (msec), click amplitude, and
% click length, in msec.

% Input 3: Customize click start times: Every 250 msec up to the first 5 
%   seconds
clickStarts = 250:250:5000;
xStereo1 = addClickChannelToMono(xMono, fs, clickStarts);
figure()
plot(((1:length(xMono))-1) / fs, xStereo1); grid on
xlabel('Time (sec)'); ylabel('Amplitude')
set(gca, 'fontsize', 12)
legend('Channel 1: Audio', 'Channel 2: Clicks', 'location', 'southwest')
title('Custom click start times')

% Input 4: Customize click amplitude: 0.4
clickAmpl = 0.4;
xStereo2 = addClickChannelToMono(xMono, fs, [], clickAmpl);
figure()
plot(((1:length(xMono))-1) / fs, xStereo2); grid on
xlabel('Time (sec)'); ylabel('Amplitude')
set(gca, 'fontsize', 12)
legend('Channel 1: Audio', 'Channel 2: Clicks', 'location', 'southwest')
title(['Custom click amplitude: ' num2str(clickAmpl)])

% Input 5: Customize click duration: 250 msec
clickDur = 250;
xStereo3 = addClickChannelToMono(xMono, fs, [], [], clickDur);
figure()
plot(((1:length(xMono))-1) / fs, xStereo3); grid on
xlabel('Time (sec)'); ylabel('Amplitude')
set(gca, 'fontsize', 12)
legend('Channel 1: Audio', 'Channel 2: Clicks', 'location', 'southwest')
title(['Custom click duration: ' num2str(clickDur) ' msec'])

% All of them at once!: Put clicks (250 msec long, 0.4 amplitude) every 500 
%   msec up to the first 5 seconds
clickStarts = 500:500:5000;
clickAmpl = 0.4; 
clickDur = 250;
xStereo4 = addClickChannelToMono(xMono, fs, clickStarts, clickAmpl, clickDur);
figure()
plot(((1:length(xMono))-1) / fs, xStereo4); grid on
xlabel('Time (sec)'); ylabel('Amplitude')
set(gca, 'fontsize', 12)
legend('Channel 1: Audio', 'Channel 2: Clicks', 'location', 'southwest')
title(['Custom: ' num2str(clickDur) '-msec clicks (ampl ' num2str(clickAmpl) ...
    ', every 500 msec in first 5 seconds'])