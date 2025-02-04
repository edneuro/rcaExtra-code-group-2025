function adults6HzInfo = loadExperimentInfo_2021_K2_MW
    
    %% info is a structure describing experiment parameters
    adults6HzInfo = rcaExtra_genStructureTemplate;
    [curr_path, ~, ~] = fileparts(mfilename('fullpath'));
    adults6HzInfo.path.rootFolder = curr_path;
    
    % source EEG data
    srcDirPath = uigetdir(curr_path, 'Select EEG SOURCE directory');
    if (~isempty(srcDirPath))
        adults6HzInfo.path.sourceEEGDir = srcDirPath;
    end
        
    % destination EEG directory
    adults6HzInfo.path.destDataDir = uigetdir(curr_path, 'Select analysis results directory');
    

    %% create subdirectories
    dirNames = {'MAT', 'FIG', 'RCA'};
    dirPaths = rcaExtra_setupDestDir(adults6HzInfo.path.destDataDir, dirNames);
    
    adults6HzInfo.path.destDataDir_MAT = dirPaths{1};
    adults6HzInfo.path.destDataDir_FIG = dirPaths{2};
    adults6HzInfo.path.destDataDir_RCA = dirPaths{3};
   
    % replace default values here
    adults6HzInfo.info.subjTag = '*';
    adults6HzInfo.info.subDirTxt = 'Exp_TEXT_HCN_128_Avg_Btn';
    adults6HzInfo.info.subDirMat = 'Exp_MATL_HCN_128_Avg_Btn';
    adults6HzInfo.info.groupLabels = {'kids'};
    %adults6HzInfo.info.conditionLabels = {'WvsPF', 'WvsOLN', 'OLNvsOIN','Condition123',''};
    adults6HzInfo.info.conditionLabels = {'TvsUT2', 'Practice', 'HFWvsPW','MFWvsPW', 'TvsUT3'};
    adults6HzInfo.info.frequenciesHz = [1, 3];
    adults6HzInfo.info.useSpecialDataLoader = false;
    adults6HzInfo.info.frequencyLabels = {{'1F1', '2F1', '3F1', '4F1','5F1','6F1','7F1','8F1','9F1'},{'1F2', '2F2', '3F2', '4F2', '5F2','6F2','7F2','8F2','9F2'}};
    adults6HzInfo.info.binsNmb = 10;
end



