%% DESCRIPTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% processWIOT16 parses and pre-processes the WIOD WIOT 2016 release. It
% produces a mat structure data file: wiot16_strc.mat
% It requires:
% - idExtract.m
% - netInventCorrect.m
% NOTE: WIOD provides the data in XLSB format. Python is used to convert XLSB
% into CSV files. See convertXlsb2Csv.py code for unzipping and convertion.
% Source: https://www.rug.nl/ggdc/valuechain/wiod/wiod-2016-release
% Refer to the Readme.md file for more details.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Import WIOD WIOT 2016 release data from Excel

% Set file paths
wiod_vers = 2016;
wiod_funfolder = fullfile('.', 'functions');
wiod_dtafolder = fullfile('.', 'data','raw', 'WIOD','WIOT16', filesep);

% Add folders to path
addpath(wiod_funfolder);
addpath(wiod_dtafolder);

% Identify CSV files in the data folder
xlsinfo_infolder = dir(fullfile(wiod_dtafolder, '*.csv'));

%% Reading Meta Data
WIOT2000_filename = 'WIOT2000_Nov16_ROW.csv';
T = readtable(WIOT2000_filename,"VariableNamingRule","preserve","VariableNamesLine",3);

TT = importdata(WIOT2000_filename);
info = TT.textdata(7:2470,:);%Removing first rows and total rows
industrycode  = unique(info(:,1),'stable');
industries = unique(info(:,2),'stable');
countrycode = unique(info(:,3),'stable');
industrycode_wiod  = unique(info(:,4),'stable');

%listing the year range
years_wiod = transpose(str2double(extract({xlsinfo_infolder.name}, digitsPattern(4))));

% Sizing the IO data 
nyrs = size(xlsinfo_infolder,1);%number of years
nind = length(industries);
ncty = length(countrycode);

% number of rows and cols in IO data 
[nrowitems, ncolitems] = size(TT.data);

cols = T.Properties.VariableNames;
finalCols = cols(nind*ncty+5:end-1);%+5 for the 4 cols of info, -1 total col
ncat = size(finalCols,2)/ncty;
finalcat = finalCols(1:ncat)';

%% Importing WIOT16 release
% Preallocate the wiot matrix
wiot_raw = zeros(nrowitems,ncolitems,nyrs);

% Loop through CSV files and create the icio matrix
for i = 1:nyrs
    wiot_dtaimport = importdata(char(xlsinfo_infolder(i).name));
    wiot_raw(:,:,i) = wiot_dtaimport.data;
    fprintf('Finished importing year %d\n', years_wiod(i,1));
end

%% Correcting data for net inventories (See Antras & Chor 2013, 2019)

wiot16 = wiot_raw;
wiot_wototals = wiot16(1:ncty*nind,1:(ncty*nind)+(ncat*ncty),:);
wiot_cln = netInventCorrect(wiot_wototals,finalcat,nind,ncty);

% Remove INVEN from finalcat
finalcat(ismember(finalcat,'INVEN')==1) = [];

%% Exporting the data to .mat files
% Z matrix with Z_ij^rs as a typical element
Z = wiot_cln(1:nind*ncty,1:nind*ncty,:);

% F matrix with F_ij^r as a typical element (& 4 final categories per country)
F = wiot_cln(1:nind*ncty,(nind*ncty)+1:size(wiot_cln,2),:);

% Creating a structure with text/info/meta data and numeric data
wiot16_text.countrycode = countrycode; 
wiot16_text.industrycode_wiod = industrycode_wiod;  
wiot16_text.industrycode = industrycode; 
wiot16_text.industries = industries; 
wiot16_text.finalcat = finalcat; 
wiot16_text.years = years_wiod;
wiot16_strc.wiot16_text = wiot16_text;
wiot16_data.Z = Z;
wiot16_data.F = F;
wiot16_strc.wiot16_data = wiot16_data;

% save data and text data into .mat file
save('-v7.3','./data/processed/wiot16_strc.mat', '-struct', 'wiot16_strc');
fprintf('%s\n','Finished saving wiot16_strc.mat');

clearvars