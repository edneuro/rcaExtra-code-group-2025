function [xOut, binsKeep] = retainSelectedBins(xIn, binsToRetain, binsPerTrial)
% xOut = retainSelectedBins(xIn, binsToRetain, binsPerTrial)
% ------------------------------------------------------------------
% Creator: Blair Kaneshiro (Sep 2021)
% Maintainer: Blair Kaneshiro
%
% This function subsets bins-on-third-dimension data matrices and returns a
% reduced matrix containing only the specified bin numbers in each trial.
%
% Inputs (required)
% - xIn: A 3D feature x electrode x bin matrix, or cell array containing
%   such matrices. The third (bin) dimension is assumed to contain
%   ordered, concatenated bins for each trial (e.g., bins 1:10 for Trial 1,
%   followed by bins 1:10 for Trial 2, etc.)
% - binsToRetain: A vector of which bins in each trial to retain. If the
%   input is not provided or is empty, the function will return an error.
%   If the input is 0, the function will print a warning and return the
%   input matrix as the output.
%
% Inputs (optional)
% - binsPerTrial (default = 10): Total number of bins in each trial. If
%   not entered or empty, it will be set to 10.
%
% Outputs
% - xOut: A 3D feature x electrode x subset-bin matrix, or cell array
%   containing such matrices. Each matrix now includes, for every trial,
%   only the bins specified by the binsToRetainInput.
% - binsKeep: Vector indicating bin numbers (dimension 3 indices) that were
%   retained from every 3D input matrix.

%% Input checks and assignments

% At least 2 inputs are required; 2nd input must not be empty
if nargin < 2 || isempty(binsToRetain)
    error('At least two inputs are required: Input data variable and vector of bins to retain.'); end

% If input 2 = 0, print warning and return
if binsToRetain == 0
    warning('Input ''binsToRetain'' is set to zero. Returning input data as output.');
    xOut = xIn;
    return;
end

% If nargin < 3 or binsPerTrial is empty, set binsPerTrial to 10
if nargin < 3 || isempty(binsPerTrial), binsPerTrial = 10; end

% Make sure no element of binsToRetain > binsPerTrial
if any(binsToRetain > binsPerTrial)
    error(['One or more elements of input ''binsToRetain'' ('...
        mat2str(binsToRetain(:)') ') exceeds the number of bins in each trial ('...
        num2str(binsPerTrial) ').']); end

%% Recursive call for cell input

% Is input data variable a cell?
cellFlag = iscell(xIn);

% If input is single matrix (NOT cell array), make it a cell array for now.
if ~cellFlag
%     disp('Input is not a cell array; making temp cell array');
    xIn = {xIn}; end

% Iterate through cell array elements
xOut = cell(size(xIn));
binsKeep = xOut;
[nRow,nCol] = size(xIn);
for r = 1:nRow
    for c = 1:nCol
        thisIn = xIn{r,c};
        thisTotalBins = size(thisIn, 3);
        thisMatrixBinsKeep = bsxfun(@plus, 0:binsPerTrial:thisTotalBins, binsToRetain(:));
        thisVectorBinsKeep = thisMatrixBinsKeep(:);
        thisBinsKeep = thisVectorBinsKeep(thisVectorBinsKeep <= thisTotalBins);
        binsKeep{r,c} = thisBinsKeep;
        xOut{r, c} = thisIn(:, :, thisBinsKeep);
        clear this*
    end
end

% If the input data was a matrix and not a cell array, convert outputs back
% to single matrices.
if ~cellFlag
    xOut = cell2mat(xOut);
    binsKeep = cell2mat(binsKeep); end



