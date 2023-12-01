%% A continuació hi ha el codi per fer TOTS els païssos de manera automàtica "arriscant" amb unes certes condicions que quedi bé a 1 output
clear all
close all
% Primer tenim la opció de probar només un país o fer-ho per tots:
Countries = "Europe"; 
% Countries = ["Austria","Belgium","Bulgaria","Croatia","Cyprus","Czechia","Denmark","Estonia","Finland","France",...
% "Germany","Greece","Iceland","Ireland","Italy","Latvia","Lithuania","Luxembourg","Netherlands","Norway","Poland",...
% "Portugal","Romania","Slovakia","Slovenia","Spain","Sweden"];
for iii = 1:length(Countries)
    Country = Countries{iii};
opts = spreadsheetImportOptions("NumVariables", 23);
opts.Sheet = Country;
opts.DataRange = "A2:W169";
opts.VariableNames = ["B117", "B1351", "B1427B1429", "B1525", "B1616", "B16171", "B16172", "B1620", "B1621", "BA1", "BA2", "BA275", "BA4", "BA5", "BQ1", "C37", "Other", "P1", "P3", "UNK", "XBB", "XBB15", "Dijous"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "string"];
opts = setvaropts(opts, "Dijous", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "Dijous", "EmptyFieldRule", "auto");
GisaidAllCV = readtable("D:\OneDrive - Universitat Politècnica de Catalunya\2022_01_Historic_variants\Gisaid_ONLY_Countries_variants_april.xlsx", opts, "UseExcel", false);
clear opts
GisaidAllCV.DijousOK = datetime(GisaidAllCV.Dijous,'InputFormat','dd/MM/yyyy','Format','dd/MM/yyyy');

%Aquí tenim totes les variants que ens interesaran per fer les diferents
%substitucions
    N_Other = GisaidAllCV.('Other'); %prealfa!
    N_Alpha = GisaidAllCV.('B117'); %VOC
    N_Beta = GisaidAllCV.('B1351'); %VOC
    N_Gamma = GisaidAllCV.('P1'); %VOC
    N_Delta = GisaidAllCV.('B16172'); %VOC
    N_Omicron = GisaidAllCV.('BA1')+GisaidAllCV.('BA2')+GisaidAllCV.('BA4')+GisaidAllCV.('BA5')+GisaidAllCV.('BQ1')+GisaidAllCV.('XBB')+GisaidAllCV.('XBB15')+GisaidAllCV.('BA275');
    N_Altres = GisaidAllCV.('B1621') + GisaidAllCV.('B1427B1429') + GisaidAllCV.('B1525') + GisaidAllCV.('B1616') +...
        GisaidAllCV.('B16171') + GisaidAllCV.('B1620') + GisaidAllCV.('C37') + GisaidAllCV.('P3'); %+ GisaidAllCV.('UNK');
    N_AltresOther = N_Other+N_Altres;

    %% Substitution Wuhan vs Alpha
    ini = 35; fin = 80;
    N_Desc = N_Other(ini:fin);
    N_Asc1 = N_Alpha(ini:fin);
    N_Ctt = N_Altres(ini:fin) + N_Beta(ini:fin) + N_Gamma(ini:fin) + N_Delta(ini:fin) + N_Omicron(ini:fin);
    WeekThurs = GisaidAllCV.DijousOK(ini:fin);

    [BAlpha,BerrAlpha,R0Alpha,R0errAlpha,DayAlpha,DayAlpha20,DayAlpha40,DayAlpha60,DayAlpha80] = FWuhanAlphab(N_Desc, N_Asc1, N_Ctt,Country,WeekThurs);
    clear ini fin N_Desc N_Asc1 N_Ctt WeekThurs 

        %% Substitution Alpha vs Delta
    ini = 60; fin = 110;
    N_Desc = N_Alpha(ini:fin);
    N_Asc1 = N_Delta(ini:fin);
    N_Asc2 = N_Gamma(ini:fin);
    N_Asc4 = N_Beta(ini:fin);
    N_Ctt = N_AltresOther(ini:fin) + N_Omicron(ini:fin);
    WeekThurs = GisaidAllCV.DijousOK(ini:fin);

    [BDelta,BerrDelta,R0Delta,R0errDelta,DayDelta,DayDelta20,DayDelta40,DayDelta60,DayDelta80] = FAlphaDelta(N_Desc, N_Asc1, N_Asc2, N_Asc4, N_Ctt,Country,WeekThurs);
    clear ini fin N_Desc N_Asc1 N_Asc2 N_Asc4 N_Ctt WeekThurs 

        %% Substitution Delta vs Omicron
    ini = 90; fin = 140;
    N_Desc = N_Delta(ini:fin);
    N_Asc1 = N_Omicron(ini:fin);
    N_Ctt = N_AltresOther(ini:fin) + N_Alpha(ini:fin) + N_Gamma(ini:fin) + N_Beta(ini:fin);
    WeekThurs = GisaidAllCV.DijousOK(ini:fin);

    [BOmicron,BerrOmicron,R0Omicron,R0errOmicron,DayOmicron,DayOmicron20,DayOmicron40,DayOmicron60,DayOmicron80] = FDeltaOmicron(N_Desc, N_Asc1, N_Ctt,Country,WeekThurs);
    clear ini fin N_Desc N_Asc1 N_Ctt WeekThurs

            %% Carreguem les dades del Plot i el Fit que acabem de fer per totes les onades:
% pre-Alfa vs Alfa
    opts = delimitedTextImportOptions("NumVariables", 10);
    opts.DataLines = [2, Inf];
    opts.Delimiter = ",";
    opts.VariableNames = ["Dia", "Perc_wuhan_dia", "Perc_wuhan_dia_errMAX", "Perc_wuhan_dia_errMIN", "Perc_alfa_dia", "Perc_alfa_dia_errMAX", "Perc_alfa_dia_errMIN", "Perc_altres_dia", "Perc_altres_dia_errMAX", "Perc_altres_dia_errMIN"];
    opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts = setvaropts(opts, "Dia", "InputFormat", "dd/MM/yyyy");
    FitWuhanAlfa = readtable("D:\OneDrive - Universitat Politècnica de Catalunya\2022_01_Historic_A_D_O_GISAID\DadesCSV_hist_variants_Alfa\Fit_SeqVar_wuhan_alfa_altres" + Country + ".csv", opts);
    clear opts
    opts = delimitedTextImportOptions("NumVariables", 7);
    opts.DataLines = [2, Inf];
    opts.Delimiter = ",";
    opts.VariableNames = ["Dia", "Perc_wuhan", "Error_wuhan", "Perc_alfa", "Error_alfa", "Perc_altres", "Error_altres"];
    opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts = setvaropts(opts, "Dia", "InputFormat", "dd/MM/yyyy");
    ExpWuhanAlfa = readtable("D:\OneDrive - Universitat Politècnica de Catalunya\2022_01_Historic_A_D_O_GISAID\DadesCSV_hist_variants_Alfa\Plot_SeqVar_wuhan_alfa_altres"+ Country + ".csv", opts);
    clear opts 

% Alfa vs Delta
    opts = delimitedTextImportOptions("NumVariables", 16);
    opts.DataLines = [2, Inf];
    opts.Delimiter = ",";
    opts.VariableNames = ["Dia", "Perc_alfa_dia", "Perc_alfa_dia_errMAX", "Perc_alfa_dia_errMIN", "Perc_delta_dia", "Perc_delta_dia_errMAX", "Perc_delta_dia_errMIN", "Perc_gamma_dia", "Perc_gamma_dia_errMAX", "Perc_gamma_dia_errMIN", "Perc_Beta_dia", "Perc_Beta_dia_errMAX", "Perc_Beta_dia_errMIN", "Perc_altres_dia", "Perc_altres_dia_errMAX", "Perc_altres_dia_errMIN"];
    opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts = setvaropts(opts, "Dia", "InputFormat", "dd/MM/yyyy");
    FitAlfaDelta = readtable("D:\OneDrive - Universitat Politècnica de Catalunya\2022_01_Historic_A_D_O_GISAID\DadesCSV_hist_variants_Delta\Fit_SeqVar_alfa_delta_gamma_Beta_altres" + Country + ".csv", opts);
    clear opts
    opts = delimitedTextImportOptions("NumVariables", 11);
    opts.DataLines = [2, Inf];
    opts.Delimiter = ",";
    opts.VariableNames = ["Dia", "Perc_alfa", "Error_alfa", "Perc_delta", "Error_delta", "Perc_gamma", "Error_gamma", "Perc_Beta", "Error_Beta", "Perc_altres", "Error_altres"];
    opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts = setvaropts(opts, "Dia", "InputFormat", "dd/MM/yyyy");
    ExpAlfaDelta = readtable("D:\OneDrive - Universitat Politècnica de Catalunya\2022_01_Historic_A_D_O_GISAID\DadesCSV_hist_variants_Delta\Plot_SeqVar_alfa_delta_gamma_Beta_altres" + Country + ".csv", opts);
    clear opts 

% Delta vs Omicron
    opts = delimitedTextImportOptions("NumVariables", 10);
    opts.DataLines = [2, Inf];
    opts.Delimiter = ",";
    opts.VariableNames = ["Dia", "Perc_delta_dia", "Perc_delta_dia_errMAX", "Perc_delta_dia_errMIN", "Perc_omicron_dia", "Perc_omicron_dia_errMAX", "Perc_omicron_dia_errMIN", "Perc_altres_dia", "Perc_altres_dia_errMAX", "Perc_altres_dia_errMIN"];
    opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts = setvaropts(opts, "Dia", "InputFormat", "dd/MM/yyyy");
    FitDeltaOmicron = readtable("D:\OneDrive - Universitat Politècnica de Catalunya\2022_01_Historic_A_D_O_GISAID\DadesCSV_hist_variants_Omicron\Fit_SeqVar_delta_omicron_altres"+Country+".csv", opts);
    clear opts
    opts = delimitedTextImportOptions("NumVariables", 7);
    opts.DataLines = [2, Inf];
    opts.Delimiter = ",";
    opts.VariableNames = ["Dia", "Perc_delta", "Error_delta", "Perc_omicron", "Error_omicron", "Perc_altres", "Error_altres"];
    opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts = setvaropts(opts, "Dia", "InputFormat", "dd/MM/yyyy");
    ExpDeltaOmicron = readtable("D:\OneDrive - Universitat Politècnica de Catalunya\2022_01_Historic_A_D_O_GISAID\DadesCSV_hist_variants_Omicron\Plot_SeqVar_delta_omicron_altres"+Country+".csv", opts);
    clear opts 

                %% Fem la figura completa per tots els païssos
iniciimg = datetime(2020, 09, 1);
finalimg = datetime(2023, 3, 1);
            % Primer la figura amb els casos sequenciats
figure('Position', get(0, 'Screensize'));
fig = tiledlayout(3,1); 
textCaption = ".\Figures_Variants\" + Country + " variants";
fig1 = nexttile;
    Nomsvariants = {'Wuhan','Alpha', 'Altres', 'Delta', 'Gamma', 'Beta', 'Omicron'};
colorsvar = [1 0. 0.1
             0.00 0.45 0.74
             0.93 0.69 0.13
             0.85 0.33 0.10
             1 0.45 0.54
             0.1 0.1 0.9
             0.13, 0.55, 0.13 
             0.93 0.69 0.13];
colororder(colorsvar)
bar((GisaidAllCV.DijousOK(1:70)),(N_Other(1:70)),'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.6);
hold on
bar(GisaidAllCV.DijousOK,(N_Alpha),'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.7);
bar(GisaidAllCV.DijousOK,(N_Altres),'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.9);
bar(GisaidAllCV.DijousOK,(N_Delta),'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.7);
bar(GisaidAllCV.DijousOK,(N_Gamma),'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.4);
bar(GisaidAllCV.DijousOK,(N_Beta),'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.6);
bar(GisaidAllCV.DijousOK,(N_Omicron),'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.4);
bar((GisaidAllCV.DijousOK(70:end)),(N_AltresOther(70:end)),'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.5);
hold off

% title(Country + ": Dynamics of COVID-19 variants (GISAID)",'FontSize', 16);
ylabel('Weekly sample sequencing','Color','k','FontSize', 14);
xticklabels(fig1,{})
set(gca, 'Color','w', 'XColor','k', 'YColor','k')
xlim ([ GisaidAllCV.DijousOK(35) GisaidAllCV.DijousOK(end-45)])

    % Fem la figura de les substitucions
    fig2 = nexttile;
    fill([ExpWuhanAlfa.Dia(1) FitWuhanAlfa.Dia(1) FitWuhanAlfa.Dia(1) ExpWuhanAlfa.Dia(1)],[0 0 100 100],[0.8 0.8 0.8],FaceAlpha=0.3,EdgeColor='none')
    hold on
    fill([FitWuhanAlfa.Dia(end) FitAlfaDelta.Dia(1) FitAlfaDelta.Dia(1) FitWuhanAlfa.Dia(end)],[0 0 100 100],[0.8 0.8 0.8],FaceAlpha=0.3,EdgeColor='none')
    fill([FitAlfaDelta.Dia(end) FitDeltaOmicron.Dia(1) FitDeltaOmicron.Dia(1) FitAlfaDelta.Dia(end)],[0 0 100 100],[0.8 0.8 0.8],FaceAlpha=0.3,EdgeColor='none')
    fill([FitDeltaOmicron.Dia(end) ExpDeltaOmicron.Dia(end) ExpDeltaOmicron.Dia(end) FitDeltaOmicron.Dia(end)],[0 0 100 100],[0.8 0.8 0.8],FaceAlpha=0.3,EdgeColor='none')

        difffinal = abs(FitAlfaDelta.Dia(1) - ExpWuhanAlfa.Dia);
        [~, idxfinal] = min(difffinal);    
        ExpWuhanAlfa((idxfinal):end,:) = [];
errorbar(ExpWuhanAlfa.Dia,ExpWuhanAlfa.Perc_wuhan,ExpWuhanAlfa.Error_wuhan,ExpWuhanAlfa.Error_wuhan,'o','Color',[1 0. 0.1])
errorbar(ExpWuhanAlfa.Dia,ExpWuhanAlfa.Perc_alfa,ExpWuhanAlfa.Error_alfa,ExpWuhanAlfa.Error_alfa,'o','Color',[0.00 0.45 0.74])
errorbar(ExpWuhanAlfa.Dia,ExpWuhanAlfa.Perc_altres,ExpWuhanAlfa.Error_altres,ExpWuhanAlfa.Error_altres,'o','Color',[0.93 0.69 0.13])
plot(FitWuhanAlfa.Dia,FitWuhanAlfa.Perc_wuhan_dia,'Color',[1 0. 0.1],'LineWidth',1.2)
plot(FitWuhanAlfa.Dia,FitWuhanAlfa.Perc_alfa_dia,'Color',[0.00 0.45 0.74],'LineWidth',1.2)
plot(FitWuhanAlfa.Dia,FitWuhanAlfa.Perc_altres_dia,'Color',[0.93 0.69 0.13],'LineWidth',1.2)
fill([FitWuhanAlfa.Dia; flip(FitWuhanAlfa.Dia)], [FitWuhanAlfa.Perc_wuhan_dia_errMIN; flip(FitWuhanAlfa.Perc_wuhan_dia_errMAX)],'r','FaceColor',[1 0. 0.10],'FaceAlpha',0.3,'EdgeColor','none');
fill([FitWuhanAlfa.Dia; flip(FitWuhanAlfa.Dia)], [FitWuhanAlfa.Perc_alfa_dia_errMIN; flip(FitWuhanAlfa.Perc_alfa_dia_errMAX)],'r','FaceColor',[0.00 0.45 0.74],'FaceAlpha',0.3,'EdgeColor','none');
fill([FitWuhanAlfa.Dia; flip(FitWuhanAlfa.Dia)], [FitWuhanAlfa.Perc_altres_dia_errMIN; flip(FitWuhanAlfa.Perc_altres_dia_errMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
clear idxinici diffinici difffinal idxfinal

%Busco on començo o acabo de dibuixar la alfa-delta per no trepitjar les altres
        diffinici = abs(FitAlfaDelta.Dia(1) - ExpAlfaDelta.Dia);
        [~, idxinici] = min(diffinici);    
        ExpAlfaDelta(1:(idxinici-1),:) = [];
        difffinal = abs(FitDeltaOmicron.Dia(1) - ExpAlfaDelta.Dia);
        [~, idxfinal] = min(difffinal);    
        ExpAlfaDelta((idxfinal):end,:) = [];
errorbar(ExpAlfaDelta.Dia,ExpAlfaDelta.Perc_alfa,ExpAlfaDelta.Error_alfa,ExpAlfaDelta.Error_alfa,'o','Color',[0.00 0.45 0.74])
errorbar(ExpAlfaDelta.Dia,ExpAlfaDelta.Perc_delta,ExpAlfaDelta.Error_delta,ExpAlfaDelta.Error_delta,'o','Color',[0.85 0.33 0.10])
errorbar(ExpAlfaDelta.Dia,ExpAlfaDelta.Perc_gamma,ExpAlfaDelta.Error_gamma,ExpAlfaDelta.Error_gamma,'o','Color',[1 0.45 0.54])
errorbar(ExpAlfaDelta.Dia,ExpAlfaDelta.Perc_Beta,ExpAlfaDelta.Error_Beta,ExpAlfaDelta.Error_Beta,'o','Color',[0.1 0.1 0.9])
errorbar(ExpAlfaDelta.Dia,ExpAlfaDelta.Perc_altres,ExpAlfaDelta.Error_altres,ExpAlfaDelta.Error_altres,'o','Color',[0.93 0.69 0.13])
plot(FitAlfaDelta.Dia,FitAlfaDelta.Perc_alfa_dia,'Color',[0.00 0.45 0.74],'LineWidth',1.2)
plot(FitAlfaDelta.Dia,FitAlfaDelta.Perc_delta_dia,'Color',[0.85 0.33 0.10],'LineWidth',1.2)
plot(FitAlfaDelta.Dia,FitAlfaDelta.Perc_gamma_dia,'Color',[1 0.45 0.54],'LineWidth',1.2)
plot(FitAlfaDelta.Dia,FitAlfaDelta.Perc_Beta_dia,'Color',[0.1 0.1 0.9],'LineWidth',1.2)
plot(FitAlfaDelta.Dia,FitAlfaDelta.Perc_altres_dia,'Color',[0.93 0.69 0.13],'LineWidth',1.2)
fill([FitAlfaDelta.Dia; flip(FitAlfaDelta.Dia)], [FitAlfaDelta.Perc_alfa_dia_errMIN; flip(FitAlfaDelta.Perc_alfa_dia_errMAX)],'r','FaceColor',[0.00 0.45 0.74],'FaceAlpha',0.3,'EdgeColor','none');
fill([FitAlfaDelta.Dia; flip(FitAlfaDelta.Dia)], [FitAlfaDelta.Perc_delta_dia_errMIN; flip(FitAlfaDelta.Perc_delta_dia_errMAX)],'r','FaceColor',[0.85 0.33 0.10],'FaceAlpha',0.3,'EdgeColor','none');
fill([FitAlfaDelta.Dia; flip(FitAlfaDelta.Dia)], [FitAlfaDelta.Perc_gamma_dia_errMIN; flip(FitAlfaDelta.Perc_gamma_dia_errMAX)],'r','FaceColor',[1 0.45 0.54],'FaceAlpha',0.3,'EdgeColor','none');
fill([FitAlfaDelta.Dia; flip(FitAlfaDelta.Dia)], [FitAlfaDelta.Perc_Beta_dia_errMIN; flip(FitAlfaDelta.Perc_Beta_dia_errMAX)],'r','FaceColor',[0.1 0.1 0.9],'FaceAlpha',0.3,'EdgeColor','none');
fill([FitAlfaDelta.Dia; flip(FitAlfaDelta.Dia)], [FitAlfaDelta.Perc_altres_dia_errMIN; flip(FitAlfaDelta.Perc_altres_dia_errMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
clear idxinici diffinici idxfinal difffinal

%Busco on començo o acabo de dibuixar la delta-OMICRON per no trepitjar les altres
        diffinici = abs(FitDeltaOmicron.Dia(1) - ExpDeltaOmicron.Dia);
        [~, idxinici] = min(diffinici);    
        ExpDeltaOmicron(1:(idxinici-1),:) = [];
errorbar(ExpDeltaOmicron.Dia,ExpDeltaOmicron.Perc_delta,ExpDeltaOmicron.Error_delta,ExpDeltaOmicron.Error_delta,'o','Color',[0.85 0.33 0.10])
errorbar(ExpDeltaOmicron.Dia,ExpDeltaOmicron.Perc_omicron,ExpDeltaOmicron.Error_omicron,ExpDeltaOmicron.Error_omicron,'o','Color',[0.13, 0.55, 0.13])
errorbar(ExpDeltaOmicron.Dia,ExpDeltaOmicron.Perc_altres,ExpDeltaOmicron.Error_altres,ExpDeltaOmicron.Error_altres,'o','Color',[0.93 0.69 0.13])
plot(FitDeltaOmicron.Dia,FitDeltaOmicron.Perc_delta_dia,'Color',[0.85 0.33 0.10],'LineWidth',1.2)
plot(FitDeltaOmicron.Dia,FitDeltaOmicron.Perc_omicron_dia,'Color',[0.13, 0.55, 0.13],'LineWidth',1.2)
plot(FitDeltaOmicron.Dia,FitDeltaOmicron.Perc_altres_dia,'Color',[0.93 0.69 0.13],'LineWidth',1.2)
fill([FitDeltaOmicron.Dia; flip(FitDeltaOmicron.Dia)], [FitDeltaOmicron.Perc_delta_dia_errMIN; flip(FitDeltaOmicron.Perc_delta_dia_errMAX)],'r','FaceColor',[0.85 0.33 0.10],'FaceAlpha',0.3,'EdgeColor','none');
fill([FitDeltaOmicron.Dia; flip(FitDeltaOmicron.Dia)], [FitDeltaOmicron.Perc_omicron_dia_errMIN; flip(FitDeltaOmicron.Perc_omicron_dia_errMAX)],'r','FaceColor',[0.13, 0.55, 0.13],'FaceAlpha',0.3,'EdgeColor','none');
fill([FitDeltaOmicron.Dia; flip(FitDeltaOmicron.Dia)], [FitDeltaOmicron.Perc_altres_dia_errMIN; flip(FitDeltaOmicron.Perc_altres_dia_errMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
clear idxfinal difffinal idxinici diffinici

yline(5,'--'); 
hold off

fig.TileSpacing = 'none';
xlim ([ GisaidAllCV.DijousOK(35) GisaidAllCV.DijousOK(end-45)  ])
xticklabels(fig2,{})
ylim([0 100]);
ylabel({'Percentage and', 'Substitution Processes'}, 'Color', 'k','FontSize', 14);
yticks(0:20:100);
yticklabels({'','20%','40%','60%','80%'});


    % Figura final de nombre de casos  i Rt per tots els paisos
    fig3 = nexttile;
opts = spreadsheetImportOptions("NumVariables", 3);
opts.Sheet = Country;
opts.DataRange = "A2:C164";
opts.VariableNames = ["cases", "deaths", "Dijous"];
opts.VariableTypes = ["double", "double", "string"];
opts = setvaropts(opts, "Dijous", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "Dijous", "EmptyFieldRule", "auto");
Cases_Death_gisaid = readtable("D:\OneDrive - Universitat Politècnica de Catalunya\2022_01_Historic_variants\Gisaid_Countries_CasesDeaths.xlsx", opts, "UseExcel", false);
clear opts
Cases_Death_gisaid.DijousOK = datetime(Cases_Death_gisaid.Dijous,'InputFormat','dd/MM/yyyy','Format','dd/MM/yyyy');

% Trobem els index per poder pintar correctament les barres del diagrama amb 
% els colors de la variant a la última figura
idxWuhanAlfaSTRT = find(Cases_Death_gisaid.DijousOK == ExpWuhanAlfa.Dia(1));
idxWuhanAlfaEND = find(Cases_Death_gisaid.DijousOK == ExpWuhanAlfa.Dia(end));
idxAlfaDeltaSTRT = find(Cases_Death_gisaid.DijousOK == ExpAlfaDelta.Dia(1));
idxAlfaDeltaEND = find(Cases_Death_gisaid.DijousOK == ExpAlfaDelta.Dia(end));
idxDeltaOmSTRT = find(Cases_Death_gisaid.DijousOK == ExpDeltaOmicron.Dia(1));
idxDeltaOmEND = find(Cases_Death_gisaid.DijousOK == ExpDeltaOmicron.Dia(end));

opts = delimitedTextImportOptions("NumVariables", 2);
opts.DataLines = [2, Inf];
opts.Delimiter = ",";
opts.VariableNames = ["Date", "Rt"];
opts.VariableTypes = ["datetime", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts = setvaropts(opts, "Date", "InputFormat", "dd/MM/yyyy");
Rtoutput = readtable("D:\OneDrive - Universitat Politècnica de Catalunya\2022_Calcul_Rt_Nuria\Rt_output"+Country+".csv", opts);
clear opts

% Trobo els valors mitjans de Rt en els moments on la variant ascendent va
% de 20 al 40% i quan passa del 60 al 80%.
RtAlpha20 = mean(Rtoutput.Rt((find(Rtoutput.Date == DayAlpha20)):(find(Rtoutput.Date == DayAlpha40))));
    if isempty(DayAlpha80)
        RtAlpha60 = 0;
    else
        RtAlpha60 = mean(Rtoutput.Rt((find(Rtoutput.Date == DayAlpha60)):(find(Rtoutput.Date == DayAlpha80))));
    end
RtDelta20 = mean(Rtoutput.Rt((find(Rtoutput.Date == DayDelta20)):(find(Rtoutput.Date == DayDelta40))));
RtDelta60 = mean(Rtoutput.Rt((find(Rtoutput.Date == DayDelta60)):(find(Rtoutput.Date == DayDelta80))));
RtOmicron20 = mean(Rtoutput.Rt((find(Rtoutput.Date == DayOmicron20)):(find(Rtoutput.Date == DayOmicron40))));
RtOmicron60 = mean(Rtoutput.Rt((find(Rtoutput.Date == DayOmicron60)):(find(Rtoutput.Date == DayOmicron80))));

Rt20 = [RtAlpha20, RtDelta20, RtOmicron20]'; 
Rt60 = [RtAlpha60, RtDelta60, RtOmicron60]';

yyaxis left
bar(Cases_Death_gisaid.DijousOK(idxWuhanAlfaSTRT:idxWuhanAlfaEND),(ExpWuhanAlfa.Perc_wuhan/100).*(Cases_Death_gisaid.cases(idxWuhanAlfaSTRT:idxWuhanAlfaEND)),'FaceColor',[1 0. 0.1],'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.9);
hold on
bar(Cases_Death_gisaid.DijousOK(idxWuhanAlfaSTRT:idxWuhanAlfaEND),(ExpWuhanAlfa.Perc_alfa/100).*(Cases_Death_gisaid.cases(idxWuhanAlfaSTRT:idxWuhanAlfaEND)),'FaceColor',[0.00 0.45 0.74],'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.7);
bar(Cases_Death_gisaid.DijousOK(idxWuhanAlfaSTRT:idxWuhanAlfaEND),(ExpWuhanAlfa.Perc_altres/100).*(Cases_Death_gisaid.cases(idxWuhanAlfaSTRT:idxWuhanAlfaEND)),'FaceColor',[0.93 0.69 0.13],'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.9);

bar(Cases_Death_gisaid.DijousOK(idxAlfaDeltaSTRT:idxAlfaDeltaEND),(ExpAlfaDelta.Perc_alfa/100).*(Cases_Death_gisaid.cases(idxAlfaDeltaSTRT:idxAlfaDeltaEND)),'FaceColor',[0.00 0.45 0.74],'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.7);
bar(Cases_Death_gisaid.DijousOK(idxAlfaDeltaSTRT:idxAlfaDeltaEND),(ExpAlfaDelta.Perc_delta/100).*(Cases_Death_gisaid.cases(idxAlfaDeltaSTRT:idxAlfaDeltaEND)),'FaceColor',[0.85 0.33 0.10],'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.7);
bar(Cases_Death_gisaid.DijousOK(idxAlfaDeltaSTRT:idxAlfaDeltaEND),(ExpAlfaDelta.Perc_gamma/100).*(Cases_Death_gisaid.cases(idxAlfaDeltaSTRT:idxAlfaDeltaEND)),'FaceColor',[1 0.45 0.54],'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.4);
bar(Cases_Death_gisaid.DijousOK(idxAlfaDeltaSTRT:idxAlfaDeltaEND),(ExpAlfaDelta.Perc_Beta/100).*(Cases_Death_gisaid.cases(idxAlfaDeltaSTRT:idxAlfaDeltaEND)),'FaceColor',[0.1 0.1 0.9],'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.6);
bar(Cases_Death_gisaid.DijousOK(idxAlfaDeltaSTRT:idxAlfaDeltaEND),(ExpAlfaDelta.Perc_altres/100).*(Cases_Death_gisaid.cases(idxAlfaDeltaSTRT:idxAlfaDeltaEND)),'FaceColor',[0.93 0.69 0.13],'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.9);

bar(Cases_Death_gisaid.DijousOK(idxDeltaOmSTRT:idxDeltaOmEND),(ExpDeltaOmicron.Perc_delta/100).*(Cases_Death_gisaid.cases(idxDeltaOmSTRT:idxDeltaOmEND)),'FaceColor',[0.85 0.33 0.10],'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.7);
bar(Cases_Death_gisaid.DijousOK(idxDeltaOmSTRT:idxDeltaOmEND),(ExpDeltaOmicron.Perc_omicron/100).*(Cases_Death_gisaid.cases(idxDeltaOmSTRT:idxDeltaOmEND)),'FaceColor',[0.13, 0.55, 0.13],'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.4);
bar(Cases_Death_gisaid.DijousOK(idxDeltaOmSTRT:idxDeltaOmEND),(ExpDeltaOmicron.Perc_altres/100).*(Cases_Death_gisaid.cases(idxDeltaOmSTRT:idxDeltaOmEND)),'FaceColor',[0.93 0.69 0.13],'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.9);
hold off

ylabel('Weekly cases [x10^6]','Color','k','FontSize', 14);
set(gca, 'Color','w', 'XColor','k', 'YColor','k')
yticks(0:2000000:10000000);
% yticklabels({'0', '0.5', '1', '1.5','2','2.5','3'});
yticklabels({'0','2','4','6','8','10'});
xlim ([ GisaidAllCV.DijousOK(35) GisaidAllCV.DijousOK(end-45)  ])

yyaxis right
plot(Rtoutput.Date,Rtoutput.Rt,'Color',[0.9 0.1 0.1],'LineWidth',1.2)
yline(1,'-','Color','r');
set(gca,'YColor','r')

ylabel('Effective reproduction number','FontSize', 14);
lgd = legend('pre-Alpha','Alpha','','','Delta','Gamma','Beta','','','Omicron','Others','Rt','Location','north','Orientation','horizontal');
lgd.FontSize = 12;
xlim ([ GisaidAllCV.DijousOK(35) GisaidAllCV.DijousOK(end-45)  ])
% ax = gca;
% set(ax.YAxis, 'FontSize', 9);

fig.TileSpacing = 'none';
fig.Padding = 'tight';

fig1.XAxis.TickLabelFormat = 'MMM yyyy';
fig1.XAxis.TickValues = iniciimg:calmonths(2):finalimg;
fig2.XAxis.TickLabelFormat = 'MMM yyyy';
fig2.XAxis.TickValues = iniciimg:calmonths(2):finalimg;
fig3.XAxis.TickLabelFormat = 'MMM yyyy';
fig3.XAxis.TickValues = iniciimg:calmonths(2):finalimg;
ax = gca;
ax.XAxis.FontSize = 14; 


saveas(fig,textCaption,'png');
saveas(fig, textCaption,'fig');

            %% Guardem totes les dades de Beta, R0, dies substitució, vacunació, CARACT. dels països
opts = spreadsheetImportOptions("NumVariables", 7);
opts.Sheet = "Hoja1";
opts.DataRange = "A2:G32";
opts.VariableNames = ["Country", "Pop20", "Pop21", "Pop22", "Area", "Density2021","GINI"];
opts.VariableTypes = ["string", "double", "double", "double", "double", "double", "double"];
opts = setvaropts(opts, "Country", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "Country", "EmptyFieldRule", "auto");
EUPopArea = readtable("D:\OneDrive - Universitat Politècnica de Catalunya\2022_01_Historic_variants\EU_population_surface.xlsx", opts, "UseExcel", false);
clear opts

% Clasifiquem el tema vacunes a partir de la web OurWorldInData
opts = delimitedTextImportOptions("NumVariables", 30);
opts.DataLines = [2, Inf];
opts.Delimiter = ";";
opts.VariableNames = ["continent", "location", "date", "total_cases", "new_cases", "new_cases_smoothed", "total_deaths", "new_deaths", "new_deaths_smoothed", "total_cases_per_million", "new_cases_per_million", "new_cases_smoothed_per_million", "total_deaths_per_million", "new_deaths_per_million", "new_deaths_smoothed_per_million", "total_vaccinations", "people_vaccinated", "people_fully_vaccinated", "new_vaccinations", "new_vaccinations_smoothed", "total_vaccinations_per_hundred", "people_vaccinated_per_hundred", "people_fully_vaccinated_per_hundred", "total_boosters_per_hundred", "new_vaccinations_smoothed_per_million", "new_people_vaccinated_smoothed", "new_people_vaccinated_smoothed_per_hundred", "population_density", "gdp_per_capita", "population"];
opts.VariableTypes = ["categorical", "categorical", "datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts = setvaropts(opts, ["continent", "location"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "date", "InputFormat", "dd/MM/yyyy");
opts = setvaropts(opts, ["total_cases", "new_cases", "new_cases_smoothed", "total_deaths", "new_deaths", "new_deaths_smoothed", "total_cases_per_million", "new_cases_per_million", "new_cases_smoothed_per_million", "total_deaths_per_million", "new_deaths_per_million", "new_deaths_smoothed_per_million", "total_vaccinations", "people_vaccinated", "people_fully_vaccinated", "new_vaccinations", "new_vaccinations_smoothed", "total_vaccinations_per_hundred", "people_vaccinated_per_hundred", "people_fully_vaccinated_per_hundred", "total_boosters_per_hundred", "new_vaccinations_smoothed_per_million", "new_people_vaccinated_smoothed", "new_people_vaccinated_smoothed_per_hundred", "population_density", "gdp_per_capita", "population"], "FillValue", 0);
opts = setvaropts(opts, ["new_cases_smoothed", "new_deaths_smoothed", "total_cases_per_million", "new_cases_per_million", "new_cases_smoothed_per_million", "total_deaths_per_million", "new_deaths_smoothed_per_million", "total_vaccinations", "people_vaccinated", "people_fully_vaccinated", "new_vaccinations", "new_vaccinations_smoothed", "total_vaccinations_per_hundred", "people_vaccinated_per_hundred", "people_fully_vaccinated_per_hundred", "total_boosters_per_hundred", "new_vaccinations_smoothed_per_million", "new_people_vaccinated_smoothed", "new_people_vaccinated_smoothed_per_hundred", "population_density", "gdp_per_capita"], "TrimNonNumeric", true);
opts = setvaropts(opts, ["new_cases_smoothed", "new_deaths_smoothed", "total_cases_per_million", "new_cases_per_million", "new_cases_smoothed_per_million", "total_deaths_per_million", "new_deaths_smoothed_per_million", "total_vaccinations", "people_vaccinated", "people_fully_vaccinated", "new_vaccinations", "new_vaccinations_smoothed", "total_vaccinations_per_hundred", "people_vaccinated_per_hundred", "people_fully_vaccinated_per_hundred", "total_boosters_per_hundred", "new_vaccinations_smoothed_per_million", "new_people_vaccinated_smoothed", "new_people_vaccinated_smoothed_per_hundred", "population_density", "gdp_per_capita"], "ThousandsSeparator", ",");
owidcoviddata = readtable("D:\OneDrive - Universitat Politècnica de Catalunya\2022_01_Historic_variants\owid-covid-data.csv", opts);
clear opts

idxcountry = ismember(owidcoviddata.location,Country);
OWiDCountry = owidcoviddata(idxcountry,{'date', 'people_fully_vaccinated'});
for i = 2:length(OWiDCountry.people_fully_vaccinated)
    if OWiDCountry.people_fully_vaccinated(i) == 0
        OWiDCountry.people_fully_vaccinated(i) = OWiDCountry.people_fully_vaccinated(i-1);
    end
end

if Country == "Europe" %extrets directament de la web OWID, com la resta
    N_full_vacc_Alfa = 0;
    N_full_vacc_Delta = 81500000;
    N_full_vacc_Om = 299370000;
else
N_full_vacc_Alfa = OWiDCountry.people_fully_vaccinated(find(OWiDCountry.date == DayAlpha));
N_full_vacc_Delta = OWiDCountry.people_fully_vaccinated(find(OWiDCountry.date == DayDelta));
N_full_vacc_Om = OWiDCountry.people_fully_vaccinated(find(OWiDCountry.date == DayOmicron));
end

N_full_vacc = [N_full_vacc_Alfa, N_full_vacc_Delta, N_full_vacc_Om]';
    
    country_idx = find(strcmp(EUPopArea.Country, Country));
    population = repmat(EUPopArea.Pop21(country_idx),3,1);
    area = repmat(EUPopArea.Area(country_idx),3,1);
    gini = repmat(EUPopArea.GINI(country_idx),3,1);

    CountryWave = [Country+" Alpha", Country+" Delta", Country+" Omicron"];
DayFit = [DayAlpha, DayDelta, DayOmicron]';
DayFit20 = [DayAlpha20, DayDelta20, DayOmicron20]';
DayFit60 = [DayAlpha60, DayDelta60, DayOmicron60]';
DayFitstring = datestr(DayFit); DayFitstring20 = datestr(DayFit20); DayFitstring60 = datestr(DayFit60);

TB = [BAlpha,BerrAlpha,R0Alpha,R0errAlpha;BDelta,BerrDelta,R0Delta,R0errDelta;BOmicron,BerrOmicron,R0Omicron,R0errOmicron];

T = array2table([CountryWave', DayFitstring, N_full_vacc, DayFitstring20, DayFitstring60, TB, Rt20, Rt60, population, area, gini], ...
    'VariableNames', {'Country_Subs','Start_Day','Vaccination','Fitting_Day_20','Fitting_Day_60', 'Beta', 'Error Beta', 'R0', 'Error R0','mean_Rt_20_40','mean_Rt_60_80','Population','Area','GINI'});
writetable(T, 'BetaR0_27pais_ADO_GISAID.xlsx', 'Sheet', Country)

end
    