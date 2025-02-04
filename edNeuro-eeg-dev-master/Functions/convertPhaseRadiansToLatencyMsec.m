function latencyMsec = convertPhaseRadiansToLatencyMsec(phaseRadians, freqHz)
% latencyMsec = convertPhaseRadiansToLatencyMsec(phaseRadians, freqHz)
% -----------------------------------------------------------------------
% Creator: Blair Kaneshiro, Sep 2020
% Maintainer: Blair Kaneshiro <blairbo@gmail.com>
%
% This function converts one or more phase angles to latencies.
%
% INPUTS (required)
% - phaseRadians: Phase angle(s) in radians. Can be a scalar, vector, or
%   matrix.
% - freqHz: Frequency/frequencies in Hz. Can be a scalar, in which case the
%   same frequency is assumed for all entries of phaseRadians; or can be
%   the same size as phaseRadians, in which case each element freqHz will
%   be pointwise applied to each element of phaseRadians.

% Make sure there are two inputs
assert(nargin == 2, ...
    'The function requires two inputs: A phase variable and a frequency variable.');

% Input 2 should be a scalar or the same size as input 1
assert(isscalar(freqHz) || isequal(size(phaseRadians), size(freqHz)), ...
    'The second input (freqHz) must be a scalar or be the same size as the first input (phaseRadians).')

% If the freqHz input is a scalar, make it the same size as phaseRadians
if isscalar(freqHz)
   freqHz = repmat(freqHz, size(phaseRadians)); 
end

% For freq f and phase phi, msec = phi / (2*pi*f)
latencyMsec = phaseRadians ./ (2 * pi * freqHz) * 1000;