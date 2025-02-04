function [yHat, w] = predictContinuousWithRegression(y, X, addIntercept)
% [yHat, w] = predictContinuousWithRegression(y, X, addIntercept)
% ------------------------------------------------------------------------
% May 2020
% Author: Blair Kaneshiro, blairbo@gmail.com
%
% This is a simple function to perform OLS regression to predict values of
% an output vectory y (length nObservations) from an input matrix X (size
% nObservations by nFeatures).
%
% Inputs:
% - y (required): Vector of outcome measures. This vector should be
%   of length nObservations.
% - X (required): Matrix of data predictors. This should be a matrix 
%   of size nObservations by nFeatures.
% - addIntercept (optional): Whether to add a column of 1's to the data 
%   matrix to serve as the intercept during regression. If not specified or
%   empty, the function will print a message and set to true.
%
% Outputs:
% - yHat: Vector of predicted outcomes. Will be the same length as y.
% - w: Vector of predictor feature weightings (a.k.a. the betas). Will be a
%   vector of length nFeatures.
%
% If the row dimension of input matrix X does not match the length of input
%   vector y, the function will attempt to match the dimensions by
%   transposing X. If the row dimension does not match after that, the
%   function will return an error.

%% For live function, skip during development

if nargin < 2
    error('Function requires both an output vector ''y'' and data matrix ''X''.');
elseif nargin < 3 || isempty(addIntercept)
    disp('Third input ''addIntercept'' not specified; setting to ''true''.');
    addIntercept = true;
end

%% For development, comment out when running as function

% clear; close all; clc
% nObs = 100; nFeat = 5;
% % Make some fake data
% rng(1)
% XTrue = randi([-20 20], [nObs, nFeat]); % nObs x nFeat
% betaTrue = [.1 -10 5 2.98 0.0001]'; % nFeat x 1
% y = XTrue * betaTrue; % nObs x 1
% X = XTrue + (rand(size(XTrue)) - 0.5) * 2;
% addIntercept = 1

%%
% Make sure y is a vector
assert(isvector(y),...
    'Input y should be a vector of length nTrials.')
    
% Make sure X is a 2D matrix
assert(ndims(X) == 2,...
    'Input X should be a 2D trial-by-feature matrix.')

% If dimension 1 size of X does not equal length of y, attempt transposing
%   X to get the dimensions to match.
try
    assert(size(X, 1) == length(y));
catch
    X = transpose(X);
    assert(size(X, 1) == length(y),...
        'Number of rows of input matrix X should equal the number of entries in input vector y.')
    warning('Input matrix X is being transposed to match the length of input vector y.');
end

% If the addIntercept flag is on, add a column of 1's to the X matrix
if addIntercept
    X = [X ones(size(X, 1), 1)];
end

w = pinv(X) * y;

% Here are 3 ways to do the regression:
% beta = inv(X'*X)* X'*y % nFeat x 1
% betaNoiseFn = regress(y, X)
% betaNoisePinv = pinv(X) * y

yHat = X * w;