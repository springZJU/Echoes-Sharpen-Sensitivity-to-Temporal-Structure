ccc;
addpath(genpath("D:\Lab members\Public\code\MATLAB Utils - integrated"), "-begin");
%% Parameters
run(".\utils\config_plot_EEG.m");

chIdx = ~ismember(EEGPos.channels, badChs);

colors = cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false);

margins = [0.05, 0.05, 0.1, 0.1];
paddings = [0.01, 0.03, 0.01, 0.01];

set(0, "DefaultAxesFontSize", 14);

%% Load
pID = 311;
load('.\Fig3chData 311.mat')
load('.\Fig3Data311.mat');
load('.\Fig3RMChange 311.mat');
load('.\Fig3stats.mat');

fs = data(1).fs;
window = data(1).window;
data = {data.chData}';
ICI    = unique([data{1}.ICI])';
level  = unique([data{1}.level])';

%% Plot & Export - PDF
% Fig3A
chDataCompare = [chData(length(ICI)); chData(length(ICI)*2); chData(length(ICI)*3)];
chDataCompare(1).color = [0, 0, 0] / 255;
chDataCompare(2).color = [0, 100, 255] / 255;
chDataCompare(3).color = [255, 100, 100] / 255;

chDataCompare(1).legend = "level 0";
chDataCompare(2).legend = "level 1";
chDataCompare(3).legend = "level 2";

exampleCh = 'P4';
exampleChIdx = find(strcmpi(EEGPos.channelNames, exampleCh));
t = linspace(window(1), window(2), size(chDataCompare(1).chMean, 2))';

FigWave = plotRawWaveMulti(chDataCompare, window, [], [1, 1], exampleChIdx, "LineWidth", 0.5);
addLines2Axes(struct("X", {0; 1000}, "color", [255, 195, 0] / 255, "width", 0.5));
xlim([-200, 1500]);
xticks([-200, 0, 500, 1000, 1500]);
ylim([-3, 3]);
yticks(-3:3);
b = addBars2Axes(t(stats.mask), [255, 255, 128] / 255, 0.7); uistack(b, "bottom");
b = addBars2Axes(windowChange(1):windowChange(2), [192, 192, 192] / 255, 0.4); uistack(b, "bottom");
title(exampleCh);
xlabel("Time from onset (ms)");
ylabel("Amplitude (\muV)")
legend off;
setAxesStyle;
exportFigure2PDF(FigWave, '.\Figures\Figure3A.pdf', 90, 35);

% Fig3B
FigTopo = figure;
for dIndex = 1:length(ICI) % change level1
    axChange(dIndex, 1) = mu.subplot(3, length(ICI), dIndex );
    val = mean(RM_change{dIndex, 1}, 2);
    params = topoplotConfig(EEGPos, [], 0, 15);
    topoplot(val, EEGPos.locs, params{:});
    title(num2str(ICI(dIndex)), "Interpreter", "none");
end

for dIndex = 1:length(ICI) % change level2
    axChange(dIndex, 2) = mu.subplot(3, length(ICI), dIndex + length(ICI));
    val = mean(RM_change{dIndex, 2}, 2);
    params = topoplotConfig(EEGPos, [], 0, 15);
    topoplot(val, EEGPos.locs, params{:});
    % title(['level1_', num2str(ICI(dIndex))], "Interpreter", "none");
end

for dIndex = 1:length(ICI) % change level3
    axChange(dIndex, 3) = mu.subplot(3, length(ICI), dIndex + 2*length(ICI));
    val = mean(RM_change{dIndex, 3}, 2);
    params = topoplotConfig(EEGPos, [], 0, 15);
    topoplot(val, EEGPos.locs, params{:});
    % title(['level2_', num2str(ICI(dIndex))], "Interpreter", "none");
end
colormap("jet")
mu.colorbar
scaleAxes("c", [0.5, 1.7], "ignoreInvisible", false);
setAxesStyle(axChange)
exportFigure2PDF(FigTopo, '.\Figures\Figure3B.pdf', 90, 40);

%% Tuning - RM
boxplotLineSettingsPDF = {"SymbolParameters", {'SizeData', 3, "LineWidth", 0.05}, ...
                          "BoxParameters", {'LineWidth', 0.3}, ...
                          "Notch", "on", ...
                          "IndividualDataPoint", "show", ...
                           "Outlier", "hide"};

FigRM = figure;

% 311 Contrast
ax = mu.subplot(1, 3, 1, "alignment", "left-center");
x1 = cellfun(@(x) mean(x(chIdx, :), 1)', RM_change(:, 1), "UniformOutput", false);
x1 = cat(2, x1{:});
x2 = cellfun(@(x) mean(x(chIdx, :), 1)', RM_change(:, 2), "UniformOutput", false);
x2 = cat(2, x2{:});
x3 = cellfun(@(x) mean(x(chIdx, :), 1)', RM_change(:, 3), "UniformOutput", false);
x3 = cat(2, x3{:});
x = {x1, x2, x3};

mu.boxplot(x, ...
              "Colors",  {[0, 0, 0] / 255, [0, 100, 255] / 255, [255, 100, 100] / 255}, ...
              "CategoryLabels", arrayfun(@num2str, ICI(:), "UniformOutput", false), ...
              boxplotLineSettingsPDF{:}, ...
              "CategorySpace", 0.4, "GroupSpace", 0.1);
ylim([0.5, 2.5]);
yticks(0.5:0.5:2.5);
title('RM Contrast');
xticks(1:5);
xlim([.5, 5.5]);
xticklabels(string([0, 0.25, 0.5, 0.75, 1.5]));
xlabel("ICI Difference (%)");
ylabel("Amplitude (\muV)")
setAxesStyle(ax)

% 331 Insertion
load('.\Fig3RMChange 331.mat');
ax = mu.subplot(1, 3, 2, "alignment", "left-center");
x1 = cellfun(@(x) mean(x(chIdx, :), 1)', RM_change(:, 1), "UniformOutput", false);
x1 = cat(2, x1{:});
x2 = cellfun(@(x) mean(x(chIdx, :), 1)', RM_change(:, 2), "UniformOutput", false);
x2 = cat(2, x2{:});
x3 = cellfun(@(x) mean(x(chIdx, :), 1)', RM_change(:, 3), "UniformOutput", false);
x3 = cat(2, x3{:});
x = {x1, x2, x3};

mu.boxplot(x, ...
              "Colors",  {[0, 0, 0] / 255, [0, 100, 255] / 255, [255, 100, 100] / 255}, ...
              "CategoryLabels", arrayfun(@num2str, ICI(:), "UniformOutput", false), ...
              boxplotLineSettingsPDF{:}, ...
              "CategorySpace", 0.4, "GroupSpace", 0.1);
ylim([0.5, 2.5]);
yticks(0.5:0.5:2.5);
title('RM Insertion');
xticks(1:5);
xlim([.5, 5.5]);
xticklabels([string([0, 2, 8, 32]), "Reg4-4.06"]);
xlabel("Insert Number");
ylabel("Amplitude (\muV)");
setAxesStyle(ax)

% 340 Insertion
load('.\Fig3RMChange 340.mat');
boxplotLineSettingsPDF = {"SymbolParameters", {'SizeData', 3, "LineWidth", 0.05}, ...
                          "BoxParameters", {'LineWidth', 0.3}, ...
                          "Notch", "on", ...
                          "IndividualDataPoint", "show", ...
                           "Outlier", "hide"};
% change
ax = mu.subplot(1, 3, 3, "alignment", "left-center");
x1 = cellfun(@(x) mean(x(chIdx, :), 1)', RM_change(:, 1), "UniformOutput", false);
x1 = cat(2, x1{:});
x2 = cellfun(@(x) mean(x(chIdx, :), 1)', RM_change(:, 2), "UniformOutput", false);
x2 = cat(2, x2{:});
x = {x1, x2};

defaultWhiskerParameters = {"LineStyle", get(0, "DefaultLineLineStyle"), ...
                            "LineWidth", 1, ...
                            "Color", "auto"};
defaultBoxParameters = {"LineStyle", get(0, "DefaultPatchLineStyle"), ...
                        "LineWidth", 1, ...
                        "FaceColor", "none", ...
                        "FaceAlpha", 0.5};
mu.boxplot(x, ...
              "Colors",  {[0, 100, 255] / 255,  [255, 100, 100] / 255}, ...
              "CategoryLabels", arrayfun(@num2str, (ICI(:) - ICI(1)) * 100 / ICI(1), "UniformOutput", false), ...
              boxplotLineSettingsPDF{:}, ...
              "CategorySpace", 0.4, "GroupSpace", 0.1, ...
              "WhiskerParameters", defaultWhiskerParameters, ...
              "BoxParameters", defaultBoxParameters);
ylim([0.5, 2]);
yticks(0.5:0.5:2);
title('RM realistic environment');
xticks(1:5);
xlim([.5, 5.5]);
xticklabels(string([0, 0.25, 0.5, 0.75, 1.5]));
xlabel("ICI Difference (%)");
ylabel("Amplitude (\muV)")
setAxesStyle(ax)

exportFigure2PDF(FigRM, '.\Figures\Figure3D_F.pdf', 95, 35);
