% Author: Amanze Ejiogu
% Name: OzoneDataProcessor.m
% Description: This program will ingest the sonde ICARTT file as well as the
% lidar .h5 file to create a csv that can be processed by an adjacent
% Python script.
% Notes: This requires the function "ICARTTreader" written by Glen Wolfe, \
% which can be found at https://github.com/AirChem/DataHandling/blob/master/ICARTTreader.m.
clearvars

%Current file you would like to compare data
%Enter the pathname for folder that contains data
sounding_folder = "C:\Users\BOSS COMPUTER\Documents\Hart Miller Island 2018\Plotting Data\HMI\Ozonesondes\";
sounding_file = "owlets2-HMI_SONDE_20180630_R0_L1.ict"; %Enter file name
sonde_data = ICARTTreader(strcat(sounding_folder,sounding_file));

%Save location of file for the processed data
save_loc = strcat('C:\Users\BOSS COMPUTER\Documents\Hart Miller Island 2018\Plotting Data\',...
    'ProcessedData.csv');

%Enter the pathname for folder that contains data
lidar_folder = "C:\Users\BOSS COMPUTER\Documents\Hart Miller Island 2018\Plotting Data\HMI\Ozone Lidar\";
lidar_file = "owlets2-HMI-LMOL-LaRC_Ozone-Lidar_20180630_R1.h5"; %Enter file name
lidar = strcat(lidar_folder,lidar_file);



%Here, we get the sounding date from the header
raw_date = sonde_data.header{7,1};
sounding_date = datetime(raw_date(1:12), "InputFormat","yyyy, MM, dd");

%Data that the program will read and save from the ozone lidar
lidar_O3 = h5read(lidar,"/DATA/O3MR");
lidar_uncert = h5read(lidar,"/DATA/O3MRUncert");
lidar_alt = h5read(lidar,"/DATA/ALT");
lidar_raw_time = h5read(lidar, "/DATA/TIME_MID_UT_DATEVEC");
lidar_time = transpose(datetime(datevec(lidar_raw_time)));

if abs((lidar_time(1,1) - sounding_date)) > days(1)
    disp(['The lidar data (', datestr(lidar_time(1,1), "dd-mmm-yyyy"), ') and the sounding data (',...
        datestr(sounding_date), ') are from 2 different dates. ']);
    resp = input("Continue (Y/N)? ", "s");
    if resp == "N"|| resp == "n"
        return
    end
end

%Retrieving the time after UTC of the sounding
sounding_raw_time = sonde_data.Seconds_UTC; %Note, this is time in seconds after UTC

%Covert that time to date
sonde_time =  sounding_date + seconds(sounding_raw_time);

%Data that the program will read and save from the sounding
ozone = sonde_data.Ozone_ppmv;
temp = sonde_data.Temp_degC;
pressure = sonde_data.Pressure_hPa;
sonde_alt =  sonde_data.GPSAltitude_km;
pres_alt = sonde_data.Altitude_km;
rh = sonde_data.RH_percent;
theta_k = sonde_data.Theta_K;

%Find 10 km
for i = 1:size(temp,1)
    current_height = sonde_alt(i,1);
    if current_height > 10
        max_index = i;
        break
    end
end

%The script defaults to GPS altitude, but if data is missing, pressure based
%altitude will be used instead.
for i = 1:max_index
    if isnan(sonde_alt(i,1))
        %sonde_alt(i,1) = pres_alt(i,1);
    end
end

%Convert kilometers to meters
sonde_alt = sonde_alt*1000;

%We assume the ground level pressure and temperature are the first values
%in the data set. Using the Calusius-Clapeyron Equation
if isnan(pressure(1,1))
    start_pres = 1.01325;
else
    start_pres = pressure(1,1);
end


%Using the Buck Equation
v_pressure_B = zeros(max_index,1); %Uses 
v_pressure_CC = zeros(max_index,1);
mixing_ratio = zeros(max_index,1);

%Calculating mixing ratio
for i = 1:max_index
    v_pressure_CC(i,1) = start_pres * exp((-40700/8.3145)*((1/(temp(i,1)+273.15))-(1/(373))));

    if temp(i,1) > 0
        v_pressure_B(i,1) = 6.1121 * exp((18.678-(temp(i,1)/234.5))*(temp(i,1)/...
            (257.14+temp(i,1))));
    elseif temp(i,1) <= 0
        v_pressure_B(i,1) = 6.1115 * exp((23.036-(temp(i,1)/333.7))*(temp(i,1)/...
            (279.82+temp(i,1))));
    else
        v_pressure_B(i,1) = NaN;
    end
    
    mixing_ratio(i,1) = 0.622 * (v_pressure_CC(i,1) / (pressure(i,1) -  v_pressure_CC(i,1)));
    mixing_ratio(i,2) = 0.622 * (v_pressure_B(i,1) / (pressure(i,1) -  v_pressure_B(i,1)));
end

%mixing_ratio = 0.622 * (v_pressure_CC / (pressure -  v_pressure_CC));
sat_mixing_ratio = (mixing_ratio(i,2) * 100)./rh(1:max_index,1);


%This portion calculates an estimated ozone concentration via lidar depending 
%on where the balloon is in the atmosphere and when the measurement was taken
ozone_est = zeros(max_index,2); %Column 1: Ozone est. Column 2: Ozone uncert
for i = 1:max_index
    compare_alt = abs(sonde_alt(i,1) - lidar_alt);
    [null,alt_index] = min(compare_alt);
    
    compare_time = abs(sonde_time(i,1) - lidar_time);
    [null,time_index] = min(compare_time);
    
    ozone_est(i,1) = lidar_O3(time_index,alt_index);
    ozone_est(i,2) = lidar_uncert(time_index,alt_index);
end

ozone_est(ozone_est == -9999) = NaN;

final_data(:,1) = ozone(1:max_index,1)*1000;
final_data(:,2) = theta_k(1:max_index,1);
final_data(:,3) = mixing_ratio(:,2);
final_data(:,4) = sat_mixing_ratio;
final_data(:,5) = sonde_alt(1:max_index,1);
final_data(:,6) = ozone_est(:,1);
final_data(:,7) = ozone_est(:,2);

final_data = [["O3", "Theta_K", "MR", "SMR",...
    "Alt", "EstO3", "O3Uncert"];final_data];
    
writematrix(final_data,save_loc)
