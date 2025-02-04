function [xOut, subIds] = reshapeCellSubToSupersub(xIn)
% [xOut, subIds] = reshapeCellSubToSupersub(xIn)
% -------------------------------------------------------------
% Maintainer: Blair Kaneshiro <blairbo@gmail.com>
% Creator: Blair Kaneshiro, Aug-Sep 2020
%
% This function takes in the ?? subjects x conditions ?? cell array that is
%   input to the main rcaRun function and combines the data across subjects
%   for each condition. Thus, the output cell array is of size 
%   1 x condition, where each entry represents the "super-subject" of that
%   condition.
%
% INPUT (required)
% - xIn: The ?? subject x condition ?? cell array. Each entry in the cell
%   array should be a 3D feature x electrode x trial (bin) matrix (permute
%   function has already been called, putting electrodes on dimension 2).
%   The cell array matrix entries are assumed to share a common data shape,
%   and to be combinable across dimension ?? 1 ?? (the subject dimension).
%
% OUTPUTS
% - xOut: The ?? 1 x condition cell array, where trials (bins) have been
%   aggregated across all subjects for each condition.
%
% - subIds: Cell array of size 1 x condition. Every entry is a vector that 
%   specifies subject index membership of each trial (bin) in the 
%   corresponding super-subject matrix for that condition. This variable is 
%   used to separate the super-subject matrix entries back into 
%   individual matrices for each subject.

% warning on backtrace

%% Data checks

% Check 1: Make sure input is a cell array
assert(iscell(xIn), ...
    'Input variable needs to be a cell array of 3D matrices');

% Check 2: Make sure every non-empty cell array element is (1) a 3D matrix, 
%   and that (2) the sizes of their first two dimensions (features and 
%   electrodes) are consistent for all entries.
tempCol = xIn(:); % Convert to column cell array
tempNonEmpty = tempCol(~cellfun('isempty', tempCol)); % Exclude empty entries
tempFeatSize = unique(cellfun('size', tempNonEmpty, 1)); % What feature dim sizes are present
tempElectrodeSize = unique(cellfun('size', tempNonEmpty, 2)); % What electrode dim sizes are present

% Make sure feature and electrode data size is the same for all matrices
assert(length(tempFeatSize) == 1,... 
    'Input 3D matrices do not share a common number of features.'); 
assert(length(tempElectrodeSize) == 1, ...
    'Input 3D matrices do not share a common number of electrodes.');

% Print size of feature and electrode dimensions
disp(['Input data: ' num2str(tempFeatSize) ' features over ' num2str(tempElectrodeSize) ' electrodes.'])

%% 

% Get size of input matrix
[nSubs, nCondt] = size(xIn);

% Print message about data size
disp(['Reshaping ' num2str(nSubs) ' x ' num2str(nCondt) ' subject-by-condition cell array to 1 x ' ...
    num2str(nCondt) ' super-subject-by-condition cell array']);

%%

%%% Initialize outputs: xOut and subIds %%%
xOut = cell(1, nCondt); % Each entry will contain a super-sub matrix
subIds = cell(1, nCondt); % Each entry will contain an id vector

% Iterate through each condition and combine
for c = 1:nCondt
   thisXIn = xIn(:, c); 
   
   % Init outputs for the current condition
   thisXOut = [];
   thisSubsIdx = [];
   
   % Iterate through the subjects in this condition
   for s = 1:nSubs
        currX = thisXIn{s};
        
        % If this subject has no data, continue to next subject
        if isempty(currX) 
            warning(['Condition ' num2str(c) ': Empty matrix for subject ' num2str(s) '.']); 
            clear currX; continue; 
        end
        
        thisXOut = cat(3, thisXOut, currX);
        thisSubsIdx = [thisSubsIdx; s * ones(size(currX, 3), 1)];
        
   end
   
   % Append to main output for this condition
   xOut{c} = thisXOut;
   subIds{c} = thisSubsIdx;
   
   clear this*
end