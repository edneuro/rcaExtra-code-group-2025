inputfolder = '/Volumes/GSE/K2/separategroup_readingscore/fre_oddball_lowmiddlehigh/RCA/RCAoutput';
cd (inputfolder)

FnIn1 = 'rcaResult_Freq_WvsPF_adjustWeights_recomputeaverages.mat';

FnIn2 = 'rcaResults_Freq_WvsOLN.mat';

FnIn3 = 'rcaResult_Freq_OLNvsOIN_adjustWeights_recomputeaverages.mat';

FnIn4 = 'rcaResults_Freq_WvsPF.mat';

FnIn5 = 'rcaResults_Freq_OLNvsOIN.mat';


CurrentFnIn = FnIn3;

load (CurrentFnIn)

CurrentPhase = squeeze(out.subjAvg.phase); 
%size(out.subjAvg.phase): 4(harmonics)X6(components)X16(sub) for data trained on 1 condition
% 4(harmonics)X6(components)X2(conditions)X16(sub) for data trained on 2
% conditions, then should use CurrentPhase = squeeze(mean(out.subjAvg.phase,3));

data_location = '/Volumes/GSE/K2/excels';

reader_file = fullfile(data_location, 'combined_oddballandcarrier_allconds_allcomps_RSS.csv');
reader_data = readtable(reader_file);
    
group_l_idx = strcmp(reader_data.group3, 'l');
group_m_idx = strcmp(reader_data.group3, 'm');
group_h_idx = strcmp(reader_data.group3, 'h');
% run analysis on different groups

group_l_idx = strcmp(reader_data.group2, 'l');
group_h_idx = strcmp(reader_data.group2, 'h');

reader_data.grade = string(reader_data.grade);
group_1_idx = strcmp(reader_data.grade, '1');
group_0_idx = strcmp(reader_data.grade, '0');
group_2_idx = strcmp(reader_data.grade, '2');
    
CurrentHz = 1; %change based on harmonics frequency (e.g., 2f1 in condition 1 is 4Hz) not deviant (2Hz)

for h = 1
    ThisPhase = squeeze(CurrentPhase(h,1:3,:));
    ThisRC1Mean = circ_mean(ThisPhase(:,1));
    ThisRC2Mean = circ_mean(ThisPhase(:,2));
    
    ThisRC1Mean_k = circ_mean(ThisPhase(group_0_idx,1));
    ThisRC1Mean_1 = circ_mean(ThisPhase(group_1_idx,1));
    ThisRC1Mean_2 = circ_mean(ThisPhase(group_2_idx,1));
    
    ThisRC2Mean_k = circ_mean(ThisPhase(group_0_idx,2));
    ThisRC2Mean_1 = circ_mean(ThisPhase(group_1_idx,2));
    ThisRC2Mean_2 = circ_mean(ThisPhase(group_2_idx,2));
    
    ThisRC3Mean_k = circ_mean(ThisPhase(group_0_idx,3));
    ThisRC3Mean_1 = circ_mean(ThisPhase(group_1_idx,3));
    ThisRC3Mean_2 = circ_mean(ThisPhase(group_2_idx,3));
    
    ThisRC1Mean_l = circ_mean(ThisPhase(group_l_idx,1));
    ThisRC1Mean_m = circ_mean(ThisPhase(group_m_idx,1));
    ThisRC1Mean_h = circ_mean(ThisPhase(group_h_idx,1));
    
    ThisRC2Mean_l = circ_mean(ThisPhase(group_l_idx,2));
    ThisRC2Mean_m = circ_mean(ThisPhase(group_m_idx,2));
    ThisRC2Mean_h = circ_mean(ThisPhase(group_h_idx,2));
    
    ThisRC3Mean_l = circ_mean(ThisPhase(group_l_idx,3));
    ThisRC3Mean_m = circ_mean(ThisPhase(group_m_idx,3));
    ThisRC3Mean_h = circ_mean(ThisPhase(group_h_idx,3));
    %make subplots for phases
    figure()
    subplot(1,3,1)
    polarhistogram(ThisPhase(group_0_idx,1),8, 'DisplayStyle', 'stairs')
    rl = get(gca, 'rlim')
    hold on;
    polarplot(ThisRC1Mean_k*ones(2,1), rl, '--r')
    title('RC1/k')
    
    subplot(1,3,2)
    polarhistogram(ThisPhase(group_1_idx,1),8,'DisplayStyle', 'stairs')
    rl = get(gca, 'rlim')
    hold on;
    polarplot(ThisRC1Mean_1*ones(2,1), rl, '--r')
    title('RC1/1')
    sgtitle(CurrentFnIn,'interpreter', 'none')
    
    subplot(1,3,3)
    polarhistogram(ThisPhase(group_2_idx,1),8,'DisplayStyle', 'stairs')
    rl = get(gca, 'rlim')
    hold on;
    polarplot(ThisRC1Mean_2*ones(2,1), rl, '--r')
    title('RC1/2')
    sgtitle(CurrentFnIn,'interpreter', 'none')
    
    circ_wwtest(ThisPhase(:,1), ThisPhase(:,2));
    circ_wwtest(ThisPhase(group_0_idx,1), ThisPhase(group_1_idx,1));
    
    circ_mtest(ThisPhase(:,1) - ThisPhase(:,2), 0, 0.05);
    
    
    RCMeanDiff= ThisRC1Mean_k - ThisRC1Mean_1;
    
    rcPhaseDiffMsec = convertPhaseRadiansToLatencyMsec(RCMeanDiff, CurrentHz);
    
    rcPhaseDiffMsec + 1000/CurrentHz*[0:3]
end

