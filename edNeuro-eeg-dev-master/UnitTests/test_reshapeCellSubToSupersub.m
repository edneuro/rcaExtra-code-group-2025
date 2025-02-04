% test_reshapeCellSubToSupersub.m
% -----------------------------------
% Maintainer: Blair Kaneshiro <blairbo@gmail.com>
% Creator: Blair Kaneshiro, Sep 2020
%
% Unit testing the super-subjects reshaping function with synthetic data
%   and actual data.


%% Synthesize some data
rng('shuffle')
clear all; close all; clc

nSubs = 3;
nCondt = 2;

nFeat = 6;
nElectrode = 128;
nTrials = randi(10, nSubs, nCondt);

for s = 1:nSubs
    for c = 1:nCondt
        xIn{s, c} = rand([nFeat nElectrode nTrials(s, c)]);
    end
end

% Make subject 1, condition 2 an empty element
xIn{1, 2} = []; nTrials(1,2) = 0

%% Call the function

[xSuperSub, subV] = reshapeCellSubToSupersub(xIn);

%% Data check: Number of trials per s, c match for input and output
for s = 1:nSubs
    for c = 1:nCondt
        tempIn = nTrials(s, c);
        tempOut = sum(subV{c} == s);
        disp(['Sub ' num2str(s) ', condt ' num2str(c) ': ' ...
            num2str(tempIn) ' input trials, ' num2str(tempOut) ' output trials.'])
        assert(isequal( ...
            tempIn, tempOut),...
            ['Mismatch in number of trials for condition ' ...
            num2str(c) ', subject ' num2str(s) '.'])
        
        clear temp
        
    end
end

%% Data check: Retrieved s, c data matches for input and output

clc
for c = 1:nCondt
   for s = 1:nSubs
       thisIn = xIn{s,c};
       thisOutIdx = sum(nTrials(1:(s-1),c)) + (1:(nTrials(s,c)));
       disp(['Condt ' num2str(c) ', sub ' num2str(s) ': ' ...
           mat2str(thisOutIdx)])
       if isempty(thisOutIdx), continue; end
       thisOut = xSuperSub{c}(:, :, thisOutIdx);
       assert(isequal(thisIn, thisOut), ...
           'Input and output don''t match!')
       pause 
   end
end

%% Data check: Recover input data by calling both functions

xBackToSub = reshapeCellSupersubToSub(xSuperSub, subV);
isequal(xIn, xBackToSub)