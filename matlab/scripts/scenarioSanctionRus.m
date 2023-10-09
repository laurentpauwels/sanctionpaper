%% DESCRIPTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% scenarioSanctionRus is a script that produces 3D Figures 1 - 3 in the 
% Imbs and Pauwels (2023, EconPolicy). Figure 1 is created with STATA based
% on a simulation output produced in this script. 
% The Figures are produced with several scripts and functions.
% scenarioSanctionRus depends on the master script evaluateApproximation.m 
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

%% Scenario 1: Shocks in the cost of exporting Russian Petrol Prod. to EU

scenario1_folder = fullfile(io_plotfolder,'scenario1');

%% Parameter definitions
ban_oncty = number_rus; % Country sanctioned
ban_bycty = number_eur;% Country imposing sanctions
ban_onind = petrol;% Industry/ies sanctioned

lnTau = zeros(nind,ncty,ncty);%(r,i,j)
lnTau(ban_onind,ban_oncty,ban_bycty) = 1;
lnTau = reshape(lnTau,nind*ncty,ncty);

%% Run simulations
%%%% Figure 1 in './output' 
run("getSimulationOutput.m")
writetable(tab_sim,filename_txtdata_sim)

%% Simulation output

%%%% Figure 2 in './output/plots/scenario1' %%%% 
% Regressions (beta and R2) and 3D graphs
graph3Dregression(lnVhat_mat3d, lnV_mat3d, elast,scenario1_folder)

%%%% Figure 3 in './output/plots/scenario1' %%%% 
% 3D Simulated and Approximated Responses

% Parameters
%psi=2;%Set in Master Script evaluateApproximation.m
alpha_cty = reshape(alpha_r,nind,ncty-1);%-1 ROW is missing in SEA16

% Approximate Response for 3D plots
HOT = downstreamBan(PMbar,PFbar_nrxn,ban_oncty,ban_bycty,ban_onind);
lnvhot = approxResponse(alpha_cty(:,ban_oncty),psi_scalar,HOT);%alpha_cty(:,ban_oncty)
lnvhot_ban = lnvhot(ban_onind);

SHOT = upstreamBan(PMbar,PFbar_nrxn,ban_oncty,ban_bycty,ban_onind);
lnvshot = approxResponse(alpha_cty(:,ban_bycty),psi_scalar,SHOT);
lnvshot_ban = lnvshot(chemicals,matches(eur_list,'DEU'));

%RUS OIL TO EUR (HOT response)
lnV_ruspet = squeeze(lnV_mat3d(ban_onind,ban_oncty,:));
graph3Dresponse(lnV_ruspet,elast,lnvhot_ban,0,0,-0.2,-0.1)
exportgraphics(gca,fullfile(scenario1_folder,'hot_ruspet.jpg'));

%DEU CHEM FROM RUS OIL (SHOT response)
lnV_deuchem = squeeze(lnV_mat3d(chemicals,number_deu,:));
graph3Dresponse(lnV_deuchem,elast,lnvshot_ban,0,0,-0.05,-0.05)
exportgraphics(gca,fullfile(scenario1_folder,'shot_deuchem.jpg'));

clearvars lnTau lnvshot lnvshot_ban lnvhot lnvhot_ban ban_oncty ban_onind ban_bycty SHOT HOT lnV_mat3d
