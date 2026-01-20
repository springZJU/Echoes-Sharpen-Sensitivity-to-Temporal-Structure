function ECOGPos = ECOGPos_Kedou32(varargin)
narginchk(0, 1);
if nargin > 0
    arrayPos = varargin{1};
else
    arrayPos = "left";
end
% channels not to plot
ECOGPos.ignore = [];

%% Channel Alias
ECOGPos.channelNames = cellstr(string(1:32))';

%% projection
if matches(arrayPos, "left")
p(2:5) = 1:4;
p(7:12) = 5:10;
p(13:18) = 11:16;
p(19:24) = 17:22;
p(25:30) = 23:28;
p(32:35) = 29:32;
p(36) = 0;
elseif matches(arrayPos, "right")
p(2:5) = 32:-1:29;
p(7:12) = 28:-1:23;
p(13:18) = 22:-1:17;
p(19:24) = 16:-1:11;
p(25:30) = 10:-1:5;
p(32:35) = 4:-1:1;
p(36) = 0;
end

%% Neighbours
temp = mPrepareNeighbours(1:36, [6, 6]);
temp([1, 6, 31, 36]) = [];
for tIndex = 1 : length(temp)
    ECOGPos.neighbours(tIndex).label = num2str(tIndex*matches(arrayPos, "left") + (33-tIndex)*matches(arrayPos, "right"));
    ECOGPos.neighbours(tIndex).neighblabel = p(str2double((temp(tIndex).neighblabel)));
    ECOGPos.neighbours(tIndex).neighblabel(ismember(ECOGPos.neighbours(tIndex).neighblabel,  [0, tIndex])) = [];
    ECOGPos.neighbours(tIndex).neighbch = ECOGPos.neighbours(tIndex).neighblabel;
    ECOGPos.neighbours(tIndex).neighblabel = cellstr(string(ECOGPos.neighbours(tIndex).neighblabel));
    
end

%% Grid
% grid size
ECOGPos.grid = [6, 6]; % row-by-column
if matches(arrayPos, "left")
% channel map into grid
ECOGPos.map(1:4) = 2:5;
ECOGPos.map(5:28) = 7:30;
ECOGPos.map(29:32) = 32:35;
elseif matches(arrayPos, "right")
ECOGPos.map(1:4) = 35:-1:32;
ECOGPos.map(5:28) = 30:-1:7;
ECOGPos.map(29:32) = 5:-1:2;
end
ECOGPos.channels = 1:32;
