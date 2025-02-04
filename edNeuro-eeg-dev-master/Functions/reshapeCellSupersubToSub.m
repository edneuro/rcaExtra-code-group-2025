function xOut = reshapeCellSupersubToSub(xSuperSub, subV)
% xOut = reshapeCellSupersubToSub(xIn, subIds)
% ------------------------------------------------------
% Maintainer: Blair Kaneshiro
% Creator: Blair Kaneshiro, Sep 2020
%
% This function takes in a {1 x nConditions} cell array containing 
%   supersubject 3D data matrices separated by condition and a 
%   corresponding cell array containing participant identifiers for each 
%   trial of data. It outputs a {nSubjects x nConditions} cell array where
%   there exists a separate 3D matrix for each subject.
%
% INPUTS (required)
% - xIn: A {1 x condition} cell array. Every entry in the cell array is a
%   matrix of size [feature x electrode or component x trial or bin]. Each
%   matrix is assumed to comprise EEG data for a given stimulus condition 
%   that has been aggregated across subjects.
% - subIds: A {1 x condition cell array}. Every entry in the cell array is
%   a vector that stores the participant index of each trial of data in the
%   corresponding data matrix (same cell array entry in xIn). The length of
%   each vector must equal the size of the bin or trial dimension in that
%   corresponding xIn data matrix. The numbering designates the subject
%   index into which an individual data matrix will be placed for an
%   output.
%
% OUTPUTS
% - xOut: A {nSubs x nCondition} cell array. Every entry in the cell array
%   is a matrix of size [feature x electrode or component x trial or bin].
%   The data in each column of the cell array (representing a single
%   condition) is thus an entry of xIn that has been separated out by
%   participant. 

%% Data checks

% Check 1: Two inputs are required
assert(nargin == 2, ...
    ['Two input variables required: A cell array of supersubject data, '...
    'and a cell array of trial-wise subject identifiers.']);

%% Check 2: Length of each cell array element 

subIdLengths = cellfun('length', subV);
dataNTrials = cellfun('size', xSuperSub, 3);

assert(isequal(subIdLengths, dataNTrials), ...
    ['Lengths of participant id vectors (' mat2str(subIdLengths) ... 
    ') does not match number of trials in each element of '...
    'input cell array (' mat2str(dataNTrials) ').']);

% Edge case: Inputs are single 3D matrices (e.g., for single condition)
% (Convert them to cell array)
if ~iscell(xSuperSub)
    temp = xSuperSub; clear xIn; xSuperSub{1} = temp; clear temp; end
if ~iscell(subV)
    temp = subV; clear subIds; subV{1} = temp; clear temp; end

%% 

%%% Initialize output: xOut %%%
nSubs = max(cellfun(@(x) max(x), subV));
nCondt = length(xSuperSub);
xOut = cell(nSubs, nCondt);

% Fill in the output cell array one condition at a time
for c = 1:nCondt
   thisX = xSuperSub{c}; % Single 3D matrix
   thisSubIdx = subV{c}; % Single vector
   
   for s = 1:nSubs
      thatSub = thisX(:, :, thisSubIdx == s);
      if isempty(thatSub), continue; end
      xOut{s, c} = thatSub;
   end
   
   clear this*
   
end

