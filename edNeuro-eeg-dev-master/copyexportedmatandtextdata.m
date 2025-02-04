% move exported matlab and text files to out layer folder
clear all
classpath = '/Users/fangwang/Ed Neuro Initiative Dropbox/Educational Neuroscience Initiative/2022_MW_2hz&3HZ/Class3';
path = '/Users/fangwang/Ed Neuro Initiative Dropbox/Educational Neuroscience Initiative/2022_MW_2hz&3HZ/Class3/Version3';

cd(path)
files = dir('BLC*');

for subj = 1:length(files)
        
        sourcepath = fullfile(path, files(subj).name);
        cd(classpath)
       
        mkdir(classpath, files(subj).name);
        cd(sourcepath)
        EEGSsn = dir('*EEGSsn');
       
        copyfrom = fullfile(sourcepath, EEGSsn.name);
        cd(copyfrom)
        MAT = fullfile(copyfrom, 'Exp_MATL_HCN_128_Avg_Btn');
        TXT = fullfile(copyfrom, 'Exp_TEXT_HCN_128_Avg_Btn');
      
        destpath = fullfile(classpath, files(subj).name);
        cd(destpath)
        mkdir(destpath, 'Exp_MATL_HCN_128_Avg_Btn');
        destdestpath_mat = fullfile(destpath, 'Exp_MATL_HCN_128_Avg_Btn');
        cd(MAT)
        copyfile('*.mat', destdestpath_mat);
        
        mkdir(destpath, 'Exp_TEXT_HCN_128_Avg_Btn');
        destdestpath_txt = fullfile(destpath, 'Exp_TEXT_HCN_128_Avg_Btn');
        cd(TXT)
        copyfile('*.txt', destdestpath_txt);

end


% since doing counterbalanced condition orders, need to rename the
% condition number so that each number in each version refers to the same
% thing

clear all

classpath = '/Users/fangwang/Ed Neuro Initiative Dropbox/Educational Neuroscience Initiative/2022_MW_2hz&3HZ/Class1';
path = '/Users/fangwang/Ed Neuro Initiative Dropbox/Educational Neuroscience Initiative/2022_MW_2hz&3HZ/Class1/Version2';

cd(path)
files = dir('BLC*');

needtochangepath = '/Volumes/GSE/2022_MW_2Hz&3Hz/exportdata';
cd(needtochangepath)

%for version 2, first change cond3 to cond6, then change cond4 to cond3,
%cond5 to cond4, con6(original cond3) to cond5
for i = 1:length(files)
    sourcepath = fullfile(needtochangepath, files(i).name, 'Exp_MATL_HCN_128_Avg_Btn');
    %sourcepath = fullfile(needtochangepath, files(i).name, 'Exp_TEXT_HCN_128_Avg_Btn');
    cd(sourcepath)
    filesneedtorename1 = dir('*_c003*');
    %filesneedtorename1(1:11) = [];
   
    for j = 1:length(filesneedtorename1)
   
    oldname = filesneedtorename1(j).name;
    newname = strrep(filesneedtorename1(j).name,'c003','c006');
    %newname = append(filesneedtorename1(1).name(1:4), 'c006' ,filesneedtorename1(1).name(9:end));
    movefile(oldname, newname);

    end
end

for i = 1:length(files)
    sourcepath = fullfile(needtochangepath, files(i).name, 'Exp_MATL_HCN_128_Avg_Btn');
    %sourcepath = fullfile(needtochangepath, files(i).name, 'Exp_TEXT_HCN_128_Avg_Btn');
    cd(sourcepath)
    filesneedtorename1 = dir('*_c004*');
    %filesneedtorename1(1:12) = [];
   
    for j = 1:length(filesneedtorename1)
   
    oldname = filesneedtorename1(j).name;
    newname = strrep(filesneedtorename1(j).name,'c004','c003');
    %newname = append(filesneedtorename1(1).name(1:4), 'c006' ,filesneedtorename1(1).name(9:end));
    movefile(oldname, newname);

    end
end

for i = 1:length(files)
    sourcepath = fullfile(needtochangepath, files(i).name, 'Exp_MATL_HCN_128_Avg_Btn');
    %sourcepath = fullfile(needtochangepath, files(i).name, 'Exp_TEXT_HCN_128_Avg_Btn');
    cd(sourcepath)
    filesneedtorename1 = dir('*_c005*');
    %filesneedtorename1(1:12) = [];
   
    for j = 1:length(filesneedtorename1)
   
    oldname = filesneedtorename1(j).name;
    newname = strrep(filesneedtorename1(j).name,'c005','c004');
    %newname = append(filesneedtorename1(1).name(1:4), 'c006' ,filesneedtorename1(1).name(9:end));
    movefile(oldname, newname);

    end
end

for i = 1:length(files)
    sourcepath = fullfile(needtochangepath, files(i).name, 'Exp_MATL_HCN_128_Avg_Btn');
    %sourcepath = fullfile(needtochangepath, files(i).name, 'Exp_TEXT_HCN_128_Avg_Btn');
    cd(sourcepath)
    filesneedtorename1 = dir('*_c006*');
    %filesneedtorename1(1:11) = [];
   
    for j = 1:length(filesneedtorename1)
   
    oldname = filesneedtorename1(j).name;
    newname = strrep(filesneedtorename1(j).name,'c006','c005');
    %newname = append(filesneedtorename1(1).name(1:4), 'c006' ,filesneedtorename1(1).name(9:end));
    movefile(oldname, newname);

    end
end

%for version 3, the same logic, just first change cond5 to cond6, then change cond4 to cond5,
% con6(original cond5) to cond4

clear all

classpath = '/Users/fangwang/Ed Neuro Initiative Dropbox/Educational Neuroscience Initiative/2022_MW_2hz&3HZ/Class1';
path = '/Users/fangwang/Ed Neuro Initiative Dropbox/Educational Neuroscience Initiative/2022_MW_2hz&3HZ/Class1/Version3';

cd(path)
files = dir('BLC*');

needtochangepath = '/Volumes/GSE/2022_MW_2Hz&3Hz/exportdata';
cd(needtochangepath)

for i = 1:length(files)
    sourcepath = fullfile(needtochangepath, files(i).name, 'Exp_MATL_HCN_128_Avg_Btn');
    %sourcepath = fullfile(needtochangepath, files(i).name, 'Exp_TEXT_HCN_128_Avg_Btn');
    cd(sourcepath)
    filesneedtorename1 = dir('*_c003*');
    %filesneedtorename1(1:11) = [];
   
    for j = 1:length(filesneedtorename1)
   
    oldname = filesneedtorename1(j).name;
    newname = strrep(filesneedtorename1(j).name,'c003','c006');
    %newname = append(filesneedtorename1(1).name(1:4), 'c006' ,filesneedtorename1(1).name(9:end));
    movefile(oldname, newname);

    end
end

for i = 1:length(files)
    sourcepath = fullfile(needtochangepath, files(i).name, 'Exp_MATL_HCN_128_Avg_Btn');
    %sourcepath = fullfile(needtochangepath, files(i).name, 'Exp_TEXT_HCN_128_Avg_Btn');
    cd(sourcepath)
    filesneedtorename1 = dir('*_c005*');
    %filesneedtorename1(1:12) = [];
   
    for j = 1:length(filesneedtorename1)
   
    oldname = filesneedtorename1(j).name;
    newname = strrep(filesneedtorename1(j).name,'c005','c003');
    %newname = append(filesneedtorename1(1).name(1:4), 'c006' ,filesneedtorename1(1).name(9:end));
    movefile(oldname, newname);

    end
end

for i = 1:length(files)
    sourcepath = fullfile(needtochangepath, files(i).name, 'Exp_MATL_HCN_128_Avg_Btn');
    %sourcepath = fullfile(needtochangepath, files(i).name, 'Exp_TEXT_HCN_128_Avg_Btn');
    cd(sourcepath)
    filesneedtorename1 = dir('*_c004*');
    %filesneedtorename1(1:12) = [];
   
    for j = 1:length(filesneedtorename1)
   
    oldname = filesneedtorename1(j).name;
    newname = strrep(filesneedtorename1(j).name,'c004','c005');
    %newname = append(filesneedtorename1(1).name(1:4), 'c006' ,filesneedtorename1(1).name(9:end));
    movefile(oldname, newname);

    end
end

for i = 1:length(files)
    sourcepath = fullfile(needtochangepath, files(i).name, 'Exp_MATL_HCN_128_Avg_Btn');
    %sourcepath = fullfile(needtochangepath, files(i).name, 'Exp_TEXT_HCN_128_Avg_Btn');
    cd(sourcepath)
    filesneedtorename1 = dir('*_c006*');
    %filesneedtorename1(1:11) = [];
   
    for j = 1:length(filesneedtorename1)
   
    oldname = filesneedtorename1(j).name;
    newname = strrep(filesneedtorename1(j).name,'c006','c004');
    %newname = append(filesneedtorename1(1).name(1:4), 'c006' ,filesneedtorename1(1).name(9:end));
    movefile(oldname, newname);

    end
end