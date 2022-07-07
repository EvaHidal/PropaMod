% plotSSP
% Plot Sound Speed Profile for region of choice.
% Configured for use with HYCOM's files
% Latitudes and longitudes are configured for Western Atlantic (WAT). To
% change this, make edits in ext_hycom_gofs_3_1.m.

% AD: HYCOM data provides data points for every 1/12 degree. I believe 
% that is at most every ~9.25 km. This MIGHT allow us to see significant
% differences in sound speed across a 20-km range, but given such a low
% resolution, I think those differences will be somewhat imprecise.

clearvars
close all

%% Parameters defined by user
% Before running, make sure desired data has been downloaded from HYCOM
% using ext_hycom_gofs_3_1.m.
fileName = '0014_20170301T000000'; % File name to match.
regionabrev = 'WAT';
FilePath = 'H:\My Drive\WAT_TPWS_metadataReduced\HYCOM';
saveDirectory = 'H:\My Drive\WAT_TPWS_metadataReduced\HYCOM\Plots';

%For PART B (Longitude Line Plots): Select longitude line along which to cut
long = 150; %At present this code cannot accept longitude values directly...
            %After running line 32, open D.Longitude and enter the position
            %of your desired longitude (e.g. 150 --> 290 deg E)
            %I (AD) may update this to accept any (actual) longitude and extrapolate
            %from the data

%For PART C (Site Plots): Add site data below: siteabrev, lat, long
siteabrev = ["NC";       "BC";       "GS";       "BP";       "BS"];
Latitude  = [39.8326;    39.1912;    33.6675;    32.1061;    30.5833];
Longitude = [-69.9800;   -72.2300;   -76;        -77.0900;   -77.3900];

%% Load data
load([FilePath,'\', fileName]);
temp_frame = D.temperature;
sal_frame = D.salinity;
temp_frame = flip(permute(temp_frame, [2 1 3]),1); % To make maps work, swaps lat/long and flips lat
sal_frame = flip(permute(sal_frame, [2 1 3]),1);
depth_frame = zeros(length(D.Latitude), length(D.Longitude), length(D.Depth)); % Generates a 3D depth frame to match with sal and temp
for i=1:301
    for j=1:length(D.Longitude)
        depth_frame(i,j,1:length(D.Depth)) = D.Depth;
    end
end

cdat = nan(length(D.Latitude),length(D.Longitude),length(D.Depth)); % Generates an empty frame to input sound speeds
for i=1:(length(D.Latitude)*length(D.Longitude)*length(D.Depth)) % Only adds sound speed values ABOVE the seafloor
    if temp_frame(i) ~= 0 & sal_frame(i) ~= 0
        cdat(i) = salt_water_c(temp_frame(i),(-depth_frame(i)),sal_frame(i)); % Sound Speed data
    end
end

%% (A) REGION: Plot sound speed by depth across region

Xtix = D.Longitude; % Adjust plot tick marks (found this code somewhere on google, as always)
reducedXtix = string(Xtix);
reducedXtix(mod(Xtix,1) ~= 0) = "";
Ytix = flip(D.Latitude);
reducedYtix = string(Ytix);
reducedYtix(mod(Ytix,1) ~= 0) = "";

% MAKE FIGURE
figure(5) % Sound Speed at various depths
set(gcf,"Position",[100 200 1300 400])
subplot(1,4,1)                                      % 0M, SURFACE
depthlevel = heatmap(cdat(:,:,1), 'Colormap', turbo, 'ColorLimits', [1400 1560]);
grid off; colorbar off
title("0 m")
depthlevel.XDisplayLabels = reducedXtix;
depthlevel.YDisplayLabels = reducedYtix;
subplot(1,4,2)                                      % -300M
depthlevel = heatmap(cdat(:,:,25), 'Colormap', turbo, 'ColorLimits', [1400 1560]);
grid off; colorbar off
title("300 m")
depthlevel.XDisplayLabels = reducedXtix;
depthlevel.YDisplayLabels = reducedYtix;
subplot(1,4,3)                                      % -600M
depthlevel = heatmap(cdat(:,:,29), 'Colormap', turbo, 'ColorLimits', [1400 1560]);
grid off; colorbar off
title("600 m")
depthlevel.XDisplayLabels = reducedXtix;
depthlevel.YDisplayLabels = reducedYtix;
subplot(1,4,4)                                      % -1000M
depthlevel = heatmap(cdat(:,:,33), 'Colormap', turbo, 'ColorLimits', [1400 1560]);
grid off
title("1000 m")
depthlevel.XDisplayLabels = reducedXtix;
depthlevel.YDisplayLabels = reducedYtix;

%% (B) LONGITUDE: Plot sound speed profiles by longitude line slices

cdat_slice = permute(cdat, [3 1 2]); % Place depth in first position (y), latitude in second position (x)
depthlist = abs(transpose(D.Depth)); % List of depth values to assign to the y's in cdat_slice

Xtix = flip(D.Latitude); % Adjust plot tick marks
reducedXtix = string(Xtix);
reducedXtix(mod(Xtix,1) ~= 0) = "";
Ytix = 1:5000;
reducedYtix = string(Ytix);
reducedYtix(mod(Ytix,500) ~= 0) = "";

%MAKE FIGURE
sspslicefig = figure(5000 + long);
longcut_table = cdat_slice(:,:,long);
longcut_table(longcut_table(:,:)==0) = NaN;
[latq, depthq] = meshgrid(1:1:length(D.Latitude),1:1:5000);
longcut_table = interp2((1:length(D.Latitude)).', (depthlist).', longcut_table, latq, depthq);
longcut = heatmap(longcut_table, 'Colormap', turbo, 'ColorLimits', [1400 1560]);
grid off
longcut.XDisplayLabels = reducedXtix;
longcut.YDisplayLabels = reducedYtix;
xlabel("Latitude (*N)")
ylabel("Depth (m)")
titledate = datetime(str2num(string(extractBetween(fileName, 6,13))), 'ConvertFrom', 'yyyymmdd', 'Format', 'MM/dd/yyyy');
title([char(titledate), ' | ', num2str(D.Longitude(long)), char(176), 'E'])

%SAVE FIGURE
plotDate = extractBetween(fileName, 6,13);
Longitu = D.Longitude(long);
set(gcf,'Position',[500 200 700 400]);
saveas(gcf,[saveDirectory,'\',char(plotDate),'_',...
    char(string(round(10*Longitu))),'_SSPslice'],'png');

%saveas(gcf,[saveDirectory,'\',regionabrev,'\',char(plotDate),'_',... %More complicated workaround for lines 120-21
    %char(string(round(Longitu))),char(string(round(10*mod(Longitu, round(Longitu))))),'_SSPslice'],'png');
    
%% (C) LOCATION: Plot sound speed profile at each site

LongitudeE = Longitude + 360;
siteCoords = [Latitude, LongitudeE];

%MAKE FIGURES, and GENERATE TABLE OF SITE SSP VALUES
SSP_table = [depthlist.', nan(5,40).'];
for i=1:length(siteabrev)
    numdepths = nan(1,length(depthlist));
    for j=1:length(depthlist) %interpolate sound speed grid at each depth to infer sound speed values at site coordinates
        numdepths(j) = interp2(D.Longitude,flip(D.Latitude),cdat(:,:,j),siteCoords(i,2),siteCoords(i,1).');
    end
    figure(200+i)
    plot(numdepths, -depthlist,'-o')
    xlabel("Sound Speed (m/s)"); ylabel("Depth (m)")
    title(['SSP at ', char(siteabrev(i)),' | ', num2str(siteCoords(i,1)),char(176), 'N, ', num2str(siteCoords(i,2)),char(176), 'E'])
    set(gcf,"Position",[(305*i - 300) 100 300 600])
    saveas(gcf,[saveDirectory,'\',char(plotDate),'_',char(siteabrev(i)),'_SSP'],'png');
    
    SSP_table(:,i+1) = numdepths;
end
SSP_table = array2table(SSP_table);
SSP_table.Properties.VariableNames = {'Depth' char(siteabrev(1)) char(siteabrev(2)) char(siteabrev(3)) char(siteabrev(4)) char(siteabrev(5))};
writetable(SSP_table,[saveDirectory,'\', 'SSP_', regionabrev, '.xlsx'])