%% DESCRIPTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convertMatlabStruc2data script converts the MATLAB structure in 
% MATLAB v7.3 format to an updated format without structure for 
% compatibility with other software. 
% The script is applied to icio21_strc.mat and sea16_strc.mat data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ICIO21 in MATLAB v7.3 format

% Load data
load('../data/processed/icio21_strc.mat')

% Assigning variables
countries = icio21_text.countries; % %Nx1
countrycode = icio21_text.countrycode;%Nx1
industries = icio21_text.industries;%Rx1
industrycode = icio21_text.industrycode;%Rx1
finalcat = icio21_text.finalcat;%Cx1
years = icio21_text.years;%Tx1

%Z matrix: 3-dimensional matrix of size (NxR)x(NxR)xT
Z = icio21_data.Z;
%F matrix: 3-dimensional matrix of size (NxR)x(NxC)xT
F = icio21_data.F;

clearvars icio21_data icio21_text io_dtafolder

save('../data/processed/icio21_data.mat')

clearvars


%% SEA16 in MATLAB v7.3 format

% Load data
load('../data/processed/sea16_strc.mat')

countrycode = sea16_text.countrycode; 
countries = sea16_text.countries; 
industrycode = sea16_text.industrycode; 
industries = sea16_text.industries;  
variables = sea16_text.variables;
years = sea16_text.years;

GO = sea16_data.GO;
II = sea16_data.II;
VA = sea16_data.VA;
EMP = sea16_data.EMP;
EMPE = sea16_data.EMPE;
H_EMPE = sea16_data.H_EMPE;
COMP = sea16_data.COMP;
LAB = sea16_data.LAB;
CAP = sea16_data.CAP;
K = sea16_data.K;
GO_PI = sea16_data.GO_PI;
II_PI = sea16_data.II_PI;
VA_PI = sea16_data.VA_PI;
GO_QI = sea16_data.GO_QI;
II_QI = sea16_data.II_QI;
VA_QI = sea16_data.VA_QI;

clearvars sea16_data sea16_text

save('../data/processed/sea16_data.mat')

clearvars
