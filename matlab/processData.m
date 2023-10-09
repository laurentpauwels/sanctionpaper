% This main code produces: three .mat files: 
% icio21_strc.mat, wiot16_strc.mat, and sea16_strc.mat

%% PATHS
% Add folders to path
io_funfolder = fullfile('.', 'functions');
io_scrfolder = fullfile('.', 'scripts');
io_dtafolder = fullfile('.', 'data','processed',filesep);

addpath(io_funfolder);
addpath(io_scrfolder);
addpath(io_dtafolder);

%% OECD ICIO21 Data Parsing
% The ICIO21 dataset is used in evaluateTradeSanctions.m to reproduce
% Tables 1 to 8 and Figures 4 to 8.
% Source: OECD-ICIO 2021 release data is downloaded at http://oe.cd/icio
run("processICIO21.m")
clear

%% WIOD SEA16 Data Parsing
% The approximations (Tables 3-6) require parameter alpha
% alpha = Labor Compensation / Value Addded (in national currency)
% This is constructed from WIOD Socio-Economic Accounts (2016 release)
% Source: WIOD Socio-Economic Accounts (2016 release) which can be 
% downloaded at https://www.rug.nl/ggdc/valuechain/wiod/wiod-2016-release
run("processSEA16.m")
clear

%% WIOD WIOT16 Data Parsing
% The WIOD IO Tables are used to evaluate the approximation in script:
% evaluateApproximation.m. The script produces Figures 1 - 3.
% Source: WIOD 2016 release data is downloaded at http://wiod.org
run("processWIOT16.m")
clear