% test_reshapeTrialToBinForRCA.m
% ---------------------------------
% Maintainer: Blair Kaneshiro <blairbo@gmail.com>
% Creator: Blair Kaneshiro, Aug 2020
%
% Unit testing the trials-to-bins-on-dim 3reshaping function with 
%   synthetic data and actual data.

clear all; close all; clc

%% Synthetic data
clc
rng('shuffle')

% Make the synthetic input matrix
nFreqs = 3; nBins = 10; nTrials = 10; nElectrodes = 128;
trialData_syn = rand([nFreqs * 2 * nBins, nElectrodes, nTrials]); % 60 x 128 x 10

% Call function w/ 1 input to get output matrix
binData_syn1 = reshapeTrialToBinForRCA(trialData_syn);
quicktest(trialData_syn, binData_syn1, nBins, nFreqs, nTrials, nElectrodes)

% Call function w/ 2 inputs to get output matrix
binData_syn2 = reshapeTrialToBinForRCA(trialData_syn, nBins);
quicktest(trialData_syn, binData_syn2, nBins, nFreqs, nTrials, nElectrodes)

assert(isequal(binData_syn1, binData_syn2))


%% Actual data

clear all; close all; clc

fnIn = '/Users/blair/Dropbox/Research/EdNeuro/EdNeuroCodebase/EdNeuroDevData/testReshapeTrialsToBins.mat'
load(fnIn)

testIn = dataIn{1,1};

% one input
testOut1 = reshapeTrialToBinForRCA(testIn);
quicktest(testIn, testOut1, ... 
    length(rcSettings.binsToUse), length(rcSettings.freqsToUse), ...
    size(testIn, 3), size(testIn, 2))

% two inputs
testOut2 = reshapeTrialToBinForRCA(testIn, length(rcSettings.binsToUse));
quicktest(testIn, testOut2, ... 
    length(rcSettings.binsToUse), length(rcSettings.freqsToUse), ...
    size(testIn, 3), size(testIn, 2))

assert(isequal(testOut1, testOut2))

%% A quick viewer for visual comparison with an RLS file (1366)

trLook = 4;
chLook = 28;
frLook = 2;
binLook = 9;

squeeze(testOut2(frLook:length(rcSettings.freqsToUse):end, chLook,... 
    (trLook-1) * length(rcSettings.binsToUse) + binLook))
    

%%
% Local function to test on some random indices
function quicktest(trialData, binData, nBins, nFreqs, nTrials, nElectrodes)
for i = 1:10
    rCh = randi(nElectrodes)
    rTr = randi(nTrials)
    rB = randi(nBins)
    rF = randi(nFreqs)
    useIm = 0;
    
    rIn = trialData((rF-1)*nBins + rB + nFreqs * nBins*useIm, rCh, rTr)
    rOut = binData(rF + nFreqs*useIm, rCh, (rTr-1)*nBins + rB)
    
    assert(rIn == rOut)
end
end