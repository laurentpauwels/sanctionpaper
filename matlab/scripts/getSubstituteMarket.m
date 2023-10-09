%% DESCRIPTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getSubstituteMarket is the script that produces Tables 7 - 8 
% in the Imbs and Pauwels (2023, EconPolicy). It depends on master script
% evaluateTradeSanction.m. 
% It requires the following functions:
% - downstreamBan.m
% - upstreamBan.m
% Refer to the Readme.md file for more details.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Preliminaries
ban_inyrs = find(years);%find(years==2018); %year of sanction
ban_oncty = number_rus; % Country sanctioned
ban_bycty = number_eur;% Country imposing sanctions
ban_onind = energy;% Industry/ies sanctioned

% Number of Top Industries considered
top_nind = 2;
% Remove individual EU countries (including GBR), Russia, and the Rest-of-World
non_eurwukrusrow =find(~ismember(countrycode,[eurwuk_iso3;{'RUS'};{'ROW'}]));
% Sample selection of EU countries analysed
select_eurctry = find(matches(countrycode,{'FRA','DEU','LVA','LTU','BGR'}));
% Remove individual EU countries (keep GBR), Russia, and the Rest-of-World
non_eur27rusrow =find(~ismember(countrycode,[eur27_iso3;{'RUS'};{'ROW'}]));

%% Table 7: HOT

% STEP 1: Consider the sectors in Russia most affected by EU sanction on Russia
% Focus on 2018 and select most affected sectors

hot_rus_eur_2018 = downstreamBan(PM(:,:,ban_inyrs(end,1)),PF_nrxn(:,:,ban_inyrs(end,1)),...
    ban_oncty,ban_bycty,ban_onind);

[~,sort_sect] = sort(hot_rus_eur_2018,'descend');
sort_top_rus = sort_sect(1:top_nind,1);

% STEP 2: Find substitute markets for Russia's most affected sectors.
% Do that for every year using 2018 as reference point.

num_tbls = size(ban_inyrs,2);
sort_tbl_hot_y = cell(num_tbls,1);
table_hot_y = cell(num_tbls,1);

hot_rus_eur  = zeros(nind,length(ban_inyrs));
hot_rus_k_y = zeros(top_nind,length(non_eurwukrusrow),length(ban_inyrs));
for y = 1:length(ban_inyrs)
    PM_y = PM(:,:,ban_inyrs(y,1));
    PF_y = PF_nrxn(:,:,ban_inyrs(y,1));
    
    % Russia's HOT to EU
    hot_rus_eur(:,y) = downstreamBan(PM_y,PF_y,...
        ban_oncty,ban_bycty,ban_onind);
    
    % Russia's substitute markets: HOT to market k
    parfor k = 1:size(non_eurwukrusrow,1)
        non_eu_k = non_eurwukrusrow(k,1);
        hot_rus_wld = downstreamBan(PM_y,PF_y,ban_oncty,non_eu_k,ban_onind);
        hot_rus_k_y(:,k,y)  = squeeze(hot_rus_wld(sort_top_rus,:));
    end

    tbl_hot1 = table(countrycode(non_eurwukrusrow,1),squeeze(hot_rus_k_y(1,:,y))'*100,...
        'VariableNames',["Country_1","RUS "+industries(sort_top_rus(1))]);
    tbl_hot2 = table(countrycode(non_eurwukrusrow,1),squeeze(hot_rus_k_y(2,:,y))'*100,...
        'VariableNames',["Country_2","RUS "+industries(sort_top_rus(2))]);
    table_hot_y{y} = [tbl_hot1,tbl_hot2;...
        {'EUR', hot_rus_eur(sort_top_rus(1),y)*100,...
         'EUR', hot_rus_eur(sort_top_rus(2),y)*100}];

    % Sorting tables by most affected sectors
    sort_tbl_hot1 = sortrows(tbl_hot1,2,'descend');
    sort_tbl_hot2 = sortrows(tbl_hot2,2,'descend');
    % Keep top 5 substitute markets and append EUR for comparaison
    sort_tbl_hot_y{y} = [sort_tbl_hot1(1:5,:),sort_tbl_hot2(1:5,:);...
        {'EUR',hot_rus_eur(sort_top_rus(1),y)*100,...
         'EUR',hot_rus_eur(sort_top_rus(2),y)*100}];
end

% Output: Table 7
table_7 = sort_tbl_hot_y{1,end};

% Export Output in Excel Spreadsheet
writetable(table_7,fullfile(io_outfolder, 'result_tables.xlsx'),...
    'FileType','spreadsheet','Sheet','Table 7');

fprintf('%s\n','Table 7 is done and exported into result_tables.xls located in the output folder');

clearvars PM_y PF_y


%% Table 8 SHOT

% STEP 1: Consider the sectors in Europe most affected by EU sanction on Russia
% Focus on 2018

shot_rus_eur_2018 = upstreamBan(PM(:,:,ban_inyrs(end,1)),PF_nrxn(:,:,ban_inyrs(end,1)),...
    ban_oncty,ban_bycty,ban_onind);

num_tbls_j = size(select_eurctry,1);
num_tbls_y = size(ban_inyrs,2);
table_shot_jy = cell(num_tbls_j,num_tbls_y);
sort_tbl_shot_jy = cell(num_tbls_j,num_tbls_y);

shot_rus_eur = zeros(nind,length(ban_bycty),length(ban_onind));
shot_k_eur_y = zeros(top_nind,length(select_eurctry),length(non_eur27rusrow),length(ban_onind));

for j = 1:length(select_eurctry)%Selected EU country
    % Selecting most affected sectors in Selected EU country
    % Location in eu_list of countries
    num_ineurlist = find(matches(eur_list,countrycode(select_eurctry(j))));
    [~,sort_sect] = sort(shot_rus_eur_2018(:,num_ineurlist),'descend');
    sort_top_eur = sort_sect(1:top_nind,1);
    select_eurctry_j = select_eurctry(j);

% STEP 2: Find substitute markets for EU selected country's most affected sectors.
% Do that for every year using 2018 as reference point.

    for y = 1:length(ban_inyrs)%Saction scenario
        PM_y = PM(:,:,ban_inyrs(y,1));
        PF_y = PF_nrxn(:,:,ban_inyrs(y,1));
        
        % (All countries) SHOT from sanctions on RUS 
        shot_rus_eur(:,:,y) = upstreamBan(PM_y,PF_y,ban_oncty,ban_bycty,ban_onind);

        % Selected EU country's substitute markets: SHOT from market k
        parfor k = 1:length(non_eur27rusrow)%Substitute Market
            substitute_mkt = non_eur27rusrow(k,1);%Location in Non-EU Non-RUS Non-ROW list
            shot_wld_eur = upstreamBan(PM_y,PF_y,...
                substitute_mkt,select_eurctry_j,ban_onind);
            shot_k_eur_y(:,j,k,y)  = squeeze(shot_wld_eur(sort_top_eur,:));
        end

        tbl_shot1 = table(countrycode(non_eur27rusrow,1),squeeze(shot_k_eur_y(1,j,:,y))*100,...
            'VariableNames',["Country_1",string(countrycode(select_eurctry_j))+' '+industries(sort_top_eur(1))]);
        tbl_shot2 = table(countrycode(non_eur27rusrow,1),squeeze(shot_k_eur_y(2,j,:,y))*100,...
            'VariableNames',["Country_2",string(countrycode(select_eurctry_j))+' '+industries(sort_top_eur(2))]);
        
        % Selected EU country's SHOT substitute markets and SHOT with RUS
        table_shot_jy{j,y} = [tbl_shot1,tbl_shot2;...
            {'RUS', shot_rus_eur(sort_top_eur(1),num_ineurlist,y)*100,...
             'RUS', shot_rus_eur(sort_top_eur(2),num_ineurlist,y)*100}]; 

        % Sorting tables by most affected sectors
        sort_tbl_shot1 = sortrows(tbl_shot1,2,'descend');
        sort_tbl_shot2 = sortrows(tbl_shot2,2,'descend');
        % Keep top 5 substitute markets and append EUR for comparaison
        sort_tbl_shot_jy{j,y} = [sort_tbl_shot1(1:5,:),sort_tbl_shot2(1:5,:);...
            {'RUS', shot_rus_eur(sort_top_eur(1),num_ineurlist,y)*100,...
             'RUS', shot_rus_eur(sort_top_eur(2),num_ineurlist,y)*100}];
    end

end

% Output: Table 8
table_8 = sort_tbl_shot_jy(:,end);

% Export Output in Excel Spreadsheet
for t = 1:length(table_8)
    A_number = "A"+(7*(t-1)+1);
    writetable(table_8{t,1},fullfile(io_outfolder, 'result_tables.xlsx'),...
        'FileType','spreadsheet','Sheet','Table 8','Range',A_number);
end

fprintf('%s\n','Table 8 is done and exported into result_tables.xls located in the output folder');

clearvars PF_y PM_y ban* hot* shot* sort* select_eurctry_j top* non* tbl* num_tbl*... 
       num_ineurlist subs* t r i j y A_number