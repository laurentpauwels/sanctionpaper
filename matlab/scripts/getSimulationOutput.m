%% DESCRIPTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getSimulationOutput is a script that simulates the Huo et al. (2023) 
% model to get a response of production to trade shocks so that the 
% simulated response can be evaluated against the approximation.
% This simulation and extensions are discussed in Imbs and Pauwels 
% (2023, EconPolicy). getSimulationOutput depends on the master script 
% evaluateApproximation.m, and also scripts: scenarioSanctionRus.m, 
% scenarioSanctionEur.m, and concordanceAlpha.m for the parameters alpha_r.
% It requires the following functions:
% - getShares.m
% - getTransportCostImpact.m
% - getScriptMatrix.m
% - idMultilateral.m
% The function getScriptMatrix requires:
% - getScriptH.m
% - getScriptM.m
% - getScriptP.m
% - getLambda.m
% Refer to the Readme.md file for more details.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Preliminaries: Inserting NaN instead of absolute 0 or negative values
% For Share of labour (alpha)
VA_natcur(VA_natcur<0) = 0;
VA_natcur(sum(VA_natcur,2,'omitnan')==0) = NaN;
COMP(COMP<0) = NaN;
COMP(sum(COMP,2,'omitnan')==0) = NaN;

%% STEADY-STATE: Averages of WIOT Data 
PYbar = squeeze(mean(PY,2, 'omitnan'));
PMbar = squeeze(mean(PM,3, 'omitnan'));
PFbar = squeeze(mean(PF,3, 'omitnan'));
PFbar_nrxn = squeeze(mean(PF_nrxn,3, 'omitnan'));
PVAbar = squeeze(mean(PVA,2, 'omitnan'));
PVAbar_natcur = squeeze(mean(VA_natcur,2, 'omitnan'));
COMPbar = squeeze(mean(COMP,2, 'omitnan'));

%% MODEL COEFFICIENT AND PARAMETERS

% Share of value added in production:
eta = PVAbar ./ PYbar; %eta = VAbar./Ybar;
eta(eta>1) = NaN;
eta(eta<=0) = NaN;
etabar = repmat(squeeze(mean(reshape(eta,nind,ncty),2,'omitnan')),ncty,1);%Country averages

% Share of Labor:
alpha_r = COMPbar./PVAbar_natcur;
alpha_r(alpha_r>1) = NaN;
alpha_r(alpha_r<=0) = NaN;
alphabar = repmat(squeeze(mean(reshape(alpha_r,nind,ncty-1),2,'omitnan')),ncty,1);%Country averages

% A coefficients: (%[A, B] = directreq_fun(PMbar,PYbar);)
AT_m = transpose(getShares(PMbar, transpose(PYbar)));%PM ./ [PY_11,...,PY_ir,...,PY_NR]
AT_mm = transpose(getShares(PMbar,sum(PMbar,1,'omitnan'))); %A_mm^T with nansum(PMbar,1)) = 1xNR
AT_c = transpose(getShares(PFbar_nrxn,sum(PFbar_nrxn,1,'omitnan'))); %A_c^T with nansum(PCbar1c,1)) = 1xN

% B coefficients:
B_m = getShares(PMbar,PYbar);%PM ./ [PY_11;...;PY_ir;...;PY_NR]
B_c = getShares(PFbar_nrxn,PYbar);

% Upsilon:
GDP = transpose(sum(reshape(PVAbar,nind,ncty),1, 'omitnan'));
Upsilon = transpose(PVAbar ./ kron(GDP,ones(nind,1))) .* kron(diag(ones(ncty,1)),ones(1,nind));
%PF_i = transpose(sum(PFbar1c,1, 'omitnan'));
%Upsilon = transpose(PVAbar ./ kron(PF_i,ones(nind,1))) .* kron(diag(ones(ncty,1)),ones(1,nind));

%% ELASTICITIES: rho, epsilon, and psi
%rho = final goods substitution elasticity 0.5, 1, 2.75
%eps = intermediate goods substitution elasticity 0.5, 1, 1.5
%psi = Frisch elasticity 2 or 0.5

elast_rho = [0;0.05;(0.1:0.1:2.5)'];
elast_eps = [0;0.05;(0.1:0.1:1.5)'];
elast_psi = 2;
 
elast = [kron(elast_rho,ones(size(elast_eps,1),1)),...
         repmat(elast_eps,size(elast_rho,1),1),...
         2*ones(size(elast_rho,1)*size(elast_eps,1),1)];

nelastcomb = size(elast,1);

%% SIMULATIONS
lnV_mat = zeros(ncty*nind,nelastcomb);
lnVhat_mat = zeros(ncty*nind,nelastcomb);

Inan = ones(nind*ncty,1);
Inan(PYbar==0) = NaN;
parfor e = 1:nelastcomb

    %% MODEL KEY MATRICES: scriptT, scriptM, scriptP, scriptH, Lambda
    [SM, SP, SH, Lambda] = getScriptMatrix(elast(e,:), AT_mm, AT_c, B_m, B_c,...
        Upsilon, alphabar, etabar);

    %% MODEL SIMULATIONS
    [~, ~, lnPYe, lnVe] = getTransportCostImpact(SM, SP, SH, Lambda,lnTau,...
                                        AT_c, B_c, AT_mm, AT_m, B_m,...    
                                        elast(e,:), alphabar, etabar); 

    lnVhat_mat(:,e) = ((alphabar*elast_psi)/(1+elast_psi)).*lnPYe.*Inan;
    lnV_mat(:,e) = lnVe.*Inan;
    
    fprintf('Just finished simulation #%d\n', e);

end

%% SIMULATION OUTPUT

% Remove Public Admin
public_r = find(contains(industries,{'Public','Education','Human',...
    'Other service activities','households','extraterritorial'}));
size_public = length(public_r);
row = find(contains(countrycode,{'ROW'}));

countrycode_worow = countrycode(1:end-1,1);
industrycode_wopub = industrycode(1:end-size_public,1);
industries_wopub = industries(1:end-size_public,1);
[country_i, sector_r, sectorcode_r] = idMultilateral(industries_wopub,...
    industrycode_wopub, countrycode_worow,1);

country_i = repmat(country_i,nelastcomb,1);
sector_r = repmat(sector_r,nelastcomb,1);
sectorcode_r = repmat(sectorcode_r,nelastcomb,1);


lnV_mat3d = reshape(lnV_mat,nind,ncty,nelastcomb);
lnV_mat3d(:,row,:) = [];
lnV_mat3d(public_r,:,:) = [];

lnVhat_mat3d = reshape(lnVhat_mat,nind,ncty,nelastcomb);
lnVhat_mat3d(:,row,:) = [];
lnVhat_mat3d(public_r,:,:) = [];

lnVhat = reshape(lnVhat_mat3d,((ncty-1)*(nind-size_public))*nelastcomb,1);
lnV = reshape(lnV_mat3d,((ncty-1)*(nind-size_public))*nelastcomb,1);

elast_vec = kron(elast, ones((ncty-1)*(nind-size_public),1));
rho = elast_vec(:,1);
eps = elast_vec(:,2);
psi = elast_vec(:,3);

tab_sim = table(rho, eps, psi, country_i, sector_r, sectorcode_r,...
     lnVhat, lnV);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
