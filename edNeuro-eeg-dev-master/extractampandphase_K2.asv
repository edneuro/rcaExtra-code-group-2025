%% extract amplitude and phase to .csv files


for nComp = 1%1:3
    oddball_condition2_amp_allsubjects = squeeze(rcaResult.subjAvg.amp(:,nComp,:,:))';
    fileName = 'oddball_TvsUT3_amp_allsubjects_%s%d%s';
    A = 'comp';
    B = nComp ;
    C = '_unweighted';
    str = sprintf(fileName,A,B,C);
    csvname = append(str,'.csv');
    csvwrite(csvname,oddball_condition2_amp_allsubjects);
end

%extract weighted amplitude, projected through mean amplitude
for nComp = 1%1:3
    oddball_condition1_amp_allsubjects = squeeze(rcaResult.subjProj.amp(:,nComp,:,:))';
    fileName = 'oddball_TvsUT3_amp_allsubjects_%s%d%s';
    A = 'comp';
    B = nComp ;
    C = '_weighted';
    str = sprintf(fileName,A,B,C);
    csvname = append(str,'.csv');
    csvwrite(csvname,oddball_condition1_amp_allsubjects);
end

% read and combine csv files

myDir = uigetdir; %gets directory
myFiles = dir(fullfile(myDir,'*.csv'));
fileNames = {myFiles.name};
for k = 1:numel(myFiles)
    data{k} = csvread(fileNames{k});
    
end
allCsv = [data{1}, data{2}, data{3}, data{4}, data{5}, data{6}, data{7}, data{8}, data{9}];
csvwrite('combines_allconds_allcomps.csv',allCsv);


% these are for phases, but will not use them for now, tony is working with
% stats people to deal with this...
for nComp = 1%1:3
    carrier_condition1_phase_allsubjects = squeeze(out.subjProj.phase(:,nComp,:,:))';
    fileName = 'carrier_condition1_phase_allsubjects_%s%d';
    A = 'comp';
    B = nComp ; 
    str = sprintf(fileName,A,B);
    csvname = append(str,'.csv');
    csvwrite(csvname,carrier_condition1_phase_allsubjects);
end