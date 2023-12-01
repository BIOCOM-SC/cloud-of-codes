%% A continuació hi ha el codi per fer TOTS els païssos de manera automàtica "arriscant" amb unes certes condicions que quedi bé a 1 output
clear all
close all
%Primer tenim la opció de probar només un país o fer-ho per tots:
Countries = "Poland";
% Tots els països, 28 en total (queden fora Liechtenstein i Malta):
% Countries = ["Austria","Belgium","Bulgaria","Croatia","Cyprus","Czechia","Denmark","Estonia","Finland","France","Germany","Greece","Hungary","Iceland","Ireland","Italy","Latvia","Lithuania","Luxembourg","Netherlands","Norway","Poland","Portugal","Romania","Slovakia","Slovenia","Spain","Sweden"];

% Països amb les 6 onades de variants ben diferenciades, 19!?!? GISAAID en total:
% Countries = ["Belgium","Croatia","Czechia","Denmark","Finland","France","Germany","Ireland","Italy",...
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

        %% Substitution OBA5 vs OBQ: 12 inputs
    ini = 135; fin = 169;
    N_Desc = N_OBA5(ini:fin);
    N_Asc1 = N_OBQ(ini:fin); 
    N_Asc2 = N_OXBB(ini:fin); 
    N_Ctt = N_OBA2(ini:fin)+N_OBA275(ini:fin);
    N_Asc4 = N_Altres(ini:fin) + N_Other(ini:fin) + N_Alpha(ini:fin) + N_Gamma(ini:fin) + N_Beta(ini:fin) +  ...
            N_Delta(ini:fin) + N_OBA1(ini:fin) + N_OBA4(ini:fin);
    WeekThurs = GisaidAllCV.DijousOK(ini:fin);

        [BOBQ,BerrOBQ,R0OBQ,R0errOBQ,DayOBQ,DayOBQ20] = FOBA5OBQXBBb(N_Desc, N_Asc1, N_Asc2, N_Asc4, N_Ctt, Country, WeekThurs);

    clear ini fin N_Desc N_Asc1 N_Asc2 N_Ctt WeekThurs

end
    