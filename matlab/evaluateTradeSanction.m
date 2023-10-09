%% DESCRIPTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% evaluateTradeSanction is the main script that produces Tables 1 - 8 and
% Figures 4 - 6 in the Imbs and Pauwels (2023, EconPolicy).
% The tables and figures are produced with several scripts and functions.
% evaluateTradeSanction.m requires these scripts: 
% - compareDirectTrade.m 
% - approxEffectSanction.m 
% - concoranceAlpha.m 
% - getSubstituteMarket.m
% - graphSubstituteMarket.m
% The data required are:
% - sea16_strc.mat
% - icio21_strc.mat
% For the required functions, consult the individual scripts. 
% Refer to the Readme.md file for more details.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% PATHS
% Add folders to path
io_funfolder = fullfile('.', 'functions');
io_scrfolder = fullfile('.', 'scripts');
io_dtafolder = fullfile('.', 'data','processed',filesep);
io_outfolder = fullfile('.', 'output');
io_plotfolder = fullfile('.', 'output','plots',filesep);

addpath(io_funfolder);
addpath(io_scrfolder);
addpath(io_dtafolder);
addpath(io_outfolder);
addpath(io_plotfolder);

%% DATA PROCESSING
% Load WIOD Socio-Economic Accounts data (for alpha)
load('sea16_strc.mat')

% SEA16 dataset variables: 
COMP = sea16_data.COMP;
VA_natcur = sea16_data.VA;

% Load ICIO21 data
load('icio21_strc.mat')

% Defining IDs
countries = icio21_text.countries;
countrycode = icio21_text.countrycode;
industries = icio21_text.industries;
industrycode = icio21_text.industrycode;
years = icio21_text.years;

% IO Dataset Parameters:
nind = size(industries,1); % # of industries
ncty = size(countries,1); % # of countries
nyrs = size(years,1); % # of years
ncat  = size(icio21_text.finalcat,1); % # final demand categories

%Z matrix with Z_ij^rs as a typical element.
PM = icio21_data.Z;
%F matrix with F_ij^dr as a typical element (d = # final categories per ctry).
PF = icio21_data.F;
%F matrix with F_ij^r (summing all final demand categories)
PF_nrxn = zeros(nind*ncty,ncty,nyrs);
for j=1:ncty
    PF_nrxn(:,j,:) = sum(PF(:,(j-1)*ncat+1:j*ncat,:),2);
end
%Gross Output %(J x S by 1) by years.
PY = max(squeeze(sum(PM,2,'omitnan')) + squeeze(sum(PF,2,'omitnan')),0);
% Computing PVA (correct. net invent) in current USD.
PVA = squeeze(sum(PM,2,'omitnan')) + squeeze(sum(PF,2,'omitnan')) - squeeze(sum(PM,1,'omitnan'));
PVA(PVA<0)=0;

%% COUNTRIES - SECTORS SELECTION

% EU27 with GBR (UK) and without.
eurwuk_iso3 = {'AUT', 'BEL', 'BGR', 'HRV', 'CYP', 'CZE', 'DNK', 'EST', ...
              'FIN', 'FRA', 'DEU', 'GRC', 'HUN', 'IRL', 'ITA', 'LVA', ...
              'LTU', 'LUX', 'MLT', 'NLD', 'POL', 'PRT', 'ROU', 'SVK', ...
              'SVN', 'ESP', 'SWE', 'GBR'}';

number_eur = find(matches(countrycode,eurwuk_iso3));
eur_list = countrycode(number_eur,1);

% remove GBR from EU
eur27_iso3 = eurwuk_iso3(~matches(eurwuk_iso3,{'GBR'}));

% Russia   
number_rus = find(matches(countrycode,{'RUS'}));
% Russian focus sectors
energy = find(contains(industrycode,{'D05T06'}));
petrol = find(contains(industrycode,{'D19'}));
% All sectors
allsec = {(1:nind)};

%% Tables 1 and 2
% Script export Tables 1 and 2 into result_tables.xls in './output' 
run("compareDirectTrade.m")

%% PARAMETERS
% Setting Psi = Labour Elasticity
psi = 2;

% Run concordance between SEA6 and ICIO21: outputs alpha_r  (labour Share)
run("concordanceAlpha.m")

%% Tables 3 - 6
% Script export Tables 3-6 into result_tables.xls in './output' 
run("approxEffectSanction.m")

%% Table 7 and 8 (Warning: May take over 35 min to complete)
% Script export Table 7 into result_tables.xls in './output'
run("getSubstituteMarket.m")

%% Graphs 1 - 12
% Script export Graphs into './ouput/plots' 
run("graphSubstituteMarket.m")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%