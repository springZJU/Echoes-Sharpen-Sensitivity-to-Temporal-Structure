addpath(genpath("D:\Lab members\Public\code\MATLAB Utils - integrated"), "-begin");

ccc
ICIs       = [4, 4.4, 4.6, 4.8, 5];
Vars       = [1/5, 1/10, 1/20, 1/50, 1/100, 1/625];
windowSPK  = [-50, 1500];
colors     = {[0,0,0]; [0,0,1]; [1,0,0]};
respWin = [10, 200]; respWin_Ref = [400, 800];
baseWin = [-200, 0]; baseWin_Ref = [-800, -400];

load(".\Fig5Data.mat");
ratName = "All";
exampleStr = "20250806Rat3SPR_Reflection_A5V3o5_ACCH1040";

neuExample = neuTemp(matches(string({neuTemp.dateStr}'), exampleStr));
FR_Mean = reshape(cellfun(@(x) mean(mu_calFR(x, respWin)), neuExample.ChangeSpike), 5, []);
FR_SE   = reshape(cellfun(@(x) SE(mu_calFR(x, respWin)), neuExample.ChangeSpike), 5, []);

FR_Resp    = reshape(cellfun(@(x) [mu_calFR(x, respWin) / 1000 * diff(respWin), ones(length(x), 1)], neuExample.ChangeSpike, "UniformOutput", false), 5, []);
FR_Control = cellfun(@(x) [mu_calFR(x, baseWin) / 1000 * diff(respWin), zeros(length(x), 1)], repmat(neuExample.ChangeSpike(1:5:end), 1, 5), "UniformOutput", false)';


%% plot figures

% Fig5B raster
examFig = figure;
maximizeFig
axesSPK = mu.subplot(2,1,1);
mu.rasterplot(flipud(cell2struct([neuExample.OnsetSpike(4:5:end), {[0,0,0]; [0,0,1]; [1,0,0]}], ["X", "color"], 2)), 2, "border", true);
xticklabels(""); yticks([15, 45, 75]); yticklabels(["level 2", "level 1", "level 0"]);
setAxesStyle(axesSPK, "box", "on", "TickLength", [0, 0], "XLim", [-10, 1500]);

% Fig5A PSTH
axesPSTH = mu.subplot(2,1,2);
mPSTH_Blocked(axesPSTH, neuExample.OnsetSpike(4:5:end)', windowSPK, 30, 1, "color", [0,0,0; 0,0,1; 1,0,0], "labelStr", "", "LineWidth", 0.3)
scaleAxes(axesSPK, "x", windowSPK);
scaleAxes(axesPSTH, "y");
setAxesStyle(axesPSTH);
ylim([0, 100]); yticks(0:25:100); yticklabels("auto"); ylabel("FR (Hz)"); xlabel("Time from onset (ms)")
exportFigure2PDF(examFig, '.\Figures\Figure5A.pdf', 50, 40);

% Fig5B tuning curve -Regular
tuningFig = figure;
maximizeFig
for i = 1 : 3
    errorbar(1:5, FR_Mean(:, i), FR_SE(:, i), 'Color', colors{i}, 'LineWidth', 0.5); hold on;
end
setAxesStyle;
xticks(1:5); xticklabels(string([0, 10, 15, 20, 25])); xlabel("ICI diffenrence (%)")
ylim([0, 50]); yticks(0:10:50); ylabel("FR of change response (Hz)")
exportFigure2PDF(tuningFig, '.\Figures\Figure5B.pdf', 55, 42);

%% Fig5C quiver
quiverFig = figure;
maximizeFig
diffFR = (FR_Mean(:, [2, 3]) - FR_Mean(:, 1)) ./ (FR_Mean(:, [2, 3]) + FR_Mean(:, 1));
quiver(zeros(4, 1), zeros(4, 1), diffFR(2:end, 1), diffFR(2:end, 2), 0, 'LineWidth', 0.3, 'MaxHeadSize', 0.1, 'Color', [0, 0, 0]); hold on
% quiver(0, 0, mean(diffFR(2:end, 1)), mean(diffFR(2:end, 2)), 0, 'LineWidth', 1, 'MaxHeadSize', 0.3, 'Color', [1, 0, 0]);
xlim([0, 1]); ylim([0, 1]);
xlabel("Effect of  level1");
ylabel("Effect of  level2");
setAxesStyle;
exportFigure2PDF(quiverFig, '.\Figures\Figure5C.pdf', 55, 45);
close all   


%% Fig5D-F
ccc
load('.\Fig5PopData.mat');
i = 4; % 4-4.8

% Fig5D scatter
FR_AC_Change = {popRes(1).data.FR_Mean_Raw}';
temp_Change  = cell2mat(cellfun(@(x) (x(i, [2, 3]) - x(i, 1)) ./ (x(i, [2, 3]) + x(i, 1)), FR_AC_Change, "UniformOutput", false));
temp_Change  = mu.replacevalMat(temp_Change, 0, [NaN, Inf]);

FR_AC_On     = {popRes(1).data.FR_Mean_On_Raw}';
temp_On      = cell2mat(cellfun(@(x) (x(i, [2, 3]) - x(i, 1)) ./ (x(i, [2, 3]) + x(i, 1)), FR_AC_On, "UniformOutput", false));
temp_On      = mu.replacevalMat(temp_On, 0, [NaN, Inf]);

FR_AC_Off    = {popRes(1).data.FR_Mean_Off_Raw}';
temp_Off     = cell2mat(cellfun(@(x) (x(i, [2, 3]) - x(i, 1)) ./ (x(i, [2, 3]) + x(i, 1)), FR_AC_Off, "UniformOutput", false));
temp_Off     = mu.replacevalMat(temp_Off, 0, [NaN, Inf]);

scatterFig = figure;
maximizeFig
scatter(temp_Change(:, 1), temp_Change(:, 2), 3, "red", "filled"); hold on
scatter(temp_On(:, 1), temp_On(:, 2), 3, "blue", "filled"); hold on
xticks(-1:0.5:1); yticks(-1:0.5:1)
xlim([-1, 1]); ylim([-1, 1]);

ax = gca;
ax.XAxisLocation = 'origin';  
ax.YAxisLocation = 'origin';  

xrange = xlim;
yrange = ylim;

annotation('arrow', ...
    [0.08 0.97], [0.518 0.518], ...
    'Color', 'k', 'LineWidth', 0.7, 'HeadLength', 8, 'HeadWidth', 8);

annotation('arrow', ...
    [0.518 0.518], [0.08 1], ...
    'Color', 'k', 'LineWidth', 0.7, 'HeadLength', 8, 'HeadWidth', 8);

setAxesStyle;
exportFigure2PDF(scatterFig, '.\Figures\Figure5D.pdf', 55, 45);

% Fig5E distance
histogramSettingsPDF = { "FaceColor", {[1,0,0], [0,0,1]}, ...
                         "EdgeColor", {[0,0,0], [0,0,0]}, ...
                         "DistributionCurve", "show", ...
                         "FitCurveLineWidth", 0.3};


distance_Change   = rowFcn(@(x) norm(x), temp_Change);
distance_On       = rowFcn(@(x) norm(x), temp_On);
mean([distance_Change, distance_On])
X = {distance_Change, distance_On};
distFig = figure;
maximizeFig
mu.histogram(X, "BinWidth", .05, "DisplayName", {'Change', 'Onset'}, histogramSettingsPDF{:});
setAxesStyle;
ylabel("Count");
xlabel("Vector length");
ylim([0, 40])
xlim([0, 1.5]);
xticks(0:0.3:1.5);
yticks(0:10:50)
exportFigure2PDF(distFig, '.\Figures\Figure5E.pdf', 55, 45);

% Fig5F angle
polarhistogramSettingsPDF = { "FaceColor", {[1, 0, 0], [0, 0, 1]}, ...
                              "Normalization", "probability", ...
                               "DisplayName", {'Change', 'Onset'}, ...
                               'RTicks',[15, 30, 45], ...
                               'RTickLabel',{'15%','30%','45%'}, ...
                         };
angle_Change  = rowFcn(@(x) atan2(x(2), x(1)), temp_Change);
angle_On      = rowFcn(@(x) atan2(x(2), x(1)), temp_On);

X = {angle_Change, angle_On};
angleFig = figure;
maximizeFig
mu.polarhistogram(X, "BinWidth", pi/10, polarhistogramSettingsPDF{:});
setAxesStyle("XColor", "none", "YColor", "none");
target = findobj(angleFig, "type", "text");
set(target, "FontName", "Arial");
set(target, "FontSize", 7);
set(target, "FontWeight", "bold");
exportFigure2PDF(angleFig, '.\Figures\Figure5F.pdf', 70, 60);

close all