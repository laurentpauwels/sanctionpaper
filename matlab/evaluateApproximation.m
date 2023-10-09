%% DESCRIPTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% evaluateApproximation is the main script that produces 3 dimensions
% Figures 2, 3, 7 and 8 in the Imbs and Pauwels (2023, EconPolicy).
% The Figures are produced with several scripts and functions.
% evaluateApproximation.m requires these scripts: 
% - scenarioSanctionRus.m
% - scenarioSanctionEur.m
% - concoranceAlpha.m 
% The data required are:
% - sea16_strc.mat
% - wiot16_strc.mat
% For the required functions, consult the individual scripts. 
% Refer to the Readme.md file for more details.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% PATHS
% Add folders to path
io_funfolder = fullfile('.', 'functions');
io_scrfolder = fullfile('.', 'scripts');
io_dtafolder = fullfile('.', 'data','processed',filesep);
io_plotfolder = fullfile('.', 'output','plots',filesep);

filename_txtdata_sim = fullfile('.','output','simulation_output.txt');

addpath(io_funfolder);
addpath(io_scrfolder);
addpath(io_dtafolder);
addpath(io_plotfolder);

%% DATA PROCESSING

% Load WIOD Socio-Economic Accounts data
load('sea16_strc.mat')

COMP = sea16_data.COMP;
VA_natcur = sea16_data.VA;
countries = sea16_text.countries;

% Load WIOD16 data
load('wiot16_strc.mat')

% IO Dataset Parameters:
nind = size(wiot16_text.industries,1); % # of industries
ncty = size(wiot16_text.countrycode,1); % # of countries
nyrs = size(wiot16_text.years,1); % # of years
ncat = size(wiot16_text.finalcat,1); % # final demand categories

% Assigning variables
countries = [countries;'RestOfWorld'];%adding ROW (NA in SEA16).
countrycode = wiot16_text.countrycode;
industries = wiot16_text.industries;
industrycode = wiot16_text.industrycode;
years = wiot16_text.years;

%Z matrix with Z_ij^rs as a typical element.
PM = wiot16_data.Z;
%F matrix with F_ij^dr as a typical element (d = # final categories per ctry).
PF = wiot16_data.F;
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

%% PARAMETERS
% Setting Psi = Labour Elasticity
psi_scalar = 2;

% Run concordance between SEA6 and ICIO21: outputs alpha_r (labour Share) 
run("concordanceAlpha.m")

%% COUNTRIES - SECTORS SELECTION

% EU27 with GBR (UK) and without.
eurwuk_iso3 = {'AUT', 'BEL', 'BGR', 'HRV', 'CYP', 'CZE', 'DNK', 'EST', ...
              'FIN', 'FRA', 'DEU', 'GRC', 'HUN', 'IRL', 'ITA', 'LVA', ...
              'LTU', 'LUX', 'MLT', 'NLD', 'POL', 'PRT', 'ROU', 'SVK', ...
              'SVN', 'ESP', 'SWE', 'GBR'}';

number_eur = find(matches(countrycode,eurwuk_iso3));
eur_list = countrycode(number_eur,1);

% DEU & RUS
number_deu = find(matches(countrycode,'DEU'));
number_rus = find(contains(countrycode,{'RUS'}));

% Sectors
mining = find(contains(industries,{'Mining'}));
petrol = find(contains(industries,{'petroleum'}));
chemicals = find(contains(industries,{'chemicals'}));

%% Scenario 1: Shocks in the cost of exporting Russian Petrol Prod. to EU
run("scenarioSanctionRus.m")
% requires script "getSimulationOutput.m" 
close all

%% Scenario 2: Shocks in the cost of exporting Russian Petrol Prod. to EU
tic
run("scenarioSanctionEur.m")
toc
% requires script "getSimulationOutput.m" 
close all
