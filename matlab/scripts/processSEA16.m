%% DESCRIPTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% processSEA16 parses and pre-processes the WIOD WIOT 2016 release. It
% produces a mat structure data file: sea16_strc.mat
% It requires:
% - idExtract.m
% Source: https://www.rug.nl/ggdc/valuechain/wiod/wiod-2016-release
% Refer to the Readme.md file for more details.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Import WIOD SEA release data from XLSX

% Set file paths
wiodsea_vers = 2016;
wiodsea_funfolder = fullfile('.', 'functions');
wiodsea_dtafolder = fullfile('.', 'data','raw', 'WIOD','SEA16',filesep);

% Add folders to path
addpath(wiodsea_funfolder);
addpath(wiodsea_dtafolder);

%% Reading Meta Data

% Import readme excel file
SEA_filename = 'Socio_Economic_Accounts.xlsx';

SEA_table = readtable(SEA_filename, 'VariableNamesRange', 1,...
    "NumHeaderLines", 1, 'VariableNamingRule', 'preserve', "Sheet","DATA");

notes_table = readtable(SEA_filename, "Sheet","Notes");
notes = table2cell(notes_table);

% Countries
countrycode = notes(:,1);
countrycode_pattern = lettersPattern(3);
countrycode = countrycode(matches(countrycode,countrycode_pattern));

countries = idExtract(notes,'Name');
countries = countries(1:end-1);%Remove "Local Currency" comment

% Variables
variables = idExtract(notes,'Values');
variables((matches(variables,{'Variables','Prices','Volumes'}))) =[];
variable_description = idExtract(notes,'Description');

% Length/Sizes
nvar = length(variables);
ncty = length(countries);
nrow = height(SEA_table);
nind = nrow/(ncty*nvar);

% Industries
industries = SEA_table{1:nind,3};
industrycode = SEA_table{1:nind,4};

% Years
years = str2double((SEA_table.Properties.VariableNames(5:end))');

% Data
Tbl = table;
strvar = string(variables);
for v = 1:nvar
    % Filter the table according to specific variable in SEA
    Tbl = SEA_table(categorical(SEA_table.variable)==variables(v,1),: );
    % Convert table to array of size NRxT (T=time)
    M = Tbl{:,5:end}; 
    eval([strvar{v,1} '=M;']);
end

% Creating a structure with text/info/meta data and numeric data
sea16_text.countrycode = countrycode; 
sea16_text.countries = countries; 
sea16_text.industrycode = industrycode; 
sea16_text.industries = industries;  
sea16_text.variables = variables;
sea16_text.years = years;
sea16_strc.sea16_text = sea16_text;
sea16_data.GO = GO;
sea16_data.II = II;
sea16_data.VA = VA;
sea16_data.EMP = EMP;
sea16_data.EMPE = EMPE;
sea16_data.H_EMPE = H_EMPE;
sea16_data.COMP = COMP;
sea16_data.LAB = LAB;
sea16_data.CAP = CAP;
sea16_data.K = K;
sea16_data.GO_PI = GO_PI;
sea16_data.II_PI = II_PI;
sea16_data.VA_PI = VA_PI;
sea16_data.GO_QI = GO_QI;
sea16_data.II_QI = II_QI;
sea16_data.VA_QI = VA_QI;
sea16_data.SEA_table = SEA_table;
sea16_strc.sea16_data = sea16_data;


% save data and text data into .mat file
save('-v7.3','./data/processed/sea16_strc.mat', '-struct', 'sea16_strc');
fprintf('%s\n','Finished saving sea16_strc.mat');

clearvars
