function rcaResult = runRCA_frequency(rcaSettings, sensorData, cellNoiseData1, cellNoiseData2)
% Alexandra Yakovleva, Stanford University 2012-2020.

    if (isfield(rcaSettings, 'useCnds') && ~isempty(rcaSettings.useCnds))
        dataSlice = sensorData(:, rcaSettings.useCnds)';
    else
        dataSlice = sensorData';
        rcaSettings.useCnds = size(sensorData, 2);
    end
    fprintf('Running RCA frequency for dataset %s number of components: %d ...\n', rcaSettings.label, rcaSettings.nComp);
    % file with results
    savedFile = fullfile(rcaSettings.destDataDir_RCA, strcat('rcaResults_Freq_', rcaSettings.label, '.mat'));
     
    if (~exist(savedFile, 'file'))
        [rcaData, W, A, Rxx, Ryy, Rxy, dGen, ~] = ...
            rcaRun(dataSlice, rcaSettings.nReg, rcaSettings.nComp); 
        covData.Rxx = Rxx;
        covData.Ryy = Ryy;
        covData.Rxy = Rxy;
        covData.dGen = dGen;
        noiseData.lowerSideBand = rcaProject(cellNoiseData1, W); 
        noiseData.higherSideBand = rcaProject(cellNoiseData2, W);
        
        %% generate final output struct
        rcaResult.projectedData = rcaData;
        rcaResult.sourceData = dataSlice;

        rcaResult.W = W;
        rcaResult.A = A;
        rcaResult.covData = covData; 
        rcaResult.noiseData = noiseData;
        rcaResult.rcaSettings = rcaSettings;
        % store average data 
        [projAvg, subjAvg] = averageFrequencyData(rcaData, ...
            numel(rcaSettings.binsToUse), numel(rcaSettings.freqsToUse));
        rcaResult.projAvg = projAvg;
        rcaResult.subjAvg = subjAvg;
 
        save(savedFile, 'rcaResult','-v7.3','-nocompression');        
    else
        try
            load(savedFile, 'rcaResult');
            % compare runtime settings
            if (~rcaExtra_compareRCASettings_freq(rcaResult.rcaSettings, rcaSettings))
                % if settings don't match, save old file and re-run the analysis
            
                disp('New settings don''t match previous instance, re-running RCA ...'); 
                matFileRCA_old = fullfile(rcaSettings.destDataDir_RCA, ['previous_rcaResults_' rcaSettings.label '_freq.mat']);
                movefile(savedFile ,matFileRCA_old, 'f');
                rcaResult = runRCA_frequency(rcaSettings, sensorData, cellNoiseData1, cellNoiseData2);
            end
            % if average data doesn't exist (older version), dd it to the
            % output
            [projAvg, subjAvg] = averageFrequencyData(rcaResult.projectedData, ...
                numel(rcaSettings.binsToUse), numel(rcaSettings.freqsToUse));
            rcaResult.projAvg = projAvg;
            rcaResult.subjAvg = subjAvg;
            
        catch err
            disp('Failed to load stored data, re-running RCA ...');
            rcaExtra_displayError(err);
            matFileRCA_old = fullfile(rcaSettings.destDataDir_RCA, ['corrupted_rcaResults_' rcaSettings.label '_freq.mat']);
            movefile(savedFile ,matFileRCA_old, 'f');
            rcaResult = runRCA_frequency(rcaSettings, sensorData, cellNoiseData1, cellNoiseData2);            
        end
    end
    
    statSettings = rcaExtra_getStatsSettings(rcaSettings);
    subjRCMean = rcaExtra_prepareDataArrayForStats(rcaResult.projectedData', statSettings);
    
    % add stats    
    statData = rcaExtra_testSignificance(subjRCMean, [], statSettings);
    try
        rcaExtra_plotRCSummary(rcaResult, statData);
    catch err
        rcaExtra_displayError(err);
    end
end
