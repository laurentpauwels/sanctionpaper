%% DESCRIPTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% scenarioSanctionEur is a script that produces 3D Figures 7 and 8 
% in the Imbs and Pauwels (2023, EconPolicy).
% The Figures are produced with several scripts and functions.
% scenarioSanctionEur depends on the master script evaluateApproximation.m 
% and also concordanceAlpha.m for the parameters alpha_r. It requires 
% getSimulationOutput.m for the simulation output.
% It requires the following functions:
% - graph3Dregression.m
% - graph3Dresponse.m
% - downstreamBan.m
% - upstreamBan.m
% - approxResponse.m
% Refer to the Readme.md file for more details.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Scenario 2: Shocks in the cost of exporting EU Prod. to RUS

scenario2_folder = fullfile(io_plotfolder,'scenario2');

%% Parameter definitions
ban_oncty = number_eur; % Country sanctioned
ban_bycty = number_rus;% Country imposing sanctions
ban_onind = (1:nind)';% Industry/ies sanctioned

lnTau = zeros(nind,ncty,ncty);%(r,i,j)
lnTau(ban_onind,ban_oncty,ban_bycty) = 1;
lnTau = reshape(lnTau,nind*ncty,ncty);

%% Run simulations
%%%% Script export output for Figures in Appendix B in './output'
run("getSimulationOutput.m")

%% Simulation output

%%%% Figure 7 in './output/plots/scenario2' %%%% 
% Regressions (beta and R2) and 3D graphs
graph3Dregression(lnVhat_mat3d, lnV_mat3d, elast,scenario2_folder)

%%%% Figure 8 in './output/plots/scenario2' %%%% 
% 3D Simulated and Approximated Responses

% Parameters
%psi=2;%Set in Master Script evaluateApproximation.m
alpha_cty = reshape(alpha_r,nind,ncty-1);%-1 ROW is missing in SEA16

% Approximate Response for 3D plots
HOT = downstreamBan(PMbar,PFbar_nrxn,ban_oncty,ban_bycty,ban_onind);
lnvhot = approxResponse(alpha_cty(:,ban_oncty),psi_scalar,HOT);
lnvhot_ban = lnvhot(chemicals,matches(eur_list,'DEU'));

SHOT = upstreamBan(PMbar,PFbar_nrxn,ban_oncty,ban_bycty,ban_onind);
lnvshot = approxResponse(alpha_cty(:,ban_bycty),psi_scalar,SHOT);
lnvshot_ban = lnvshot(petrol);

%DEU CHEM to RUS (HOT response)
lnV_deuchem = squeeze(lnV_mat3d(chemicals,number_deu,:));
graph3Dresponse(lnV_deuchem,elast,lnvhot_ban,0,0,-0.2,-0.2)
exportgraphics(gca,fullfile(scenario2_folder,'hot_deuchem.jpg'));

%RUS OIL FROM DEU CHEM  (SHOT response)
lnV_ruspet = squeeze(lnV_mat3d(petrol,number_rus,:));
graph3Dresponse(lnV_ruspet,elast,lnvshot_ban,0,0,-0.05,-0.05)
exportgraphics(gca,fullfile(scenario2_folder,'shot_ruspet.jpg'));

clearvars lnTau lnvshot lnvshot_ban lnvhot lnvhot_ban ban_oncty ban_onind ban_bycty SHOT HOT lnV_mat3d

