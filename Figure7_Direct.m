ccc
addpath('.\utils', '-begin');
addpath(genpath('E:\code\MultiChannelProcess'), '-begin');
load('.\Fig7LayerInfo.mat');
%%
load(".\Fig7LFPData.mat");
Window    = [-1500, 1500];
rmfcn = @(x) rms(x, 2);
RMWinChange     = [0, 150];   RMWinOnset     = [-1000, -850];   RMWinOffset     = [1000, 1150];
RMWinChangeBase = [-150, 0];  RMWinOnsetBase = [-1150, -1000];  RMWinOffsetBase = [850, 1000];
t = linspace(Window(1), Window(2), size(LFPData(1).meanLFP{1}, 2));
RMChange      = cellfun(@(x) cell2mat(calRM(x, Window, RMWinChange, rmfcn)') ./ max(max(cell2mat(calRM(x, Window, RMWinChange, rmfcn)'))), {LFPData.meanLFP}', "UniformOutput", false);
RMOnset       = cellfun(@(x) cell2mat(calRM(x, Window, RMWinOnset, rmfcn)') ./ max(max(cell2mat(calRM(x, Window, RMWinOnset, rmfcn)'))), {LFPData.meanLFP}', "UniformOutput", false);
RMOffset      = cellfun(@(x) cell2mat(calRM(x, Window, RMWinOffset, rmfcn)') ./ max(max(cell2mat(calRM(x, Window, RMWinOffset, rmfcn)'))), {LFPData.meanLFP}', "UniformOutput", false);

RMChange_Norm = cellfun(@(x, y) x ./ y, RMChange, RMOnset, "UniformOutput", false);
save('.\Fig7RM.mat', 'RMOnset', 'RMChange', 'RMChange_Norm');
%%
mIndex = 8;
load('.\Fig7chAll.mat');
sitePos = "20250729KXK_A4o5V2o1_AC";
if ~isnumeric(badCHExcel{mIndex, 1})
    badCh  = sort(65 - (double(string(strsplit(badCHExcel{mIndex, 1}, ","))) + 1)/2);
else
    badCh  = badCHExcel{mIndex, 1};
end

%%
trialsLFP = chAll(14).rawLFP.rawWave;
trialsLFP = cellfun(@(x) x(chanMap, :), trialsLFP, "UniformOutput", false);
trialsLFP = cellfun(@(x) flipud(x(1:2:end, :)), trialsLFP, "UniformOutput", false);

%% calculate latency


%% plot LFP & CSD
[CSD, LFP] = CSD_Process(trialsLFP, Window, "five point", badCh, 50);
LFPWin    = [-1050, 500] + 1000;  CSDWin = [-1050, -850] + 1000;
YLines = (double(string(strsplit(layerBoundary{mIndex}, ','))) + 1)'/2 + 0.5;

margins = [0.05, 0.05, 0, 0];
marginsRM = [0.1, 0.05, 0, 0];
marginsCSD = [0.1, 0.25, 0, 0];
paddings = [0.01, 0.03, 0.1, 0.1];
FigCSD = figure;
maximizeFig(FigCSD);

% plot LFP Wave
chIdx = 64 - (min(YLines)-0.5 : max(YLines)-0.5) + 1; 
Axes =  mu.subplot(FigCSD, 1, 5, 1, "margins", margins, "paddings", paddings);
lineSpace = 160;
adds = repmat(flip(LFP.Chs - 1)' * lineSpace, 1, size(LFP.Raw, 2));
temp = LFP.Raw(chIdx, :) + adds(chIdx, :);
yMax = adds(min(chIdx) - 1, 1);
yMin = adds(max(chIdx) + 1, 1);
% plot(LFP.tWave + 1000, adds, "b:"); hold on
plot(LFP.tWave + 1000, temp, "k-", "LineWidth", 1); hold on
ylim([yMin, yMax]);
xlim(LFPWin);
yticks([])
% title(Axes, "Averaged LFP Waveform");

% plot CSD and corresponding MUA wave
vertSeg = (1 - sum(paddings(3 : 4))) / (length(LFP.Chs) - 1);
Axes = mu.subplot(FigCSD, 1, 5, 2, "margins", marginsCSD, "paddings", paddings);
box(Axes, "off");
CData = flipud(CSD.Data);
csdY = linspace(3, 62, size(CData, 1));
imagesc('XData', CSD.t + 1000, 'YData', csdY, 'CData', CData); hold on
colormap("jet");
ylim([min(YLines), max(YLines)]);
xlim(CSDWin);
scaleAxes(Axes, "c", max(max(abs(CSD.Data(:, CSD.t > CSDWin(1) & CSD.t < CSDWin(2))))) * [-1, 1]);
csdYTick = linspace(1, size(CSD.Data, 1), length(CSD.Chs));
yticks([])
mu.colorbar("Interval", 0.1);



heatAxes = findobj(FigCSD, "type", "Axes");
heatAxes(1).YTickLabel = string(flip(double(string(heatAxes(1).YTickLabel))*2-1));
heatAxes(2).YTickLabel = string(flip(double(string(heatAxes(2).YTickLabel))*2-1));

% plot RM
% RM Onset
CData = flipud(RMOnset{mIndex});
mu.subplot(FigCSD, 1, 5, 3,"nsize", [0.3, 1], "alignment", "left-center", "margins", marginsRM, "paddings", paddings);
imagesc('XData', 1:5, 'CData', CData(:, 1:5)); hold on; title("Level0")
colormap("jet"); ylim([min(YLines), max(YLines)]); xlim([0.5, 5.5]); clim([0, 1]); yticks([]); xticks([]); 
mu.subplot(FigCSD, 1, 5, 3,"nsize", [0.3, 1], "alignment", "center", "margins", marginsRM, "paddings", paddings);
imagesc('XData', 1:5, 'CData', CData(:, 6:10)); hold on; title("Level1")
colormap("jet"); ylim([min(YLines), max(YLines)]); xlim([0.5, 5.5]); clim([0, 1]); yticks([]); xticks([])
mu.subplot(FigCSD, 1, 5, 3,"nsize", [0.3, 1], "alignment", "right-center", "margins", marginsRM, "paddings", paddings);
imagesc('XData', 1:5, 'CData', CData(:, 11:15)); hold on; title("Level2")
colormap("jet"); ylim([min(YLines), max(YLines)]); xlim([0.5, 5.5]); clim([0, 1]); yticks([]); xticks([])

% RM Change
CData = flipud(RMChange{mIndex});
mu.subplot(FigCSD, 1, 5, 4,"nsize", [0.3, 1], "alignment", "left-center", "margins", marginsRM, "paddings", paddings);
imagesc('XData', 1:5, 'CData', CData(:, 1:5)); hold on; title("Level0")
colormap("jet"); ylim([min(YLines), max(YLines)]); xlim([0.5, 5.5]); clim([0, 1]); yticks([]); xticks([]); 
mu.subplot(FigCSD, 1, 5, 4,"nsize", [0.3, 1], "alignment", "center", "margins", marginsRM, "paddings", paddings);
imagesc('XData', 1:5, 'CData', CData(:, 6:10)); hold on; title("Level1")
colormap("jet"); ylim([min(YLines), max(YLines)]); xlim([0.5, 5.5]); clim([0, 1]); yticks([]); xticks([])
mu.subplot(FigCSD, 1, 5, 4,"nsize", [0.3, 1], "alignment", "right-center", "margins", marginsRM, "paddings", paddings);
imagesc('XData', 1:5, 'CData', CData(:, 11:15)); hold on; title("Level2")
colormap("jet"); ylim([min(YLines), max(YLines)]); xlim([0.5, 5.5]); clim([0, 1]); yticks([]); xticks([])

% RM Offset
CData = flipud(RMOffset{mIndex});
mu.subplot(FigCSD, 1, 5, 5,"nsize", [0.3, 1], "alignment", "left-center", "margins", marginsRM, "paddings", paddings);
imagesc('XData', 1:5, 'CData', CData(:, 1:5)); hold on; title("Level0")
colormap("jet"); ylim([min(YLines), max(YLines)]); xlim([0.5, 5.5]); clim([0, 1]); yticks([]); xticks([]); 
mu.subplot(FigCSD, 1, 5, 5,"nsize", [0.3, 1], "alignment", "center", "margins", marginsRM, "paddings", paddings);
imagesc('XData', 1:5, 'CData', CData(:, 6:10)); hold on; title("Level1")
colormap("jet"); ylim([min(YLines), max(YLines)]); xlim([0.5, 5.5]); clim([0, 1]); yticks([]); xticks([])
mu.subplot(FigCSD, 1, 5, 5,"nsize", [0.3, 1], "alignment", "right-center", "margins", marginsRM, "paddings", paddings);
imagesc('XData', 1:5, 'CData', CData(:, 11:15)); hold on; title("Level2")
colormap("jet"); ylim([min(YLines), max(YLines)]); xlim([0.5, 5.5]); clim([0, 1]); yticks([]); xticks([])
mu.colorbar("Interval", 0.1);

% add lines
mu.addLines(heatAxes, struct("X", num2cell([0, 1000, 2000]), "width", {0.3}));
Axes = findobj(FigCSD, "type", "Axes");
mu.addLines(Axes(1:9), struct("Y", num2cell(YLines(2:end-1)), "width", {0.3}));
setAxesStyle(Axes);
lineObj = findobj(FigCSD, "type", "line");
set(lineObj, "LineWidth", 0.3);
exportFigure2PDF(FigCSD, '.\Figures\Figure7A_C.pdf', 160, 70);

close all


%%
Window     = [-1500, 1500];
winChange  = [-100, 500];
fs         = 600; % Hz
SFigName   = ["A", "B", "C", "D"];
yScaleWave = [-100, 60; -120, 40; -100, 40; -100, 40];
yScaleHist = [0, 10; 0, 10; 0, 10; 0, 6];
ch1        = 32;
gIndex = 4;
mIndex = 8;
    if ~isnumeric(badCHExcel{mIndex, 1})
        badCh  = sort(65 - (double(string(strsplit(badCHExcel{mIndex, 1}, ","))) + 1)/2);
    else
        badCh  = badCHExcel{mIndex, 1};
    end

    for dIndex = 1 : length(chAll)
        trialsLFP = chAll(dIndex).rawLFP.rawWave;
        tRaw      = linspace(Window(1), Window(2), size(trialsLFP{1}, 2));
        trialsLFP = cellfun(@(x) x(chanMap, :), trialsLFP, "UniformOutput", false);
        trialsLFP = cellfun(@(x)  x ./ std(x(:, tRaw > -1500 & tRaw < -1000), 1, 2), trialsLFP, "UniformOutput", false);
        trialsLFP = baselineCorrection(trialsLFP, fs, Window, [-300, 0]);
        trialsLFP = cellfun(@(x) flipud(x(1:2:end, :)), trialsLFP, "UniformOutput", false);
        trialsLFP = correctBadCh(trialsLFP, Window, badCh);
        trialsLFP = cutData(trialsLFP, Window, winChange);
        trialsLFP_All{dIndex, 1} = trialsLFP;
    end

    trialsLFP_group{1, 1} = mCell2mat(trialsLFP_All(gIndex));
    trialsLFP_group{2, 1} = mCell2mat(trialsLFP_All(gIndex + 5));
    trialsLFP_group{3, 1} = mCell2mat(trialsLFP_All(gIndex + 10));
    load(strcat(".\Fig7popStat_3Level_diff", string(gIndex), ".mat"));
    stat = popStat(matches(string({popStat.dateStr}'), sitePos)).stat;


%% Fig7 E-F
badCh  = cellfun(@(x) sort(65 - (double(string(strsplit(x, ","))) + 1)/2), layerBoundary, "UniformOutput", false);
upper   = cellfun(@(x) x(1):x(2)-1, badCh, "UniformOutput", false);
middle  = cellfun(@(x) x(2):x(3)-1, badCh, "UniformOutput", false);
lower   = cellfun(@(x) x(3):x(end), badCh, "UniformOutput", false);

Window    = [-1500, 1500];
rmfcn = @(x) rms(x, 2);
RMWinChange     = [0, 150];   RMWinOnset     = [-1000, -850];   RMWinOffset     = [1000, 1150];
RMWinChangeBase = [-150, 0];  RMWinOnsetBase = [-1150, -1000];  RMWinOffsetBase = [850, 1000];
t = linspace(Window(1), Window(2), size(LFPData(1).meanLFP{1}, 2));
RMChange      = cellfun(@(x) cell2mat(calRM(x, Window, RMWinChange, rmfcn)') ./ max(max(cell2mat(calRM(x, Window, RMWinChange, rmfcn)'))), {LFPData.meanLFP}', "UniformOutput", false);
RMOnset       = cellfun(@(x) cell2mat(calRM(x, Window, RMWinOnset, rmfcn)') ./ max(max(cell2mat(calRM(x, Window, RMWinOnset, rmfcn)'))), {LFPData.meanLFP}', "UniformOutput", false);
RMOffset      = cellfun(@(x) cell2mat(calRM(x, Window, RMWinOffset, rmfcn)') ./ max(max(cell2mat(calRM(x, Window, RMWinOffset, rmfcn)'))), {LFPData.meanLFP}', "UniformOutput", false);
RMChange_Norm = cellfun(@(x, y) x ./ y, RMChange, RMOnset, "UniformOutput", false);

RMOnset_Upper = cellfun(@(x, y) reshape(mean(x(y, :), 1), 5, []), RMOnset, upper, "UniformOutput", false);
RMOnset_Middle= cellfun(@(x, y) reshape(mean(x(y, :), 1), 5, []), RMOnset, middle, "UniformOutput", false);
RMOnset_Lower = cellfun(@(x, y) reshape(mean(x(y, :), 1), 5, []), RMOnset, lower, "UniformOutput", false);
RMOnset_All   = cellfun(@(x, y, z) x+y+z, RMOnset_Upper, RMOnset_Middle, RMOnset_Lower, "UniformOutput", false);

RMChange_Upper = cellfun(@(x, y) reshape(mean(x(y, :), 1), 5, []), RMChange, upper, "UniformOutput", false);
RMChange_Middle= cellfun(@(x, y) reshape(mean(x(y, :), 1), 5, []), RMChange, middle, "UniformOutput", false);
RMChange_Lower = cellfun(@(x, y) reshape(mean(x(y, :), 1), 5, []), RMChange, lower, "UniformOutput", false);
RMChange_All   = cellfun(@(x, y, z) x+y+z, RMChange_Upper, RMChange_Middle, RMChange_Lower, "UniformOutput", false);

RMOffset_Upper = cellfun(@(x, y) reshape(mean(x(y, :), 1), 5, []), RMOffset, upper, "UniformOutput", false);
RMOffset_Middle= cellfun(@(x, y) reshape(mean(x(y, :), 1), 5, []), RMOffset, middle, "UniformOutput", false);
RMOffset_Lower = cellfun(@(x, y) reshape(mean(x(y, :), 1), 5, []), RMOffset, lower, "UniformOutput", false);
RMOffset_All   = cellfun(@(x, y, z) x+y+z, RMOffset_Upper, RMOffset_Middle, RMOffset_Lower, "UniformOutput", false);

RMOnset_Vector_Upper    = cell2mat(cellfun(@(x) max((x(2:end, [2, 3]) - x(2:end, 1)) ./ (x(2:end, [2, 3]) + x(2:end, 1)), [], 1), RMOnset_Upper, "UniformOutput", false));
RMOnset_Vector_Middle   = cell2mat(cellfun(@(x) max((x(2:end, [2, 3]) - x(2:end, 1)) ./ (x(2:end, [2, 3]) + x(2:end, 1)), [], 1), RMOnset_Middle, "UniformOutput", false));
RMOnset_Vector_Lower    = cell2mat(cellfun(@(x) max((x(2:end, [2, 3]) - x(2:end, 1)) ./ (x(2:end, [2, 3]) + x(2:end, 1)), [], 1), RMOnset_Lower, "UniformOutput", false));


RMChange_Vector_Upper   = cell2mat(cellfun(@(x) max((x(2:end, [2, 3]) - x(2:end, 1)) ./ (x(2:end, [2, 3]) + x(2:end, 1)), [], 1), RMChange_Upper, "UniformOutput", false));
RMChange_Vector_Middle  = cell2mat(cellfun(@(x) max((x(2:end, [2, 3]) - x(2:end, 1)) ./ (x(2:end, [2, 3]) + x(2:end, 1)), [], 1), RMChange_Middle, "UniformOutput", false));
RMChange_Vector_Lower   = cell2mat(cellfun(@(x) max((x(2:end, [2, 3]) - x(2:end, 1)) ./ (x(2:end, [2, 3]) + x(2:end, 1)), [], 1), RMChange_Lower, "UniformOutput", false));

RMOffset_Vector_Upper   = cell2mat(cellfun(@(x) max((x(2:end, [2, 3]) - x(2:end, 1)) ./ (x(2:end, [2, 3]) + x(2:end, 1)), [], 1), RMOffset_Upper, "UniformOutput", false));
RMOffset_Vector_Middle  = cell2mat(cellfun(@(x) max((x(2:end, [2, 3]) - x(2:end, 1)) ./ (x(2:end, [2, 3]) + x(2:end, 1)), [], 1), RMOffset_Middle, "UniformOutput", false));
RMOffset_Vector_Lower   = cell2mat(cellfun(@(x) max((x(2:end, [2, 3]) - x(2:end, 1)) ./ (x(2:end, [2, 3]) + x(2:end, 1)), [], 1), RMOffset_Lower, "UniformOutput", false));


% distances
RMOnset_Distance_Upper  = rowFcn(@(x) norm(x), RMOnset_Vector_Upper);
RMOnset_Distance_Middle = rowFcn(@(x) norm(x), RMOnset_Vector_Middle);
RMOnset_Distance_Lower  = rowFcn(@(x) norm(x), RMOnset_Vector_Lower);

RMChange_Distance_Upper  = rowFcn(@(x) norm(x), RMChange_Vector_Upper);
RMChange_Distance_Middle = rowFcn(@(x) norm(x), RMChange_Vector_Middle);
RMChange_Distance_Lower  = rowFcn(@(x) norm(x), RMChange_Vector_Lower);

RMOffset_Distance_Upper  = rowFcn(@(x) norm(x), RMOffset_Vector_Upper);
RMOffset_Distance_Middle = rowFcn(@(x) norm(x), RMOffset_Vector_Middle);
RMOffset_Distance_Lower  = rowFcn(@(x) norm(x), RMOffset_Vector_Lower);


figure
siteIdx = 1 : 36;
mu.subplot(1,3,1, [1, 1], "margin_left", 0.1)
scatter(RMOnset_Vector_Upper(siteIdx, 1), RMOnset_Vector_Upper(siteIdx, 2), 3, "red", "filled"); hold on
scatter(RMOnset_Vector_Middle(siteIdx, 1), RMOnset_Vector_Middle(siteIdx, 2), 3, "blue", "filled"); hold on
scatter(RMOnset_Vector_Lower(siteIdx, 1), RMOnset_Vector_Lower(siteIdx, 2), 3, "black", "filled"); hold on
xticks(-1:0.5:1); yticks(-1:0.5:1);
xlim([-1, 1]); ylim([-1, 1]);
ax = gca;
ax.XAxisLocation = 'origin';  % 
ax.YAxisLocation = 'origin';  % 
xrange = xlim;  yrange = ylim;
arrow_len = 0.2 * diff(xrange);  % 
arrow_width = 0.02 * diff(yrange); % 
h1 = annotation('arrow', ... % for x
    [0.043 0.348], [0.53 0.53], ...
    'Color', 'k', 'LineWidth', 0.8, 'HeadLength', 4, 'HeadWidth', 4);
h2 = annotation('arrow', ... % for y
    [0.1944 0.1944], [0.12 0.97], ...
    'Color', 'k', 'LineWidth', 0.8, 'HeadLength', 4, 'HeadWidth', 4);
uistack(h1, 'bottom'); uistack(h2, 'bottom'); 


mu.subplot(1,3,2, [1, 1], "margin_left", 0.1)
scatter(RMChange_Vector_Upper(siteIdx, 1), RMChange_Vector_Upper(siteIdx, 2), 3, "red", "filled"); hold on
scatter(RMChange_Vector_Middle(siteIdx, 1), RMChange_Vector_Middle(siteIdx, 2), 3, "blue", "filled"); hold on
scatter(RMChange_Vector_Lower(siteIdx, 1), RMChange_Vector_Lower(siteIdx, 2), 3, "black", "filled"); hold on
xlim([-1, 1]); ylim([-1, 1]);
ax = gca;
ax.XAxisLocation = 'origin';  % 
ax.YAxisLocation = 'origin';  % 
xticks(-1:0.5:1); yticks(-1:0.5:1);
xrange = xlim;  yrange = ylim;
h3 = annotation('arrow', ... % for x
    [0.043 0.348] + 0.3136, [0.53 0.53], ...
    'Color', 'k', 'LineWidth', 0.8, 'HeadLength', 4, 'HeadWidth', 4);
h4 = annotation('arrow', ... % for y
    [0.1944 0.1944] + 0.3136, [0.12 0.97], ...
    'Color', 'k', 'LineWidth', 0.8, 'HeadLength', 4, 'HeadWidth', 4);
uistack(h3, 'top'); uistack(h4, 'top'); 

setAxesStyle(gcf, "XTickLabelRotation", 0);
exportFigure2PDF(gcf, '.\Figures\Figure7E.pdf', 100, 37);

histogramSettingsPDF = { "FaceColor", {[0,0,1], [1,0,0]}, ...
                         "EdgeColor", {[0,0,0], [0,0,0]}, ...
                         "DistributionCurve", "show", ...
                         "FitCurveLineWidth", 0.3};
figure
siteIdx = 1 : 36;
% Sg
mu.subplot(1,3,1, "margin_left", 0.1, "margin_right", 0.1)
X = {RMOnset_Distance_Upper, RMChange_Distance_Upper};
mu.histogram(X, "BinWidth", .1, histogramSettingsPDF{:});
xlim([0, 1.5]); xticks(0:0.5:1.5); xlabel("Distance"); 
xlabel("Distance"); ylabel("Counts"); set(gca, "XTickLabelRotation", 0);
ylim([0, 20]); yticks(0:5:20)

% Gr
mu.subplot(1,3,2, "margin_left", 0.1, "margin_right", 0.1)
X = {RMOnset_Distance_Middle, RMChange_Distance_Middle};
mu.histogram(X, "BinWidth", .1,  histogramSettingsPDF{:});
xlim([0, 1.5]); xticks(0:0.5:1.5); xlabel("Distance"); 
ylim([0, 20]); yticks(0:5:20); set(gca, "XTickLabelRotation", 0);


% Ig
mu.subplot(1,3,3, "margin_left", 0.1, "margin_right", 0.1)
X = {RMOnset_Distance_Lower, RMChange_Distance_Lower};
mu.histogram(X, "BinWidth", .1, histogramSettingsPDF{:});
xlim([0, 1.5]); xticks(0:0.5:1.5); xlabel("Distance"); 
ylim([0, 20]); yticks(0:5:20); set(gca, "XTickLabelRotation", 0);


mean([RMOnset_Distance_Upper, RMOnset_Distance_Middle, RMOnset_Distance_Lower], 1)
[p_Onset, ~, stats] = friedman([RMOnset_Distance_Upper, RMOnset_Distance_Middle, RMOnset_Distance_Lower], 1, "off");
posthoc_Onset = multcompare(stats, "Display", "off");


mean([RMChange_Distance_Upper, RMChange_Distance_Middle, RMChange_Distance_Lower], 1)
[p_Change, ~, stats] = friedman([RMChange_Distance_Upper, RMChange_Distance_Middle, RMChange_Distance_Lower], 1, "off");
posthoc_Change = multcompare(stats, "Display", "off");


mean([RMOffset_Distance_Upper, RMOffset_Distance_Middle, RMOffset_Distance_Lower], 1)
[p_Offset, ~, stats] = friedman([RMOffset_Distance_Upper, RMOffset_Distance_Middle, RMOffset_Distance_Lower], 1, "off");
posthoc_Offset = multcompare(stats, "Display", "off");


setAxesStyle(gcf);
exportFigure2PDF(gcf, '.\Figures\Figure7F.pdf', 70, 37);
%% Fig7 G-I

YLines = (double(string(strsplit(layerBoundary{mIndex}, ','))) + 1)'/2 + 0.5;

figF = figure;
t = linspace(winChange(1), winChange(2), size(trialsLFP_group{1}{1}, 2));
channels = 1:64;
% AC
maskAC = stat.prob  < alphaSites(mIndex);
fAC = stat.stat .* maskAC;
temp = rowFcn(@(x) t(find(x ~= 0 & t > 20, 1)), fAC, "UniformOutput", false);
temp(cellfun(@isempty, temp)) = {winChange(2)};
temp = cat(1, temp{:});
clearvars ax
axSig(2) = mu.subplot(1, 3, 2, "margins", [0.05, 0.2, 0.05, 0.05], "paddings", [0.05, 0.05, 0.08, 0.05]);
imagesc("XData", t, "YData", channels, "CData", flipud(fAC));
hold on;
plot(flip(temp), channels, "Color", "k", "LineWidth", 1);
set(gca, "XLimitMethod", "tight");
set(gca, "YLimitMethod", "tight");
% scaleAxes("c", [-8, 8]);
xlim([0, 300]);
ylim([min(YLines), max(YLines)])
yticks(channels);
yticks([]);
yticklabels(num2str(flip(channels')));
xlabel('Time from change (ms)');
heatAxes = findobj(gcf, "type", "axes");
mu.addLines(heatAxes, struct("Y", num2cell(YLines(2:end-1)), "width", {0.3}));
mu.colorbar("Label", "F-Value", "Interval", 0.01)

% histogram

histogramSettingsPDF = { "FaceColor", {[1,0,0], [0,0,1], [0,0,0]}, ...
    "EdgeColor", {[0,0,0], [0,0,0], [0,0,0]}, ...
    "DistributionCurve", "show", ...
    "DisplayName", {'Sg', 'Gr', 'Ig'}, ...
    "FitCurveLineWidth", 0.3};

load(strcat(".\Fig7popStat_3Level_Valid_diff", string(gIndex), ".mat"));

t = linspace(-100, 500, size(popStat(1).stat.prob, 2));

firstTimes = [popStat.firstSigTime];

axSig(3) = mu.subplot(1, 3, 3, "margins", [0.2, 0.1, 0.05, 0.05], "paddings", [0.05, 0.05, 0.08, 0.05]);
X = {firstTimes(1, :)', firstTimes(2, :)', firstTimes(3, :)'};
mu.histogram(X, "BinWidth", 10, histogramSettingsPDF{:});
xlim([0, 150]); xticks(0:30:150); ylim(yScaleHist(gIndex-1, :));
xlabel("First significant latency (ms)"); ylabel("Counts");

setAxesStyle(gcf);
exportFigure2PDF(gcf, '.\Figures\Figure7H_I.pdf', 160, 35);
mean(firstTimes', 1)
[p_latency, ~, stats] = friedman(firstTimes', 1, "off");
posthoc_Latency = multcompare(stats, "Display", "off");
% LFP Waveform
ref2   = cell2mat(cellfun(@mean, changeCellRowNum(trialsLFP_group{3}), "UniformOutput", false));
ref1   = cell2mat(cellfun(@mean, changeCellRowNum(trialsLFP_group{2}), "UniformOutput", false));
noref = cell2mat(cellfun(@mean, changeCellRowNum(trialsLFP_group{1}), "UniformOutput", false));
ref2SE   = cell2mat(cellfun(@SE, changeCellRowNum(trialsLFP_group{3}), "UniformOutput", false));
ref1SE   = cell2mat(cellfun(@SE, changeCellRowNum(trialsLFP_group{2}), "UniformOutput", false));
norefSE = cell2mat(cellfun(@SE, changeCellRowNum(trialsLFP_group{1}), "UniformOutput", false));
% level 0
chDataRef(1).chMean = noref;
chDataRef(1).chErr = norefSE;
chDataRef(1).color = [0, 0, 0];
chDataRef(1).legend = [];
chDataRef(1).LineWidth   = 0.3;

% level 1
chDataRef(2).chMean = ref1;
chDataRef(2).chErr = ref1SE;
chDataRef(2).color = [0, 0, 1];
chDataRef(2).legend = [];
chDataRef(2).LineWidth   = 0.3;

% level 2
chDataRef(3).chMean = ref2;
chDataRef(3).chErr = ref2SE;
chDataRef(3).color = [1, 0, 0];
chDataRef(3).legend = [];
chDataRef(3).LineWidth   = 0.3;

FigRef_Reg = plotRawWaveMulti(chDataRef, [t(1), t(end)], "", [1, 1], ch1);

xlabel("Time from change (ms)");
ylabel("Amplitude (\muV)");
xticks(0:100:300);
ylim([-120, 60]);
yticks(-120:60:60);
xlim([0, 300]);
mu.addBars(t(maskAC(ch1, :) == 1), "r");
setAxesStyle(gcf);

temp = findobj(gcf, "type", "axes");
temp.Title = [];
exportFigure2PDF(gcf, '.\Figures\Figure7G.pdf', 45, 35);

