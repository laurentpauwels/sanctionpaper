%% DESCRIPTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compareDirectTrade is the script that produces Tables 1 - 2 
% in the Imbs and Pauwels (2023, EconPolicy). It depends on master script
% evaluateTradeSanction.m. It requires the following functions:
% - downstreamBan.m
% - upstreamBan.m
% - directTrade.m
% Refer to the Readme.md file for more details.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Tables 1 and 2

ban_inyrs = find(years==2018); %year of sanction
ban_oncty = number_rus; % Country sanctioned
ban_bycty = number_eur;% Country imposing sanctions
ban_onind = petrol;% Industry sanctioned

hot_rus_eur = zeros(nind,length(ban_bycty),1);
ex_rus_eur = zeros(nind,length(ban_bycty),1);
shot_rus_eur = zeros(nind,length(ban_bycty));
im_rus_eur = zeros(nind,length(ban_bycty));
for j = 1:length(ban_bycty)
    hot_rus_eur(:,j) = downstreamBan(PM(:,:,ban_inyrs),PF_nrxn(:,:,ban_inyrs),...
        ban_oncty,ban_bycty(j,1),ban_onind);
    shot_rus_eur(:,j) = upstreamBan(PM(:,:,ban_inyrs),PF_nrxn(:,:,ban_inyrs),...
        ban_oncty,ban_bycty(j,1),ban_onind);
    [im_rus_eur(:,j), ex_rus_eur(:,j)] = directTrade(PM(:,:,ban_inyrs),PF_nrxn(:,:,ban_inyrs),...
        ban_oncty,ban_bycty(j,1),ban_onind);
end

% GO in country i, sector r, divided by total GO in country i.
PY_rxnxt = reshape(PY,nind,ncty,nyrs);
PY_ratio = PY_rxnxt(:,ban_bycty,ban_inyrs) ./ ...
    sum(PY_rxnxt(:,ban_bycty,ban_inyrs),1,'omitnan');

% Table 1 sorted on Ratio_HOT_X
table_1 = sortrows(table(repmat(countrycode(number_rus,1),size(hot_rus_eur,2),1), countrycode(number_eur,1),...
    hot_rus_eur(ban_onind,:)'*100, ...
    ex_rus_eur(ban_onind,:)'*100, ...
    hot_rus_eur(ban_onind,:)'./ex_rus_eur(ban_onind,:)',...
    'VariableNames',["Sanctioned country", "country",...
        "HOT", "Final Exports", "Ratio_HOT_X"]),5,'descend');

% Table 2 sorted on Ratio_SHOT_M
table_2 = sortrows(table(repmat(countrycode(number_rus,1),size(hot_rus_eur,2),1), countrycode(number_eur,1),...
    sum(shot_rus_eur.*PY_ratio,1,'omitnan')'*100, ...
    sum(im_rus_eur.*PY_ratio,1,'omitnan')'*100,...
    sum(shot_rus_eur.*PY_ratio,1,'omitnan')'./...
    sum(im_rus_eur.*PY_ratio,1,'omitnan')',...
    'VariableNames',["Sanctioned country", "country",...
        "SHOT","Intmd Imports","Ratio_SHOT_M"]),5,'descend');

% Export Output in Excel Spreadsheet
writetable(table_1,fullfile(io_outfolder, 'result_tables.xlsx'),'FileType','spreadsheet','Sheet','Table 1');
writetable(table_2,fullfile(io_outfolder, 'result_tables.xlsx'),'FileType','spreadsheet','Sheet','Table 2');

fprintf('%s\n','Tables 1 and 2 are done and exported into result_tables.xls located in the output folder');

clearvars ban* hot* shot* im* ex* PY_*
%%