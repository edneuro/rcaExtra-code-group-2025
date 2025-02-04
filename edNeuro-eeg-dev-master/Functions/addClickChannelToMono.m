function xStereo = addClickChannelToMono(xMono, fs, clickStartMsec, clickAmpl, clickLenMsec)
% xStereo = addClickChannelToMono(xMono, fs, clickStartMsec, clickAmpl, clickLenMsec)
% -----------------------------------------------------------------------------------
% Creator: Blair Kaneshiro, June 2021
% Maintainer: Blair Kaneshiro
%
% This function takes in a vector of mono audio and the audio sampling
% rate, creates a second audio channel of intermittent square-wave pulses
% (clicks), and returns a stereo audio variable.
%
% INPUTS (required)
% - xMono: Vector of mono audio 
% - fs: Sampling rate of the audio
%
% INPUTS (optional)
% - clickStartMsec: Scalar or vector of click times, in msec (e.g., [1000,
%   2000, 3000]. 
%   - If not entered or empty, the function will specify a click at every 
%     second, starting at 1 second in (i.e., [1000, 2000, ...]). 
%   - If the user enters a vector of times that exceed the length of the 
%     audio file, the function will print a warning and ignore excess time 
%     stamps.
% - clickAmpl: Scalar amplitude of the click.
%   - If not entered or empty, the function will set click amplitues to
%     0.9.
%   - Should be a value less than 1; if the user enters a value greater 
%     than or equal to 1, the function will print a warning and set 
%     amplitude to 0.999.
%
% OUTPUTS
% - xStereo: A stereo audio variable. The first channel is the input xMono.
%   The second channel is the click channel.


%% Verify inputs and assign defaults if needed

% User must enter at least input mono audio and sampling rate
assert(nargin >= 2, ...
    'At least two inputs are required: Mono audio variable and sampling rate.');
xMono = xMono(:);

% Default click length is 20 msec
if nargin < 5 || isempty(clickLenMsec)
    clickLenMsec = 20;
end

% Here is the click length in time samples
clickLenSamp = round(clickLenMsec / 1000 * fs);

% Default click amplitude is 0.9
if nargin < 4 || isempty(clickAmpl)
    clickAmpl = 0.9; 
end

% Default click start times are every second, starting at 1 second in
if nargin < 3 || isempty(clickStartMsec)
    xMonoLenMsecUsable = length(xMono) / fs * 1000 - clickLenMsec;
    clickStartMsec = 1000:1000:xMonoLenMsecUsable;
end

%% Create clicks and embed in vector

% Click start times, in samples
clickStartSamp_all = round(clickStartMsec / 1000 * fs);

% Trim off excess ones (may happen if user inputs the times)
clickStartSamp = clickStartSamp_all(clickStartSamp_all + clickLenSamp <= length(xMono));
if length(clickStartSamp) < length(clickStartSamp_all)
    warning('Specified click onset times exceed length of audio file. Ignoring excess entries.');
end

% Correct amplitude if it is too large
if clickAmpl >= 1
    warning('Click amplitude will cause clipping. Setting to 0.999.');
    clickAmpl = 0.999;
end

% Expand click onset times to a vector of length clickLenSamp --> matrix
clickSampMatrix = bsxfun(@plus, clickStartSamp, (0:(clickLenSamp-1))');
clickSampVector = clickSampMatrix(:); % Reshape to vector

% Initialize click channel (zeros) and fill in click values
xClick = zeros(size(xMono)); % Initialize the click vector
xClick(clickSampVector) = clickAmpl; % Fill in click samples w/ amplitude

% Append to audio mono input <-- this is the output
xStereo = [xMono xClick]; 