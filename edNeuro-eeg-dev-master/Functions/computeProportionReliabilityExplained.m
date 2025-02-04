function [PropRel, rankUse] = computeProportionReliabilityExplained(dGen, Rxx, Ryy, Rxy)
% [PropRel, rankUse] = computeProportionReliabilityExplained(dGen, Rxx, Ryy, Rxy)
% --------------------------------------------------------------------------------
% Maintainer: Blair Kaneshiro <blairbo@gmail.com>
% Creator: Blair Kaneshiro
%
% This function computes the proportion of reliability explained based on
%   the eigenvalues (dGen) and total matrix rank to consider.
%
% INPUTS (required)
% - dGen: Vector of RCA coefficients (eigenvalues).
% - Rxx: Within-trials xx covariance matrix.
% - Ryy: Within-trials yy covariance matrix.
% - Rxy: Across-trials covariance matrix.
%
% OUTPUTS
% - PropRel: Struct with two fields
%   - PropRel.individual 
%   Vector of proportion of reliability explained by
%   individual components (element 1 is the proportion of reliability
%   expoained by only the 1st element, element 2 is the proportion of
%   reliability explained by only the 2nd element, etc).
%   - PropRel.cumulative 
%   Vector of cumulative proportion of reliability 
%   explained (element 1 is the proportion of reliability explained by the 
%   1st component, element 2 is the proportion of reliability explained by 
%   the first 2 components collectively, etc).
% - rankUse: The effective rank that was used in the calculation.
%
% This computation follows Eq. 8 from Dmochowski et al. (2015),
%   Maximally Reliable Spatial Filtering of Steady-State Visual Evoked
%   Potentials. NeuroImage 109, p. 63-72.

%%%%%%%%%%%%%%% Data checks %%%%%%%%%%%%%%%
% We need 4 inputs
assert(nargin == 4,... 
    'The function requires 4 inputs: dGen, Rxx, Ryy, Rxy.');

% The dGen input should be a vector
assert(isvector(dGen),...
    'The first input (dGen) should be a vector.');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% Compute D = min[ rank(Rxy), rank(Rxx + Ryy) ]
rankUse = min(rank(Rxy), rank(Rxx + Ryy));

% Make sure the length of dGen spans D
assert(length(dGen) >= rankUse,...
    ['The covariance matrix rank (' num2str(rankUse) ... 
    ') exceeds the length of the dGen vector (' num2str(length(dGen))... 
    '). Please input the full dGen vector with length nElectrodes.'])
% keyboard
% Denominator is a constant: The sum of D largest elements of dGen.
dGenUse = sort(dGen, 'descend');

% Here is the proportion reliability explained: Each dGen value divided by
%   the total sum of the D largest elements of dGen.
PropRel.individual = dGenUse(1:rankUse) / sum(dGenUse(1:rankUse));

% The cumulative sum of the D largest elements of dGen divided by the 
%   total sum of the D largest elements of dGen.
PropRel.cumulative = cumsum(dGenUse(1:rankUse)) / sum(dGenUse(1:rankUse));