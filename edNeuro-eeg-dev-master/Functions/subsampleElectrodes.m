function Y = subsampleElectrodes(X, montage)
% Y = subsampleElectrodes(X, montage)
% --------------------------------------------------------
% Creator: Blair Kaneshiro (May 2021)
% Maintainer: Blair Kaneshiro
%
% This function takes in a cell array of data for input to RCA, and outputs
% a cell array for which each 3D matrix element has been subsampled along
% the space dimension.
% 
% INPUTS (required)
% - X: Cell array or matrix of RCA input data. If a cell array, every 
%   element should be a feature x space x trial dimension. If not a cell 
%   array, input should be a single feature x space x trial matrix. 
%   - We only care about the space dimension, so the feature dimension can 
%     be anything (e.g., time points, Fourier coefficients) and the trial 
%     dimension can be long trials or short bins. 
%   - The function will check to make sure the length of the space 
%     dimension is 128, and print a warning if it is not.
%
% INPUTS (optional)
% - montage: String specifying the montage of the input matrix A. If not
%   entered or empty, the function will print a warning and assign a best 
%   guess based on the size of the space dimension of input A.

%% Assign output electrode numbers of various input montages

%%% Wearables DSI-VR300
% https://wearablesensing.com/wp-content/uploads/2018/07/Wearable-Sensing-DSI-VR300-Specifications_2018.pdf
% Fz, Pz, P3, P4, PO7, PO8, Oz
montage_wearablesDSIVR300 = [11 62 52 92 65 90 75];

%montage_wearablesDSIVR300 = [11 62 52 92 65 90 75]; %DSI 24 comment out if needed


%% Input data checks

% Make sure X cell array was input
assert(nargin >= 1, ['The function requires at least one input ' ...
    '(matrix or cell array X).'])

% If second input is missing, assign default and print warning.
if nargin < 2 || isempty(montage)
    % LATER: Switch based on attributes of input data
    montage = 'dsivr300';
    
    warning(['Input ''montage'' not specified. Setting to ''' ...
        montage '''.'])
end

%% Get correct montage and fill in output variable

% Get correct montage
switch montage
    case 'dsivr300'
        outChan = montage_wearablesDSIVR300;
    otherwise
        error('Montage not recognized!')
end

% Do the subsampling
if iscell(X)
    
    % Check the size of the space dimension
    if ~isequal(128, ...
        unique(cell2mat(cellfun(@(x) size(x, 2), X, 'UniformOutput', 0))))
        warning('Input data does not have 128 electrodes!'); end
    
    % Do the subsampling
    Y = cellfun(@(x) x(:, outChan, :), X, 'UniformOutput', 0);
else
    
    % Check the size of the space dimension
    if ~isequal(128, size(X, 2))
        warning('Input data does not have 128 electrodes!'); end
    
    % Do the subsampling
    Y = X(:, outChan, :);
    
end