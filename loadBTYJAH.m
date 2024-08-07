function AllVariables = loadBTYJAH(distDec, hlat_range, hlon_range, GEBCODir, GEBCOFile)
try
    %% Load file from GEBCO
    fullPath = fullfile(GEBCODir, GEBCOFile);
    [~, ~, exten] = fileparts(fullPath);
    if strcmp(exten, '.tif')
        [A, R] = readgeoraster(fullPath);
        A = double(A);
        % Step 2: Create a meshgrid for pixel coordinates
        [rowLon, colLon] = meshgrid(1:R.RasterSize(1), 1);
        [rowLat, colLat] = meshgrid(1, 1:R.RasterSize(2));
        % Step 3: Convert intrinsic coordinates to geographic coordinates
        [lat, ~] = intrinsicToGeographic(R, rowLat, colLat);
        [~, lon] = intrinsicToGeographic(R, rowLon, colLon);
        lon = lon';
        AllVariables{1,1} = 'x';
        AllVariables{1,2} = 'y';
        AllVariables{1,3} = 'z';
        AllVariables{1,4} = 'R';
        AllVariables{2,1} = lon;
        AllVariables{2,2} = lat';
        AllVariables{2,3} = abs(flipud(A));
        AllVariables{2,4} = R;
        disp('Processed .tif file');
    elseif strcmp(exten, '.nc')
        ncid = netcdf.open(fullPath, 'nowrite');
        vars = netcdf.inqVarIDs(ncid);
        AllVariables = cell(2, width(vars));
        for i = vars
            [varname] = netcdf.inqVar(ncid, i);
            var = netcdf.getVar(ncid, i);
            cellLoc = find(vars == i);
            AllVariables{1, cellLoc} = char(varname);
            AllVariables{2, cellLoc} = var;
        end
        disp('Processed .nc file');
    else
        error('Unsupported file extension: %s', exten);
    end
catch ME
    disp('An error occurred:');
    disp(ME.message);
end
end
