ratName = 'RatECoG1';
load('.\Fig4chData.mat');
load('.\Fig4Windows.mat', 'windowChange', 'windowOnset', 'windowOffset');
load('.\Fig4RM.mat');
load('.\Fig4p_channels.mat');

ECOGPos = ECOGPos_Kedou32("left");
window  = [-500, 4000];
plotSize  = [6, 6];
bootAlpha = 0.05;
ICI   = [4, 4.4, 4.6, 4.8, 5, 5, 10, 20, 50, 100];
cOnset  = [0, 3];
cChange = [0, 0.6];
cOffset = [0, 0.5];
cDiffOnset  = [-1, 1];
cDiffChange = [-0.5, 0.5];
cDiffOffset = [-0.2, 0.2];
colors = repmat(cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false), 1, 2);

margins = [0.05, 0.05, 0.1, 0.1];
paddings = [0.01, 0.03, 0.01, 0.01];
devOrder = (1:10)';
badCHs   = [];

%% raw wave - Figure 4C

mkdir('.\Figures')
load('Fig4Windows.mat', 'windowChange', 'windowOnset', 'windowOffset');
% regular
exampleCh = '26';
exampleChIdx = find(strcmpi(ECOGPos.channelNames, exampleCh));
t = linspace(window(1), window(2), size(chDataRef(1).chMean, 2))';
for i = 1 : length(chDataRef)
    chDataRef(i).legend   = []; chDataRef(i).LineWidth   = 0.3;
    chDataNoRef(i).legend = []; chDataNoRef(i).LineWidth = 0.3;
end

FigNoRef_Reg = plotRawWaveMulti(chDataNoRef(1:length(devOrder)/2), window, "noRef", [1, 1], exampleChIdx);
xlabel("Time from onset (ms)"); ylabel("Response(\muV)"); yticks(-2:2); xticks([-200, 0, 500, 1000, 1500]);
FigRef_Reg = plotRawWaveMulti(chDataRef(1:length(devOrder)/2), window, "ref", [1, 1], exampleChIdx);
xlabel("Time from onset (ms)"); yticks(-2:2);  xticks([-200, 0, 500, 1000, 1500]);
addLines2Axes([FigNoRef_Reg, FigRef_Reg], struct("X", {0; 1000; 2000}, "color", [1, 1, 0], "width", 0.3));
scaleAxes([FigNoRef_Reg, FigRef_Reg], "x", [-200, 1500]);
scaleAxes([FigNoRef_Reg, FigRef_Reg], "y", [-2, 2]);

addBars2Axes(findobj(FigNoRef_Reg, "type", "axes"), windowChange(1):windowChange(2), [1, 1, 0]);
addBars2Axes(findobj(FigRef_Reg, "type", "axes"), windowChange(1):windowChange(2), [1, 1, 0]);
setAxesStyle([FigNoRef_Reg, FigRef_Reg]);

exportFigure2PDF(FigNoRef_Reg, '.\Figures\Figure4C_L.pdf', 53, 40);
exportFigure2PDF(FigRef_Reg, '.\Figures\Figure4C_R.pdf', 53, 40);
close all
%% topo_regular_Change - Figure 4D
set(groot, 'DefaultAxesColor', "none");
scatterSigSettingsPDF = {5, "black", "LineWidth", 0.5, "Marker", "x"};
scatterNoSigSettingsPDF = {5, "black", "LineWidth", 0.5, "Marker", "o"};

figTopo = figure;
% reg - noRef
for dIndex = 1:5
    axChange(dIndex, 1) = mu.subplot(3, 5,  dIndex);
    val = RM_change_noRef{dIndex}';
    temp = [0; val(1:4); 0; val(5:28); 0; val(29:32); 0];
    pVal = p_change_noRef_channels{dIndex};
    p = [1; pVal(1:4); 1; pVal(5:28); 1; pVal(29:32); 1];
    plotTopo(gca, temp, plotSize, ...
        "contourVal", p < bootAlpha);
    [ytemp, xtemp] = find(flipud(reshape(p >= bootAlpha & p ~=1, plotSize)'));
    scatter(gca, xtemp, ytemp, scatterNoSigSettingsPDF{:});
    [ytemp, xtemp] = find(flipud(reshape(p < bootAlpha, plotSize)'));
    scatter(gca, xtemp, ytemp, scatterSigSettingsPDF{:});
    titles(dIndex, 1) = title(['ICI_2 = ', num2str(ICI(dIndex))]);
end
mu.colorbar("Interval", 0.05);

% reg - Ref
for dIndex = 1:5
    axChange(dIndex+5, 1) = mu.subplot(3, 5,  dIndex + 5);
    val = RM_change_ref{dIndex}';
    temp = [0; val(1:4); 0; val(5:28); 0; val(29:32); 0];
    pVal = p_change_Ref_channels{dIndex};
    p = [1; pVal(1:4); 1; pVal(5:28); 1; pVal(29:32); 1];
    plotTopo(gca, temp, plotSize, ...
        "contourVal", p < bootAlpha);
    [ytemp, xtemp] = find(flipud(reshape(p >= bootAlpha & p ~=1, plotSize)'));
    scatter(gca, xtemp, ytemp, scatterNoSigSettingsPDF{:});
    [ytemp, xtemp] = find(flipud(reshape(p < bootAlpha, plotSize)'));
    scatter(gca, xtemp, ytemp, scatterSigSettingsPDF{:});
end
mu.colorbar("Interval", 0.05);
scaleAxes(axChange, "c", cChange, "ignoreInvisible", false);

% reg - diff
for dIndex = 1:5
    axDiff(dIndex, 1) = mu.subplot(3, 5, dIndex + 10);
    val = RM_change_ref{dIndex}' - RM_change_noRef{dIndex}';
    temp = [0; val(1:4); 0; val(5:28); 0; val(29:32); 0];
    pVal = p_change_channels{dIndex};
    p = [1; pVal(1:4); 1; pVal(5:28); 1; pVal(29:32); 1];
    plotTopo(gca, temp, plotSize, ...
        "contourOpt", "on", ...
        "contourVal", p < bootAlpha);
    % titles(dIndex, 2) = title(['ICI_2 = ', num2str(ICI(dIndex))]);
    [ytemp, xtemp] = find(flipud(reshape(p >= bootAlpha & p ~=1, plotSize)'));
    scatter(gca, xtemp, ytemp, scatterNoSigSettingsPDF{:});
    [ytemp, xtemp] = find(flipud(reshape(p < bootAlpha, plotSize)'));
    scatter(gca, xtemp, ytemp, scatterSigSettingsPDF{:});
end
mu.colorbar("Interval", 0.05);
cRange = scaleAxes(axDiff, "c", cDiffChange, "ignoreInvisible", false);
setAxesStyle(gcf, "XColor", "none", "YColor", "none", "FontSize", 5);
axesObj = findobj(gcf, "type", "axes");
set(axesObj, "XLim", [axesObj(1).XLim(1) + 0.5, axesObj(1).XLim(2) - 0.5]);
set(axesObj, "YLim", [axesObj(1).YLim(1) + 0.5, axesObj(1).YLim(2) - 0.5])
lineObj = findobj(gcf, "type", "contour");
set(lineObj, "LineWidth", 0.3);
% setTitlePosition(titles, 0.97);
exportFigure2PDF(figTopo, '.\Figures\Figure4D.pdf', 80, 50);
% clear titles
close all

%% topo_regular_Onset - Figure 4E
set(groot, 'DefaultAxesColor', "none");
scatterSigSettingsPDF = {5, "black", "LineWidth", 0.5, "Marker", "x"};
scatterNoSigSettingsPDF = {5, "black", "LineWidth", 0.5, "Marker", "o"};

figTopo = figure;
% reg - noRef
for dIndex = 1
    axOnset(dIndex, 1) = mu.subplot(3, 5,  dIndex);
    val = RM_onset_noRef{dIndex}';
    temp = [0; val(1:4); 0; val(5:28); 0; val(29:32); 0];
    pVal = p_onset_noRef_channels{dIndex};
    p = [1; pVal(1:4); 1; pVal(5:28); 1; pVal(29:32); 1];
    plotTopo(gca, temp, plotSize, ...
        "contourVal", p < bootAlpha);
    [ytemp, xtemp] = find(flipud(reshape(p >= bootAlpha & p ~=1, plotSize)'));
    scatter(gca, xtemp, ytemp, scatterNoSigSettingsPDF{:});
    [ytemp, xtemp] = find(flipud(reshape(p < bootAlpha, plotSize)'));
    scatter(gca, xtemp, ytemp, scatterSigSettingsPDF{:});
    titles(dIndex, 1) = title(['ICI_1 = ', num2str(ICI(dIndex))]);
end
mu.colorbar("Interval", 0.05);

% reg - Ref
for dIndex = 1
    axOnset(dIndex+1, 1) = mu.subplot(3, 5,  dIndex + 5);
    val = RM_onset_ref{dIndex}';
    temp = [0; val(1:4); 0; val(5:28); 0; val(29:32); 0];
    pVal = p_onset_ref_channels{dIndex};
    p = [1; pVal(1:4); 1; pVal(5:28); 1; pVal(29:32); 1];
    plotTopo(gca, temp, plotSize, ...
        "contourVal", p < bootAlpha);
    [ytemp, xtemp] = find(flipud(reshape(p >= bootAlpha & p ~=1, plotSize)'));
    scatter(gca, xtemp, ytemp, scatterNoSigSettingsPDF{:});
    [ytemp, xtemp] = find(flipud(reshape(p < bootAlpha, plotSize)'));
    scatter(gca, xtemp, ytemp, scatterSigSettingsPDF{:});
end
mu.colorbar("Interval", 0.05);
scaleAxes(axOnset, "c", cOnset, "ignoreInvisible", false);

% reg - diff
for dIndex = 1
    axOnDiff(dIndex, 1) = mu.subplot(3, 5, dIndex + 10);
    val = RM_onset_ref{dIndex}' - RM_onset_noRef{dIndex}';
    temp = [0; val(1:4); 0; val(5:28); 0; val(29:32); 0];
    pVal = p_onset_channels{dIndex};
    p = [1; pVal(1:4); 1; pVal(5:28); 1; pVal(29:32); 1];
    plotTopo(gca, temp, plotSize, ...
        "contourOpt", "on", ...
        "contourVal", p < bootAlpha);
    % titles(dIndex, 2) = title(['ICI_2 = ', num2str(ICI(dIndex))]);
    [ytemp, xtemp] = find(flipud(reshape(p >= bootAlpha & p ~=1, plotSize)'));
    scatter(gca, xtemp, ytemp, scatterNoSigSettingsPDF{:});
    [ytemp, xtemp] = find(flipud(reshape(p < bootAlpha, plotSize)'));
    scatter(gca, xtemp, ytemp, scatterSigSettingsPDF{:});
end
mu.colorbar("Interval", 0.05);
cRange = scaleAxes(axOnDiff, "c", cDiffOnset, "ignoreInvisible", false);
setAxesStyle(gcf, "XColor", "none", "YColor", "none", "FontSize", 5);
axesObj = findobj(gcf, "type", "axes");
set(axesObj, "XLim", [axesObj(1).XLim(1) + 0.5, axesObj(1).XLim(2) - 0.5]);
set(axesObj, "YLim", [axesObj(1).YLim(1) + 0.5, axesObj(1).YLim(2) - 0.5])
lineObj = findobj(gcf, "type", "contour");
set(lineObj, "LineWidth", 0.3);
% setTitlePosition(titles, 0.97);
exportFigure2PDF(figTopo, '.\Figures\Figure4E.pdf', 80, 50);
% clear titles
close all
%% Tuning_Regular - Figure 4FG
chIdx = ~ismember(ECOGPos.channels, badChs);
boxplotLineSettingsPDF = {"SymbolParameters", {'SizeData', 10, "LineWidth", 0.05}, ...
    "BoxParameters", {'LineWidth', 0.3}, ...
    "WhiskerParameters", {'LineWidth', 0.3}, ...
    "WhiskerCapParameters", {'LineWidth', 0.3}, ...
    "CenterLineParameters", {'LineWidth', 0.3}, ...
    "Notch", "on", ...
    "IndividualDataPoint", "show", ...
    "Outlier", "hide"};

figBox = figure;

% onset
axOnsetRM = mu.subplot(1, 5, 1, "nSize", [1, 1], "alignment", "left-center", "margin_left", 0.4, "margin_right", 0.25);
x1 = cell2mat(RM_onset_noRef((1)));
x2 = cell2mat(RM_onset_ref((1)));
x = {x1', x2'};
mu.boxplot(x, ...
    "Colors", {[0, 0, 255] / 255, [255, 0, 0] / 255}, ...
    "CategoryLabels", "Reg_4", ...
    boxplotLineSettingsPDF{:}, ...
    "CategorySpace", 0.4, "GroupSpace", 0.15);
[p_onset, stats_onset, efsz_onset, bf10_onset] = rowFcn(@mstat.ttest, x1, x2);

% change
axChangeRM = mu.subplot(1, 5, 2, "nSize", [2, 1], "alignment", "left-center", "margin_right", 0.1);
x1 = cell2mat(RM_change_noRef((1:5)));
x2 = cell2mat(RM_change_ref((1:5)));
x = {x1', x2'};
mu.boxplot(x, ...
    "Colors", {[0, 0, 255] / 255, [255, 0, 0] / 255}, ...
    "CategoryLabels", string((ICI(1:5) - ICI(1)) / ICI(1)*100), ...
    boxplotLineSettingsPDF{:}, ...
    "CategorySpace", 0.4, "GroupSpace", 0.1);
[p_change, stats_change, efsz_change, bf10_change] = rowFcn(@mstat.ttest, x1, x2);


setAxesStyle(figBox);
exportFigure2PDF(figBox, '.\Figures\Figure4FG.pdf', 230, 40);
close all


% close all
