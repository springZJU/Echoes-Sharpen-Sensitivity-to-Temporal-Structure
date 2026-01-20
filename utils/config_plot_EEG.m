%% 
windowOnset0  = [0, 500];     % ms
windowChange0 = [1000, 1500]; % ms
windowOffset0 = [2000, 2500]; % ms

windowOnset  = [0, 300]; % ms
windowChange = [1050, 1350]; % ms
windowOffset = [2000, 2300]; % ms

alphaVal = 0.05;

set(groot, "DefaultFigureWindowState", "maximized");
set(groot, "DefaultAxesFontSize", 12);
set(groot, "DefaultAxesTitleFontSize", 1.1);
set(groot, "DefaultAxesTitleFontWeight", "bold");
set(groot, "DefaultAxesXTickLabelRotation", 0);

EEGPos = EEGPos_Neuracle32;
badChs = EEGPos.ignore;

rms = path2func(fullfile(matlabroot, "toolbox/matlab/datafun/rms.m"));
rmfcn = @(x) rms(x, 2);
