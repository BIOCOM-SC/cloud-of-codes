%% A continuació hi ha el codi per fer TOTS els païssos de manera automàtica "arriscant" amb unes certes condicions que quedi bé a 1 output
clear all
close all
% Primer tenim la opció de probar només un país o fer-ho per tots:
Countries = "Espanya"; 
% Countries = ["Andalusia","Balears","Catalunya","Castilla_Leon","Madrid","Navarra_EH","Comunitat_Valenciana_Murcia","Espanya"];

for iii = 1:length(Countries)
    Country = Countries{iii};

opts = spreadsheetImportOptions("NumVariables", 16);
opts.Sheet = Country;
opts.DataRange = "A2:P21";
opts.VariableNames = ["Var1", "Var2", "Var3", "Var4", "Var5", "Var6", "Var7", "Var8", "Var9", "finalSetmana", "Alfa", "Beta", "Delta", "Gamma", "Altres", "Total1"];
opts.SelectedVariableNames = ["finalSetmana", "Alfa", "Beta", "Delta", "Gamma", "Altres", "Total1"];
opts.VariableTypes = ["char", "char", "char", "char", "char", "char", "char", "char", "char", "datetime", "double", "double", "double", "double", "double", "double"];
opts = setvaropts(opts, ["Var1", "Var2", "Var3", "Var4", "Var5", "Var6", "Var7", "Var8", "Var9"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Var1", "Var2", "Var3", "Var4", "Var5", "Var6", "Var7", "Var8", "Var9"], "EmptyFieldRule", "auto");
EspCCAA = readtable("D:\OneDrive - Universitat Politècnica de Catalunya\2023_01_Hist_variants_ESP_CCAA\Estudi Espanya.xlsx", opts, "UseExcel", false);
clear opts
EspCCAA.Dijous = EspCCAA.finalSetmana -3;

%Aquí tenim totes les variants que ens interesaran per fer les diferents
%substitucions
    N_Other = EspCCAA.Altres;
    N_Alpha = EspCCAA.Alfa; %VOC
    N_Beta = EspCCAA.Beta; %VOC
    N_Gamma = EspCCAA.Gamma; %VOC
    N_Delta = EspCCAA.Delta; %VOC 

        %% Substitution Alpha vs Delta
    N_Desc = N_Alpha;
    N_Asc1 = N_Delta;
    N_Asc2 = N_Gamma;
    N_Asc4 = N_Beta;
    N_Ctt = N_Other;
    WeekThurs = EspCCAA.Dijous;

    [BDelta,BerrDelta,R0Delta,R0errDelta,DayDelta,DayDelta20,DayDelta40,DayDelta60,DayDelta80] = FAlphaDelta(N_Desc, N_Asc1, N_Asc2, N_Asc4, N_Ctt,Country,WeekThurs);
    clear ini fin N_Desc N_Asc1 N_Asc2 N_Asc4 N_Ctt WeekThurs 
end