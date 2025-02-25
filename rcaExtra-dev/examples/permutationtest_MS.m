clear all;

 git_folder = '/Users/fangwang/Documents/code';

addpath(genpath(fullfile(git_folder, 'svndl_code')),'-end');
addpath(genpath(fullfile(git_folder, 'rcaExtra_dev')),'-end');
%addpath(genpath(fullfile(git_folder, 'rcaExtra_main')),'-end');
addpath(genpath(fullfile(git_folder, 'rcaExtra-dev_fang')),'-end');
addpath(genpath(fullfile(git_folder, 'mrC')),'-end');
addpath(genpath(fullfile(git_folder, 'rcaBase')),'-end');
addpath(genpath(fullfile(git_folder, 'edNeuro-eeg-dev')),'-end');
addpath(genpath(fullfile(git_folder, 'BKanMatEEGToolbox')),'-end');


% Define the main folder and output folder
main_folder = '/Users/fangwang/Dropbox (Personal)/2019_MiddleSchool';
output_folder = '/Users/fangwang/Dropbox (Personal)/Filtered_MiddleSchool';

% Create the output folder if it doesn't exist
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Get a list of all BLC_# folders in the main folder
blc_folders = dir(fullfile(main_folder, 'BLC_*'));

% Iterate through each BLC_# folder
for i = 1:length(blc_folders)
    blc_folder = blc_folders(i);
    
    % Skip if not a folder
    if ~blc_folder.isdir
        continue;
    end
    
    % Full path to the BLC_# folder
    blc_path = fullfile(main_folder, blc_folder.name);
    
    % Get a list of all subfolders in the current BLC_# folder
    subfolders = dir(blc_path);
    
    for j = 1:length(subfolders)
        subfolder = subfolders(j);
        
        % Check if the subfolder ends with 'EEGSsn'
        if subfolder.isdir && endsWith(subfolder.name, 'EEGSsn')
            eegssn_path = fullfile(blc_path, subfolder.name);
            
            % Check for the required folders inside the EEGSsn folder
            target_folders = {'Exp_MATL_HCN_128_Avg', 'Exp_TEXT_HCN_128_Avg'};
            for k = 1:length(target_folders)
                target_folder = target_folders{k};
                source_path = fullfile(eegssn_path, target_folder);
                
                % If the folder exists, copy it to the new structure
                if exist(source_path, 'dir')
                    dest_path = fullfile(output_folder, blc_folder.name, target_folder);
                    % Create destination folder if it doesn't exist
                    if ~exist(dest_path, 'dir')
                        mkdir(dest_path);
                    end
                    % Copy folder contents
                    copyfile(source_path, dest_path);
                    
                    % Delete specific files if in Exp_TEXT_HCN_128_Avg
                    if strcmp(target_folder, 'Exp_TEXT_HCN_128_Avg')
                        files_to_delete = {'sourceData_DFT.mat', 'sourceData_RLS.mat'};
                        for f = 1:length(files_to_delete)
                            file_to_delete = fullfile(dest_path, files_to_delete{f});
                            if exist(file_to_delete, 'file')
                                delete(file_to_delete);
                            end
                        end
                    end
                end
            end
        end
    end
end


disp('Filtering complete. Data is saved in the output folder.');

% Compute and store RCA for however many iteration indices
for i = 201:500
    
    doPerm = 1;
    saveOutput =1;
        
        sourcepath = '/Users/fangwang/Dropbox (Personal)/Filtered_MiddleSchool'; % path for each individual subject
        %path = '/Users/fangwang/Dropbox (Personal)/Filtered_MiddleSchool';
        %sourcepath = fullfile(path, 'BLC_001');
 
        destpath = '/Users/fangwang/Dropbox (Personal)/PermutationCarrierOut';
        
        analysisStruct = loadExperimentInfo_2019_MS_Data_indiv(sourcepath,destpath);
  
    analysisStruct.domain = 'freq';
    loadSettings = rcaExtra_getDataLoadingSettings(analysisStruct);
    loadSettings.useBins = 1:10;
    %loadSettings.useFrequencies = {'1F1', '2F1', '4F1','5F1','7F1','8F1'}; %oddball
    loadSettings.useFrequencies = {'3F1','6F1','9F1'}; %carrier
    %loadSettings.useFrequencies = {'1F1', '2F1', '3F1', '4F1', '5F1', '6F1', '7F1', '8F1', '9F1'}; %oddball
    %loadSettings.useFrequencies = {'1F2', '2F2', '3F2', '4F2', '5F2'}; %carrier
    %loadSettings.useFrequencies = {'1F2', '2F2', '3F2', '4F2', '5F2', '6F2', '7F2', '8F2', '9F2'}; %carrier
    % read raw dat
    
    [subjList, sensorData, cellNoiseData1, cellNoiseData2, ~] = getRawData(loadSettings);
    
    rcSettings = rcaExtra_getRCARunSettings(analysisStruct);
    rcSettings.subjList = subjList;
    rcSettings.useBins = loadSettings.useBins;
    rcSettings.useFrequencies = loadSettings.useFrequencies;
    
    [xCell_out, allR_cell] = phaseScrambleCellArray(sensorData);

    
    reshapeTrialToBin = 1;
    if reshapeTrialToBin

        sensorData_tr = xCell_out; % Move orig to new variable, this is for reshaping without permutation test

        DataIn = cellfun(@(x) reshapeTrialToBinForRCA(x, length(rcSettings.useBins)),...
            sensorData_tr, 'UniformOutput', false);

        cellNoiseData1_tr = cellNoiseData1; % Move orig to new variable
        cellNoiseData1 = cellfun(@(x) reshapeTrialToBinForRCA(x, length(rcSettings.useBins)),...
            cellNoiseData1_tr, 'UniformOutput', false);

        cellNoiseData2_tr = cellNoiseData2; % Move orig to new variable
        cellNoiseData2 = cellfun(@(x) reshapeTrialToBinForRCA(x, length(rcSettings.useBins)),...
            cellNoiseData2_tr, 'UniformOutput', false);

        % Adjust rcSettings accordingly
        rcSettings_tr = rcSettings; % Mover orig to new variable
        rcSettings.useBins = 1; % Used to be 1:10

    end
    
   nConditions = size(sensorData, 2);
    rcSettings_byCondition = cell(1, nConditions);
    rcResultStruct_byCondition = cell(1, nConditions);
  rng('shuffle'); %
    %for nc = 1:nConditions
    
        %rcSettings_byCondition{nc} = rcSettings;
        %rcSettings_byCondition{nc}.label = analysisStruct.info.conditionLabels{nc};
        %rcSettings_byCondition{nc}.useCnds = nc;
        
        %rcResultStruct_byCondition{nc} = rcaExtra_runAnalysis(rcSettings_byCondition{nc}, DataIn, cellNoiseData1, cellNoiseData2);
    
       
        
    %end
    
     rcSettings_cnd_123 = rcSettings;
    rcSettings_cnd_123.saveFile = [analysisStruct.path.destDataDir_RCA filesep 'rcaResults_freq_cnd123.mat'];

    cData = DataIn(:, [1 2 3]);
    cNoise1 = cellNoiseData1(:, [1 2 3]);
    cNoise2 = cellNoiseData2(:, [1 2 3]);
    rcSettings_cnd_123.condsToUse = [1 2 3];
    rcSettings_cnd_123.label = 'Condition123';
    
    rcResultStruct_cnd_123 = rcaExtra_runAnalysis(rcSettings_cnd_123, cData, cNoise1, cNoise2);
    
       
    % Save the RCA output in the out dir
    if saveOutput
        
        cd('/Users/fangwang/Dropbox (Personal)/PermutationCarrierOut')
        matFnOut = ['rcaOut'...
            '_doPerm_' num2str(doPerm)...
            '_run_' sprintf('%03d', i)...
            '_' datestr(now, 'yyyymmdd_HHMMSS')]
        
        
        save(matFnOut,'rcResultStruct_cnd_123');
    end
    
    clear all

delete('/Users/fangwang/Dropbox (Personal)/PermutationCarrierOut/RCA/rcaResults_Freq_Condition123.mat')

end 






ccolors


myDir = uigetdir; %gets directory
myFiles = dir(fullfile(myDir,'*.mat'));

fileNames = {myFiles.name};
for k = 1:numel(myFiles)
    data(k) = load(fileNames{k});    
end

%load permuted dGen
% condition 1
nPerm = 401;

% for trained on each condition separately
for i = 1:nPerm
    for c =1:3
    PERM_dGen(i,c,:) = data(i).rcResultStruct_byCondition{1,c}.covData.dGen(end : -1 : end-4); % 1 x 5
    end
end

%for trained on conditions together
for i = 1:nPerm
    PERM_dGen(i,:) = data(i).rcResultStruct_cnd_123.covData.dGen(end : -1 : end-4); % 1 x 5
end

%for trained on conditions seperately
INTACT_dGen = nan(3,5); %
% Load intact dGen
load('/Volumes/GSE/K2Followup_MW/K2_T1_T4/GroupRCA_oddball_31subjs/RCA/rcaResults_Freq_WvsPF.mat'); % codnition 1
INTACT_dGen(1,:) = rcaResult.covData.dGen(end : -1 : end-4); % 5 x 1
load('/Volumes/GSE/K2Followup_MW/K2_T1_T4/GroupRCA_oddball_31subjs/RCA/rcaResults_Freq_WvsOLN.mat'); % codnition 2
INTACT_dGen(2,:) = rcaResult.covData.dGen(end : -1 : end-4);
load('/Volumes/GSE/K2Followup_MW/K2_T1_T4/GroupRCA_oddball_31subjs/RCA/rcaResults_Freq_OLNvsOIN.mat') % codnition 3
INTACT_dGen(3,:) = rcaResult.covData.dGen(end : -1 : end-4);

%for trained on conditions together
load('/Users/fangwang/Dropbox (Personal)/GroupOutput/RCA/rcaResults_Freq_Conditions123.mat')
INTACT_dGen(1,:) = rcaResult.covData.dGen(end : -1 : end-4); % 5 x 1

% Color specifications
load('colors.mat', 'rgb10');%colors.mat is in 
grayCol = [.5 .5 .5];
fSize = 14;
txtSize = 10;
% Get the intact dGens
thisDGen = INTACT_dGen; % 1 x RC

% Get the 95th percentile of the null distribution
this95 = prctile(PERM_dGen, 95, 1); % 1 x RC
close all
figure()
hold on;


for i = 1:3
    
    % Statistical significance threshold
    thatP = permTestPVal(thisDGen(i), PERM_dGen(:, i));
    thatPlot95 = bar(i, this95(1,i), 1);
    thatPlot95.FaceColor = grayCol;
    thatPlot95.EdgeColor = 'none';
    
    % [debug] Print dGen and p-value
    text(i, thisDGen(i)+0.001,...
        ['dGen=' sprintf('%.3f', thisDGen(con,i)) ', p=' sprintf('%.3f', thatP)], ...
        'horizontalalignment', 'left', 'verticalalignment', 'middle',...
        'fontsize', txtSize, 'rotation', 30, 'color', 'r')
    
    % Print info in console
    disp(['RC' num2str(i) ': dGen=' sprintf('%.3f', thisDGen(i)) ', p=' sprintf('%.3f', thatP)])
    
    clear that*
end

% dGen line plot
plot(thisDGen(1:3), 'linewidth', 2, 'color', rgb10(2,:));
plot(thisDGen(1:3), '.', 'linewidth', 2, 'color', rgb10(2,:),...
    'markersize', 20);

set(gca, 'fontsize', fSize, 'xtick', 1:3, 'ytick', 0:0.1:0.6)
ylim([0 0.6])
xlabel('RC number')
ylabel('Eigenvalue Coefficient')
title('All conditions together')
box off; grid on


% Iterate through RCs


subplot(1,3,1);
hold on;
con = 1;
for i = 1:5
    
    % Statistical significance threshold
    thatP = permTestPVal(thisDGen(con,i), PERM_dGen(:, con, i));
    thatPlot95 = bar(i, this95(1,con,i), 1);
    thatPlot95.FaceColor = grayCol;
    thatPlot95.EdgeColor = 'none';
    
    % [debug] Print dGen and p-value
    text(i, thisDGen(con,i)+0.001,...
        ['dGen=' sprintf('%.3f', thisDGen(con,i)) ', p=' sprintf('%.3f', thatP)], ...
        'horizontalalignment', 'left', 'verticalalignment', 'middle',...
        'fontsize', txtSize, 'rotation', 30, 'color', 'r')
    
    % Print info in console
    disp(['RC' num2str(i) ': dGen=' sprintf('%.3f', thisDGen(con,i)) ', p=' sprintf('%.3f', thatP)])
    
    clear that*
end

% dGen line plot
plot(thisDGen(con,:), 'linewidth', 2, 'color', rgb10(2,:));
plot(thisDGen(con,:), '.', 'linewidth', 2, 'color', rgb10(2,:),...
    'markersize', 20);

set(gca, 'fontsize', fSize, 'xtick', 1:5, 'ytick', 0:0.05:0.25)
ylim([0 0.25])
xlabel('RC number')
ylabel('Eigenvalue Coefficient')
title(['Condition ' num2str(con) ': ' 'W-PF' ' Eigenvalue coefficients'])
box off; grid on

subplot(1,3,2);
hold on;
con = 2;
for i = 1:5
    
    % Statistical significance threshold
    thatP = permTestPVal(thisDGen(con,i), PERM_dGen(:, con, i));
    thatPlot95 = bar(i, this95(1,con,i), 1);
    thatPlot95.FaceColor = grayCol;
    thatPlot95.EdgeColor = 'none';
    
    % [debug] Print dGen and p-value
    text(i, thisDGen(con,i)+0.001,...
        ['dGen=' sprintf('%.3f', thisDGen(con,i)) ', p=' sprintf('%.3f', thatP)], ...
        'horizontalalignment', 'left', 'verticalalignment', 'middle',...
        'fontsize', txtSize, 'rotation', 30, 'color', 'r')
    
    % Print info in console
    disp(['RC' num2str(i) ': dGen=' sprintf('%.3f', thisDGen(con,i)) ', p=' sprintf('%.3f', thatP)])
    
    clear that*
end

% dGen line plot
plot(thisDGen(con,:), 'linewidth', 2, 'color', rgb10(2,:));
plot(thisDGen(con,:), '.', 'linewidth', 2, 'color', rgb10(2,:),...
    'markersize', 20);

set(gca, 'fontsize', fSize, 'xtick', 1:5, 'ytick', 0:0.05:0.25)
ylim([0 0.25])
xlabel('RC number')
ylabel('Eigenvalue Coefficient')
title(['Condition ' num2str(con) ': ' 'W-PW' ' Eigenvalue coefficients'])
box off; grid on


subplot(1,3,3);
hold on;
con = 3;
for i = 1:5
    
    % Statistical significance threshold
    thatP = permTestPVal(thisDGen(con,i), PERM_dGen(:, con, i));
    thatPlot95 = bar(i, this95(1,con,i), 1);
    thatPlot95.FaceColor = grayCol;
    thatPlot95.EdgeColor = 'none';
    
    % [debug] Print dGen and p-value
    text(i, thisDGen(con,i)+0.001,...
        ['dGen=' sprintf('%.3f', thisDGen(con,i)) ', p=' sprintf('%.3f', thatP)], ...
        'horizontalalignment', 'left', 'verticalalignment', 'middle',...
        'fontsize', txtSize, 'rotation', 30, 'color', 'r')
    
    % Print info in console
    disp(['RC' num2str(i) ': dGen=' sprintf('%.3f', thisDGen(con,i)) ', p=' sprintf('%.3f', thatP)])
    
    clear that*
end

% dGen line plot
plot(thisDGen(con,:), 'linewidth', 2, 'color', rgb10(2,:));
plot(thisDGen(con,:), '.', 'linewidth', 2, 'color', rgb10(2,:),...
    'markersize', 20);

set(gca, 'fontsize', fSize, 'xtick', 1:5, 'ytick', 0:0.05:0.25)
ylim([0 0.25])
xlabel('RC number')
ylabel('Eigenvalue Coefficient')
title(['Condition ' num2str(con) ': ' 'PW-NW' ' Eigenvalue coefficients'])
box off; grid on

