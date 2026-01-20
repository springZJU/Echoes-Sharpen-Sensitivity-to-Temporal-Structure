%% Path settings

% Public repositories
addpath(genpath(".\code\MATLABUtils\"));
addpath(genpath(".\code\MATLAB-Utils\"));
initMATLABUtils;

% FieldTrip
addpath(".\code\toolbox\FieldTrip");
ft_defaults;

% EEGLAB
addpath(genpath(".\code\toolbox\EEGLAB\"));

% Multi-Channel Process
addpath(genpath('.\code\MultiChannelProcess'));

% ECOG Process
addpath(genpath(".\code\ECOGProcess\plot\"));
addpath(genpath(".\code\ECOGProcess\utils\"));

% EEG Process
addpath(genpath(".\code\EEGProcess\plot\"));
addpath(genpath(".\code\EEGProcess\utils\"));

% remove all .git folders
pathsAll = split(path, ";");
rmpath(pathsAll{contains(pathsAll, '\.git')});

% set built-in toolbox to top
addpath(pathsAll{contains(pathsAll, fullfile(matlabroot, 'toolbox'))}, '-begin');

clearvars pathsAll

%% Figure setting
% Figure window state
set(0, "DefaultFigureWindowState", "maximized");

%% 
clear;
