% run_phaseScramble3dMatrix.m
% -----------------------------
% Blair - March 31, 2022
%
% Script to test and call the phaseScramble3dMatrix function.

clear all; close all; clc

% Load dev data
IN = load('sensorData_bins1dimension.mat');
xIn_cellArray = IN.sensorData; % 48 x 3 cell array
xIn_single3dMatrix = xIn_cellArray{1,1}; % 100 x 128 x 8 matrix
clear IN

%% Call function to randomize a single 3d matrix

% Function inputs are 3d input data, nBinsPerObservation, debugMode
[x3d_out, allR] = phaseScramble3dMatrix(xIn_single3dMatrix, [], 1);

%% Spot check some values
clc

[nFeature, nElectrode, nObs] = size(xIn_single3dMatrix);
nBinPerTrial = 10;
nHarmonic = nFeature / (2 * nBinPerTrial);

%%%%%%% Make some random values %%%%%%%%%

% Trial and harmonic: Can set to non-random value to confirm they use a 
%   consistent random angle.
rObs = 1; %randi(nObs);
rHarm = 2; %randi(nHarmonic);

% Electrode and bin: Always use a random value.
rEle = randi(nElectrode); 
rBin = randi(nBinPerTrial);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(['Checking data for observation ' num2str(rObs) ...
    ', harmonic ' num2str(rHarm) ', bin ' num2str(rBin) ...
    ', electrode ' num2str(rEle) '...'])

% Get the rotation angle for said conditions and compute matrix
checkAngle = allR(rHarm, rObs);
checkRotation = createRotationMatrix(checkAngle); % 2 x 2 matrix

% Get the input data for said conditions
checkRealRow = (rHarm-1) * nBinPerTrial + rBin;
checkImagRow = checkRealRow + (nHarmonic * nBinPerTrial); 
checkBothRows = [checkRealRow checkImagRow];
disp(['Rotation angle applied: ' sprintf('%.2f', checkAngle/pi) 'pi'])
disp(['Rows used: ' mat2str(checkBothRows)])
checkIn = xIn_single3dMatrix(checkBothRows, rEle, rObs);
checkOut = checkRotation * checkIn; % Computed here by hand
functionOut = x3d_out(checkBothRows, rEle, rObs);
assert(isequal(checkOut, functionOut), 'Values do not match! :(')
disp('Spot check confirms correct values! :)')
checkOut
functionOut
