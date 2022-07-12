% plotSSP
% Plot Sound Speed Profile for region of choice.
% Configured for use with HYCOM's files
% Latitudes and longitudes are configured for Western Atlantic (WAT). To
% change this, make edits in ext_hycom_gofs_3_1.m.

% AD: HYCOM data provides data points for every 1/12 degree. I believe 
% that is at most every ~9.25 km. This MIGHT allow us to see significant
% differences in sound speed across a 20-km range, but given such a low
% resolution, I think those differences will be somewhat imprecise.

% Different parts of the code should be commented out as appropriate when
% analyzing large amounts of data for speed

clearvars
close all
    
%% Parameters defined by user
% Before running, make sure desired data has been downloaded from HYCOM
% using ext_hycom_gofs_3_1.m.
regionabrev = 'WAT';
FilePath = 'H:\My Drive\PropagationModeling\HYCOM_data';
fileNames = ls(fullfile(FilePath, '*0*')); % File name to match.
%FilePath = 'H:\My Drive\WAT_TPWS_metadataReduced\HYCOM';
saveDirectory = 'H:\My Drive\PropagationModeling\SSPs';
%saveDirectory = 'H:\My Drive\WAT_TPWS_metadataReduced\HYCOM\Plots';

%For PART B (Longitude Line Plots): Select longitude line along which to cut
long = 150;

%For PART C (Site Plots): Add site data below: siteabrev, lat, long
siteabrev = ["NC";       "BC";       "GS";       "BP";       "BS";      "WC";       "OC";       "HZ";       "JAX"];
Latitude  = [39.8326;    39.1912;    33.6675;    32.1061;    30.5833;   38.3738;    40.2550;    41.0618;    30.1523]; %jax avg is for D_13, 14, 15 only
Longitude = [-69.9800;   -72.2300;   -76;        -77.0900;   -77.3900;  -73.37;     -67.99;     -66.35;     -79.77];

%% Overarching loop runs through all timepoints requested
for k = 1:length(fileNames(:,1))
fileName = fileNames(k,:);

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

% Make timestamp for plot labels
timestamp = [fileName(6:9), '/', fileName(10:11), '/', fileName(12:13), ' ',...
    fileName(15:16), ':', fileName(17:18), ':', fileName(19:20)];

% %% (A) REGION: Plot sound speed by depth across region
% 
% Xtix = D.Longitude; % Adjust plot tick marks (found this code somewhere on google, as always)
% reducedXtix = string(Xtix);
% reducedXtix(mod(Xtix,1) ~= 0) = "";
% Ytix = flip(D.Latitude);
% reducedYtix = string(Ytix);
% reducedYtix(mod(Ytix,1) ~= 0) = "";
% 
% % MAKE FIGURE
% figure(5) % Sound Speed at various depths
% set(gcf,"Position",[100 200 1300 400])
% subplot(1,4,1)                                      % 0M, SURFACE
% depthlevel = heatmap(cdat(:,:,1), 'Colormap', turbo, 'ColorLimits', [1400 1560]);
% grid off; colorbar off
% title("0 m")
% depthlevel.XDisplayLabels = reducedXtix;
% depthlevel.YDisplayLabels = reducedYtix;
% subplot(1,4,2)                                      % -300M
% depthlevel = heatmap(cdat(:,:,25), 'Colormap', turbo, 'ColorLimits', [1400 1560]);
% grid off; colorbar off
% title("300 m")
% depthlevel.XDisplayLabels = reducedXtix;
% depthlevel.YDisplayLabels = reducedYtix;
% subplot(1,4,3)                                      % -600M
% depthlevel = heatmap(cdat(:,:,29), 'Colormap', turbo, 'ColorLimits', [1400 1560]);
% grid off; colorbar off
% title("600 m")
% depthlevel.XDisplayLabels = reducedXtix;
% depthlevel.YDisplayLabels = reducedYtix;
% subplot(1,4,4)                                      % -1000M
% depthlevel = heatmap(cdat(:,:,33), 'Colormap', turbo, 'ColorLimits', [1400 1560]);
% grid off
% title("1000 m")
% depthlevel.XDisplayLabels = reducedXtix;
% depthlevel.YDisplayLabels = reducedYtix;
% 
% disp([fileName, ' - Completed Part A'])
%     
% %% (B) LONGITUDE: Plot sound speed profiles by longitude line slices
% 
% cdat_slice = permute(cdat, [3 1 2]); % Place depth in first position (y), latitude in second position (x)
% depthlist = abs(transpose(D.Depth)); % List of depth values to assign to the y's in cdat_slice
% 
% Xtix = flip(D.Latitude); % Adjust plot tick marks
% reducedXtix = string(Xtix);
% reducedXtix(mod(Xtix,1) ~= 0) = "";
% Ytix = 1:5000;
% reducedYtix = string(Ytix);
% reducedYtix(mod(Ytix,500) ~= 0) = "";
% 
% %MAKE FIGURE
% sspslicefig = figure(5000 + long);
% longcut_table = cdat_slice(:,:,long);
% longcut_table(longcut_table(:,:)==0) = NaN;
% [latq, depthq] = meshgrid(1:1:length(D.Latitude),1:1:5000);
% longcut_table = interp2((1:length(D.Latitude)).', (depthlist).', longcut_table, latq, depthq);
% longcut = heatmap(longcut_table, 'Colormap', turbo, 'ColorLimits', [1400 1560]);
% grid off
% longcut.XDisplayLabels = reducedXtix;
% longcut.YDisplayLabels = reducedYtix;
% xlabel("Latitude (*N)")
% ylabel("Depth (m)")
% titledate = datetime(str2num(string(extractBetween(fileName, 6,13))), 'ConvertFrom', 'yyyymmdd', 'Format', 'MM/dd/yyyy');
% title([char(titledate), ' | ', num2str(D.Longitude(long)), char(176), 'E'])
% 
% %SAVE FIGURE
% plotDate = extractBetween(fileName, 6,13);
% Longitu = D.Longitude(long);
% set(gcf,'Position',[500 200 700 400]);
% saveas(gcf,[saveDirectory,'\',char(plotDate),'_',...
%     char(string(round(10*Longitu))),'_SSPslice'],'png');
% 
% disp([fileName, ' - Completed Part B'])
% 
% %saveas(gcf,[saveDirectory,'\',regionabrev,'\',char(plotDate),'_',... %More complicated workaround for lines 120-21
%     %char(string(round(Longitu))),char(string(round(10*mod(Longitu, round(Longitu))))),'_SSPslice'],'png');
    
%% (C) LOCATION: Plot sound speed profile at each site

depthlist = abs(transpose(D.Depth)); % List of depth values to assign to the y's
LongitudeE = Longitude + 360;
siteCoords = [Latitude, LongitudeE];

%MAKE FIGURES, and GENERATE TABLE OF SITE SSP VALUES
SSP_table = [depthlist.'];
for i=1:length(siteabrev)
    numdepths = nan(1,length(depthlist));
    for j=1:length(depthlist) %interpolate sound speed grid at each depth to infer sound speed values at site coordinates
        numdepths(j) = interp2(D.Longitude,flip(D.Latitude),cdat(:,:,j),siteCoords(i,2),siteCoords(i,1).');
    end
    %figure(200+i)
    %plot(numdepths, -depthlist,'-o')
    %xlabel("Sound Speed (m/s)"); ylabel("Depth (m)")
    %%title(['SSP at ', char(siteabrev(i)),' | ', num2str(siteCoords(i,1)),char(176), 'N, ', num2str(siteCoords(i,2)),char(176), 'E'])
    %title(['SSP at ', char(siteabrev(i)),' | ', timestamp])
    %set(gcf,"Position",[(155*i - 150) 100 300 600])
    %saveas(gcf,[saveDirectory,'\',char(plotDate),'_',char(siteabrev(i)),'_SSP'],'png');
    
    SSP_table(:,i+1) = numdepths;
end
SSP_table = array2table(SSP_table);
SSP_table.Properties.VariableNames = {'Depth' char(siteabrev(1)) char(siteabrev(2)) char(siteabrev(3)) char(siteabrev(4)) char(siteabrev(5)) char(siteabrev(6)) char(siteabrev(7)) char(siteabrev(8)) char(siteabrev(9))};
writetable(SSP_table,[saveDirectory,'\', 'SSP_', regionabrev, '_', fileName(strfind(fileName,'_')+1:end), '.xlsx'])

disp([fileName, ' - Completed Part C'])

end

% REORDER TIME-WISE TABLES TO SITE-WISE TABLES
timeFileNames = ls(fullfile(saveDirectory,'*SSP_WAT_2*'));
SSP_NC = array2table([depthlist].');    SSP_NC.Properties.VariableNames(1) = {'Depth'};
SSP_BC = array2table([depthlist].');    SSP_BC.Properties.VariableNames(1) = {'Depth'};
SSP_GS = array2table([depthlist].');    SSP_GS.Properties.VariableNames(1) = {'Depth'};
SSP_BP = array2table([depthlist].');    SSP_BP.Properties.VariableNames(1) = {'Depth'};
SSP_BS = array2table([depthlist].');    SSP_BS.Properties.VariableNames(1) = {'Depth'};
SSP_WC = array2table([depthlist].');    SSP_WC.Properties.VariableNames(1) = {'Depth'};
SSP_OC = array2table([depthlist].');    SSP_OC.Properties.VariableNames(1) = {'Depth'};
SSP_HZ = array2table([depthlist].');    SSP_HZ.Properties.VariableNames(1) = {'Depth'};
SSP_JAX = array2table([depthlist].');   SSP_JAX.Properties.VariableNames(1) = {'Depth'};

for n = 1:length(timeFileNames)
    SSPbyTime = readtable(fullfile(saveDirectory,timeFileNames(n,:)));
    
    SSP_NC(:,n+1) = SSPbyTime(:,2);
    SSP_NC.Properties.VariableNames(n+1) = {timeFileNames(n,9:16)};
    SSP_BC(:,n+1) = SSPbyTime(:,3);
    SSP_BC.Properties.VariableNames(n+1) = {timeFileNames(n,9:16)};
    SSP_GS(:,n+1) = SSPbyTime(:,4);
    SSP_GS.Properties.VariableNames(n+1) = {timeFileNames(n,9:16)};
    SSP_BP(:,n+1) = SSPbyTime(:,5);
    SSP_BP.Properties.VariableNames(n+1) = {timeFileNames(n,9:16)};
    SSP_BS(:,n+1) = SSPbyTime(:,6);
    SSP_BS.Properties.VariableNames(n+1) = {timeFileNames(n,9:16)};
    SSP_WC(:,n+1) = SSPbyTime(:,7);
    SSP_WC.Properties.VariableNames(n+1) = {timeFileNames(n,9:16)};
    SSP_OC(:,n+1) = SSPbyTime(:,8);
    SSP_OC.Properties.VariableNames(n+1) = {timeFileNames(n,9:16)};
    SSP_HZ(:,n+1) = SSPbyTime(:,9);
    SSP_HZ.Properties.VariableNames(n+1) = {timeFileNames(n,9:16)};
    SSP_JAX(:,n+1) = SSPbyTime(:,10);
    SSP_JAX.Properties.VariableNames(n+1) = {timeFileNames(n,9:16)};
    
    disp(['Added date ' timeFileNames(n,9:16) ' to all site-wise tables'])
end

writetable(SSP_NC,[saveDirectory,'\', 'SSP_', regionabrev, '_', char(siteabrev(1)), '.csv'])
writetable(SSP_BC,[saveDirectory,'\', 'SSP_', regionabrev, '_', char(siteabrev(2)), '.csv'])
writetable(SSP_GS,[saveDirectory,'\', 'SSP_', regionabrev, '_', char(siteabrev(3)), '.csv'])
writetable(SSP_BP,[saveDirectory,'\', 'SSP_', regionabrev, '_', char(siteabrev(4)), '.csv'])
writetable(SSP_BS,[saveDirectory,'\', 'SSP_', regionabrev, '_', char(siteabrev(5)), '.csv'])
writetable(SSP_WC,[saveDirectory,'\', 'SSP_', regionabrev, '_', char(siteabrev(6)), '.csv'])
writetable(SSP_OC,[saveDirectory,'\', 'SSP_', regionabrev, '_', char(siteabrev(7)), '.csv'])
writetable(SSP_HZ,[saveDirectory,'\', 'SSP_', regionabrev, '_', char(siteabrev(8)), '.csv'])
writetable(SSP_JAX,[saveDirectory,'\', 'SSP_', regionabrev, '_', char(siteabrev(9)), '.csv'])