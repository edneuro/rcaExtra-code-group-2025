function legend_handle = customErrPlot(currAxisHandle, timecourse, muVar, ...
    errVar, clr, descr, lineSpec)

% 
    axes(currAxisHandle);
    
    title(descr, 'FontSize', 30, 'Interpreter', 'none');
    muVar = muVar*1e06;
    errVar = errVar*1e06;
    h = shadedErrorBar(timecourse, muVar, errVar, ...
        {'Color', clr, 'LineWidth', 4, 'linestyle', lineSpec}); hold on;
    legend_handle = h.mainLine;    
end