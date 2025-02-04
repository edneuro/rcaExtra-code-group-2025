function test_plot_SignificantLatencies


    load('~/Downloads/rcResultStruct_cnd_123_HIGH.mat');
    load('~/Downloads/rcResultStruct_cnd_123_LOW.mat');

    % results stored in 
    % rcResultStruct_cnd_123_HIGH
    % rcResultStruct_cnd_123_LOW

%     also need axis labels(!)

%     plotContainerStruct.rcaData = rcaData;
%     % generate default 
%     plotContainerStruct.conditionLabels = {}; % condition labels
%     plotContainerStruct.dataLabel = {};  % group label
%     
%     plotContainerStruct.conditionColors = [];
%     plotContainerStruct.conditionMarkers = {};
%     plotContainerStruct.markerStyles = {};
%     plotContainerStruct.markerSize = 12;
%     plotContainerStruct.lineStytles = {};
%     plotContainerStruct.LineWidths = 2;
% 
    % transpose data
    rcResultStruct_cnd_123_HIGH.projectedData = rcResultStruct_cnd_123_HIGH.projectedData';
    rcResultStruct_cnd_123_LOW.projectedData = rcResultStruct_cnd_123_LOW.projectedData';
    
    
    
    cnd123_high = rcaExtra_computeAverages(rcResultStruct_cnd_123_HIGH);
    cnd123_low = rcaExtra_computeAverages(rcResultStruct_cnd_123_LOW);
    
    % to get Con1, Con2, and Con3, need to duplicate the original
    % rcResultStruct_cnd_123 (load in to workspace first if already
    % have),and then delete the corresponsing collumn in projectedData
    Con1_recompute = rcaExtra_computeAverages(Con1);
    Con2_recompute = rcaExtra_computeAverages(Con2);
    Con3_recompute = rcaExtra_computeAverages(Con3);
    
    plotContainerStruct_HIGH = rcaExtra_addPlotOptionsToData(cnd123_high.projAvg);
    plotContainerStruct_LOW = rcaExtra_addPlotOptionsToData(cnd123_low.projAvg);

    plotContainerStruct_Con1 = rcaExtra_addPlotOptionsToData(Con1_recompute.projAvg);
    plotContainerStruct_Con2 = rcaExtra_addPlotOptionsToData(Con2_recompute.projAvg);
    plotContainerStruct_Con3 = rcaExtra_addPlotOptionsToData(Con3_recompute.projAvg);
    
    % add stats
    plotContainerStruct_HIGH.statData = rcaExtra_runStatsAnalysis(cnd123_high, []);
    plotContainerStruct_LOW.statData = rcaExtra_runStatsAnalysis(cnd123_low, []);
    
    plotContainerStruct_Con1.statData = rcaExtra_runStatsAnalysis(Con1_recompute, []);
    plotContainerStruct_Con2.statData = rcaExtra_runStatsAnalysis(Con2_recompute, []);
    plotContainerStruct_Con2.statData = rcaExtra_runStatsAnalysis(Con3_recompute, []);
    
    freqIdx = cellfun(@(x) str2double(x(1)), cnd123_high.rcaSettings.useFrequencies, 'uni', true);
    freqVals = cnd123_high.rcaSettings.useFrequenciesHz*freqIdx;
    
    freqIdx = cellfun(@(x) str2double(x(1)), Con1.rcaSettings.useFrequencies, 'uni', true);
    freqVals = Con1.rcaSettings.useFrequenciesHz*freqIdx;
    xLabel = arrayfun( @(x) strcat(num2str(x), 'Hz'), freqVals, 'uni', false);
    yLabel = 'Phase (Radians)';
    % specify plotting styles data for each container
    
    plotContainerStruct_HIGH.xDataLabel = xLabel;
    plotContainerStruct_HIGH.yDataLabel = yLabel;
    
    plotContainerStruct_Con1.xDataLabel = xLabel;
    plotContainerStruct_Con1.yDataLabel = yLabel;
    
    rcsToPlot = [1 2 3];
    cndsToPlot = [1];
    
    % specify plotting styles data for each container    
    plotContainerStruct_HIGH.rcsToPlot = rcsToPlot;
    plotContainerStruct_HIGH.cndsToPlot = cndsToPlot;    
    plotContainerStruct_HIGH.conditionLabels = {'Faces', 'Not Faces'};
    plotContainerStruct_HIGH.dataLabel = {'High Readers'};
    plotContainerStruct_HIGH.conditionColors = [0.65, 0.65, 0.65; 0.15, 0.15, 0.15];
    plotContainerStruct_HIGH.conditionMarkers = {'v', 'd'};
    plotContainerStruct_HIGH.markerStyles = {'filled', 'filled'};
    plotContainerStruct_HIGH.markerSize = 12;
    plotContainerStruct_HIGH.lineStytles = {'-', '-'};
    plotContainerStruct_HIGH.LineWidths = 2;
    plotContainerStruct_HIGH.significanceSaturation = 0.15;
    plotContainerStruct_HIGH.patchSaturation = 0.15;
    
     plotContainerStruct_Con1.rcsToPlot = rcsToPlot;
    plotContainerStruct_Con1.cndsToPlot = cndsToPlot;    
    plotContainerStruct_Con1.conditionLabels = {'Faces', 'Not Faces'};
    plotContainerStruct_Con1.dataLabel = {'High Readers'};
    plotContainerStruct_Con1.conditionColors = [0.65, 0.65, 0.65; 0.15, 0.15, 0.15];
    plotContainerStruct_Con1.conditionMarkers = {'v', 'd'};
    plotContainerStruct_Con1.markerStyles = {'filled', 'filled'};
    plotContainerStruct_Con1.markerSize = 12;
    plotContainerStruct_Con1.lineStytles = {'-', '-'};
    plotContainerStruct_Con1.LineWidths = 2;
    plotContainerStruct_Con1.significanceSaturation = 0.15;
    plotContainerStruct_Con1.patchSaturation = 0.15;
    % 'MarkerFaceColor' for filled
    plotContainerStruct_LOW.xDataLabel = xLabel;
    plotContainerStruct_LOW.yDataLabel = yLabel;

    plotContainerStruct_LOW.rcsToPlot = rcsToPlot;
    plotContainerStruct_LOW.cndsToPlot = cndsToPlot;    
    plotContainerStruct_LOW.conditionLabels = {'Faces', 'Not Faces'};
    plotContainerStruct_LOW.dataLabel = {'Low Readers'};
    plotContainerStruct_LOW.conditionColors = [0.65, 0.5, 0.15; 0.35, 0.45, 0.45];
    plotContainerStruct_LOW.conditionMarkers = {'v', 'd'};
    plotContainerStruct_LOW.markerStyles = {'open', 'open'};
    plotContainerStruct_LOW.markerSize = 12;
    plotContainerStruct_LOW.lineStytles = {'-', '-'};
    plotContainerStruct_LOW.LineWidths = 2;
    plotContainerStruct_LOW.significanceSaturation = 0.15;
    plotContainerStruct_LOW.patchSaturation = 0.15;
    
     plotContainerStruct_Con2.xDataLabel = xLabel;
    plotContainerStruct_Con2.yDataLabel = yLabel;

    plotContainerStruct_Con2.rcsToPlot = rcsToPlot;
    plotContainerStruct_Con2.cndsToPlot = cndsToPlot;    
    plotContainerStruct_Con2.conditionLabels = {'Faces', 'Not Faces'};
    plotContainerStruct_Con2.dataLabel = {'Low Readers'};
    plotContainerStruct_Con2.conditionColors = [0.65, 0.5, 0.15; 0.35, 0.45, 0.45];
    plotContainerStruct_Con2.conditionMarkers = {'v', 'd'};
    plotContainerStruct_Con2.markerStyles = {'open', 'open'};
    plotContainerStruct_Con2.markerSize = 12;
    plotContainerStruct_Con2.lineStytles = {'-', '-'};
    plotContainerStruct_Con2.LineWidths = 2;
    plotContainerStruct_Con2.significanceSaturation = 0.15;
    plotContainerStruct_Con2.patchSaturation = 0.15;
    
    
     plotContainerStruct_Con3.xDataLabel = xLabel;
    plotContainerStruct_Con3.yDataLabel = yLabel;

    plotContainerStruct_Con3.rcsToPlot = rcsToPlot;
    plotContainerStruct_Con3.cndsToPlot = cndsToPlot;    
    plotContainerStruct_Con3.conditionLabels = {'Faces', 'Not Faces'};
    plotContainerStruct_Con3.dataLabel = {'Low Readers'};
    plotContainerStruct_Con3.conditionColors = [0.65, 0.5, 0.15; 0.35, 0.45, 0.45];
    plotContainerStruct_Con3.conditionMarkers = {'v', 'd'};
    plotContainerStruct_Con3.markerStyles = {'open', 'open'};
    plotContainerStruct_Con3.markerSize = 12;
    plotContainerStruct_Con3.lineStytles = {'-', '-'};
    plotContainerStruct_Con3.LineWidths = 2;
    plotContainerStruct_Con3.significanceSaturation = 0.15;
    plotContainerStruct_Con3.patchSaturation = 0.15;
    
    % plot individual (conditions together)
    % plot Latency
    
    out = rcaExtra_plotSignificantLatencies(plotContainerStruct_LOW, plotContainerStruct_HIGH);  
    
    out = rcaExtra_plotSignificantLatencies(plotContainerStruct_Con1, plotContainerStruct_Con2);  
    
    out = rcaExtra_plotSignificantLatencies(plotContainerStruct_Con1, plotContainerStruct_Con2, plotContainerStruct_Con3);  
    % Amplitude
%     out = rcaExtra_plotSignificantAmplitudes(plotContainerStruct_LOW, plotContainerStruct_HIGH);    
%     statsBetween = rcaExtra_runStatsAnalysis(cnd123_high, cnd123_low);
%     % add between-stats
%     
%     
%     
%     for nc = 1:numel(cndsToPlot)
%         nc0 = cndsToPlot(nc);
%         for rc = 1:numel(rcsToPlot)
%             rc0 = rcsToPlot(rc);
%             figHandle = out{rc, nc};
%             currAxisHandle = get(figHandle, 'CurrentAxes');
%             plot_addStatsBar_freq(currAxisHandle, statsBetween.pValues(:, rc0, nc0), ...
%                 freqVals');
%         end
%     end
        
    
    
    
    
    % plot Lolliplots
end



