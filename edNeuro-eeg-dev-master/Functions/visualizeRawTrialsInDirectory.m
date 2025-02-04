function visualizeRawTrialsInDirectory(matDir, saveFigures, figDir)
% visualizeRawTrialsInDirectory(inDir, saveFigures)
% ----------------------------------------------------------------------
% Creator: Blair Kaneshiro, August 2020
% Maintainer: Blair Kaneshiro <blairbo@gmail.com>
%
% This function visualizes the Raw_*.mat files in the specified directory.
%
% INPUTS
% - matDir (required): Full path to the directory containing the .mat files 
%   of interest. If empty or not specified, the function will print an
%   error.
% - saveFigures (optional): Boolean of whether to save all the generated 
%   figures when the script finishes rendering them all. If empty or not 
%   specified, the function will print a warning and set to false.
% - figDir (optional): Full path to directory where .fig files should be
%   written, if saving figures. If empty or not specified but saveFigures
%   is true, the function will print a warning and save the .fig files into
%   the same directory as the .mat files (i.e., in matDir).
%
% OUPTUTS
% - None
%
% Usage (matDir and figDir are paths to source and destination directories)
% - Image the matrices, don't save as .fig files: 
%       visualizeRawTrialsInDirectory(matDir)
% - Image the matrices, save .fig files in same directory as .mat files:
%       visualizeRawTrialsInDirectory(matDir, 1)
% - Image the matcies, save .fig files in other specified directory: 
%       visualizeRawTrialsInDirectory(matDir, 1, figDir)
%%
assert(nargin >= 1,...
    'Function requires at least one input: Directory of input .mat files.');
disp(['Input directory with .mat files: ' pwd])

if nargin < 2 || isempty(saveFigures)
    warning(['Not saving figures. Set second input to true to save figures.']);
    saveFigures = false;
elseif nargin < 3 || isempty(figDir)
   warning(['Saving figures in same directory as .mat files: ' ...
       matDir]);
end

%%
cd(matDir)
fl = dir(['Raw_*.mat']);
fName = {fl.name};

close all
for f = 1:length(fName)
    thisFnIn = fName{f};
    disp(['Loading file ' num2str(f) '/' num2str(length(fName)) ': ' ...
        thisFnIn])
    
    thisX = load(thisFnIn)
    figure()
    imagesc(abs(thisX.RawTrial'))
    colorbar
    set(gca, 'fontsize', 16)
    title(thisFnIn, 'interpreter', 'none')
    xlabel('Time sample'); ylabel('Electrode number')
    
    if saveFigures
       thisFnOut = [thisFnIn(1:(end-4)) '_RawTrial.fig']
       savefig(thisFnOut)
    end
    
    clear this*
end

    
end
