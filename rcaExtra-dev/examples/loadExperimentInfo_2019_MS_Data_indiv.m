function adults6HzInfo = loadExperimentInfo_2019_MS_Data_indiv(sourcepath,destpath)
    
    %% info is a structure describing experiment parameters
    adults6HzInfo = rcaExtra_genStructureTemplate;
    [curr_path, ~, ~] = fileparts(mfilename('fullpath'));
    adults6HzInfo.path.rootFolder = curr_path;
    
    % source EEG data
%     srcDirPath = uigetdir(curr_path, 'Select EEG SOURCE directory');
    srcDirPath = sourcepath;
    
    if (~isempty(srcDirPath))
        adults6HzInfo.path.sourceEEGDir = srcDirPath;
    end
        
    % destination EEG directory
%     adults6HzInfo.path.destDataDir = uigetdir(curr_path, 'Select analysis results directory');
    adults6HzInfo.path.destDataDir = destpath;

    %% create subdirectories
     dirNames = {'MAT', 'FIG', 'RCA'};
    dirPaths = rcaExtra_setupDestDir(adults6HzInfo.path.destDataDir, dirNames);
    
    adults6HzInfo.path.destDataDir_MAT = dirPaths{1};
    adults6HzInfo.path.destDataDir_FIG = dirPaths{2};
    adults6HzInfo.path.destDataDir_RCA = dirPaths{3};
   
    % replace default values here
    adults6HzInfo.info.subjTag = 'BLC*';
    adults6HzInfo.info.subDirTxt = 'Exp_TEXT_HCN_128_Avg';
    adults6HzInfo.info.subDirMat = 'Exp_MATL_HCN_128_Avg';
    adults6HzInfo.info.groupLabels = {'MS'};
    adults6HzInfo.info.conditionLabels = {'WvsPF', 'NWvsPF', 'WvsNW','Conditions123'};
    adults6HzInfo.info.frequenciesHz = [1];
    adults6HzInfo.info.useSpecialDataLoader = false;
    adults6HzInfo.info.frequencyLabels = {'1F1', '2F1', '3F1', '4F1','5F1','6F1','7F1','8F1','9F1'};
    adults6HzInfo.info.binsNmb = 10;
end



