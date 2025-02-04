function [x3dOut, allR] = phaseScramble3dMatrix(x3dIn, nBinsPerObs, debugMode)
% [x3dOut, rPhases] = phaseScramble3dMatrix(x3dIn, nBinsPerObs, debugMode)
% ------------------------------------------------------------------------
% Creator: Blair Kaneshiro, March-April 2022
% Maintainer: Blair Kaneshiro
%
% This function takes in a 3D feature x electrode x observation matrix of
% frequency-domain, sensor-space data of the rcaExtra pipeline. It outputs
% a surrogate data matrix of the same size, according to the following
% phase-scrambling procedure: 
%   - A random phase offset is generated for each observation and harmonic.
%   - Data from every electrode and bin are rotated by that phase offset.
%
% INPUTS
%   - x3dIn (required): A 3D matrix whose dimensions are nFeature x
%   nElectrode x nObservation. Features are assumed to be real and 
%   imaginary Fourier coefficients for one or more bins and/or harmonics as
%   structured in the rcaExtra pipeline: 
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
%   - x3dOut: A 3D matrix of the same size as x3dIn, containing
%   phase-scrambled data.
%   - allR: A matrix of size nHarmonic x nObservation containing the 
%   random phase angle applied to all bins and electrodes for that 
%   harmonic and observation. This can be used to verify the function is 
%   working correctly.
%% Check inputs

% Make sure the data matrix was provided.
assert(nargin >= 1, 'This function requires at least one input.');

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
% keyboard

%% Get variable sizes

% Input data matrix is feature x electrode x observation
[nFeature, nElectrode, nObservation] = size(x3dIn);

% Compute nHarmonic from nFeature and nBinsPerObs:
% We know that nFeature = 2(re/im) x nBinsPerObs x nHarmonic.
nHarmonic = nFeature / (nBinsPerObs * 2);

%% Initialize outputs

x3dOut = nan(size(x3dIn)); % Phase-scrambled data - same size as input
allR = nan(nHarmonic, nObservation); % Rotation matrices - harmonic x obs

%% Do the calculation

% Iterate through every observation (dimension 3)
for o = 1:nObservation
    
    % Get the current data observation
    currObservation = x3dIn(:, :, o); % nFeature x nElectrode
    
    if debugMode
        disp(' ')
        disp(['- - - - - OBSERVATION ' num2str(o) ' - - - - -'])
    end
    
    % Iterate through every harmonic (inside dimension 1)
    for h = 1:nHarmonic
        
        % Create rotation matrix for current observation and harmonic. It
        % will be applied to every electrode and bin.
        thisRandomTheta = rand * 2*pi;
        thisR = createRotationMatrix(thisRandomTheta);
        
        if debugMode
           disp(' ')
           disp(['- * - * - * Harmonic ' num2str(h) ' * - * - * -'])
           disp(['Rotation angle: ' sprintf('%.2f', thisRandomTheta/pi) 'pi'])
        end
        
        % Save current rotation angle into aggregated matrix
        allR(h, o) = thisRandomTheta;
        
        % Iterate through every bin
        for b = 1:nBinsPerObs
            
            % Now that we are in here, we want to grab the 2 rows
            % corresponding to the real and imaginary coefficient for the
            % current harmonic and bin. We'll grab all columns (all
            % electrodes).
            
            thatRealRow = (h-1) * nBinsPerObs + b; % Row 1 (real coeff)
            thatImagRow = thatRealRow + (nHarmonic * nBinsPerObs); % Row 2 (imag coeff)
            thatRowsUse = [thatRealRow thatImagRow];
            if debugMode
                disp(['Harmonic ' num2str(h) ', bin ' num2str(b) ':'])
                disp(['Grabbing rows ' mat2str(thatRowsUse) '.'])
            end
            
            % Grab the data for those rows.
            thatXIn = currObservation(thatRowsUse,:); % 2 x nElectrodes
            thatXOut = thisR * thatXIn; % [2 x 2] * [2 x nElectrodes]
            
            % Put the output data into the main output matrix.
            % Use same rows we grabbed from ; all electrodes ; current obs
            x3dOut(thatRowsUse, :, o) = thatXOut;
            
            clear that*
        end
        
        clear this*
        
    end
    
    clear curr*
    
end