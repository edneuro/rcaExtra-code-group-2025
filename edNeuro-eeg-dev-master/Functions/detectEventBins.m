function [eventBinNumber, eventBinSec] = detectEventBins(xIn, fs, eventThresh)
% [eventBinNumbers, eventBinSec] = detectEventBins(xIn, fs, eventThresh)
% -------------------------------------------------------------------------
% Lindsey and Blair - July 16, 2020
%
% This function detects response events from the main data frame and writes
% out variables with bin number and time (in seconds) of said events

% Data checks
assert(nargin >= 1, 'Must input at least the data matrix.');
assert(size(xIn, 2) == 131, 'Input data matrix must have 131 columns.');
if nargin < 2 || isempty(fs), fs = 420; end
if nargin < 3 || isempty(eventThresh), eventThresh = -1000; end

eventChannel = xIn(:, 131);
eventBinSamp = find(eventChannel < eventThresh);
eventBinSec = eventBinSamp / fs;
eventBinNumber = ceil(eventBinSec);


