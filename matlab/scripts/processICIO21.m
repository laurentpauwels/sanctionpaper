%% DESCRIPTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% processICIO21 parses and pre-processes the OECD ICIO 2021 release. It
% produces a mat structure data file: icio21_strc.mat
% It requires:
% - idExtract.m
% - netInventCorrect.m
% Source: OECD-ICIO 2021 release data is downloaded at http://oe.cd/icio
% Refer to the Readme.md file for more details.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Import OCED-ICIO 2021 release data
% Set file paths
icio_vers = 2021;
icio_funfolder = fullfile('.', 'functions');
icio_dtafolder = fullfile('.', 'data','raw', 'ICIO2021',filesep);

% Add folders to path
addpath(icio_funfolder);
addpath(icio_dtafolder);

%% Unzip five .zip files ICIO_yyyy-yyyy.zip
unzip('ICIO_1995-1999.zip',"data/raw/ICIO2021/");
unzip('ICIO_2000-2004.zip',"data/raw/ICIO2021/");
unzip('ICIO_2005-2009.zip',"data/raw/ICIO2021/");
unzip('ICIO_2010-2014.zip',"data/raw/ICIO2021/");
unzip('ICIO_2015-2018.zip',"data/raw/ICIO2021/");


% Identify CSV files in the data folder
csvinfo_infolder = dir(fullfile(icio_dtafolder, '*.csv'));

%% Reading Meta Data

% Import readme excel file
readme_filename = 'ReadMe_ICIO2021_CSV.xlsx';
readme_data = importdata(readme_filename);

% Country, industry and year meta data
country_industry_worksheet = readme_data.textdata.Country_Industry;

countrycode_pattern = lettersPattern(3) | (lettersPattern(2) + digitsPattern(1));
countrycode = country_industry_worksheet(matches(country_industry_worksheet,countrycode_pattern));

oecd_countries = idExtract(country_industry_worksheet,'OECD countries');
non_oecd_countries = idExtract(country_industry_worksheet,'Non-OECD economies');
countries = [oecd_countries;non_oecd_countries];

industries = idExtract(country_industry_worksheet,'Industry');
isic_rev4 = idExtract(country_industry_worksheet,'ISIC Rev.4');
industrycode = idExtract(country_industry_worksheet,'Code');

% Row items meta data
Sheet_RowItems = readme_data.textdata.RowItems;
row_nitems = readme_data.data.RowItems;
row_ctryind_code = idExtract(Sheet_RowItems,'Sector code');

% Column items meta data
Sheet_ColItems = readme_data.textdata.ColItems;
col_nitems = readme_data.data.ColItems;
col_ctryind_code = idExtract(Sheet_ColItems,'Sector code');

% Create list of final demand category
col_country = idExtract(Sheet_ColItems,'Country');
finalcat = col_country(size(col_nitems,1)+1:end);

% Removing "notes" (top & bottom of spreadsheet) 
col_ctryind_code(size(col_nitems,1)+1:end) = [];

% Years meta data
years_icio = str2double(extract({csvinfo_infolder.name}, digitsPattern));%listing the year range
years_icio(years_icio == icio_vers) = [];%removing 2021


%% Importing OECD-ICIO 2021 release

% Preallocate the icio matrix
nrowitems = size(row_nitems,1);%number of rows in IO data 
ncolitems = size(col_nitems,1);%number of columns in IO data 
nyrs = size(csvinfo_infolder,1);%number of years
icio_raw = zeros(nrowitems,ncolitems,nyrs);

% Loop through CSV files and create the icio matrix
for i = 1:nyrs
    icio_dtaimport = importdata(char(csvinfo_infolder(i).name));
    icio_raw(:,:,i) = icio_dtaimport.data;
    fprintf('Finished importing year %d\n', years_icio(1,i));
end
delete(fullfile('./data/raw/ICIO2021','*.csv'))

%% Combining MEX with MX1 and MX2 and CHN with CN1 and CN2

mex = find(contains(row_ctryind_code,'MEX_D') == 1);
mx1 = find(contains(row_ctryind_code,'MX1_D') == 1);
mx2 = find(contains(row_ctryind_code,'MX2_D') == 1);

chn = find(contains(row_ctryind_code,'CHN_D') == 1);
cn1 = find(contains(row_ctryind_code,'CN1_D') == 1);
cn2 = find(contains(row_ctryind_code,'CN2_D') == 1);

icio21 = icio_raw;
%Combine MEX with MX1 and MX2
icio21(mex,:,:) = icio21(mex,:,:) + icio21(mx1,:,:) + icio21(mx2,:,:);%Add rows
icio21(:,mex,:) = icio21(:,mex,:) + icio21(:,mx1,:) + icio21(:,mx2,:);%Add cols

%Combine CHN with CN1 and CN2
icio21(chn,:,:) = icio21(chn,:,:) + icio21(cn1,:,:) + icio21(cn2,:,:);%Add rows
icio21(:,chn,:) = icio21(:,chn,:) + icio21(:,cn1,:) + icio21(:,cn2,:);%Add cols

% Note: operations are dependent. 
% (1) From icio, sum MEX+MX1+MX2 Row blocs, then save in icio MEX row bloc.
% (2) Use saved matrix in (1) to sum over MEX+MX1+MX2 Cols blocs, then same
% in icio MEX col blocs
% (3) Repeat (1) and (2) for CHN.

%Remove MX1, MX2, CN1 and CN2
icio21([mx1,mx2,cn1,cn2],:,:) = [];%Remove MX1, MX2, CN1 and CN2 rows
icio21(:,[mx1,mx2,cn1,cn2],:) = [];%Remove MX1, MX2, CN1 and CN2 cols

%Remove MX1, MX2, CN1 and CN2 from IDs
countries(ismember(countrycode,{'MX1','MX2','CN1','CN2'})) = [];
countrycode(ismember(countrycode,{'MX1','MX2','CN1','CN2'})) = [];
row_ctryind_code(contains(row_ctryind_code,{'MX1','MX2','CN1','CN2'})) = [];
col_ctryind_code(contains(col_ctryind_code,{'MX1','MX2','CN1','CN2'})) = [];

%% Correcting data for net inventories (See Antras & Chor 2013, 2019)

ncat = size(finalcat,1);
ncty = size(countries,1);
nind = size(industries,1);
icio_wototals = icio21(1:ncty*nind,1:(ncty*nind)+(ncat*ncty),:);
icio_cln = netInventCorrect(icio_wototals,finalcat,nind,ncty);

% Remove INVNT from finalcat
finalcat(ismember(finalcat,'INVNT')==1) = [];

%% Exporting the data to .mat files
% Z matrix with Z_ij^rs as a typical element
Z = icio_cln(1:nind*ncty,1:nind*ncty,:);

% F matrix with F_ij^r as a typical element (& 4 final categories per country)
F = icio_cln(1:nind*ncty,(nind*ncty)+1:size(icio_cln,2),:);

% Creating a structure with text/info/meta data and numeric data
icio21_text.countrycode = countrycode; 
icio21_text.countries = countries; 
icio21_text.industrycode = industrycode; 
icio21_text.industries = industries; 
icio21_text.isic_rev4 = isic_rev4; 
icio21_text.finalcat = finalcat; 
icio21_text.years = transpose(years_icio);
icio21_text.iciorelease = icio_vers; 
icio21_strc.icio21_text = icio21_text;
icio21_data.Z = Z;
icio21_data.F = F;
icio21_strc.icio21_data = icio21_data;

% save data and text data into .mat file
save('-v7.3','./data/processed/icio21_strc.mat', '-struct', 'icio21_strc');
fprintf('%s\n','Finished saving icio21_strc.mat');

clearvars
