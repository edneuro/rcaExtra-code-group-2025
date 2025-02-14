function [weightedAvgPerBinPerFreq, ValidTrialsPerBinPerFreq] = averageBinsTrials(dataIn)
% Alexandra Yakovleva, Stanford University 2012-1020

    [nBins, nFreq, nCh, ~] = size(dataIn);

    ValidTrialsPerBinPerFreq = sum(~isnan(dataIn), 4);
    % nBins x nF x nChannels x nTrials
    meanBinsPerTrialPerFeq = nanmean(dataIn, 4);
    if (nBins > 1)
        try
            % weighted average per bin per trial
            weightedAvgPerBinPerFreq = squeeze(wmean(meanBinsPerTrialPerFeq, ValidTrialsPerBinPerFreq));
        catch
            weightedAvgPerBinPerFreq = zeros(nFreq, nCh); 
        end
        weightedAvgPerBinPerFreq = reshape(weightedAvgPerBinPerFreq, [nFreq nCh]);
    else
        % averaging bin 0 data TODO check if mean can/should be used 
        weightedAvgPerBinPerFreq = squeeze(wmean(meanBinsPerTrialPerFeq, ValidTrialsPerBinPerFreq, 4));
    end
end