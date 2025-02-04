% edNeuroDev_rotationMatrixDev2022.m
% ------------------------------------
% Blair - March 22, 2022
%
% Trying out a rotation matrix and validating on synthetic data.
%
% See also createRotationMatrix


% From wikipedia https://en.wikipedia.org/wiki/Rotation_matrix
% "Rotate points in the xy plane counterclockwise through an angle theta
% with respect to the positive x axis about the origin of a two-dimensional
% Cartesian coordinate system
% R = [cos(theta) -sin(theta)
%      sin(theta)  cos(theta)]
%
% The point should be written as a column vector:
% v = [x
%      y]
%
% And should be multiplied to the right of V:
% [xR = Rv = [cos(theta) -sin(theta) * [x  = [x*cos(theta) - y*sin(theta)
%  yR]        sin(theta)  cos(theta)]   y]    x*sin(theta) + y*cos(theta)]

%% Example: Rotate zero-degree unit vector by 30 degrees and plot

clear all; close all; clc
v = [1; 0];
rotateTheta = [pi/6];

R = createRotationMatrix(rotateTheta);
Rv = R * v;

figure()
polaraxes
polarplot(v(1) + j*v(2), '.b', 'markersize', 20)
hold on
polarplot(Rv(1) + j*Rv(2), '.r', 'markersize', 20)
legend('original', 'rotated')
title(['Rotate blue to red: ' sprintf('%.2f', rad2deg(rotateTheta)) ' degrees'])

%% Generalize to random starting point and rotation angle

% Run this cell over and over to look at different randomized results!

clear all; close all; clc

%%%% Random stuff %%%%%%
rng('shuffle')
thetaStart = rand * 2*pi;   % Uniform random angle from 0:2pi
rStart = rand * 3;      % Uniform random amplitude from 0:3
rotateTheta = rand * 2*pi;  % Uniform random rotation angle from 0:2pi
%%%%%%%%%%%%%%%%%%%%%%%%%

[x, y] = pol2cart(thetaStart, rStart); % Takes in angle and radius
v = [x; y];

R = createRotationMatrix(rotateTheta);
Rv = R * v;

% Plot input and output
figure()
polaraxes
polarplot(v(1) + j*v(2), '.b', 'markersize', 20)
hold on
polarplot(Rv(1) + j*Rv(2), '.r', 'markersize', 20)
legend('original', 'rotated')
title(['Rotate blue to red: ' sprintf('%.2f', rad2deg(rotateTheta)) ' degrees'])

%% Confirm that this works on a matrix of starting points.
close all; clc

nPoints = 5;
IN = nan(2,nPoints);

%%%%%%%%%%%%% Initialize random stuff %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:nPoints
    thisThetaStart = rand * 2*pi;   % Uniform random angle from 0:2pi
    thisRStart = rand * 3;      % Uniform random amplitude from 0:3
    [thisX, thisY] = pol2cart(thisThetaStart, thisRStart);
    IN(:, i) = [thisX; thisY];
end

% We want to apply the same rotation angle to each starting poing
rotateTheta = rand * 2*pi;  % Uniform random rotation angle from 0:2pi
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create the rotation matrix
R = createRotationMatrix(rotateTheta);

% Apply the rotation in matrix form
OUT_matrix = R * IN;

% Apply the rotation to each point in a loop
OUT_loop = nan(size(OUT_matrix));
for i = 1:nPoints
    OUT_loop(:,i) = R * IN(:,i);
end

OUT_matrix
OUT_loop
assert(isequal(OUT_matrix, OUT_loop), 'Outputs do not match!!')

% Plot the outputs to see if the shift angles look the same
colVec = {'b', 'r', 'g', 'm', 'c', 'k'};
for i = 1:nPoints
    figure(i)
    polaraxes
    polarplot(IN(1,i) + j*IN(2,i), '.',... 
        'markersize', 20, 'color', colVec{i})
    hold on
    polarplot(OUT_matrix(1,i) + j*OUT_matrix(2,i), '+',... 
        'markersize', 20, 'color', colVec{i})
    legend('original', 'rotated')
    title(['Rotate . to +: ' sprintf('%.2f', rad2deg(rotateTheta)) ' degrees'])
    rlim([0 3])
end