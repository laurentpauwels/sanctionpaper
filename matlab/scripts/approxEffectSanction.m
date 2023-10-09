%% DESCRIPTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% approxEffectSanction is the script that produces Tables 3 - 6 
% in the Imbs and Pauwels (2023, EconPolicy). It depends on master script
% evaluateTradeSanction.m and concordanceAlpha.m for the parameters alpha_r. 
% It requires the following functions:
% - downstreamBan.m
% - upstreamBan.m
% - approxResponse.m
% Refer to the Readme.md file for more details.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Tables 3 - 6

%%% Preliminaries: 
% Construct Value-Added Weights for aggregating sectors in 
% Russia and in Europe, and also aggregating EU28 countries.

va_ir = reshape(PVA, nind, ncty,nyrs);

wva_cty = va_ir./permute(repmat(squeeze(sum(va_ir,1,'omitnan'))',1,1,nind),[3 2 1]);
wva_cty(isnan(wva_cty)) = 0;

wva_eursec = va_ir(:,number_eur,:)./permute(...
    repmat(squeeze(sum(va_ir(:,number_eur,:),2,'omitnan'))',1,1,length(number_eur)),[2 3 1]);
wva_eursec(isnan(wva_eursec)) = 0;

wva_eur28 = squeeze(sum(va_ir(:,number_eur,:),2,'omitnan'))./...
    repmat(sum(squeeze(sum(va_ir(:,number_eur,:),2,'omitnan')),1,'omitnan'),nind,1);
wva_eur28(isnan(wva_eur28)) = 0;

%% Sanctions on Russia
%%% Effects of sanctions on Russia
% - Energy
% - Petroleum 
% - All sectors

ban_inyrs = find(years==2018); %year of sanction
ban_oncty = number_rus; % Country sanctioned
ban_bycty = number_eur;% Country imposing sanctions
ban_onind = [energy,petrol,allsec];% Industry/ies sanctioned

% Russian Energy, Petroleum and all sectors sanctioned
hot_rus_eur  = zeros(nind,length(ban_onind));
shot_rus_eur = zeros(nind,length(ban_bycty),length(ban_onind));
for r = 1:length(ban_onind)
    hot_rus_eur(:,r) = downstreamBan(PM(:,:,ban_inyrs),PF_nrxn(:,:,ban_inyrs),...
        ban_oncty,ban_bycty,ban_onind{r});
    shot_rus_eur(:,:,r) = upstreamBan(PM(:,:,ban_inyrs),PF_nrxn(:,:,ban_inyrs),...
        ban_oncty,ban_bycty,ban_onind{r});
end

%%% Approximate effects of sanctions on RUS (HOT)
lnvhot_rus_eur = approxResponse(alpha_r,psi,hot_rus_eur)*100;
lnvhot_rus_eurtot = squeeze(sum(wva_cty(:,number_rus,ban_inyrs).*(lnvhot_rus_eur),1,'omitnan'));

%%% Approximate effects of sanctions on EU (SHOT)
lnvshot_rus_eur = approxResponse(alpha_r,psi,shot_rus_eur)*100;

% EU countries
lnvshot_rus_eurcty = squeeze(sum(repmat(wva_cty(:,number_eur,ban_inyrs),1,1,length(ban_onind))...
    .*lnvshot_rus_eur,1,'omitnan'));
% Response EU28 sectors
lnvshot_rus_eursec = squeeze(sum(repmat(wva_eursec(:,:,ban_inyrs),1,1,length(ban_onind))...
    .*lnvshot_rus_eur,2,'omitnan'));
% Overall EU28 response
lnvshot_rus_eurtot = sum(wva_eur28(:,ban_inyrs).*lnvshot_rus_eursec,1,'omitnan');


%%% Tables 3-5: Approximate effects of sanctions (in %), sorted by responses
numtbls = 3;
tbl_0 = cell(numtbls,1); % A cell array to store the tables
for i = 1:numtbls
    tbl_0a = sortrows(table(industries,lnvhot_rus_eur(:,i),...
        'VariableNames',["RUS Industries", "RUS Responses"]),2,'descend');
    tbl_0b = sortrows(table(industries,lnvshot_rus_eursec(:,i),...
        'VariableNames',["EU Industries", "EU Responses"]),2,'descend');
    tbl_0c = sortrows(table(countrycode(number_eur,1),lnvshot_rus_eurcty(:,i),...
        'VariableNames',["EU countries", "EU Country Responses"]),2,'descend');

    % Merging tables and ranking top 10
    tbl_0{i} = [tbl_0a(1:10,:), tbl_0b(1:10,:), tbl_0c(1:10,:);...
        {'Total RUS Effect',lnvhot_rus_eurtot(1,i) ,NaN, NaN,...
        'Total EU28 Effect', lnvshot_rus_eurtot(1,i)}];
end

table_3 = tbl_0{2,1};%on Russian Petroleum
table_4 = tbl_0{1,1};%on Russian Energy
table_5 = tbl_0{3,1};%on Russian All Sectors 

clearvars ban* tbl* numtbls

%% Sanctions on Europe
%%% Effects of sanctions on Europe
% - All sectors

ban_inyrs = find(years==2018); %year of sanction
ban_oncty = number_eur; % Country sanctioned
ban_bycty = number_rus;% Country imposing sanctions
ban_onind = allsec;% Industry/ies sanctioned

%%% Approximate effects of sanctions on Europe (HOT)
hot_eur_rus = downstreamBan(PM(:,:,ban_inyrs),PF_nrxn(:,:,ban_inyrs),...
        ban_oncty,ban_bycty,ban_onind{end});
lnvhot_eur_rus = approxResponse(alpha_r,psi,hot_eur_rus)*100;

% EU countries
lnvhot_eurcty_rus  = (sum(wva_cty(:,number_eur,ban_inyrs).*lnvhot_eur_rus,1,'omitnan'))';
% Response EU28 sectors
lnvhot_eursec_rus = (sum(wva_eursec(:,:,ban_inyrs).*lnvhot_eur_rus,2,'omitnan'));
% Overall EU28 response
lnvhot_eurtot_rus = sum(wva_eur28(:,ban_inyrs).*lnvhot_eursec_rus,1,'omitnan'); 

%%% Approximate effects of sanctions on Russia (SHOT)
shot_eur_rus = upstreamBan(PM(:,:,ban_inyrs),PF_nrxn(:,:,ban_inyrs),...
    ban_oncty,ban_bycty,ban_onind{end});
lnvshot_eur_rus = approxResponse(alpha_r,psi,shot_eur_rus)*100;
lnvshot_eur_rustot = squeeze(sum(wva_cty(:,number_rus,ban_inyrs).*lnvshot_eur_rus,1,'omitnan'))';

%%% Table 6: Approximate effects of sanctions (in %), sorted by responses
tbl_6a = sortrows(table(countrycode(number_eur,1),lnvhot_eurcty_rus(:,1),...
    'VariableNames',["EU countries", "EU Country Responses"]),2,'descend');
tbl_6b = sortrows(table(industries,lnvshot_eur_rus(:,1),...
    'VariableNames',["RUS Industries", "RUS Responses"]),2,'descend');

% Merging tables and ranking top 10
table_6 = [tbl_6a(1:10,:), tbl_6b(1:10,:);...
    {'Total EU28 Effect',lnvhot_eurtot_rus(1,1) ,...
    'Total RUS Effect', lnvshot_eur_rustot(1,1)}];

%% Export Output in Excel Spreadsheet
writetable(table_3,fullfile(io_outfolder, 'result_tables.xlsx'),'FileType','spreadsheet','Sheet','Table 3');
writetable(table_4,fullfile(io_outfolder, 'result_tables.xlsx'),'FileType','spreadsheet','Sheet','Table 4');
writetable(table_5,fullfile(io_outfolder, 'result_tables.xlsx'),'FileType','spreadsheet','Sheet','Table 5');
writetable(table_6,fullfile(io_outfolder, 'result_tables.xlsx'),'FileType','spreadsheet','Sheet','Table 6');

fprintf('%s\n','Tables 3 to 6 are done and exported into result_tables.xls located in the output folder');

clearvars ban* hot* shot* lnv* tbl* va_ir wva*

