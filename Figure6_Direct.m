addpath(genpath("D:\Lab members\Public\code\MATLAB Utils - integrated"), "-begin");

ccc

ICIs       = [4, 4.4, 4.6, 4.8, 5];
windowSPK  = [-10, 2100];
colors     = {[0,0,0]; [0,0,1]; [1,0,0]};
respWin = [10, 200]; respWin_Ref = [400, 800];
baseWin = [-200, 0]; baseWin_Ref = [-800, -400];

load(strcat(".\Fig6PopData.mat"));
exampleStr = "20250806Rat3SPR_Reflection_A5V3o5_ACCH1040";

neuExample = popRes(1).data(matches(string({popRes(1).data.dateStr}'), exampleStr));
fitRes = neuExample.fitRes;
FR_Resp    = reshape(cellfun(@(x) [mu_calFR(x, respWin) / 1000 * diff(respWin), ones(length(x), 1)], neuExample.ChangeSpike, "UniformOutput", false), [], 3);
FR_Control    = reshape(cellfun(@(x) [mu_calFR(x, baseWin) / 1000 * diff(baseWin), zeros(length(x), 1)], neuExample.ChangeSpike, "UniformOutput", false), [], 3);

AUC_Data = cellfun(@(x, y) [x; y], FR_Resp, FR_Control, "UniformOutput", false);
AUCRes   = cellfun(@(x) DPcal(x, 1000), AUC_Data, "UniformOutput", false);
AUC_Values = cellfun(@(x) x.value, AUCRes);

%% plot figures

% FR distribution
histogramSettingsPDF = { "BinWidth", 2, ...
    "EdgeColor", {[0,0,0], [0,0,0]}, ...
    "DistributionCurve", "hide"};
distFig = figure;
maximizeFig
for i = 1 : 3
    axesDist(i, 1) = mu.subplot(1, 3, i, "margin_top", 0.1, "margin_left", 0.1);
    X = {FR_Control{4, i}(:, 1), FR_Resp{4, i}(:, 1)};
    mu.histogram(X, "FaceColor", {[0.5, 0.5, 0.5], colors{i}}, histogramSettingsPDF{:});
    xticks(0:4:16); xlim([0, 16])
    xlabel("Spike number")
    if i == 1
        ylabel("Count");
    end
end
scaleAxes("x", "on"); scaleAxes("y", [0, 20]);

setAxesStyle(axesDist, "xTickLabelRotation", 0);
exportFigure2PDF(distFig, '.\Figures\Figure6A.pdf', 119.5, 34);

% AUC

AUCFig = figure;
maximizeFig
for i = 1 : 3
    plot(AUCRes{4, i}.X, AUCRes{4, i}.Y, "LineStyle", "-", "LineWidth", 0.5, "Color", colors{i}); hold on
end
plot([0,1], [0,1], "LineStyle", "--", "LineWidth", 0.5, "Color", [.5, .5, .5]); hold on
xticks([0, 0.5, 1]); xlabel("False alarm rate");
yticks([0, 0.5, 1]); ylabel("Hite rate");
setAxesStyle(AUCFig, "xTickLabelRotation", 0);
exportFigure2PDF(AUCFig, '.\Figures\Figure6B.pdf', 40, 35);
%%
% Threshold
scatterNoSigSettingsPDF = {5, "black", "LineWidth", 0.5, "Marker", "o"};
fitFig = figure;
maximizeFig
axesDist(i, 1) = mu.subplot(1, 1, 1, "margin_top", 0.1, "margin_left", 0.1);
for i = 1 : 3
    plot(fitRes{i}.xFit, fitRes{i}.yFit, "LineStyle", "-", "LineWidth", 0.5, "Color", colors{i}); hold on
    scatter(ICIs, AUC_Values(:, i), 5, colors{i}, "LineWidth", 0.3, "Marker", "^"); hold on
    temp = fitRes{i}.xFit(find(fitRes{i}.yFit >= 0.7, 1, "first"));
    if ~isempty(temp)
        plot([0, temp], [0.7, 0.7], "LineStyle", "--", "Color", colors{i}, "LineWidth", 0.5); hold on;
        plot([temp, temp], [0, 0.7], "LineStyle", "--", "Color", colors{i}, "LineWidth", 0.5); hold on;
    end 
    if i == 1
        ylabel("AUC")
    end
end
scaleAxes("x", [4, 5]);
scaleAxes("y", [0.4, 1]);
setAxesStyle(fitFig, "xTickLabelRotation", 0, "xTick", ICIs, "xTickLabel", string((ICIs-4) / 4 * 100));
xlabel("ICI difference (%)")
exportFigure2PDF(fitFig, '.\Figures\Figure6C.pdf', 82, 55);
close all


%% threshold distribution - reuglar
histogramSettingsPDF = { "BinWidth", .2,  ...
    "DistributionCurve", "show", ...
    "EdgeColor", {[0,0,0], [0,0,0], [0,0,0]}, ...
    "FitCurveLineWidth", 0.3};
clear thresholds
for pIndex = 1 : length(popRes)
    temp = {popRes(pIndex).data.fitRes}';
    if pIndex <= 4
        thresholds{pIndex, 1} = changeCellRowNum(cellfun(@(x) cellfun(@(y) min([6, y.xFit(find(y.yFit > 0.7, 1, "first"))]), x), temp, "UniformOutput", false));
    else
        thresholds{pIndex, 1} = changeCellRowNum(cellfun(@(x) cellfun(@(y) min([4, y.xFit(find(y.yFit > 0.7, 1, "first"))]), x), temp, "UniformOutput", false));
    end
end
thresholds = mCell2mat(thresholds');

thrFig = figure;
maximizeFig

colors     = {[0,0,0]; [0,0,1]; [1,0,0]};
X = thresholds(:, 1);
mu.histogram(X, "FaceColor", colors, "DisplayName", cellstr(strcat("Level", string(0:2))), histogramSettingsPDF{:});

xticks(4:.4:6); xlim([4, 6]); xticklabels(string(((4:.4:6)-4) / 4 * 100));
xlabel("Threshold (%)")
set(gca, 'Layer', 'top'); 
scaleAxes("x", "on"); scaleAxes("y", [0, 120]);  yticks(0:30:120)

setAxesStyle(gca, "xTickLabelRotation", 0);
ylabel(gca, "Count")
exportFigure2PDF(thrFig, '.\Figures\Figure6D.pdf', 85, 51);
close all
cellfun(@mean, X)
