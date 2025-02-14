function [groupcondition_Bars, groupcondition_Lolliplots] = plotGroupsConditions_freq(f, cndLabels, groupLabels, varargin)

%% INPUT:
    % varargin -- proj groups + labels: {group1, group2, groupLabels, conditionLabels, componentLabels}
    % Each group is a structure with following elements: 
    % groupX.amp = values amp, 
    % groupX.phase = values phase, 
    % groupX.EllipseError = error ellipses
    % groupX.stats -- values for statistical info (computed between conditions and between groups)  
    
    % groupX = {Values(nCnd x nComp x nFreq) Errors (nCnd x nComp x nFreq)}
    
    nConditions = numel(cndLabels);
    nGroups = numel(groupLabels);
    
    groupcondition_Bars = cell(1, nConditions);
    groupcondition_Lolliplots = cell(1, nConditions);
    
    groups = varargin;
    
    plotSettings = getOnOffPlotSettings('groupsconditions', 'Frequency');    
            
    close all;   
    nComp = 1; % taking out the OZ, todo -- add as argument
    
    for nc = 1:nConditions
        % amplitude and frequency
        nSubplots_Col = 2;
        nSubplots_Row = nComp;
        
        colorSettings = plotSettings.colors(:, :, nc);
    
        groupcondition_Bars{nc} = figure;
        set(groupcondition_Bars{nc}, 'units', 'normalized', 'outerposition', [0 0 1 1]);
    
        amplitudes = subplot(nSubplots_Row, nSubplots_Col, 1, 'Parent', groupcondition_Bars{nc});
        latencies = subplot(nSubplots_Row, nSubplots_Col, 2, 'Parent', groupcondition_Bars{nc});
    
        groupcondition_Lolliplots{nc} = figure;
        set(groupcondition_Lolliplots{nc}, 'units', 'normalized', 'outerposition', [0 0 1 1]);

        cp = 1; %RC's
 
        %% concat bars for amplitude plot   
        groupCndAmp_cell = cellfun(@(x) squeeze(x.amp(:, cp, nc)), groups, 'uni', false);
        groupCndAmpErrs_cell = cellfun(@(x) squeeze(x.errA(:, cp, nc, :)), groups, 'uni', false);
    
        groupCndAmp = cat(2, groupCndAmp_cell{:});
        groupCndAmpErrs = cat(3, groupCndAmpErrs_cell{:});
        % plot all bars first
        freqplotBar(amplitudes, groupCndAmp, permute(groupCndAmpErrs, [1 3 2]), colorSettings, groupLabels);
        set(amplitudes, plotSettings.axesprops{:});
        pbaspect(amplitudes, [1 1 1]);    

    
        %% concat frequency for latency plot
        groupLat_cell = cellfun(@(x) squeeze(x.phase(:, cp, nc)), groups, 'uni', false);
        groupLatErrs_cell = cellfun(@(x) squeeze(x.errP(:, cp, nc, :)), groups, 'uni', false);
       
        groupAngles_raw = cat(2, groupLat_cell{:});
        groupAngles = unwrap(groupAngles_raw); 
    
        groupAnglesErrs = cat(3, groupLatErrs_cell{:});
    
        freqPlotLatency(latencies, groupAngles, permute(groupAnglesErrs, [1 3 2]), colorSettings, groupLabels, f);    
        set(latencies, plotSettings.axesprops{:});
        pbaspect(latencies, [1 1 1]);
    
        % lolliplots
        nFreq = size(groupAngles, 1);
        ax = cell(1, nFreq);
        legendRef = cell(1, nGroups);
        freqLabels = cellfun( @(x) strcat('F', num2str(x)), num2cell(1:1:nFreq), 'uni', false);
    
    
        for nf = 1:nFreq        
            ax{nf} = subplot(nSubplots_Row, nFreq, nf, 'Parent', groupcondition_Lolliplots{nc});
            axes(ax{nf}); 
        
            for ng = 1:nGroups
                colorGroup = colorSettings(ng, :);            
                groupstyle = plotSettings.linestyles{ng};

                alpha = groupAngles(nf, ng);
                L = groupCndAmp(nf, ng);
                try
                    ellipseCalc = groups{ng}.ellipseErr{1};
                catch
                    ellipseCalc = currGroupProj.err;
                end
                x = L.*cos(alpha);
                y = L.*sin(alpha);
                e_x = 0;
                e_y = 0;
                try
                    e0 = ellipseCalc{nf, cp};
                catch
                    
                    e0 = ellipseCalc(nf);
                end
                if (~isempty(e0))
                    e_x = e0(:, 1) + x;
                    e_y = e0(:, 2) + y;
                end
                props = { 'linewidth', 8, 'color', colorGroup, 'linestyle', groupstyle};             
                patchSaturation = 0.5;
                patchColor =  colorGroup + (1 - colorGroup)*(1 - patchSaturation);
                errLine = line(e_x, e_y, 'LineWidth', 5); hold on;
                set(errLine,'color', patchColor);
                legendRef{ng} = plot(ax{nf}, [0, x], [0, y], props{:}); hold on;
            end
            % font size
            %linkaxes([ax{1}, ax{nf}],'xy');
            setAxisAtTheOrigin(ax{nf});
            set(ax{nf}, plotSettings.axesprops{:});
        
            descr = [cndLabels(nc) freqLabels{nf}];
            legend([legendRef{:}], groupLabels(:));
            title(descr, 'Interpreter', 'none');
        end
    end
end
