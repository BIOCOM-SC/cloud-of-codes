%% A continuació hi ha el codi per fer TOTS els païssos de manera automàtica "arriscant" amb unes certes condicions que quedi bé a 1 output
clear all
close all
%Primer tenim la opció de probar només un país o fer-ho per tots:
Countries = "Poland";
% Tots els països, 28 en total (queden fora Liechtenstein i Malta):
% Countries = ["Austria","Belgium","Bulgaria","Croatia","Cyprus","Czechia","Denmark","Estonia","Finland","France","Germany","Greece","Hungary","Iceland","Ireland","Italy","Latvia","Lithuania","Luxembourg","Netherlands","Norway","Poland","Portugal","Romania","Slovakia","Slovenia","Spain","Sweden"];
% Països amb les 6 onades de variants ben diferenciades, 19!?!? GISAAID en total:
% Countries = ["Belgium","Bulgaria","Croatia","Czechia","Denmark","Finland","France","Germany","Ireland","Italy",...
% "Latvia","Netherlands","Norway","Poland","Romania","Slovenia","Spain","Sweden","Europe"];
%%
for iii = 1:length(Countries)
    Country = Countries{iii};
opts = spreadsheetImportOptions("NumVariables", 23);
opts.Sheet = Country;
opts.DataRange = "A2:W170";
opts.VariableNames = ["B117", "B1351", "B1427B1429", "B1525", "B1616", "B16171", "B16172", "B1620", "B1621", "BA1", "BA2", "BA275", "BA4", "BA5", "BQ1", "C37", "Other", "P1", "P3", "UNK", "XBB", "XBB15", "Dijous"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "char"];
opts = setvaropts(opts, "Dijous", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "Dijous", "EmptyFieldRule", "auto");
opts = setvaropts(opts, ["B117", "B1351", "B1427B1429", "B1525", "B1616", "B16171", "B16172", "B1620", "B1621", "BA1", "BA2", "BA275", "BA4", "BA5", "BQ1", "C37", "Other", "P1", "P3", "UNK", "XBB", "XBB15"], "FillValue", 0);
GisaidAllCV = readtable("D:\OneDrive - Universitat Politècnica de Catalunya\2023_01_TOT_Variants_EU\2022_01_Historic_variants\Gisaid_ONLY_Countries_variants_april.xlsx", opts, "UseExcel", false);
clear opts
GisaidAllCV.DijousOK = datetime(GisaidAllCV.Dijous,'InputFormat','dd/MM/yyyy','Format','dd/MM/yyyy');

%Aquí tenim totes les variants que ens interesaran per fer les diferents
%substitucions
    N_Other = GisaidAllCV.('Other'); %prealfa!
    N_Alpha = GisaidAllCV.('B117'); %VOC
    N_Beta = GisaidAllCV.('B1351'); %VOC
    N_Gamma = GisaidAllCV.('P1'); %VOC
    N_Delta = GisaidAllCV.('B16172'); %VOC
    N_OBA1 = GisaidAllCV.('BA1'); %VOC
    N_OBA2 = GisaidAllCV.('BA2'); %VOC
    N_OBA4 = GisaidAllCV.('BA4'); %VOC
    N_OBA5 = GisaidAllCV.('BA5'); %VOC
    N_OBQ = GisaidAllCV.('BQ1'); %VOC 
    N_OXBB = GisaidAllCV.('XBB') + GisaidAllCV.('XBB15'); %VOC
    N_OBA275 = GisaidAllCV.('BA275'); %VOI a l'abril del 2023 competeix amb BQ i XBB
    N_Altres = GisaidAllCV.('B1621') + GisaidAllCV.('B1427B1429') + GisaidAllCV.('B1525') + GisaidAllCV.('B1616') +...
        GisaidAllCV.('B16171') + GisaidAllCV.('B1620') + GisaidAllCV.('C37') + GisaidAllCV.('P3') + GisaidAllCV.('UNK');
    N_AltresOther = N_Other+N_Altres;

    %% Substitution Wuhan vs Alpha: 13 inputs
    ini = 35; fin = 80;
    N_Desc = N_Other(ini:fin);
    N_Asc1 = N_Alpha(ini:fin);
    N_Ctt = N_Altres(ini:fin) + N_Beta(ini:fin) + N_Gamma(ini:fin) + N_Delta(ini:fin) + ...
        N_OBA1(ini:fin) + N_OBA2(ini:fin) + N_OBA4(ini:fin) + N_OBA5(ini:fin) + N_OBQ(ini:fin) + N_OXBB(ini:fin) + N_OBA275(ini:fin);
    WeekThurs = GisaidAllCV.DijousOK(ini:fin);

    [BAlpha,BerrAlpha,R0Alpha,R0errAlpha,DayAlpha,DayAlpha20,DayAlpha40,DayAlpha60,DayAlpha80] = FWuhanAlphab(N_Desc, N_Asc1, N_Ctt,Country,WeekThurs);
    clear ini fin N_Desc N_Asc1 N_Ctt WeekThurs 

        %% Substitution Alpha vs Delta: 12 inputs
    ini = 60; fin = 110;
    N_Desc = N_Alpha(ini:fin);
    N_Asc1 = N_Delta(ini:fin);
    N_Asc2 = N_Gamma(ini:fin);
    N_Asc4 = N_Beta(ini:fin);
    N_Ctt = N_Altres(ini:fin) + N_Other(ini:fin) + N_OBA275(ini:fin)+ ...
            N_OBA1(ini:fin) + N_OBA2(ini:fin) + N_OBA4(ini:fin) + N_OBA5(ini:fin) + N_OBQ(ini:fin) + N_OXBB(ini:fin);
    WeekThurs = GisaidAllCV.DijousOK(ini:fin);

    [BDelta,BerrDelta,R0Delta,R0errDelta,DayDelta,DayDelta20,DayDelta40,DayDelta60,DayDelta80] = FAlphaDeltab(N_Desc, N_Asc1, N_Asc2, N_Asc4, N_Ctt,Country,WeekThurs);
    clear ini fin N_Desc N_Asc1 N_Asc2 N_Asc4 N_Ctt WeekThurs 

        %% Substitution Delta vs OBA1: 12 inputs
    ini = 90; fin = 110;
    N_Desc = N_Delta(ini:fin);
    N_Asc1 = N_OBA1(ini:fin);
    N_Ctt = N_Altres(ini:fin) + N_Other(ini:fin) + N_Alpha(ini:fin) + N_Gamma(ini:fin) + N_Beta(ini:fin) + N_OBA275(ini:fin) + ...
            N_OBA2(ini:fin) + N_OBA4(ini:fin) + N_OBA5(ini:fin) + N_OBQ(ini:fin) + N_OXBB(ini:fin);

    WeekThurs = GisaidAllCV.DijousOK(ini:fin);

    [BOBA1,BerrOBA1,R0OBA1,R0errOBA1,DayOBA1,DayOBA120,DayOBA140,DayOBA160,DayOBA180] = FDeltaOBA1b(N_Desc, N_Asc1, N_Ctt,Country,WeekThurs);
    clear ini fin N_Desc N_Asc1 N_Ctt WeekThurs

        %% Substitution OBA1 vs OBA2: 12 inputs
    ini = 95; fin = 125;
    N_Desc = N_OBA1(ini:fin);
    N_Asc1 = N_OBA2(ini:fin);
    N_Ctt = N_Altres(ini:fin) + N_Other(ini:fin) + N_Alpha(ini:fin) + N_Gamma(ini:fin) + N_Beta(ini:fin) + N_OBA275(ini:fin) + ...
            N_Delta(ini:fin) + N_OBA4(ini:fin) + N_OBA5(ini:fin) + N_OBQ(ini:fin) + N_OXBB(ini:fin);

    WeekThurs = GisaidAllCV.DijousOK(ini:fin);

    [BOBA2,BerrOBA2,R0OBA2,R0errOBA2,DayOBA2,DayOBA220,DayOBA240,DayOBA260,DayOBA280] = FOBA1OBA2b(N_Desc, N_Asc1, N_Ctt,Country,WeekThurs);
    clear ini fin N_Desc N_Asc1 N_Ctt WeekThurs

        %% Substitution OBA2 vs OBA5: 12 inputs
    ini = 115; fin = 155;
    N_Desc = N_OBA2(ini:fin);
    N_Asc1 = N_OBA5(ini:fin);
    N_Asc2 = N_OBA4(ini:fin);
    N_Ctt = N_Altres(ini:fin) + N_Other(ini:fin)+ N_Alpha(ini:fin) + N_Gamma(ini:fin) + N_Beta(ini:fin) + N_OBA275(ini:fin) + ...
            N_Delta(ini:fin) + N_OBA1(ini:fin) + N_OBQ(ini:fin) + N_OXBB(ini:fin);

    WeekThurs = GisaidAllCV.DijousOK(ini:fin);

    [BOBA5,BerrOBA5,R0OBA5,R0errOBA5,DayOBA5,DayOBA520,DayOBA540,DayOBA560,DayOBA580] = FOBA2OBA5b(N_Desc, N_Asc1, N_Asc2, N_Ctt, Country, WeekThurs);
    clear ini fin N_Desc N_Asc1 N_Asc2 N_Ctt WeekThurs

        %% Substitution OBA5 vs OBQ: 12 inputs
    ini = 135; fin = 169;
    N_Desc = N_OBA5(ini:fin);
    N_Asc1 = N_OBQ(ini:fin); 
    N_Asc2 = N_OBA2(ini:fin); 
    N_Asc4 = N_OBA4(ini:fin);
    N_Ctt = N_Altres(ini:fin) + N_Other(ini:fin) + N_Alpha(ini:fin) + N_Gamma(ini:fin) + N_Beta(ini:fin) +  ...
            N_Delta(ini:fin) + N_OBA1(ini:fin)  + N_OXBB(ini:fin) + N_OBA275(ini:fin);
    WeekThurs = GisaidAllCV.DijousOK(ini:fin);
    if Country =="Bulgaria"
        BOBQ=0;BerrOBQ=1000000;R0OBQ=0;R0errOBQ=0;DayOBQ="01/01/2024";DayOBQ20="01/01/2024";
    else
        [BOBQ,BerrOBQ,R0OBQ,R0errOBQ,DayOBQ,DayOBQ20] = FOBA5OBQb(N_Desc, N_Asc1, N_Asc2, N_Asc4, N_Ctt, Country, WeekThurs);
    end
    clear ini fin N_Desc N_Asc1 N_Asc2 N_Ctt WeekThurs

            %% Carreguem les dades del Plot i el Fit que acabem de fer per totes les onades:
% pre-Alpha vs Alpha
    opts = delimitedTextImportOptions("NumVariables", 10);
    opts.DataLines = [2, Inf];
    opts.Delimiter = ",";
    opts.VariableNames = ["Dia", "Perc_wuhan_dia", "Perc_wuhan_dia_errMAX", "Perc_wuhan_dia_errMIN", "Perc_alfa_dia", "Perc_alfa_dia_errMAX", "Perc_alfa_dia_errMIN", "Perc_altres_dia", "Perc_altres_dia_errMAX", "Perc_altres_dia_errMIN"];
    opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts = setvaropts(opts, "Dia", "InputFormat", "dd/MM/yyyy");
    FitWuhanAlfa = readtable("D:\OneDrive - Universitat Politècnica de Catalunya\2023_01_Historic_variants_EU_GISAID\DadesCSV_hist_variants_Alfa\Fit_SeqVar_wuhan_alfa_altres" + Country + ".csv", opts);
    clear opts
    
    opts = delimitedTextImportOptions("NumVariables", 7);
    opts.DataLines = [2, Inf];
    opts.Delimiter = ",";
    opts.VariableNames = ["Dia", "Perc_wuhan", "Error_wuhan", "Perc_alfa", "Error_alfa", "Perc_altres", "Error_altres"];
    opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts = setvaropts(opts, "Dia", "InputFormat", "dd/MM/yyyy");
    ExpWuhanAlfa = readtable("D:\OneDrive - Universitat Politècnica de Catalunya\2023_01_Historic_variants_EU_GISAID\DadesCSV_hist_variants_Alfa\Plot_SeqVar_wuhan_alfa_altres"+ Country + ".csv", opts);
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
    FitAlfaDelta = readtable("D:\OneDrive - Universitat Politècnica de Catalunya\2023_01_Historic_variants_EU_GISAID\DadesCSV_hist_variants_Delta\Fit_SeqVar_alfa_delta_gamma_Beta_altres" + Country + ".csv", opts);
    clear opts

    opts = delimitedTextImportOptions("NumVariables", 11);
    opts.DataLines = [2, Inf];
    opts.Delimiter = ",";
    opts.VariableNames = ["Dia", "Perc_alfa", "Error_alfa", "Perc_delta", "Error_delta", "Perc_gamma", "Error_gamma", "Perc_Beta", "Error_Beta", "Perc_altres", "Error_altres"];
    opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts = setvaropts(opts, "Dia", "InputFormat", "dd/MM/yyyy");
    ExpAlfaDelta = readtable("D:\OneDrive - Universitat Politècnica de Catalunya\2023_01_Historic_variants_EU_GISAID\DadesCSV_hist_variants_Delta\Plot_SeqVar_alfa_delta_gamma_Beta_altres" + Country + ".csv", opts);
    clear opts 

% Delta vs Omicron BA1
    opts = delimitedTextImportOptions("NumVariables", 10);
    opts.DataLines = [2, Inf];
    opts.Delimiter = ",";
    opts.VariableNames = ["Dia", "Perc_delta_dia", "Perc_delta_dia_errMAX", "Perc_delta_dia_errMIN", "Perc_OBA1_dia", "Perc_OBA1_dia_errMAX", "Perc_OBA1_dia_errMIN", "Perc_altres_dia", "Perc_altres_dia_errMAX", "Perc_altres_dia_errMIN"];
    opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts = setvaropts(opts, "Dia", "InputFormat", "dd/MM/yyyy");
    FitDeltaOBA1 = readtable("D:\OneDrive - Universitat Politècnica de Catalunya\2023_01_Historic_variants_EU_GISAID\DadesCSV_hist_variants_OBA1\Fit_SeqVar_delta_OBA1_altres"+Country+".csv", opts);
    clear opts

    opts = delimitedTextImportOptions("NumVariables", 7);
    opts.DataLines = [2, Inf];
    opts.Delimiter = ",";
    opts.VariableNames = ["Dia", "Perc_delta", "Error_delta", "Perc_OBA1", "Error_OBA1", "Perc_altres", "Error_altres"];
    opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts = setvaropts(opts, "Dia", "InputFormat", "dd/MM/yyyy");
    ExpDeltaOBA1 = readtable("D:\OneDrive - Universitat Politècnica de Catalunya\2023_01_Historic_variants_EU_GISAID\DadesCSV_hist_variants_OBA1\Plot_SeqVar_delta_OBA1_altres"+Country+".csv", opts);
    clear opts

% Omicron BA1 vs Omicron BA2
    opts = delimitedTextImportOptions("NumVariables", 10);
    opts.DataLines = [2, Inf];
    opts.Delimiter = ",";
    opts.VariableNames = ["Dia", "Perc_oBA1_dia", "Perc_oBA1_dia_errMAX", "Perc_oBA1_dia_errMIN", "Perc_oBA2_dia", "Perc_oBA2_dia_errMAX", "Perc_oBA2_dia_errMIN", "Perc_altres_dia", "Perc_altres_dia_errMAX", "Perc_altres_dia_errMIN"];
    opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts = setvaropts(opts, "Dia", "InputFormat", "dd/MM/yyyy");
    FitO1O2 = readtable("D:\OneDrive - Universitat Politècnica de Catalunya\2023_01_Historic_variants_EU_GISAID\DadesCSV_hist_variants_OBA2\Fit_SeqVar_oBA1_oBA2_altres"+Country+".csv", opts);
    clear opts

    opts = delimitedTextImportOptions("NumVariables", 7);
    opts.DataLines = [2, Inf];
    opts.Delimiter = ",";
    opts.VariableNames = ["Dia", "Perc_oBA1", "Error_oBA1", "Perc_oBA2", "Error_oBA2", "Perc_altres", "Error_altres"];
    opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts = setvaropts(opts, "Dia", "InputFormat", "dd/MM/yyyy");
    ExpO1O2 = readtable("D:\OneDrive - Universitat Politècnica de Catalunya\2023_01_Historic_variants_EU_GISAID\DadesCSV_hist_variants_OBA2\Plot_SeqVar_oBA1_oBA2_altres"+Country+".csv", opts);
    clear opts

% Omicron BA2 vs Omicron BA5
    opts = delimitedTextImportOptions("NumVariables", 13);
    opts.DataLines = [2, Inf];
    opts.Delimiter = ",";
    opts.VariableNames = ["Dia", "Perc_oBA2_dia", "Perc_oBA2_dia_errMAX", "Perc_oBA2_dia_errMIN", "Perc_oBA5_dia", "Perc_oBA5_dia_errMAX", "Perc_oBA5_dia_errMIN", "Perc_oBA4_dia", "Perc_oBA4_dia_errMAX", "Perc_oBA4_dia_errMIN", "Perc_altres_dia", "Perc_altres_dia_errMAX", "Perc_altres_dia_errMIN"];
    opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts = setvaropts(opts, "Dia", "InputFormat", "dd/MM/yyyy");
    FitO2O5 = readtable("D:\OneDrive - Universitat Politècnica de Catalunya\2023_01_Historic_variants_EU_GISAID\DadesCSV_hist_variants_OBA5\Fit_SeqVar_oBA2_oBA5_oBA4_altres"+Country+".csv", opts);
    clear opts
    
    opts = delimitedTextImportOptions("NumVariables", 9);
    opts.DataLines = [2, Inf];
    opts.Delimiter = ",";
    opts.VariableNames = ["Dia", "Perc_oBA2", "Error_oBA2", "Perc_oBA5", "Error_oBA5", "Perc_oBA4", "Error_oBA4", "Perc_altres", "Error_altres"];
    opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts = setvaropts(opts, "Dia", "InputFormat", "dd/MM/yyyy");
    ExpO2O5 = readtable("D:\OneDrive - Universitat Politècnica de Catalunya\2023_01_Historic_variants_EU_GISAID\DadesCSV_hist_variants_OBA5\Plot_SeqVar_oBA2_oBA5_altres"+Country+".csv", opts);
    clear opts

% Omicron BA5 vs Omicron BQ
    opts = delimitedTextImportOptions("NumVariables", 16);
    opts.DataLines = [2, Inf];
    opts.Delimiter = ",";
    opts.VariableNames = ["Dia", "Perc_oBA5_dia", "Perc_oBA5_dia_errMAX", "Perc_oBA5_dia_errMIN", "Perc_oBQ_dia", "Perc_oBQ_dia_errMAX", "Perc_oBQ_dia_errMIN", "Perc_oBA2_dia", "Perc_oBA2_dia_errMAX", "Perc_oBA2_dia_errMIN", "Perc_oBA4_dia", "Perc_oBA4_dia_errMAX", "Perc_oBA4_dia_errMIN", "Perc_altres_dia", "Perc_altres_dia_errMAX", "Perc_altres_dia_errMIN"];
    opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts = setvaropts(opts, "Dia", "InputFormat", "dd/MM/yyyy");
    FitO5OBQ = readtable("D:\OneDrive - Universitat Politècnica de Catalunya\2023_01_Historic_variants_EU_GISAID\DadesCSV_hist_variants_OBQ\Fit_SeqVar_oBA5_oBQ_oBA2_altres"+Country+".csv", opts);
    clear opts
    
    opts = delimitedTextImportOptions("NumVariables", 11);
    opts.DataLines = [2, Inf];
    opts.Delimiter = ",";
    opts.VariableNames = ["Dia", "Perc_oBA5", "Error_oBA5", "Perc_oBQ", "Error_oBQ", "Perc_oBA2", "Error_oBA2", "Perc_oBA4", "Error_oBA4", "Perc_altres", "Error_altres"];
    opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts = setvaropts(opts, "Dia", "InputFormat", "dd/MM/yyyy");
    ExpO5OBQ = readtable("D:\OneDrive - Universitat Politècnica de Catalunya\2023_01_Historic_variants_EU_GISAID\DadesCSV_hist_variants_OBQ\Plot_SeqVar_oBA5_oBQ_altres"+Country+".csv", opts);
    clear opts

                %% Fem la figura completa per tots els païssos
            % Primer la figura amb els casos sequenciats
iniciimg = datetime(2020, 09, 1);
finalimg = datetime(2023, 3, 1);
figure('Position', get(0, 'Screensize'));
fig = tiledlayout(3,1,"TileSpacing","none","Padding","tight"); 
textCaption = ".\Figures_Variants_EU\" + Country + " variants";
fig1 = nexttile;
    Nomsvariants = {'Wuhan','Alpha', 'Altres', 'Delta', 'Gamma', 'Beta', 'OBA1', 'OBA2', 'OBA4', 'OBA5', 'OBQ'};
colorsvar = [1 0. 0.1
             0.00 0.45 0.74
             0.93 0.69 0.13
             0.85 0.33 0.10
             1 0.45 0.54
             0.1 0.1 0.9
             0.85 0. 0.70
             0.2 0.8 0.20
             0.2 0.8 0.80
             0.5 0.05 0.04
             0.4 0.2 0.6
             0.93 0.69 0.13];
colororder(colorsvar)
bar((GisaidAllCV.DijousOK(1:70)),(N_Other(1:70)),'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.6);
hold on
bar(GisaidAllCV.DijousOK,(N_Alpha),'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.7);
bar(GisaidAllCV.DijousOK,(N_Altres),'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.9);
bar(GisaidAllCV.DijousOK,(N_Delta),'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.7);
bar(GisaidAllCV.DijousOK,(N_Gamma),'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.4);
bar(GisaidAllCV.DijousOK,(N_Beta),'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.6);
bar(GisaidAllCV.DijousOK,(N_OBA1),'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.4);
bar(GisaidAllCV.DijousOK,(N_OBA2),'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.3);
bar(GisaidAllCV.DijousOK,(N_OBA5),'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.5);
bar(GisaidAllCV.DijousOK,(N_OBA4),'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.8);
bar(GisaidAllCV.DijousOK,(N_OBQ),'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.7);
bar((GisaidAllCV.DijousOK(70:end)),(N_AltresOther(70:end)),'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.5);
hold off

% title(Country + ": Dynamics of COVID-19 variants", 'FontSize', 16);
xticklabels(fig1,{})
ylabel('Weekly sample sequencing','Color','k', 'FontSize', 14);
set(gca, 'Color','w', 'XColor','k', 'YColor','k')
xlim ([ GisaidAllCV.DijousOK(35) GisaidAllCV.DijousOK(end-10)])

    % Fem la figura de les substitucions
    fig2 = nexttile;
    fill([ExpWuhanAlfa.Dia(1) FitWuhanAlfa.Dia(1) FitWuhanAlfa.Dia(1) ExpWuhanAlfa.Dia(1)],[0 0 100 100],[0.8 0.8 0.8],FaceAlpha=0.3,EdgeColor='none')
    hold on
    fill([FitWuhanAlfa.Dia(end) FitAlfaDelta.Dia(1) FitAlfaDelta.Dia(1) FitWuhanAlfa.Dia(end)],[0 0 100 100],[0.8 0.8 0.8],FaceAlpha=0.3,EdgeColor='none')
    fill([FitAlfaDelta.Dia(end) FitDeltaOBA1.Dia(1) FitDeltaOBA1.Dia(1) FitAlfaDelta.Dia(end)],[0 0 100 100],[0.8 0.8 0.8],FaceAlpha=0.3,EdgeColor='none')
    fill([FitDeltaOBA1.Dia(end) FitO1O2.Dia(1) FitO1O2.Dia(1) FitDeltaOBA1.Dia(end)],[0 0 100 100],[0.8 0.8 0.8],FaceAlpha=0.3,EdgeColor='none')
    fill([FitO1O2.Dia(end) FitO2O5.Dia(1) FitO2O5.Dia(1) FitO1O2.Dia(end)],[0 0 100 100],[0.8 0.8 0.8],FaceAlpha=0.3,EdgeColor='none')
    fill([FitO2O5.Dia(end) FitO5OBQ.Dia(1) FitO5OBQ.Dia(1) FitO2O5.Dia(end)],[0 0 100 100],[0.8 0.8 0.8],FaceAlpha=0.3,EdgeColor='none')
    fill([FitO5OBQ.Dia(end) ExpO5OBQ.Dia(end) ExpO5OBQ.Dia(end) FitO5OBQ.Dia(end)],[0 0 100 100],[0.8 0.8 0.8],FaceAlpha=0.3,EdgeColor='none')

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
clear difffinal idxfinal

%Busco on començo o acabo de dibuixar la alfa-delta per no trepitjar les altres
        diffinici = abs(FitAlfaDelta.Dia(1) - ExpAlfaDelta.Dia);
        [~, idxinici] = min(diffinici);    
        ExpAlfaDelta(1:(idxinici-1),:) = [];
        difffinal = abs(FitDeltaOBA1.Dia(1) - ExpAlfaDelta.Dia);
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

%Busco on començo o acabo de dibuixar la delta-OBA1 per no trepitjar les altres
        diffinici = abs(FitDeltaOBA1.Dia(1) - ExpDeltaOBA1.Dia);
        [~, idxinici] = min(diffinici);    
        ExpDeltaOBA1(1:(idxinici-1),:) = [];
        difffinal = abs(FitO1O2.Dia(1) - ExpDeltaOBA1.Dia);
        [~, idxfinal] = min(difffinal);    
        ExpDeltaOBA1((idxfinal):end,:) = [];
errorbar(ExpDeltaOBA1.Dia,ExpDeltaOBA1.Perc_delta,ExpDeltaOBA1.Error_delta,ExpDeltaOBA1.Error_delta,'o','Color',[0.85 0.33 0.10])
errorbar(ExpDeltaOBA1.Dia,ExpDeltaOBA1.Perc_OBA1,ExpDeltaOBA1.Error_OBA1,ExpDeltaOBA1.Error_OBA1,'o','Color',[0.85 0. 0.70])
errorbar(ExpDeltaOBA1.Dia,ExpDeltaOBA1.Perc_altres,ExpDeltaOBA1.Error_altres,ExpDeltaOBA1.Error_altres,'o','Color',[0.93 0.69 0.13])
plot(FitDeltaOBA1.Dia,FitDeltaOBA1.Perc_delta_dia,'Color',[0.85 0.33 0.10],'LineWidth',1.2)
plot(FitDeltaOBA1.Dia,FitDeltaOBA1.Perc_OBA1_dia,'Color',[0.85 0. 0.70],'LineWidth',1.2)
plot(FitDeltaOBA1.Dia,FitDeltaOBA1.Perc_altres_dia,'Color',[0.93 0.69 0.13],'LineWidth',1.2)
fill([FitDeltaOBA1.Dia; flip(FitDeltaOBA1.Dia)], [FitDeltaOBA1.Perc_delta_dia_errMIN; flip(FitDeltaOBA1.Perc_delta_dia_errMAX)],'r','FaceColor',[0.85 0.33 0.10],'FaceAlpha',0.3,'EdgeColor','none');
fill([FitDeltaOBA1.Dia; flip(FitDeltaOBA1.Dia)], [FitDeltaOBA1.Perc_OBA1_dia_errMIN; flip(FitDeltaOBA1.Perc_OBA1_dia_errMAX)],'r','FaceColor',[0.85 0. 0.70],'FaceAlpha',0.3,'EdgeColor','none');
fill([FitDeltaOBA1.Dia; flip(FitDeltaOBA1.Dia)], [FitDeltaOBA1.Perc_altres_dia_errMIN; flip(FitDeltaOBA1.Perc_altres_dia_errMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
clear idxfinal difffinal idxinici diffinici

%Busco on començo o acabo de dibuixar la OBA1-OBA2 per no trepitjar les altres
        diffinici = abs(FitO1O2.Dia(1) - ExpO1O2.Dia);
        [~, idxinici] = min(diffinici);    
        ExpO1O2(1:(idxinici-1),:) = [];
        difffinal = abs(FitO2O5.Dia(1) - ExpO1O2.Dia);
        [~, idxfinal] = min(difffinal);    
        ExpO1O2((idxfinal):end,:) = [];
errorbar(ExpO1O2.Dia,ExpO1O2.Perc_oBA1,ExpO1O2.Error_oBA1,ExpO1O2.Error_oBA1,'o','Color',[0.85 0. 0.70])
errorbar(ExpO1O2.Dia,ExpO1O2.Perc_oBA2,ExpO1O2.Error_oBA2,ExpO1O2.Error_oBA2,'o','Color',[0.2 0.8 0.20])
errorbar(ExpO1O2.Dia,ExpO1O2.Perc_altres,ExpO1O2.Error_altres,ExpO1O2.Error_altres,'o','Color',[0.93 0.69 0.13])
plot(FitO1O2.Dia,FitO1O2.Perc_oBA1_dia,'Color',[0.85 0. 0.70],'LineWidth',1.2)
plot(FitO1O2.Dia,FitO1O2.Perc_oBA2_dia,'Color',[0.2 0.8 0.20],'LineWidth',1.2)
plot(FitO1O2.Dia,FitO1O2.Perc_altres_dia,'Color',[0.93 0.69 0.13],'LineWidth',1.2)
fill([FitO1O2.Dia; flip(FitO1O2.Dia)], [FitO1O2.Perc_oBA1_dia_errMIN; flip(FitO1O2.Perc_oBA1_dia_errMAX)],'r','FaceColor',[0.85 0. 0.70],'FaceAlpha',0.3,'EdgeColor','none');
fill([FitO1O2.Dia; flip(FitO1O2.Dia)], [FitO1O2.Perc_oBA2_dia_errMIN; flip(FitO1O2.Perc_oBA2_dia_errMAX)],'r','FaceColor',[0.2 0.8 0.20],'FaceAlpha',0.3,'EdgeColor','none');
fill([FitO1O2.Dia; flip(FitO1O2.Dia)], [FitO1O2.Perc_altres_dia_errMIN; flip(FitO1O2.Perc_altres_dia_errMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
clear idxinici diffinici idxfinal difffinal

%Busco on començo o acabo de dibuixar la OBA2-OBA5 per no trepitjar les altres
        diffinici = abs(FitO2O5.Dia(1) - ExpO2O5.Dia);
        [~, idxinici] = min(diffinici);    
        ExpO2O5(1:(idxinici-1),:) = [];        
        difffinal = abs(FitO5OBQ.Dia(1) - ExpO2O5.Dia);
        [~, idxfinal] = min(difffinal);    
        ExpO2O5((idxfinal):end,:) = [];
errorbar(ExpO2O5.Dia,ExpO2O5.Perc_oBA2,ExpO2O5.Error_oBA2,ExpO2O5.Error_oBA2,'o','Color',[0.2 0.8 0.20])
errorbar(ExpO2O5.Dia,ExpO2O5.Perc_oBA5,ExpO2O5.Error_oBA5,ExpO2O5.Error_oBA5,'o','Color',[0.2 0.8 0.80])
errorbar(ExpO2O5.Dia,ExpO2O5.Perc_oBA4,ExpO2O5.Error_oBA4,ExpO2O5.Error_oBA4,'o','Color',[0.5 0.05 0.04])
errorbar(ExpO2O5.Dia,ExpO2O5.Perc_altres,ExpO2O5.Error_altres,ExpO2O5.Error_altres,'o','Color',[0.93 0.69 0.13])
plot(FitO2O5.Dia,FitO2O5.Perc_oBA2_dia,'Color',[0.2 0.8 0.20],'LineWidth',1.2)
plot(FitO2O5.Dia,FitO2O5.Perc_oBA4_dia,'Color',[0.5 0.05 0.04],'LineWidth',1.2)
plot(FitO2O5.Dia,FitO2O5.Perc_oBA5_dia,'Color',[0.2 0.8 0.80],'LineWidth',1.2)
plot(FitO2O5.Dia,FitO2O5.Perc_altres_dia,'Color',[0.93 0.69 0.13],'LineWidth',1.2)
fill([FitO2O5.Dia; flip(FitO2O5.Dia)], [FitO2O5.Perc_oBA2_dia_errMIN; flip(FitO2O5.Perc_oBA2_dia_errMAX)],'r','FaceColor',[0.2 0.8 0.20],'FaceAlpha',0.3,'EdgeColor','none');
fill([FitO2O5.Dia; flip(FitO2O5.Dia)], [FitO2O5.Perc_oBA5_dia_errMIN; flip(FitO2O5.Perc_oBA5_dia_errMAX)],'r','FaceColor',[0.2 0.8 0.80],'FaceAlpha',0.3,'EdgeColor','none');
fill([FitO2O5.Dia; flip(FitO2O5.Dia)], [FitO2O5.Perc_oBA4_dia_errMIN; flip(FitO2O5.Perc_oBA4_dia_errMAX)],'r','FaceColor',[0.5 0.05 0.04],'FaceAlpha',0.3,'EdgeColor','none');
fill([FitO2O5.Dia; flip(FitO2O5.Dia)], [FitO2O5.Perc_altres_dia_errMIN; flip(FitO2O5.Perc_altres_dia_errMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
clear idxinici diffinici idxfinal difffinal

%Busco on començo o acabo de dibuixar la OBA5-OBQ per no trepitjar les altres
        diffinici = abs(FitO5OBQ.Dia(1) - ExpO5OBQ.Dia);
        [~, idxinici] = min(diffinici);    
        ExpO5OBQ(1:(idxinici-1),:) = [];   
errorbar(ExpO5OBQ.Dia,ExpO5OBQ.Perc_oBA5,ExpO5OBQ.Error_oBA5,ExpO5OBQ.Error_oBA5,'o','Color',[0.2 0.8 0.80])
errorbar(ExpO5OBQ.Dia,ExpO5OBQ.Perc_oBQ,ExpO5OBQ.Error_oBQ,ExpO5OBQ.Error_oBQ,'o','Color',[0.4 0.2 0.6])
errorbar(ExpO5OBQ.Dia,ExpO5OBQ.Perc_oBA4,ExpO5OBQ.Error_oBA4,ExpO5OBQ.Error_oBA4,'o','Color',[0.5 0.05 0.04])
errorbar(ExpO5OBQ.Dia,ExpO5OBQ.Perc_oBA2,ExpO5OBQ.Error_oBA2,ExpO5OBQ.Error_oBA2,'o','Color',[0.2 0.8 0.20])
errorbar(ExpO5OBQ.Dia,ExpO5OBQ.Perc_altres,ExpO5OBQ.Error_altres,ExpO5OBQ.Error_altres,'o','Color',[0.93 0.69 0.13])
plot(FitO5OBQ.Dia,FitO5OBQ.Perc_oBA5_dia,'Color',[0.2 0.8 0.80],'LineWidth',1.2)
plot(FitO5OBQ.Dia,FitO5OBQ.Perc_oBQ_dia,'Color',[0.4 0.2 0.6],'LineWidth',1.2)
plot(FitO5OBQ.Dia,FitO5OBQ.Perc_oBA4_dia,'Color',[0.5 0.05 0.04],'LineWidth',1.2)
plot(FitO5OBQ.Dia,FitO5OBQ.Perc_oBA2_dia,'Color',[0.2 0.8 0.20],'LineWidth',1.2)
plot(FitO5OBQ.Dia,FitO5OBQ.Perc_altres_dia,'Color',[0.93 0.69 0.13],'LineWidth',1.2)
fill([FitO5OBQ.Dia; flip(FitO5OBQ.Dia)], [FitO5OBQ.Perc_oBA5_dia_errMIN; flip(FitO5OBQ.Perc_oBA5_dia_errMAX)],'r','FaceColor',[0.2 0.8 0.80],'FaceAlpha',0.3,'EdgeColor','none');
fill([FitO5OBQ.Dia; flip(FitO5OBQ.Dia)], [FitO5OBQ.Perc_oBQ_dia_errMIN; flip(FitO5OBQ.Perc_oBQ_dia_errMAX)],'r','FaceColor',[0.4 0.2 0.6],'FaceAlpha',0.3,'EdgeColor','none');
fill([FitO5OBQ.Dia; flip(FitO5OBQ.Dia)], [FitO5OBQ.Perc_oBA4_dia_errMIN; flip(FitO5OBQ.Perc_oBA4_dia_errMAX)],'r','FaceColor',[0.5 0.05 0.04],'FaceAlpha',0.3,'EdgeColor','none');
fill([FitO5OBQ.Dia; flip(FitO5OBQ.Dia)], [FitO5OBQ.Perc_oBA2_dia_errMIN; flip(FitO5OBQ.Perc_oBA2_dia_errMAX)],'r','FaceColor',[0.2 0.8 0.20],'FaceAlpha',0.3,'EdgeColor','none');
fill([FitO5OBQ.Dia; flip(FitO5OBQ.Dia)], [FitO5OBQ.Perc_altres_dia_errMIN; flip(FitO5OBQ.Perc_altres_dia_errMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
clear idxinici diffinici

yline(5,'--'); 
hold off

xlim ([ GisaidAllCV.DijousOK(35) GisaidAllCV.DijousOK(end-10)  ])
xticklabels(fig2,{})
ylim([0 100]);
ylabel({'Percentage and', 'Substitution Processes'}, 'Color', 'k','FontSize', 14);
yticks(0:20:100);
yticklabels({'','20%','40%','60%','80%'});

    % Figura final de nombre de casos  i Rt per tots els paisos
    fig3 = nexttile;
opts = spreadsheetImportOptions("NumVariables", 3);
opts.Sheet = Country;
opts.DataRange = "A2:C174";
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
idxDeltaBA1STRT = find(Cases_Death_gisaid.DijousOK == ExpDeltaOBA1.Dia(1));
idxDeltaBA1END = find(Cases_Death_gisaid.DijousOK == ExpDeltaOBA1.Dia(end));
idxBA1BA2STRT = find(Cases_Death_gisaid.DijousOK == ExpO1O2.Dia(1));
idxBA1BA2END = find(Cases_Death_gisaid.DijousOK == ExpO1O2.Dia(end));
idxBA2BA5STRT = find(Cases_Death_gisaid.DijousOK == ExpO2O5.Dia(1));
idxBA2BA5END = find(Cases_Death_gisaid.DijousOK == ExpO2O5.Dia(end));
idxBA5BQSTRT = find(Cases_Death_gisaid.DijousOK == ExpO5OBQ.Dia(1));
idxBA5BQEND = find(Cases_Death_gisaid.DijousOK == ExpO5OBQ.Dia(end));

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
RtOBA120 = mean(Rtoutput.Rt((find(Rtoutput.Date == DayOBA120)):(find(Rtoutput.Date == DayOBA140))));
RtOBA160 = mean(Rtoutput.Rt((find(Rtoutput.Date == DayOBA160)):(find(Rtoutput.Date == DayOBA180))));
RtOBA220 = mean(Rtoutput.Rt((find(Rtoutput.Date == DayOBA220)):(find(Rtoutput.Date == DayOBA240))));
RtOBA260 = mean(Rtoutput.Rt((find(Rtoutput.Date == DayOBA260)):(find(Rtoutput.Date == DayOBA280))));
RtOBA520 = mean(Rtoutput.Rt((find(Rtoutput.Date == DayOBA520)):(find(Rtoutput.Date == DayOBA540))));
RtOBA560 = mean(Rtoutput.Rt((find(Rtoutput.Date == DayOBA560)):(find(Rtoutput.Date == DayOBA580))));
RtOBQ20 = 0;
RtOBQ60 = 0;

    Rt20 = [RtAlpha20, RtDelta20, RtOBA120, RtOBA220, RtOBA520, RtOBQ20]'; 
    Rt60 = [RtAlpha60, RtDelta60, RtOBA160, RtOBA260, RtOBA560, RtOBQ60]';

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

bar(Cases_Death_gisaid.DijousOK(idxDeltaBA1STRT:idxDeltaBA1END),(ExpDeltaOBA1.Perc_delta/100).*(Cases_Death_gisaid.cases(idxDeltaBA1STRT:idxDeltaBA1END)),'FaceColor',[0.85 0.33 0.10],'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.7);
bar(Cases_Death_gisaid.DijousOK(idxDeltaBA1STRT:idxDeltaBA1END),(ExpDeltaOBA1.Perc_OBA1/100).*(Cases_Death_gisaid.cases(idxDeltaBA1STRT:idxDeltaBA1END)),'FaceColor',[0.85 0. 0.70],'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.4);
bar(Cases_Death_gisaid.DijousOK(idxDeltaBA1STRT:idxDeltaBA1END),(ExpDeltaOBA1.Perc_altres/100).*(Cases_Death_gisaid.cases(idxDeltaBA1STRT:idxDeltaBA1END)),'FaceColor',[0.93 0.69 0.13],'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.9);

bar(Cases_Death_gisaid.DijousOK(idxBA1BA2STRT:idxBA1BA2END),(ExpO1O2.Perc_oBA1/100).*(Cases_Death_gisaid.cases(idxBA1BA2STRT:idxBA1BA2END)),'FaceColor',[0.85 0. 0.70],'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.4);
bar(Cases_Death_gisaid.DijousOK(idxBA1BA2STRT:idxBA1BA2END),(ExpO1O2.Perc_oBA2/100).*(Cases_Death_gisaid.cases(idxBA1BA2STRT:idxBA1BA2END)),'FaceColor',[0.2 0.8 0.20],'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.3);
bar(Cases_Death_gisaid.DijousOK(idxBA1BA2STRT:idxBA1BA2END),(ExpO1O2.Perc_altres/100).*(Cases_Death_gisaid.cases(idxBA1BA2STRT:idxBA1BA2END)),'FaceColor',[0.93 0.69 0.13],'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.9);

bar(Cases_Death_gisaid.DijousOK(idxBA2BA5STRT:idxBA2BA5END),(ExpO2O5.Perc_oBA2/100).*(Cases_Death_gisaid.cases(idxBA2BA5STRT:idxBA2BA5END)),'FaceColor',[0.2 0.8 0.20],'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.3);
bar(Cases_Death_gisaid.DijousOK(idxBA2BA5STRT:idxBA2BA5END),(ExpO2O5.Perc_oBA5/100).*(Cases_Death_gisaid.cases(idxBA2BA5STRT:idxBA2BA5END)),'FaceColor',[0.2 0.8 0.80],'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.5);
bar(Cases_Death_gisaid.DijousOK(idxBA2BA5STRT:idxBA2BA5END),(ExpO2O5.Perc_oBA4/100).*(Cases_Death_gisaid.cases(idxBA2BA5STRT:idxBA2BA5END)),'FaceColor',[0.5 0.05 0.04],'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.8);
bar(Cases_Death_gisaid.DijousOK(idxBA2BA5STRT:idxBA2BA5END),(ExpO2O5.Perc_altres/100).*(Cases_Death_gisaid.cases(idxBA2BA5STRT:idxBA2BA5END)),'FaceColor',[0.93 0.69 0.13],'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.9);

bar(Cases_Death_gisaid.DijousOK(idxBA5BQSTRT:idxBA5BQEND),(ExpO5OBQ.Perc_oBA5/100).*(Cases_Death_gisaid.cases(idxBA5BQSTRT:idxBA5BQEND)),'FaceColor',[0.2 0.8 0.80],'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.5);
bar(Cases_Death_gisaid.DijousOK(idxBA5BQSTRT:idxBA5BQEND),(ExpO5OBQ.Perc_oBQ/100).*(Cases_Death_gisaid.cases(idxBA5BQSTRT:idxBA5BQEND)),'FaceColor',[0.4 0.2 0.6],'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.7);
bar(Cases_Death_gisaid.DijousOK(idxBA5BQSTRT:idxBA5BQEND),(ExpO5OBQ.Perc_oBA2/100).*(Cases_Death_gisaid.cases(idxBA5BQSTRT:idxBA5BQEND)),'FaceColor',[0.2 0.8 0.20],'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.3);
bar(Cases_Death_gisaid.DijousOK(idxBA5BQSTRT:idxBA5BQEND),(ExpO5OBQ.Perc_oBA4/100).*(Cases_Death_gisaid.cases(idxBA5BQSTRT:idxBA5BQEND)),'FaceColor',[0.5 0.05 0.04],'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.4);
bar(Cases_Death_gisaid.DijousOK(idxBA5BQSTRT:idxBA5BQEND),(ExpO5OBQ.Perc_altres/100).*(Cases_Death_gisaid.cases(idxBA5BQSTRT:idxBA5BQEND)),'FaceColor',[0.93 0.69 0.13],'EdgeColor',[0.0 0.0 0.0],'FaceAlpha',0.9);
hold off

ylabel('Weekly cases [x10^6]','Color','k','FontSize', 14);
set(gca, 'Color','w', 'XColor','k', 'YColor','k')
yticks(0:2000000:10000000);
% yticklabels({'0', '0.5', '1', '1.5','2','2.5','3'});
yticklabels({'0','2','4','6','8','10'});
xlim ([ GisaidAllCV.DijousOK(35) GisaidAllCV.DijousOK(end-10)  ])

yyaxis right
plot(Rtoutput.Date,Rtoutput.Rt,'Color',[0.9 0.1 0.1],'LineWidth',1.2)
yline(1,'-','Color','r');
set(gca,'YColor','r')

ylabel('Effective reproduction number', 'FontSize', 14);
lgd = legend('pre-Alpha','Alpha','','','Delta','Gamma','Beta','','','BA1','','','BA2','','','','BA4','','BA5','BQ','','','Others','Rt','Location','north','Orientation','horizontal');
lgd.FontSize = 12;
xlim ([ GisaidAllCV.DijousOK(35) GisaidAllCV.DijousOK(end-10)  ])

fig1.XAxis.TickLabelFormat = 'MMM yyyy';
fig1.XAxis.TickValues = iniciimg:calmonths(2):finalimg;
fig2.XAxis.TickLabelFormat = 'MMM yyyy';
fig2.XAxis.TickValues = iniciimg:calmonths(2):finalimg;
fig3.XAxis.TickLabelFormat = 'MMM yyyy';
fig3.XAxis.TickValues = iniciimg:calmonths(2):finalimg;
ax = gca;
ax.XAxis.FontSize = 14; 

set(gca, 'XTickLabel', get(gca, 'XTickLabel'), 'fontsize', 11)
saveas(fig,textCaption,'png');
saveas(fig, textCaption,'fig');

            %% Guardem totes les dades de Beta, R0 i dia inici substitució
% Carreguem les dades de població, superfície, etc.
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

if Country == "Europe"
    idxcountry = ismember(owidcoviddata.continent,Country);
else
    idxcountry = ismember(owidcoviddata.location,Country);
end
OWiDCountry = owidcoviddata(idxcountry,{'date', 'people_fully_vaccinated'});
for i = 2:length(OWiDCountry.people_fully_vaccinated)
    if OWiDCountry.people_fully_vaccinated(i) == 0
        OWiDCountry.people_fully_vaccinated(i) = OWiDCountry.people_fully_vaccinated(i-1);
    end
end

if Country == "Europe" %extrets directament de la web OWID, com la resta
    N_full_vacc_Alfa = 0;
    N_full_vacc_Delta = 64570000;
    N_full_vacc_BA1 = 291790000;
    N_full_vacc_BA2 = 309400000;
    N_full_vacc_BA5 = 326020000;
    N_full_vacc_BQ = 327260000;
else
    N_full_vacc_Alfa = OWiDCountry.people_fully_vaccinated(find(OWiDCountry.date == DayAlpha));
    N_full_vacc_Delta = OWiDCountry.people_fully_vaccinated(find(OWiDCountry.date == DayDelta));
    N_full_vacc_BA1 = OWiDCountry.people_fully_vaccinated(find(OWiDCountry.date == DayOBA1));
    N_full_vacc_BA2 = OWiDCountry.people_fully_vaccinated(find(OWiDCountry.date == DayOBA2));
    N_full_vacc_BA5 = OWiDCountry.people_fully_vaccinated(find(OWiDCountry.date == DayOBA5));
    N_full_vacc_BQ = OWiDCountry.people_fully_vaccinated(find(OWiDCountry.date == DayOBQ));
    if isempty(N_full_vacc_BQ)
        N_full_vacc_BQ = OWiDCountry.people_fully_vaccinated(end);
    end
end

N_full_vacc = [N_full_vacc_Alfa, N_full_vacc_Delta, N_full_vacc_BA1, N_full_vacc_BA2, N_full_vacc_BA5, N_full_vacc_BQ]';

    country_idx = find(strcmp(EUPopArea.Country, Country));
    population = repmat(EUPopArea.Pop21(country_idx),6,1);
    area = repmat(EUPopArea.Area(country_idx),6,1);
    gini = repmat(EUPopArea.GINI(country_idx),6,1);

DayFit = [DayAlpha, DayDelta, DayOBA1, DayOBA2, DayOBA5, DayOBQ]';
DayFit20 = [DayAlpha20, DayDelta20, DayOBA120, DayOBA220, DayOBA520, DayOBQ20]';
DayFit60 = [DayAlpha60, DayDelta60, DayOBA160, DayOBA260, DayOBA560, '01/01/2024']';
DayFitstring = datestr(DayFit); DayFitstring20 = datestr(DayFit20); DayFitstring60 = datestr(DayFit60);
CountryWave = [Country+" Alpha", Country+" Delta", Country+" OBA1", Country+" OBA2", Country+" OBA5", Country+" OBQ"];

TB = [BAlpha,BerrAlpha,R0Alpha,R0errAlpha; BDelta,BerrDelta,R0Delta,R0errDelta; BOBA1,BerrOBA1,R0OBA1,R0errOBA1;...
    BOBA2,BerrOBA2,R0OBA2,R0errOBA2; BOBA5,BerrOBA5,R0OBA5,R0errOBA5; BOBQ,BerrOBQ,R0OBQ,R0errOBQ];
T = array2table([CountryWave', DayFitstring, N_full_vacc, DayFitstring20, DayFitstring60, TB, Rt20, Rt60, population, area, gini], ...
    'VariableNames', {'Country_Subs','Start_Day','Vaccination','Fitting_Day_20','Fitting_Day_60', 'Beta', 'Error_Beta', 'R0', 'Error_R0','mean_Rt_20_40','mean_Rt_60_80','Population','Area','GINI'});
writetable(T, 'BetaR0_16pais_EU.xlsx', 'Sheet', Country)
end
    