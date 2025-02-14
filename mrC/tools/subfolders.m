function folderlist = subfolders(inputName,incl_path)
    if nargin < 1
        templist = dir;
        inputName = pwd;
    else
        templist = dir(inputName);
    end
    if nargin < 2
        incl_path = false;
    else
    end
    
    if ispc
        file_sep = '\';
    else
        file_sep = '/';
    end 
    
    if strcmp(inputName(end), file_sep)
        inputName = [inputName,'*']; % if it ends on slash, add *
    elseif ~contains(inputName,'*')
        inputName = [inputName, file_sep, '*']; % otherwise add /* if it is not already there
    else
    end
        
    curDir = fileparts(inputName);
    if isempty(curDir)
        curDir = pwd;
    else
    end
    num_folders = 0;
    if ~isempty(templist)
        for t=1:length(templist)
            if templist(t).isdir ==1 && ~strcmp(templist(t).name,'.') && ~strcmp(templist(t).name,'..')  
                num_folders = num_folders+1;
                if incl_path
                    folderlist(num_folders,:) = {[curDir, file_sep, templist(t).name]};
                else
                    folderlist(num_folders,:) = {templist(t).name};
                end
            else
            end
        end
    else
        folderlist = {false};
    end
end

    