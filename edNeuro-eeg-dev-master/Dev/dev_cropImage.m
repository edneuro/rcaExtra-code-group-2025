% dev_cropImage.m
% -----------------
% Blair - June 4, 2020

clear all; close all; clc

load OUT
W = OUT.W;
clear OUT

nRow = 2;
nCol = 3;
nSubplot = nRow * nCol;

figure()
S = subplot(1, 2, 1)
plotOnEgi([W(:,1); nan(4,1)])
S.Position = [0 -0.25 0.48 1.5]

S = subplot(1, 2, 2)
plotOnEgi([W(:,1); nan(4,1)])
S.Position = [0.5 -0.25 0.48 1.5]