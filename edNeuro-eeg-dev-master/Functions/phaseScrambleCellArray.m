function [xCellOut, xCellR] = phaseScrambleCellArray(xCellIn, nBinsPerObs, debugMode)
% [xCellOut, xCellR] = phaseScrambleCellArray(xCellIn, nBinsPerObs, debugMode)
% ------------------------------------------------------------------------
% Creator: Blair Kaneshiro, March-April 2022
% Maintainer: Blair Kaneshiro
%
% This function calls the phaseScramble3dMatrix function over all elements
% of a 2D cell array, each element of which contains a 3D frequency-domain,
% sensor-space matrix as used in the rcaExtra pipeline. Specifically, each
% 3d element is of size nFeature x nElectrode x nObservation.
%
% INPUTS
%   - xCellIn (required): A cell array whose dimensions are e.g., 
%   nParticipant x nCondition. Each element of the cell array is a 3D 
%   matrix whose dimensions are nFeature x nElectrode x nObservation. 
%   Features are assumed to be real and imaginary Fourier coefficients for 
%   one or more bins and/or harmonics as structured in the rcaExtra 
%   pipeline: 
%       - Top grouping is real/imaginary;
%       - In there, the next grouping is by frequency harmonic; 
%       - Finally, if a given observation comprises multiple bins (e.g., 10
%       bins in a trial), the bins are arranged consecutively.
%   - nBinsPerObs (optional): The number of bins implicated in a single
%   observation. For instance, if inputting data for which the third
%   dimension represents a trial of 10 bins, nBinsPerObs would be 10. If
%   not entered or empty, the function will set this variable to 10 and, 
%   if in debug mode, print a warning.
%   - debugMode (optional): Boolean value of whether to print debug
%   messages. If not entered or empty, will default to false.
%
% OUTPUTS
%   - xCellOut: A cell array of the same size as xCellIn, containing
%   phase-scrambled data.
%   - allR: A cell array of the same size as xCellIn. Each element is a 
%   matrix of size nHarmonic x nObservation containing the random phase 
%   angle applied to all bins and electrodes for that harmonic and
%   observation. This can be used to verify the function is working
%   correctly.

%% Check inputs

% Make sure at least one input was provided.
assert(nargin >= 1, 'At least one input is required.');

% Set debugMode if needed.
if nargin < 3 || isempty(debugMode), debugMode = 0; end

% Set nBinsPerObs if needed.
if nargin < 2 || isempty(nBinsPerObs)
    nBinsPerObs = 10;
    if debugMode, warning('Input ''nBinsPerObs'' not entered. Setting to 10.'); end 
end

if debugMode
    debugMode
    nBinsPerObs
end

rng('shuffle')

% If the user entered a single 3d matrix and not a cell array, turn it into
% a cell array.
if ~iscell(xCellIn) 
    xCellIn = {xCellIn}; 
    inputWasConverted = 1; 
else
    inputWasConverted = 0;
end

% keyboard

%% Initialize outputs

xCellOut = cell(size(xCellIn));
xCellR = cell(size(xCellIn));
% keyboard
%% Cycle through outputs and call the function on each entry

[dim1, dim2] = size(xCellIn);
dim1
dim2

disp('Calling ''phaseScramble3dMatrix'' over each element of input data matrix ')
disp(['(cell array of size ' num2str(dim1) ' by ' num2str(dim2) ').'])

for d1 = 1:dim1
    for d2 = 1:dim2
        if debugMode
           disp(' ')
           disp(['Processing cell array row ' num2str(d1) ', column ' num2str(d2) '.'])
        end
        [xCellOut{d1, d2}, xCellR{d1, d2}] = phaseScramble3dMatrix(...
            xCellIn{d1, d2}, nBinsPerObs, debugMode);
    end
end

%% If original input was not a cell, convert back to mat

if inputWasConverted
    xCellOut = cell2mat(xCellOut);
    xCellR = cell2mat(xCellR); 
end