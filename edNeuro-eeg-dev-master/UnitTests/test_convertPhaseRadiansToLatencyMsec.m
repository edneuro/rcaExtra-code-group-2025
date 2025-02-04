% test_convertPhaseRadiansToLatencyMsec.m
% ------------------------------------------
% Creator: Blair Kaneshiro, Sep 2020
% Maintainer: Blair Kaneshiro <blairbo@gmail.com>
%
% Testing the function convertPhaseRadiansToLatencyMsec.

clear all; close all; clc

% Generate some data
temp = 0:pi/2:6*pi;
p = repmat(temp(:), 1, 6)
fM = repmat(1:6, size(p, 1), 1)

% Function call with two matrix inputs
lM = convertPhaseRadiansToLatencyMsec(p, fM)

% Function call with matrix and scalar inputs
lS = convertPhaseRadiansToLatencyMsec(p, 3)

%% Bad function call: No inputs

convertPhaseRadiansToLatencyMsec

%% Bad function call: 1 input

convertPhaseRadiansToLatencyMsec(p)

%% Bad function call: Inputs not of compatible size

convertPhaseRadiansToLatencyMsec(p, [1 2])