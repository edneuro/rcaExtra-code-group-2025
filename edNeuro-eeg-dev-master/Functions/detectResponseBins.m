function [responseBins] = detectResponseBins(xIn, fs, responseThresh, preMsec, postMsec)
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
if nargin < 3 || isempty(responseThresh), responseThresh = -1000; end
if nargin < 4 || isempty(preMsec), preMsec = -500; end
if nargin < 5 || isempty(postMsec), postMsec = 300; end

responseChannel = xIn(:, 131);
responseBinSamp = find(responseChannel < responseThresh);
responseBinSec = responseBinSamp / fs;
for i = 1:length(responseBinSec)
    responseWindowSec(i, :) = responseBinSec(i) + [preMsec postMsec]/1000;
end
if ~exist('responseWindowSec'), responseWindowSec = []; end
responseBinNumber = unique(ceil(responseWindowSec(:)));

responseBins.fs = fs;
responseBins.responseThresh = responseThresh;
responseBins.preMsec = preMsec;
responseBins.postMsec = postMsec;
responseBins.responseBinSec = responseBinSec;
responseBins.responseBinNumber = responseBinNumber;


