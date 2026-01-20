ccc;
addpath(genpath("D:\Lab members\Public\code\MATLAB Utils - integrated"), "-begin");
%% Parameters
run(".\utils\config_plot_EEG.m");
chIdx = ~ismember(EEGPos.channels, badChs);
colors = cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false);
margins = [0.05, 0.05, 0.1, 0.1];
paddings = [0.01, 0.03, 0.01, 0.01];
set(0, "DefaultAxesFontSize", 14);

%% Load 311_insert
pID = 311;
MATPATHs = dir(['..\..\MAT Data\**\', num2str(pID), '\data.mat']);
MATPATHs = arrayfun(@(x) fullfile(x.folder, x.name), MATPATHs, "UniformOutput", false);

% behavior result
dataBehav = cellfun(@(x) load(x, "trialAll"), MATPATHs);
trialNum  = cellfun(@(subj) reshape(rowFcn(@(x) sum([subj.code]' == x), unique([subj.code])'), [], 3), {dataBehav.trialAll}, "uni", false);
trialNum  = cat(3, trialNum{:});
pushNum   = cellfun(@(subj) reshape(rowFcn(@(x) sum([subj.code]' == x & [subj.key]' == 37), unique([subj.code])'), [], 3), {dataBehav.trialAll}, "uni", false);
pushNum   = cat(3, pushNum{:});
pushRatio_311 = pushNum ./ trialNum;

%% Load 331_insert
pID = 331;
MATPATHs = dir(['..\..\MAT Data\**\', num2str(pID), '\data.mat']);
MATPATHs = arrayfun(@(x) fullfile(x.folder, x.name), MATPATHs, "UniformOutput", false);

% behavior result
dataBehav = cellfun(@(x) load(x, "trialAll"), MATPATHs);
trialNum  = cellfun(@(subj) reshape(rowFcn(@(x) sum([subj.code]' == x), unique([subj.code])'), [], 3), {dataBehav.trialAll}, "uni", false);
trialNum  = cat(3, trialNum{:});
pushNum   = cellfun(@(subj) reshape(rowFcn(@(x) sum([subj.code]' == x & [subj.key]' == 37), unique([subj.code])'), [], 3), {dataBehav.trialAll}, "uni", false);
pushNum   = cat(3, pushNum{:});
pushRatio_331 = pushNum ./ trialNum;

%% Load 340
pID = 340;
MATPATHs = dir(['..\..\MAT Data\**\', num2str(pID), '\data.mat']);
MATPATHs = arrayfun(@(x) fullfile(x.folder, x.name), MATPATHs, "UniformOutput", false);

% behavior result
dataBehav = cellfun(@(x) load(x, "trialAll"), MATPATHs);
trialAll  = dataBehav(1).trialAll;
trialNum  = cellfun(@(subj) reshape(rowFcn(@(x) sum([subj.code]' == x), unique([subj.code])'), [], 2), {dataBehav.trialAll}, "uni", false);
trialNum  = cat(3, trialNum{:});
pushNum   = cellfun(@(subj) reshape(rowFcn(@(x) sum([subj.code]' == x & [subj.key]' == 37), unique([subj.code])'), [], 2), {dataBehav.trialAll}, "uni", false);
pushNum   = cat(3, pushNum{:});
pushRatio_340 = pushNum ./ trialNum;

save("Fig2pushRatio.mat", "pushRatio_311", "pushRatio_331", "pushRatio_340");

%% plot Figure
colors = {[0,0,0], [0,0,1], [1,0,0]};
figure
mSubplot(1,3,1) % ratio
for rIndex = 1 : size(pushRatio_311, 2)
    errorbar(1:5, mean(pushRatio_311(:, rIndex, :), 3), SE(pushRatio_311(:, rIndex, :), 3), "LineStyle", "-", "Color", colors{rIndex}); hold on
end
xticks(1:5);
xlim([.8, 5.2]);
xticklabels(string([0, 0.25, 0.5, 0.75, 1.5]));
xlabel("ICI Difference (%)");
ylabel("Ratio of Change Detection");
title("Figure 2C");

mSubplot(1,3,2) % insertion
for rIndex = 1 : size(pushRatio_331, 2)
    errorbar(1:5, mean(pushRatio_331(:, rIndex, :), 3), SE(pushRatio_331(:, rIndex, :), 3), "LineStyle", "-", "Color", colors{rIndex}); hold on
end
xticks(1:5);
xlim([.8, 5.2]);
xticklabels([string([0, 2, 8, 32]), "Reg4-4.06"]);
xlabel("Insert Number");
title("Figure 2E");

mSubplot(1,3,3) % realistic
for rIndex = 1 : size(pushRatio_340, 2)
    errorbar(1:5, mean(pushRatio_340(:, rIndex, :), 3), SE(pushRatio_340(:, rIndex, :), 3), "LineStyle", "-", "Color", colors{rIndex+1}); hold on
end
xticks(1:5);
xlim([.8, 5.2]);
xticklabels(string([0, 0.25, 0.5, 0.75, 1.5]));
xlabel("ICI Difference (%)");
title("Figure 2G");

setAxesStyle(gcf);
exportFigure2PDF(gcf, '.\Figures\Figure2.pdf', 120, 45);

