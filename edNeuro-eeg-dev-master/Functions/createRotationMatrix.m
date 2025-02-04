function R = createRotationMatrix(theta)
% R = createRotationMatrix(theta)
% -----------------------------------------
% Creator: Blair Kaneshiro, March 2022
% Maintainer: Blair Kaneshiro
%
% This function takes in an angle theta (in radians) and returns a 2D
% rotation matrix.
%
% Input (required)
% - theta: Angle, in radians.
%
% Output
% - R: A 2D rotation matrix
%
% NOTE: The output rotation matrix R is intended to be used as a
% left-multiplier in conjunction with a COLUMN vector v, where v are the x,
% y coordinates of the vector to be rotated: 
% [xR = Rv = [cos(theta) -sin(theta) * [x  = [x*cos(theta) - y*sin(theta)
%  yR]        sin(theta)  cos(theta)]   y]    x*sin(theta) + y*cos(theta)]

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
% And should be multiplied to the right of R:
% [xR = Rv = [cos(theta) -sin(theta) * [x  = [x*cos(theta) - y*sin(theta)
%  yR]        sin(theta)  cos(theta)]   y]    x*sin(theta) + y*cos(theta)]

R = [cos(theta) -sin(theta); 
    sin(theta)   cos(theta)];