% run_phaseScramble3dMatrix.m
% -----------------------------
% Blair - March 31, 2022
%
% Script to test and call the phaseScramble3dMatrix function.

clear all; close all; clc

% Load dev data
IN = load('sensorData_bins1dimension.mat');
xIn_cellArray = IN.sensorData; % 48 x 3 cell array
clear IN

%% Call function to randomize the cell array

[xCell_out, allR_cell] = phaseScrambleCellArray(xIn_cellArray);

%% Extract a single 3d matrix from the cell array at random.

[dim1, dim2] = size(xIn_cellArray);
rd1 = randi(dim1); 
rd2 = randi(dim2);

xIn_single3dMatrix = xIn_cellArray{rd1, rd2}; % 100 x 128 x 8 matrix

%% Confirm the cell function works with a single 3D matrix

[xOut_cellToSingle, rOut_cellToSingle] = phaseScrambleCellArray(xIn_single3dMatrix);
% Confirmed -- can call the cell array function with a single matrix and it
% will return a matrix:
%   - xOut_cellToSingle is 100 x 128 x 8 matrix
%   - rOut_cellToSingle is 5 x 8 matrix

%% Spot check some values
clc

[nFeature, nElectrode, nObs] = size(xIn_single3dMatrix);
nBinPerTrial = 10;
nHarmonic = nFeature / (2 * nBinPerTrial);

%%%%%%% Make some random values %%%%%%%%%

% Trial, harmonic, and which cell array entry: Can set to non-random value 
%   to confirm they use a consistent random angle.
rObs = 3; %randi(nObs);
rHarm = 2; %randi(nHarmonic);
rCellRow = 20; %randi(dim1);
rCellCol = 1; %randi(dim2);

% Electrode and bin: Always use a random value.
rEle = randi(nElectrode); 
rBin = randi(nBinPerTrial);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['Checking data for cell array element {' ...
    num2str(rCellRow) ', ' num2str(rCellCol) '}:'])
disp(['Observation ' num2str(rObs) ...
    ', harmonic ' num2str(rHarm) ', bin ' num2str(rBin) ...
    ', electrode ' num2str(rEle) '...'])

% Get the rotation angle for said conditions and compute matrix
checkAngle = allR_cell{rCellRow, rCellCol}(rHarm, rObs);
checkRotation = createRotationMatrix(checkAngle); % 2 x 2 matrix

% Get the input data for said conditions
checkRealRow = (rHarm-1) * nBinPerTrial + rBin;
checkImagRow = checkRealRow + (nHarmonic * nBinPerTrial); 
checkBothRows = [checkRealRow checkImagRow];
disp(['Rotation angle applied: ' sprintf('%.2f', checkAngle/pi) 'pi'])
disp(['Rows used: ' mat2str(checkBothRows)])
checkIn = xIn_cellArray{rCellRow, rCellCol}(checkBothRows, rEle, rObs);
checkOut = checkRotation * checkIn; % Computed here by hand
functionOut = xCell_out{rCellRow, rCellCol}(checkBothRows, rEle, rObs);
assert(isequal(checkOut, functionOut), 'Values do not match! :(')
disp('Spot check confirms correct values! :)')
checkOut
functionOut
