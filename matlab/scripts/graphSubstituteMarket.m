%% DESCRIPTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% graphSubstituteMarket is the script that produces Figures 4 -6
% in the Imbs and Pauwels (2023, EconPolicy). It depends on master script
% evaluateTradeSanction.m and it uses getSubstituteMarket.m for 
% `table_hot_y` `table_shot_jy` and `select_eurctry`. 
% Refer to the Readme.md file for more details.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Substitute market for Europe ranked by HOT
startdate_rus = find(years==2001);
runup_rus_list{1,1} = {'USA','CHN','JPN','KOR','TUR','ISR','EUR'};
runup_rus_list{1,2} = {'USA','CHN','JPN','KOR','TUR','ISR'};

for i = 1:length(runup_rus_list)
    runup_rus_i = runup_rus_list{1,i};
    runup_rus_t1 = zeros(length(runup_rus_i),nyrs);
    runup_rus_t2 = zeros(length(runup_rus_i),nyrs);
    runup_rus_name1 = cell(length(runup_rus_i),nyrs);
    runup_rus_name2 = cell(length(runup_rus_i),nyrs);
    
    for y = 1:nyrs
        runup_rus_t1(:,y) = table2array(table_hot_y{1,y}(contains(table_hot_y{1,y}.Country_1,runup_rus_i),2));
        runup_rus_t2(:,y) = table2array(table_hot_y{1,y}(contains(table_hot_y{1,y}.Country_2,runup_rus_i),4));
        runup_rus_name1(:,y) = table_hot_y{1,y}.Country_1(matches(table_hot_y{1,y}.Country_1,runup_rus_i));
        runup_rus_name2(:,y) = table_hot_y{1,y}.Country_2(matches(table_hot_y{1,y}.Country_2,runup_rus_i));
    end

    % Distinguish filename with or without EUR in graphs
    if sum(contains(runup_rus_list{1,i},'EUR'),2)==1
        wEURornot = sprintf('wEUR');
    else
        wEURornot = sprintf('woEUR');
    end

    % Create Figure
    figureRUS1 = figure;
    % Create Axes
    axesRUS1 = axes('Parent',figureRUS1);
    hold(axesRUS1,'on');
    plot(runup_rus_t1(:,startdate_rus:end)', 'LineWidth',1.5)
    hold on
    set(gca, 'Xtick',(0:1:nyrs-startdate_rus+1),'XtickLabel',years(startdate_rus-1:1:nyrs,1))
    xtickangle(45)
    xlim(axesRUS1,[0.8 inf]);
    legend(runup_rus_name1(:,end),'Location', 'west')
    ax = gca;
    ax.FontSize = 12;
    xlabel('Year','FontSize',12)
    ylabel('HOT','FontSize',12) 

    filename_RUS1 = fullfile(io_plotfolder,sprintf('RUS_'+string(wEURornot)+'_HOT_1.jpg',i));
    exportgraphics(figureRUS1,filename_RUS1);

    % Create Figure
    figureRUS2 = figure;
    % Create Axes
    axesRUS2 = axes('Parent',figureRUS2);
    hold(axesRUS2,'on');
    plot(runup_rus_t2(:,startdate_rus:end)', 'LineWidth',1.5)
    hold on
    set(gca, 'Xtick',(0:1:nyrs-startdate_rus+1),'XtickLabel',years(startdate_rus-1:1:nyrs,1))
    xtickangle(45)
    xlim(axesRUS2,[0.8 inf]);
    legend(runup_rus_name2(:,end),'Location', 'west')
    ax = gca;
    ax.FontSize = 12;
    xlabel('Year','FontSize',12)
    ylabel('HOT','FontSize',12)

    filename_RUS2 = fullfile(io_plotfolder,sprintf('RUS_'+string(wEURornot)+'_HOT_2.jpg',i));
    exportgraphics(figureRUS2,filename_RUS2);
end

%% Substitute market for Europe ranked by SHOT
% List of Runner-Up
runup_fra_list = {'RUS','USA','SAU','NOR','KAZ','GBR'};
runup_deu_list = {'RUS','USA','SAU','NOR','KAZ','GBR'};
runup_lva_list = {'RUS','USA','SAU','NOR','KAZ','GBR','ZAF'};
runup_ltu_list = {'RUS','USA','SAU','NOR','KAZ','TUR','ZAF'};
runup_bgr_list = {'RUS','USA','SAU','NOR','KAZ','TUR','ZAF'};

% Start-Date
startdate(1,1) = find(years==2001);%FRA
startdate(1,2) = find(years==2001);%DEU 
startdate(1,3) = find(years==2003);%LVA EU accession year
startdate(1,4) = find(years==2003);%LTU EU accession year
startdate(1,5) = find(years==2007);%BGR EU accession year

% France, Germany, Latvia, Lithuania, and Bulgaria
runup_list{1,1} = runup_fra_list;
runup_list{1,2} = runup_deu_list;
runup_list{1,3} = runup_lva_list;
runup_list{1,4} = runup_ltu_list;
runup_list{1,5} = runup_bgr_list;

for i = 1:length(runup_list)
    runup_i = runup_list{1,i};
    runup_t1 = zeros(length(runup_i),nyrs);
    runup_t2 = zeros(length(runup_i),nyrs);
    runup_name1 = cell(length(runup_i),nyrs);
    runup_name2 = cell(length(runup_i),nyrs);
    for y = startdate(1,i):nyrs
        runup_t1(:,y) = table2array(table_shot_jy{i,y}(contains(table_shot_jy{i,y}.Country_1,runup_i),2));
        runup_t2(:,y) = table2array(table_shot_jy{i,y}(contains(table_shot_jy{i,y}.Country_2,runup_i),4));
        runup_name1(:,y) = table_shot_jy{i,y}.Country_1(contains(table_shot_jy{i,y}.Country_1,runup_i));
        runup_name2(:,y) = table_shot_jy{i,y}.Country_2(contains(table_shot_jy{i,y}.Country_2,runup_i));
    end
    % Create Figure
    figureEUR1 = figure;
    % Create Axes
    axesEUR1 = axes('Parent',figureEUR1);
    hold(axesEUR1,'on');
    plot(runup_t1(:,startdate(1,i):end)', 'LineWidth',1.5)
    hold on
    set(gca, 'Xtick',(0:1:nyrs-startdate(1,i)+1),'XtickLabel',years(startdate(1,i)-1:1:nyrs,1))
    xtickangle(45)
    xlim(axesEUR1,[0.8 inf]);
    legend(runup_name1(:,end),'Location', 'west')
    ax = gca;
    ax.FontSize = 12;
    xlabel('Year','FontSize',12)
    ylabel('SHOT','FontSize',12)
    
    filename_EUR1 = fullfile(io_plotfolder,sprintf(string(countrycode(select_eurctry(i)))+'_SHOT_1.jpg',i));
    exportgraphics(gca,filename_EUR1);

    % Create Figure
    figureEUR2 = figure;
    % Create Axes
    axesEUR2 = axes('Parent',figureEUR2);
    hold(axesEUR2,'on');
    plot(runup_t2(:,startdate(1,i):end)', 'LineWidth',1.5)
    hold on
    set(gca, 'Xtick',(0:1:nyrs-startdate(1,i)+1),'XtickLabel',years(startdate(1,i)-1:1:nyrs,1))
    xtickangle(45)
    xlim(axesEUR2,[0.8 inf]);
    legend(runup_name2(:,end),'Location', 'west')
    ax = gca;
    ax.FontSize = 12;
    xlabel('Year','FontSize',12)
    ylabel('SHOT','FontSize',12)

    filename_EUR2 = fullfile(io_plotfolder,sprintf(string(countrycode(select_eurctry(i)))+'_SHOT_2.jpg',i));
    exportgraphics(gca,filename_EUR2);
end

fprintf('%s\n','All graphs are done and exported in /output/plots/ folder');

clearvars filename* figure* ax* axes* runup* startdate* wEURornot i y 

