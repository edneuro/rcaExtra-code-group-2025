% run_convertPhaseRadiansToLatencyMsec.m
% ------------------------------------------
% Creator: Blair Kaneshiro, Sep 2020
% Maintainer: Blair Kaneshiro <blairbo@gmail.com>
%
% Examplme call to the function convertPhaseRadiansToLatencyMsec.

clear all; close all; clc

% Generate some data
temp = 0:pi/2:6*pi;
p = repmat(temp(:), 1, 3)

% p =
% 
%          0         0         0
%     1.5708    1.5708    1.5708
%     3.1416    3.1416    3.1416
%     4.7124    4.7124    4.7124
%     6.2832    6.2832    6.2832
%     7.8540    7.8540    7.8540
%     9.4248    9.4248    9.4248
%    10.9956   10.9956   10.9956
%    12.5664   12.5664   12.5664
%    14.1372   14.1372   14.1372
%    15.7080   15.7080   15.7080
%    17.2788   17.2788   17.2788
%    18.8496   18.8496   18.8496

%% Function call with matrix and scalar inputs

% In the case where all the phases are relative to a single frequency, we
% can call the function with input 1: Matrix of phases and input 2: Scalar
% of the single frequency. (For this case, since every column of the input
% phase matrix is the same, every column of the output will be the same
% also). 

% Our phases go up to 6*pi, so if we do frequency = 6 Hz, the maximal
% output will be 0.5 seconds (would take 12pi, i.e. 6 cycles, to reach a
% latency of 1 second).

l1 = convertPhaseRadiansToLatencyMsec(p, 6)

% l1 =
% 
%          0         0         0
%    41.6667   41.6667   41.6667
%    83.3333   83.3333   83.3333
%   125.0000  125.0000  125.0000
%   166.6667  166.6667  166.6667
%   208.3333  208.3333  208.3333
%   250.0000  250.0000  250.0000
%   291.6667  291.6667  291.6667
%   333.3333  333.3333  333.3333
%   375.0000  375.0000  375.0000
%   416.6667  416.6667  416.6667
%   458.3333  458.3333  458.3333
%   500.0000  500.0000  500.0000

%% Function call with two matrix inputs

% The function can also be called with each element of the phase matrix
% mapped to a particular frequency. 

% For instance, suppose that the columns of the p matrix reflect
% frequencies of 1, 3, and 6 Hz
fM = repmat([1 3 6], size(p, 1), 1)

% fM =
% 
%      1     3     6
%      1     3     6
%      1     3     6
%      1     3     6
%      1     3     6
%      1     3     6
%      1     3     6
%      1     3     6
%      1     3     6
%      1     3     6
%      1     3     6
%      1     3     6
%      1     3     6

% Call the function with two matrix inputs and it will pointwise compute
% the phase according to the corresponding frequency.
l2 = convertPhaseRadiansToLatencyMsec(p, fM)

% l2 =
% 
%    1.0e+03 *
% 
%          0         0         0
%     0.2500    0.0833    0.0417
%     0.5000    0.1667    0.0833
%     0.7500    0.2500    0.1250
%     1.0000    0.3333    0.1667
%     1.2500    0.4167    0.2083
%     1.5000    0.5000    0.2500
%     1.7500    0.5833    0.2917
%     2.0000    0.6667    0.3333
%     2.2500    0.7500    0.3750
%     2.5000    0.8333    0.4167
%     2.7500    0.9167    0.4583
%     3.0000    1.0000    0.5000