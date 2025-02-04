function corr_matrix_A_splithalf
% Correlating matrix of A values to compare output RCA topographies 
% Source of plotMatrix - https://github.com/berneezy3/MatClassRSA/blob/master/src/Visualization/plotMatrix.m

   % Getting the A topographies
    datalocation = '/Volumes/Backup Plus/Synapse_MiddleSchool/B_Output_FreqDomain_10bin_freq369/';
    load(strcat(datalocation,'INCLUDED_SUBJECTS_TOWRE_Low/ReshapedTrialstoBins/RCA/rcaResults_Freq_Condition 1.mat'));
    A_lowTOWRE_cond1_RC2 = rcaResult.A(:,2);
    A_lowTOWRE_cond1_RC3 = rcaResult.A(:,3);

    load(strcat(datalocation,'INCLUDED_SUBJECTS_TOWRE_Low/ReshapedTrialstoBins/RCA/rcaResults_Freq_Condition 2.mat'));
    A_lowTOWRE_cond2_RC2 = rcaResult.A(:,2);
    A_lowTOWRE_cond2_RC3 = rcaResult.A(:,3);
    
    load(strcat(datalocation,'INCLUDED_SUBJECTS_TOWRE_Low/ReshapedTrialstoBins/RCA/rcaResults_Freq_Condition 3.mat'));
    A_lowTOWRE_cond3_RC2 = rcaResult.A(:,2);
    A_lowTOWRE_cond3_RC3 = rcaResult.A(:,3);
    
    load(strcat(datalocation,'INCLUDED_SUBJECTS_TOWRE_Low/ReshapedTrialstoBins/RCA/rcaResults_Freq_Conditions123.mat'));
    A_lowTOWRE_cond123_RC2 = rcaResult.A(:,2);
    A_lowTOWRE_cond123_RC3 = rcaResult.A(:,3);
    
    load(strcat(datalocation,'INCLUDED_SUBJECTS_TOWRE_High/ReshapedTrialstoBins/RCA/rcaResults_Freq_Condition 1.mat'));
    A_highTOWRE_cond1_RC2 = rcaResult.A(:,2);
    A_highTOWRE_cond1_RC3 = rcaResult.A(:,3);
    
    load(strcat(datalocation,'INCLUDED_SUBJECTS_TOWRE_High/ReshapedTrialstoBins/RCA/rcaResults_Freq_Condition 2.mat'));
    A_highTOWRE_cond2_RC2 = rcaResult.A(:,2);
    A_highTOWRE_cond2_RC3 = rcaResult.A(:,3);
    
    load(strcat(datalocation,'INCLUDED_SUBJECTS_TOWRE_High/ReshapedTrialstoBins/RCA/rcaResults_Freq_Condition 3.mat'));
    A_highTOWRE_cond3_RC2 = rcaResult.A(:,2);
    A_highTOWRE_cond3_RC3 = rcaResult.A(:,3);
    
    load(strcat(datalocation,'INCLUDED_SUBJECTS_TOWRE_High/ReshapedTrialstoBins/RCA/rcaResults_Freq_Conditions123.mat'));
    A_highTOWRE_cond123_RC2 = rcaResult.A(:,2);
    A_highTOWRE_cond123_RC3 = rcaResult.A(:,3);

    load(strcat(datalocation,'INCLUDED_SUBJECTS/ReshapedTrialstoBins/RCA/rcResultStruct_byCondition.mat'));
    A_cond1_RC2 = rcResultStruct_byCondition{1}.A(:,2);
    A_cond1_RC3 = rcResultStruct_byCondition{1}.A(:,3);
    
    A_cond2_RC2 = rcResultStruct_byCondition{2}.A(:,2);
    A_cond2_RC3 = rcResultStruct_byCondition{2}.A(:,3);
    
    A_cond3_RC2 = rcResultStruct_byCondition{3}.A(:,2);
    A_cond3_RC3 = rcResultStruct_byCondition{3}.A(:,3);
    
    load(strcat(datalocation,'INCLUDED_SUBJECTS/ReshapedTrialstoBins/RCA/rcResultStruct_cnd_123.mat'));
    A_cond123_RC2 = rcResultStruct_cnd_123.A(:,2);
    A_cond123_RC3 = rcResultStruct_cnd_123.A(:,3);


    A_RC2 = [A_cond123_RC2,A_cond1_RC2,A_cond2_RC2,A_cond3_RC2,...
        A_highTOWRE_cond1_RC2,A_highTOWRE_cond2_RC2,A_highTOWRE_cond3_RC2,A_highTOWRE_cond123_RC2,...
        A_lowTOWRE_cond1_RC2,A_lowTOWRE_cond2_RC2,A_lowTOWRE_cond3_RC2,A_lowTOWRE_cond123_RC2];
    
    A_RC3 = [A_cond123_RC3,A_cond1_RC3,A_cond2_RC3,A_cond3_RC3,...
        A_highTOWRE_cond1_RC3,A_highTOWRE_cond2_RC3,A_highTOWRE_cond3_RC3,A_highTOWRE_cond123_RC3,...
        A_lowTOWRE_cond1_RC3,A_lowTOWRE_cond2_RC3,A_lowTOWRE_cond3_RC3,A_lowTOWRE_cond123_RC3];

    A_RC_mix = [A_cond123_RC2,A_cond1_RC2,A_cond2_RC2,A_cond3_RC2,...
        A_highTOWRE_cond1_RC3,A_highTOWRE_cond2_RC3,A_highTOWRE_cond3_RC2,A_highTOWRE_cond123_RC2,...
        A_lowTOWRE_cond1_RC2,A_lowTOWRE_cond2_RC2,A_lowTOWRE_cond3_RC3,A_lowTOWRE_cond123_RC2];

   
    [R2,~] = corrcoef(A_RC2,'Rows','pairwise'); %getting the correlation coefficient
    [R3,~] = corrcoef(A_RC3,'Rows','pairwise'); %getting the correlation coefficient
    [Rmix,~] = corrcoef(A_RC_mix,'Rows','pairwise'); %getting the correlation coefficient

    % Plotting correlation matrix.
    % You can also change the colormap
    % Note that I'm plotting the absolute value of A. 
    
    correlation_matrix_A = figure
    plotMatrix(abs(R), 'matrixLabels', 1, 'fontsize', 10,'colorBar',1);
    saveas(correlation_matrix_A,strcat(datalocation,'INCLUDED_SUBJECTS_TOWRE_High/FIG/correlation_matrix_A_RC1.fig'))

end

