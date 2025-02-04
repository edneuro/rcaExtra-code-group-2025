clear all
close all

%% Add paths
codeFolder = '/Users/fangwang/Documents/';

addpath(genpath([codeFolder 'code/rcaBase']));
addpath(genpath([codeFolder 'code/mrC']));
addpath(genpath([codeFolder 'code/mrCurrent']));
addpath(genpath([codeFolder 'code/edNeuro-eeg-dev']));
addpath(genpath([codeFolder 'MATLAB/spm12'])); 

% Specify where data is stored, and where to save output / where RCA
% weights should be stored.
dataFolder = '/Volumes/GSE/RCAonERP/baselinecorrection/';
saveFolder = '/Volumes/GSE/RCAonERP/baselinecorrection/trainonWandS/FIG/';
weightsFolder = '/Volumes/GSE/RCAonERP/baselinecorrection/trainonWandS/RCA/';

%% Characteristics of data
samplingRate = 1000; % Hz
channels = 128; % 128 electrodes

%% RCA parameters
nReg = 7;
nComp = 5; 

%% Prepare data so in a format for running RCA / analyses
baseT.ms = [-150 0]; % Baselining to the last 100 ms of the boil period.
baseT.samples = ((baseT.ms(1)/1000)*samplingRate):((baseT.ms(2)/1000)*samplingRate); % Convert this into samples

epoch.ms = [-150, 850]; % Epochs (in ms, either side of timelock) for a) boil-locked data; b) coherence-locked data; and c) longer record of coherence-locked data, 
epoch.samples = (epoch.ms/1000)*samplingRate;

%% Find all files in folder
Files = dir([dataFolder '*baselineCorrected.mat']);


%% Prepare data for RCA: Multiple conditions

load('/Volumes/GSE/RCAonERP/baselinecorrection/Xpermute.mat')
dataIn = XpermuteN250(:,[1,2,3,4,5,6]); % 1, 2 mean W in lexical task, and S in lexical task； 3， 4 mean
                                         %W in repetition task, and S in
                                         %repetition task; 5, 6 mean W in
                                         %color task, S in color task


[OUT.rca_data, OUT.W, OUT.A, OUT.Rxx, OUT.Ryy, OUT.Rxy, OUT.dGen, OUT.plotsetting] = rcaRun(dataIn', nReg, nComp);
 
save([weightsFolder 'OUT_WandS_LRC_N250.mat'], 'OUT');
savefig([saveFolder 'WandS_LRC_N250' '.fig']);
 
% Path to .mat directory - make sure there's a slash at the end
dataDir = '/Volumes/GSE/RCAonERP/baselinecorrection/trainonWandS/RCA/';

% Name of .mat file in directory
matFn = 'OUT_WandS_C.mat';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load the .mat file
load([dataDir matFn])

%%% CALL THE FUNCTION
% If you look at the docstring of the function, you'll see it wants 4
%   inputs: dGen, Rxx, Ryy, Rxy. It returns the proportion of reliability
%   explained (a second output is the matrix rank used in the calculation,
%   but we generally don't need that).
propRelExpl = computeProportionReliabilityExplained(...,
    OUT.dGen,...
    OUT.Rxx, OUT.Ryy, OUT.Rxy);

%%% PLOT THE OUTPUT (propRelExpl and dGen)
% We can plot the output along with the dGen.
compUse = size(OUT.W, 2); % How many components are in the W matrix

figure()

% Subplot 1: dGen
subplot(1, 2, 1)
dGenSort = sort(OUT.dGen, 'descend')
plot(dGenSort(1:compUse), '*-', 'linewidth', 2);
box off; grid on;
set(gca, 'xtick', 1:compUse, 'fontsize', 16)
xlim([0 compUse+1]); ylim([0 dGenSort(1) * 1.1])
title('dGen')

% Subplot 2: Proportion reliability explained
subplot(1, 2, 2)
plot(propRelExpl(1:compUse), '*-', 'linewidth', 2);
box off; grid on
set(gca, 'xtick', 1:compUse, 'fontsize', 16)
xlim([0 compUse+1]); ylim([0 1])
title('Prop reliability explained')

% Put title over subplots, or print filename
try
    sgtitle(matFn, 'interpreter', 'none');
catch
    subplot(1, 2, 2)
    % Print .mat file name
    text(compUse+1, 0, matFn, 'interpreter', 'none',...
        'horizontalalignment', 'right', 'verticalalignment', 'bottom')
end

% Adjust figure size
fPos = get(gcf, 'Position')
set(gcf, 'Position', fPos .* [1 1 1.2 .8])


%% Load weights
load([weightsFolder 'OUT_WandS_R.mat'], 'OUT') % load adult weights
CohWeights = OUT.W;

%% Plot topographic maps and timecourse for components in adults

% if using cohOut_allTog.mat as the weights, need to flip the polarity of the components so
% that they can be compared with the adult weights in cohOut_group_4.mat
cohflipped = flipSwapRCA(OUT,[],[2]);

% data2plot = OUT;
data2plot = cohflipped;

catData1 = cat(3,data2plot.rca_data{1,:});
catData2 = cat(3,data2plot.rca_data{2,:});

catData1 = Zero2NaN(catData1, 1:3);
muData1=nanmean(catData1,3);
semData1=nanstd(catData1,[],3)/sqrt(size(catData1,3));

catData2 = Zero2NaN(catData2, 1:3);
muData2=nanmean(catData2,3);
semData2=nanstd(catData2,[],3)/sqrt(size(catData2,3));

nComp = 3;

s = ones(1,nComp);

figure()
% Topographic maps of components - Figure 2, left-most panel

for c=1:nComp
    subplot(2,2,c);
    if ~isempty(which('mrC.plotOnEgi')) % check for mrC version of plotOnEgi
        mrC.plotOnEgi(s(c).*data2plot.A(:,c),data2plot.plotsetting.colorbarLimits);
    else
        plotOnEgi(s(c).*data2plot.A(:,c),data2plot.plotsetting.colorbarLimits);
    end
    %title(['Component ' num2str(c)]);
    axis off;
end




for c=1:nComp
    subplot(2,2,c+2);
    h = shadedErrorBar([],s(c).*muData1(:,c),semData1(:,c),'k');
    
    hold on
    h = shadedErrorBar([],s(c).*muData2(:,c),semData2(:,c),'r');
    title(['RC' num2str(c) ' time course']);
    axis tight;
    xlabel('Time, ms')
    ylabel('Amplitude')
    xt = [150,300,450,600,750,900,1050];
    set(gca, 'XTick',xt, 'XTickLabel',xt-150)
    
end

for c=1:nComp
    subplot(2,2,c+2);
    h = shadedErrorBar([],s(c).*muData1_WPF(:,c),semData1_WPF(:,c),'k');
    
    hold on
    h = shadedErrorBar([],s(c).*muData1_WOLN(:,c),semData1_WOLN(:,c),'r');
    
    hold on
    h = shadedErrorBar([],s(c).*muData1_OINOLN(:,c),semData1_OINOLN(:,c),'r');
    title(['RC' num2str(c) ' time course']);
    axis tight;
    xlabel('Time, ms')
    ylabel('Amplitude')
    xt = [150,300,450,600,750,900,1050];
    set(gca, 'XTick',xt, 'XTickLabel',xt-150)
    
end
    
        
%% Plot topographic maps and timecourse for first two components of RCA that trained on all conditions together

% if using cohOut_allTog.mat as the weights, need to flip the polarity of the components so
% that they can be compared with the adult weights in cohOut_group_4.mat
load('/Volumes/GSE/RCAonERP/baselinecorrection/trainonWandS/RCA/OUT_WandS_LRC.mat')
cohflipped = flipSwapRCA(OUT,[],[2]); % need to flip second component based on the polarity of values Electrodes 65 ..

% data2plot = OUT;
data2plot = cohflipped;

catData1 = cat(3,data2plot.rca_data{1,:}); %W in L
catData2 = cat(3,data2plot.rca_data{2,:}); %S in L
catData3 = cat(3,data2plot.rca_data{3,:}); %W in R
catData4 = cat(3,data2plot.rca_data{4,:}); %S in R
catData5 = cat(3,data2plot.rca_data{5,:}); %W in C
catData6 = cat(3,data2plot.rca_data{6,:}); %S in C



catData1 = Zero2NaN(catData1, 1:3);
muData1=nanmean(catData1,3);
semData1=nanstd(catData1,[],3)/sqrt(size(catData1,3));

catData2 = Zero2NaN(catData2, 1:3);
muData2=nanmean(catData2,3);
semData2=nanstd(catData2,[],3)/sqrt(size(catData2,3));

W_S_naming_mu = muData1 - muData2;
W_S_naming_sem = (semData1 + semData2)/2;



catData3 = Zero2NaN(catData3, 1:3);
muData3=nanmean(catData3,3);
semData3=nanstd(catData3,[],3)/sqrt(size(catData3,3));

catData4 = Zero2NaN(catData4, 1:3);
muData4=nanmean(catData4,3);
semData4=nanstd(catData4,[],3)/sqrt(size(catData4,3));

W_S_repetation_mu = muData3 - muData4;
W_S_repetation_sem = (semData3 + semData4)/2;

catData5 = Zero2NaN(catData5, 1:3);
muData5=nanmean(catData5,3);
semData5=nanstd(catData5,[],3)/sqrt(size(catData5,3));

catData6 = Zero2NaN(catData6, 1:3);
muData6=nanmean(catData6,3);
semData6=nanstd(catData6,[],3)/sqrt(size(catData6,3));

W_S_color_mu = muData5 - muData6;
W_S_color_sem = (semData5 + semData6)/2;

nComp = 3;

s = ones(1,nComp);

figure()
% Topographic maps of components - Figure 2, left-most panel

for c=1:nComp
    subplot(4,3,c);
    if ~isempty(which('mrC.plotOnEgi')) % check for mrC version of plotOnEgi
        mrC.plotOnEgi(s(c).*data2plot.A(:,c),data2plot.plotsetting.colorbarLimits);
    else
        plotOnEgi(s(c).*data2plot.A(:,c),data2plot.plotsetting.colorbarLimits);
    end
    title(['RC' num2str(c)]);
    axis off;
end




for c=1:nComp
    subplot(4,3,c+3);
    h = shadedErrorBar([],s(c).*muData1(:,c),semData1(:,c),'k');
    
    hold on
    h = shadedErrorBar([],s(c).*muData2(:,c),semData2(:,c),'r');
    
    hold on
    h = shadedErrorBar([],s(c).*W_S_naming_mu(:,c),W_S_naming_sem(:,c),'g');
    
    title(['RC' num2str(c) ' time course' '(naming)']);
    axis tight;
    xlabel('Time, ms')
    ylabel('Amplitude, \muV')
%     ylim([-5 30])
    xt = [150,300,450,600,750,900,1050];
    set(gca, 'XTick',xt, 'XTickLabel',xt-150)
    
end 


for c=1:nComp
    subplot(4,3,c+6);
    h = shadedErrorBar([],s(c).*muData3(:,c),semData3(:,c),'k');
    
    hold on
    h = shadedErrorBar([],s(c).*muData4(:,c),semData4(:,c),'r');
    
    hold on
    h = shadedErrorBar([],s(c).*W_S_repetation_mu(:,c),W_S_repetation_sem(:,c),'g');
   
    title(['RC' num2str(c) ' time course' '(repetition)']);
    axis tight;
    xlabel('Time, ms')
    ylabel('Amplitude, \muV')
%     ylim([-5 30])
    xt = [150,300,450,600,750,900,1050];
    set(gca, 'XTick',xt, 'XTickLabel',xt-150)
    
end   


for c=1:nComp
    subplot(4,3,c+9);
    h = shadedErrorBar([],s(c).*muData5(:,c),semData5(:,c),'k');
    
    hold on
    h = shadedErrorBar([],s(c).*muData6(:,c),semData6(:,c),'r');
    
    hold on
    h = shadedErrorBar([],s(c).*W_S_color_mu(:,c),W_S_color_sem(:,c),'g');
    
    title(['RC' num2str(c) ' time course' '(color)']);
    axis tight;
    xlabel('Time, ms')
    ylabel('Amplitude, \muV')
%     ylim([-5 30])
    xt = [150,300,450,600,750,900,1050];
    set(gca, 'XTick',xt, 'XTickLabel',xt-150)
    
end  

subplot(4,2,3)
ylim([-5 30])
subplot(4,2,5)
ylim([-5 30])
subplot(4,2,7)
ylim([-5 30])
 %% More traditional MOVEP analysis (for comparison with component 2)

% First collect data from the electrodes of interest
ROI_movep = [50, 51, 57, 58, 59, 64, 65, 90, 91, 95, 96, 97, 100, 101]; % Niedeggen & Wist used Oz (75) and then 3 electrodes positioned 3cm laterally from here.
% I've gone for 4 nearest either side. 1:4 are to the left of Oz, 5:8 are to the right of Oz.

for s = 1:18
    for c = 1:2
        Xpermute_lexical{s,c} = Xpermute{s, c};
    end
end

for s = 1:18
    for c = 3:4
        Xpermute_repeat{s,c-2} = Xpermute{s, c};
    end
end

for s = 1:18
    for c = 5:6
        Xpermute_color{s,c-4} = Xpermute{s, c};
    end
end


% MOVEP_avg = cell(1,4);
% ERP_avg = cell(1,4);

% for group = 1:4
%     
%     clear MultiDat; clear MultiDatLong;
     groupMOVEPavg_word = [];
%     ERP_groupavg = [];
%    
%     % Load group's data - load long data record (up to 800 ms after
%     % stimulus onset)
%     filename = ['MOVEP_datInLong_group' num2str(group)];
%     disp(['Loading ' filename '...'])
%     load([saveFolder filename], 'MultiDatLong')
%     
%     % Also load short data record (up to 600 ms after stimulus onset, as
%     % this also includes trial information).
%     filename = ['MOVEP_datIn_group' num2str(group)];
%     disp(['Loading ' filename '...'])
%     load([saveFolder filename], 'MultiDat')
%     disp(['Finished loading ' filename '.'])
    
    for P = 1:length(Xpermute) % for each participant
        

        MOVEPdat_word = Xpermute_color{P,1}(:,ROI_movep,:); % select only the electrodes of interest (450 frames x 9 electrodes x trials)
        MOVEPavg_word = nanmean(MOVEPdat_word,3); % average across all trials (450 frames x 9 electrodes)
        groupMOVEPavg_word= cat(3,groupMOVEPavg_word, MOVEPavg_word); % put participant averages together for each group
        
        % For plotting topographies of all electrodes at given timepoint,
        % re: reviewer comment
%         ERPdat = MultiDatLong{1,P}(:,:,trials);
%         ERP_trialavg = nanmean(ERPdat,3);
%         ERP_groupavg = cat(3,ERP_groupavg, ERP_trialavg);
        
    end
      MOVEP_avg_word = groupMOVEPavg_word;
%     MOVEP_avg{group} = groupMOVEPavg;
%     ERP_avg{group} = ERP_groupavg;
    
% end
groupMOVEPavg_symol = [];
for P = 1:length(Xpermute) % for each participant
    
    
    MOVEPdat_symol = Xpermute_color{P,2}(:,ROI_movep,:); % select only the electrodes of interest (450 frames x 9 electrodes x trials)
    MOVEPavg_symol = nanmean(MOVEPdat_symol,3); % average across all trials (450 frames x 9 electrodes)
    groupMOVEPavg_symol= cat(3,groupMOVEPavg_symol, MOVEPavg_symol); % put participant averages together for each group
    
    % For plotting topographies of all electrodes at given timepoint,
    % re: reviewer comment
    %         ERPdat = MultiDatLong{1,P}(:,:,trials);
    %         ERP_trialavg = nanmean(ERPdat,3);
    %         ERP_groupavg = cat(3,ERP_groupavg, ERP_trialavg);
    
end
      MOVEP_avg_symbol = groupMOVEPavg_symol;
      
save([saveFolder 'StimLocked_ERP_ROIdat.mat'], 'MOVEPavg');
% save([saveFolder 'StimLocked_ERP_allelectordes.mat'], 'ERP_avg');


%% FIGURE 5: Plot motion onset VEP averaged across electrodes + averaged component 2 waveform for coherence = 4 

% load RCA output if not already in workspace)
load([saveFolder 'CohData_ByGroupByCoh.mat']);
CohData = CohDataLong;
load([weightsFolder 'cohOut_group_4.mat'], 'coh')
data2plot = cohflipped;

% Plot topography of component 2, and overlay the electrodes of interest
% for the MOVEP analysis (leftmost panel of Figure 5)
s = ones(1,nComp);
data2plot.A = data2plot.A * (-1);

figure()
mrC.plotOnEgi(s(1).*data2plot.A(:,2),data2plot.plotsetting.colorbarLimits, [], ROI_movep);


figure() % for right panels of Figure 5
for group = 1:4
    
    subplot(1,4,group)
    title(legendnames(group))
    if group == 1
        ylabel('amplitude (?V)')
    end
    
    hold on
    
    % First plot MOVEP data
    
%     summation = 0;
%     for s= 1:length(MOVEPavg)
        elecavg_word = squeeze(nanmean(MOVEP_avg_word,2)); % average over electrodes
        elecavg_symbol = squeeze(nanmean(MOVEP_avg_symbol,2));
%         summation = summation + elecavg{s,1}; % Add next matrix element
%         muData_movep = summation/length(MOVEPavg); % then average over participants
        muData_movep_word = nanmean(elecavg_word,2); % then average over participants to get a group average
       
        semData_movep_word = nanstd(elecavg_word,[],2)/sqrt(size(elecavg_word,2)); % and get SEM  
        
        muData_movep_symbol = nanmean(elecavg_symbol,2); % then average over participants to get a group average
       
        semData_movep_symbol = nanstd(elecavg_symbol,[],2)/sqrt(size(elecavg_symbol,2)); % and get SEM  
        
        h = shadedErrorBar([], muData_movep_word, semData_movep_word, {'Color', [0.5,0,0.5]}, 1);
        hold on
        h = shadedErrorBar([], muData_movep_symbol, semData_movep_symbol, {'Color', [0.5,0,0.5], 'LineStyle','--'}, 1);
%         h.mainLine.DisplayName = legendnames{group};
        
        % Then overlap component 2 data 
        groupData_comp2avg_word = [];
        
        for s = 1:18
        Data_comp2_word = OUT.rca_data{1,s}(:,2,:);% select only the electrodes of interest (450 frames x 9 electrodes x trials)
          Data_comp2_word = Data_comp2_word * (-1);
        
        Data_comp2avg_word = nanmean(Data_comp2_word,3); % average across all trials (450 frames x 9 electrodes)
        groupData_comp2avg_word= cat(3,groupData_comp2avg_word, Data_comp2avg_word); 
        
        end
    
        muData_comp2_word = squeeze(nanmean(groupData_comp2avg_word,3));
        
        semData_comp2_word = nanstd(groupData_comp2avg_word,[],3)/sqrt(size(groupData_comp2avg_word,3)); % get SEM over participants
        h = shadedErrorBar([], muData_comp2_word, semData_comp2_word, 'k', 1);
        
        
        groupData_comp2avg_symbol = [];
        
        for s = 1:18
        Data_comp2_symbol = OUT.rca_data{2,s}(:,2,:);% select only the electrodes of interest (450 frames x 9 electrodes x trials)
          Data_comp2_symbol = Data_comp2_symbol * (-1);
        
        Data_comp2avg_symbol = nanmean(Data_comp2_symbol,3); % average across all trials (450 frames x 9 electrodes)
        groupData_comp2avg_symbol= cat(3,groupData_comp2avg_symbol, Data_comp2avg_symbol); 
        
        end
    
        muData_comp2_symbol = squeeze(nanmean(groupData_comp2avg_symbol,3));
        
        semData_comp2_symbol = nanstd(groupData_comp2avg_symbol,[],3)/sqrt(size(groupData_comp2avg_symbol,3)); % get SEM over participants
        h = shadedErrorBar([], muData_comp2_symbol, semData_comp2_symbol, '--k', 1);
        xt = [150,300,450,600,750,900,1050];
        set(gca, 'XTick',xt, 'XTickLabel',xt-150)
                
                
        xlim([0 450])
        ylim([-16 8])
        line(repmat(timelock,25,1), -16:1:8, 'Color', [0,0,0])
        line(0:50:450, repmat(0,10,1), 'Color', [0,0,0])
        
        set(gca, 'XTick', 50:100:450)
        set(gca, 'XTickLabel', labels_long)
%     end
end

savefig([saveFolder 'MOVEP_Group.fig']);
print([saveFolder 'MOVEP_Group'], '-dpng');

% Calculate correlation coefficient between group average waveforms
[R,P,RL,RU] = corrcoef(muData_movep, muData_comp2);