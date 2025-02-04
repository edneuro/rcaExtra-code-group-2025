function rcOut = convertProjectCellToSubCell(rcResult)
% rcOut = convertProjectCellToSubCells(rcResult)
% ---------------------------------------------------------
% Creator: Blair Kaneshiro, Oct 2020
% Maintainer: Blair Kaneshiro
%
% This function reshapes a subject x condition cell array (as field of
%   input struct) and outputs a trial x condition cell array for each
%   subject (as field of elements in output struct array).
%
% INPUT
% - rcResult: A struct as output by runRCA_frequency. This struct should 
%   contain a field named projectedData, which is a subject x condition 
%   cell array. Every element of the cell array should be a 3D
%   feature x rc x trial or bin matrix.
%
% OUTPUT
% - rcOut: A struct array of length nSubjects. Each element of the
%   struct array is an rcResult struct for a single subject. Each of these
%   structs contains a projectedData field, which is a trial x condition
%   cell array. Every element in this cell array is a 2D feature x rc
%   matrix representing a single trial of data.

% LATER: Extend function to work on both bin0 and bin1:10 input data.
% LATER: Make empty-to-NaN operation optional?

%% Data checks

% Make sure the projectedData field exists
assert(isfield(rcResult, 'projectedData'), ...
    'Input RCA struct does not contain a field called ''projectedData''.')

% Make sure the projectedData variable is a cell array or a single 3D
% matrix.
assert(iscell(rcResult.projectedData) || ndims(rcResult.projectedData) == 3, ...
    'ProjectedData variable should be a cell array or a single 3D matrix')

%% Analysis

% Get number of subjects and conditions
[nSub, nCondt] = size(rcResult.projectedData);
disp(['Reshaping project cell array to subject cell arrays for ' ... 
    num2str(nSub) ' subjects.'])

% Initialize the struct array (copy input struct array into each element)
rcOut(1:nSub) = rcResult;

% Iterate through the subjects and conditions to fill in the new
%   projectedData fields.
for s = 1:nSub
    
    % Clear the existing projectedData cell array for this subject
    rcOut(s).projectedData = {};
    
    for c = 1:nCondt
        
        % Grab the 3D matrix of the current sub, condt
        thisData = rcResult.projectedData{s, c}; % feature x rc x 'trial'
        
        % Get size of third dim so we can iterate over it
        thisNTrial = size(thisData, 3);
        
        % Iterate over the trials and move data into output cell array
        for t = 1:thisNTrial
            rcOut(s).projectedData{t, c} = thisData(:, :, t);
        end
        
        clear this*
        
    end
    
    % Also grab the subject name from the input struct and append it to the
    % output figure directory for the output struct
    currSubID = rcResult.rcaSettings.subjList{s};
    currFigDirIn = rcOut(s).rcaSettings.destDataDir_FIG;
    rcOut(s).rcaSettings.destDataDir_FIG = [currFigDirIn '/' sprintf('%02d', s) '_' currSubID];
    
end

%% Replace empty entries with matrices of NaN

% Go through the output cell array and replace any empty elements with
% arrays of NaNs
for s = 1:nSub
    
    [currNTrial, currNCondt] = size(rcOut(s).projectedData);
    currMatSize = size(rcOut(s).projectedData{1,1});
    
    for t = 1:currNTrial
       for c = 1:currNCondt
           if isempty(rcOut(s).projectedData{t, c})
               rcOut(s).projectedData{t, c} = nan(currMatSize);
           end
       end
    end
    
    clear curr*
    
end