function corr_matrix_A
% Correlating matrix of A values to compare output RCA topographies 
% Source of plotMatrix - https://github.com/berneezy3/MatClassRSA/blob/master/src/Visualization/plotMatrix.m

   % Getting the A topographies
    datalocation = '/Volumes/Backup Plus/Synapse_MiddleSchool/B_Output_FreqDomain_10bin_freq369/INCLUDED_SUBJECTS_TOWRE_Low/';
    load(strcat(datalocation,'RCA/rcaResults_Freq_Condition 1.mat'));
    cond1_A = rcaResult.A;
    
    load(strcat(datalocation,'RCA/rcaResults_Freq_Condition 2.mat'));
    cond2_A = rcaResult.A;
    
    load(strcat(datalocation,'RCA/rcaResults_Freq_Condition 3.mat'));
    cond3_A = rcaResult.A;
    
    load(strcat(datalocation,'RCA/rcaResults_Freq_Conditions12.mat'));
    cond12_A = rcaResult.A;
    
    load(strcat(datalocation,'RCA/rcaResults_Freq_Conditions123.mat'));
    cond123_A = rcaResult.A;
    
    A = [cond1_A,cond2_A,cond3_A,cond12_A,cond123_A];
    
    [R,P] = corrcoef(A,'Rows','pairwise'); %getting the correlation coefficient

    % Plotting correlation matrix.
    % You can also change the colormap
    % Note that I'm plotting the absolute value of A. 
    
    correlation_matrix_A = figure
    subplot(1,3,1);
    plotMatrix(abs(R(1:6,19:24)), 'matrixLabels', 1, 'fontsize', 10,'colorBar',1);
    xlabel('Cond 1'); ylabel('Cond 4')
    
    subplot(1,3,2);
    plotMatrix(abs(R(7:12,19:24)), 'matrixLabels', 1, 'fontsize', 10,'colorBar',1);
    xlabel('Cond 2'); ylabel('Cond 4');
    
    subplot(1,3,3);
    plotMatrix(abs(R(13:18,19:24)), 'matrixLabels', 1, 'fontsize', 10,'colorBar',1);
    xlabel('Cond 3'); ylabel('Cond 4');
    
    subplot(1,4,4);
    plotMatrix(abs(R(1:6,19:24)), 'matrixLabels', 1, 'fontsize', 10,'colorBar',1);
    xlabel('Cond 1'); ylabel('Cond 4')
    
    subplot(3,3,5);
    plotMatrix(abs(R(1:6,25:30)), 'matrixLabels', 1, 'fontsize', 10,'colorBar',1);
    xlabel('Cond 123'); ylabel('Cond 1')
    
    subplot(3,3,6);
    plotMatrix(abs(R(7:12,19:24)), 'matrixLabels', 1, 'fontsize', 10,'colorBar',1);
    xlabel('Cond 12'); ylabel('Cond 2')
    
    subplot(3,3,7);
    plotMatrix(abs(R(7:12,25:30)), 'matrixLabels', 1, 'fontsize', 10,'colorBar',1);
    xlabel('Cond 123'); ylabel('Cond 2');
    
    subplot(3,3,8);
    plotMatrix(abs(R(13:18,19:24)), 'matrixLabels', 1, 'fontsize', 10,'colorBar',1);
    xlabel('Cond 12'); ylabel('Cond 3');
    
    subplot(3,3,9);
    plotMatrix(abs(R(13:18,25:30)), 'matrixLabels', 1, 'fontsize', 10,'colorBar',1);
    xlabel('Cond 123'); ylabel('Cond 3');
    
    saveas(correlation_matrix_A,strcat(datalocation,'FIG/correlation_matrix_A.fig'))

    % Plotting p-value.
    
    correlation_matrix_Pvalue = figure
    subplot(3,3,1);
    plotMatrix(abs(P(1:6,7:12)), 'matrixLabels', 1, 'fontsize', 10,'colorBar',1);
    xlabel('Cond 2'); ylabel('Cond 1')
    
    subplot(3,3,2);
    plotMatrix(abs(P(1:6,13:18)), 'matrixLabels', 1, 'fontsize', 10,'colorBar',1);
    xlabel('Cond 3'); ylabel('Cond 1');
    
    subplot(3,3,3);
    plotMatrix(abs(P(7:12,13:18)), 'matrixLabels', 1, 'fontsize', 10,'colorBar',1);
    xlabel('Cond 3'); ylabel('Cond 2');
    
    subplot(3,3,4);
    plotMatrix(abs(P(1:6,19:24)), 'matrixLabels', 1, 'fontsize', 10,'colorBar',1);
    xlabel('Cond 12'); ylabel('Cond 1')
    
    subplot(3,3,5);
    plotMatrix(abs(P(1:6,25:30)), 'matrixLabels', 1, 'fontsize', 10,'colorBar',1);
    xlabel('Cond 123'); ylabel('Cond 1')
    
    subplot(3,3,6);
    plotMatrix(abs(P(7:12,19:24)), 'matrixLabels', 1, 'fontsize', 10,'colorBar',1);
    xlabel('Cond 12'); ylabel('Cond 2')
    
    subplot(3,3,7);
    plotMatrix(abs(P(7:12,25:30)), 'matrixLabels', 1, 'fontsize', 10,'colorBar',1);
    xlabel('Cond 123'); ylabel('Cond 2');
    
    subplot(3,3,8);
    plotMatrix(abs(P(13:18,19:24)), 'matrixLabels', 1, 'fontsize', 10,'colorBar',1);
    xlabel('Cond 12'); ylabel('Cond 3');
    
    subplot(3,3,9);
    plotMatrix(abs(P(13:18,25:30)), 'matrixLabels', 1, 'fontsize', 10,'colorBar',1);
    xlabel('Cond 123'); ylabel('Cond 3');
    
    saveas(correlation_matrix_Pvalue,strcat(datalocation,'FIG/correlation_matrix_Pvalue.fig'))

end

