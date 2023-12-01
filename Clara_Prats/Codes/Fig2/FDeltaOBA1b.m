function     [BOBA1,BerrOBA1,R0OBA1,R0errOBA1,DayOBA1,DayOBA120,DayOBA140,DayOBA160,DayOBA180] = FDeltaOBA1b(N_Desc, N_Asc1, N_Ctt,Country,WeekThurs)

N_total = N_Desc + N_Asc1 + N_Ctt;

% Les normalitzem respecte a les 3 variants (o les que siguin) a estudiar
for i=1:length(N_total)
    if N_total(i)==0 
        N_total(i)=1;
    end
end

 Norm_Desc = 100*N_Desc ./ N_total;
Norm_Asc1 = 100*N_Asc1 ./ N_total;
Norm_Ctt = 100*N_Ctt ./ N_total;

% Trobem els errors "binaris" (o tinc la variant o NO la tinc) de les
% nostres dades experimentals
Desc_int = 100*sqrt(N_total .* (N_Desc ./ N_total) .* (1-(N_Desc ./ N_total))) ./ N_total;
Asc1_int = 100*sqrt(N_total .* (N_Asc1 ./ N_total) .* (1-(N_Asc1 ./ N_total))) ./ N_total;
Ctt_int = 100*sqrt(N_total .* (N_Ctt ./ N_total) .* (1-(N_Ctt ./ N_total))) ./ N_total;

% Definim intervals de temps ja que voldrem un estudiu diari!
Duration = length(WeekThurs)-1;
Duration_days=Duration*7; 

startDay = min(WeekThurs); 
%finishDay = startDay+Duration_days;

tstart = datetime(startDay,'InputFormat','dd/MM/yyyy');
tend = tstart+Duration_days;

% Això serà un dijous, que és on dibuixem al BIOCOM les dades setmanals
Day_plot=tstart:7:tend; 
n=1;
princ2 = 0;
princ1 = find(Norm_Asc1>1,1);
% Preparem on comencem el fitting, perquè sigui automàtic
        while princ2 == 0
        princ2 = Norm_Asc1(princ1)>1 && Norm_Asc1(princ1+1)>3; % && Norm_Asc1(princ1)<Norm_Asc1(princ1+1), && Norm_Asc1(princ1)<Norm_Asc1(princ1+2);
        princ1 = princ1+1;
        end
        principi = princ1-5; %recuperem l'ultim valor que hem analitzat
        if principi == 0
            principi = 1;
        end
        if Country == "Denmark" 
            principi = principi -5;
        elseif Country=="Slovenia" ||Country=="Estonia" || Country == "Iceland" || Country == "Ireland"
            principi = principi - 2;
        elseif Country == "Finland" || Country =="Netherlands"
            principi = principi + 3;
        elseif Country == "Austria"
            principi = principi + 2;
        end

% i on l'acabem!!
final2 = 0;
final1 = find(Norm_Asc1>90,1);
% Preparem on comencem el fitting, perquè sigui automàtic
        try
        while final2 == 0
        final2 = (Norm_Asc1(final1)>90 && Norm_Asc1(final1)>Norm_Asc1(final1+1) && Norm_Asc1(final1+1)>90) || (Norm_Asc1(final1)>95 && Norm_Asc1(final1+1)>96);
        final1 = final1+1;
        end
        final = final1 + 2; % 2 recuperem l'ultim valor que hem analitzat  
        catch
                final = find(Norm_Asc1 == max(Norm_Asc1),1);
        end
        if Country == "Iceland"
            final = final - 6;
        elseif Country == "Ireland"
            final = final - 3;
        elseif (Country == "Austria")
            final = final + 1;
        elseif Country == "Cyprus"
            final = final + 1;
        elseif (Country == "Belgium" || Country=="Romania" || Country == "Spain")
            final = final - 1;
        elseif Country=="Estonia"
            final = final +1;
        elseif Country=="Latvia"
            final = final + 1;
        elseif Country == "Croatia"
            final = final -3;
        elseif Country == "Finland" || Country == "France" || Country == "Italy" || Country == "Netherlands"
            final = final -3;
        elseif Country =="Slovenia"
            final = final - 2;
        end
% Els paràmetres Beta i R0 necessiten un valor inicial que després s'anirà
% ajustant:
aa=0.9;ab=1.1;ac=0.01;ad=0.2;

    for ID_fitting = (principi):1:final  
        if (n<2)
Fitting_date=Day_plot(ID_fitting:final);
t=1:length(Fitting_date)';
Fit_Desc = Norm_Desc(ID_fitting:final)/100;
Fit_Asc1 = Norm_Asc1(ID_fitting:final)/100;
Fit_Ctt = Norm_Ctt(ID_fitting:final)/100;

global_fit_data = [Fit_Asc1;Fit_Ctt]'; 
global_fit_function = @(params,t) [params(3)*exp(params(1)*t)./(1+params(3)*exp(params(1)*t)+params(4)*exp(params(2)*t)),...
    params(4)*exp(params(2)*t)./(1+params(3)*exp(params(1)*t)+params(4)*exp(params(2)*t))]; % Fitting functions
%estimem els parametres que utilitzarem
squared_errors = @(params) norm(global_fit_data - global_fit_function(params,t));
options=optimset('MaxFunEvals', 10000000, 'MaxIter',10000000, 'Display', 'final', 'TolX', 1e-0012);
fit = fminsearch(squared_errors,[aa ab ac ad],options); % BetaBA4, BetaBA5; Ratio_ini_BA4, Ratio_ini_BA5

                if (fit(3) > 0.001 && fit(1)>fit(2) && fit(2) > 0)
    n=n+1;

% Pasem de setmanes a dies i mirem pre i post dades
                t_plot=(1-2/7):1/7:(length(t)+2/7);
% Trobem els paràmetres inicials
[paramfit,Resid,Jacob,CovB,~,~] = nlinfit(t,global_fit_data,global_fit_function,[fit(1) fit(2) fit(3) fit(4)]);
[Ypercen,YCI] = nlpredci(global_fit_function,t_plot,paramfit,Resid,'Covar',CovB);
                Ypercen(Ypercen<0)=0;

conf1 = nlparci(paramfit,Resid,'jacobian',Jacob);
conf2 = nlparci(paramfit,Resid,'covariance',CovB);
% De manera automàtica el programa agafarà els paràmetres fitejats anteriorment com punt de partida
aa=fit(1);ab=fit(2);ac=fit(3);ad=fit(4);
    close
% Les normalitzem respecte a les 3 variants a estudiar
Fitplot_Asc1no = 100*Ypercen(1:length(t_plot));
Fitplot_Cttno = 100*Ypercen((length(t_plot)+1):end);
Fitplot_Descno = 100 - Fitplot_Asc1no - Fitplot_Cttno;
Fitplot_total = Fitplot_Asc1no + Fitplot_Cttno + Fitplot_Descno;
Fitplot_Asc1 = 100*Fitplot_Asc1no./Fitplot_total;
Fitplot_Ctt = 100*Fitplot_Cttno./Fitplot_total;
Fitplot_Desc = 100*Fitplot_Descno./Fitplot_total;

% Trobem els errors
Fitplot_Asc1MAX = Fitplot_Asc1+100*YCI(1:length(t_plot));
Fitplot_Asc1MIN = Fitplot_Asc1-100*YCI(1:length(t_plot));
Fitplot_CttMAX = Fitplot_Ctt+100*YCI((length(t_plot)+1):end);
Fitplot_CttMIN = Fitplot_Ctt-100*YCI((length(t_plot)+1):end);
Fitplot_DescMAX = Fitplot_Desc + 100*sqrt(YCI(1:length(t_plot)).^2 + YCI((length(t_plot)+1):end).^2);
Fitplot_DescMIN = Fitplot_Desc - 100*sqrt(YCI(1:length(t_plot)).^2 + YCI((length(t_plot)+1):end).^2);

% A continuació hi ha unes linies per calcular el RMSE de manera manual,
% que segurament es podria reduir alguna funció de MatLab, però ho vaig fer
% al principi (octubre 2022) i funcionava bé
for tt = 1:length(t)
    tajust = tt*7-6;
    Fitajust_Asc1 (tt) = Fitplot_Asc1(tajust);
    ttt = ID_fitting+tt-1;
    Norm_Asc1RMSE (tt)= Norm_Asc1(ttt);
end
[h,p] = ttest2(Norm_Asc1RMSE,Fitajust_Asc1); %H0
RMSE = sqrt(mean((Norm_Asc1RMSE - Fitajust_Asc1).^2)); % Compute RMSE

%Sortides de variables a un excel
T = table(Fitting_date(1), paramfit(1), abs(conf1(1,1)-paramfit(1)), paramfit(3), abs(conf1(3,1)-paramfit(3)),...
    paramfit(2), abs(conf1(2,1)-paramfit(2)), paramfit(4), abs(conf1(4,1)-paramfit(4)), p, RMSE,...
    'VariableNames',['Inici Fit',"Beta_OBA1","error_B_OBA1","R0_OBA1","error_R0_OBA1","Beta_Altres","error_B_Altres","R0_Altres","error_R0_Altres","p-value","RMSE"])
Tname = ".\Variables_hist_variants_OBA1\BetaR0_DeltaVSOBA1_altres"+Country+".xlsx";
NameSheet = "Full ID " + ID_fitting;
writetable(T,Tname,"Sheet",NameSheet);

% Sortida de dades experimentals de SIVIC normalitzades segons variants i
% agrupades les "no importants" a Altres
PlotSeqVar_delta_OBA1 = table(Day_plot', Norm_Desc, Desc_int, Norm_Asc1, Asc1_int, Norm_Ctt, Ctt_int);
PlotSeqVar_delta_OBA1.Properties.VariableNames = ['Dia',"Perc_delta",'Error_delta',"Perc_OBA1",'Error_OBA1',"Perc_altres","Error_altres"];
Plotname = ".\DadesCSV_hist_variants_OBA1\Plot_SeqVar_delta_OBA1_altres" + Country + ".csv";
writetable(PlotSeqVar_delta_OBA1,Plotname)

% Preparem la figura: dades SIVIC, observacions ("reals")
figure
errorbar(Day_plot,Norm_Desc,Desc_int,Desc_int,'o','Color',[0.85 0.33 0.10])
hold on
errorbar(Day_plot,Norm_Asc1,Asc1_int,Asc1_int,'o','Color',[0.85 0. 0.70])
errorbar(Day_plot,Norm_Ctt,Ctt_int,Ctt_int,'o','Color',[0.93 0.69 0.13])

% Definim l'escala del plot perquè després queda massa gran amb el FIT
tstart_plot = datetime(tstart,'InputFormat','dd/MM/yyyy');
tend_plot = datetime(tend,'InputFormat','dd/MM/yyyy');
xlim([tstart_plot tend_plot]);
ylim([0 100]);
%Finalment afegim a la imatge els fits
                    Fitting_date_plot=(Fitting_date(1)-2):(Fitting_date(1)+length(t_plot)-3);
plot(Fitting_date_plot,Fitplot_Desc,'-','Color',[0.85 0.33 0.10])
plot(Fitting_date_plot,Fitplot_Asc1,'-','Color',[0.85 0. 0.7])
plot(Fitting_date_plot,Fitplot_Ctt,'-','Color',[0.93 0.69 0.13])

fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_DescMIN flip(Fitplot_DescMAX)],'r','FaceColor',[0.85 0.33 0.10],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc1MIN flip(Fitplot_Asc1MAX)],'r','FaceColor',[0.85 0. 0.70],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_CttMIN flip(Fitplot_CttMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
yline(5,'--'); 

Fit_delta_OBA1 = table(Fitting_date_plot', Fitplot_Desc',Fitplot_DescMAX',Fitplot_DescMIN', Fitplot_Asc1',Fitplot_Asc1MAX',Fitplot_Asc1MIN',Fitplot_Ctt',Fitplot_CttMAX',Fitplot_CttMIN');
Fit_delta_OBA1.Properties.VariableNames = ['Dia',"Perc_delta_dia","Perc_delta_dia_errMAX","Perc_delta_dia_errMIN","Perc_OBA1_dia","Perc_OBA1_dia_errMAX","Perc_OBA1_dia_errMIN","Perc_altres_dia","Perc_altres_dia_errMAX","Perc_altres_dia_errMIN"];
Fitname = ".\DadesCSV_hist_variants_OBA1\Fit_SeqVar_delta_OBA1_altres"+Country+".csv";
writetable(Fit_delta_OBA1,Fitname)

textCaption = ".\Figures_hist_variants_OBA1\" + Country + " Delta VS OBA1 + Altres " + ID_fitting;
lgd = legend ('Delta','OBA1','Others','Model Delta','Model OBA1','Model Others','Location','best');
lgd.FontSize = 7;
title(Country + " Delta VS OBA1")
xlim([Day_plot(ID_fitting)-1 Day_plot(final)+1]);
print(textCaption,'-dpng','-r300')
close

                elseif ((fit(3) > 0.001 && fit(1)<fit(2)) || (fit(3) > 0.001 && fit(2) < 0))
                disp("*********************is working!!****************")
                    global_fit_data = [Fit_Asc1;Fit_Ctt]'; 
global_fit_function = @(params,t) [params(3)*exp(params(1)*t)./(1+params(3)*exp(params(1)*t)),...
    (params(4))+(params(2)*t)]; % Fitting functions
%estimem els parametres que utilitzarem
squared_errors = @(params) norm(global_fit_data - global_fit_function(params,t));
options=optimset('MaxFunEvals', 10000000, 'MaxIter',10000000, 'Display', 'final', 'TolX', 1e-0012);
fit = fminsearch(squared_errors,[aa ab ac ad],options); % BetaBA4, BetaBA5; Ratio_ini_BA4, Ratio_ini_BA5
% Pasem de setmanes a dies, he tret el 7* que la Clara multiplicava al length ja que anava MASSA al futur
                t_plot=(1-2/7):1/7:(length(t)+2/7);
% això (desde 1) es per fer tot el càlcul...amb el 0 és per les imatges.
[paramfit,Resid,Jacob,CovB,MSE,ErrorModelInfo] = nlinfit(t,global_fit_data,global_fit_function,[fit(1) fit(2) fit(3) fit(4)]);
[Ypercen,YCI] = nlpredci(global_fit_function,t_plot,paramfit,Resid,'Covar',CovB);
                        Ypercen(Ypercen<0)=0;
paramfit;
conf1 = nlparci(paramfit,Resid,'jacobian',Jacob);
conf2 = nlparci(paramfit,Resid,'covariance',CovB);
% De manera automàtica el programa agafarà els paràmetres fitejats anteriorment com punt de partida
aa=fit(1);ab=fit(2);ac=fit(3);ad=fit(4);
n=n+1;
    close
% Les normalitzem respecte a les 3 variants a estudiar
Fitplot_Asc1no = 100*Ypercen(1:length(t_plot));
Fitplot_Cttno = 100*Ypercen((length(t_plot)+1):end);
Fitplot_Descno = 100 - Fitplot_Asc1no;
Fitplot_total = Fitplot_Asc1no + Fitplot_Cttno + Fitplot_Descno;
Fitplot_Asc1 = 100*Fitplot_Asc1no./Fitplot_total;
Fitplot_Ctt = 100*Fitplot_Cttno./Fitplot_total;
Fitplot_Desc = 100*Fitplot_Descno./Fitplot_total;

% Trobem els errors
Fitplot_Asc1MAX = Fitplot_Asc1+100*YCI(1:length(t_plot));
Fitplot_Asc1MIN = Fitplot_Asc1-100*YCI(1:length(t_plot));
Fitplot_CttMAX = Fitplot_Ctt+100*YCI((length(t_plot)+1):end);
Fitplot_CttMIN = Fitplot_Ctt-100*YCI((length(t_plot)+1):end);
Fitplot_DescMAX = Fitplot_Desc + 100*sqrt(YCI(1:length(t_plot)).^2);
Fitplot_DescMIN = Fitplot_Desc - 100*sqrt(YCI(1:length(t_plot)).^2);

% A continuació hi ha unes linies per calcular el RMSE de manera manual,
% que segurament es podria reduir alguna funció de MatLab, però ho vaig fer
% al principi (octubre 2022) i funcionava bé
for tt = 1:length(t)
    tajust = tt*7-6;
    Fitajust_Asc1 (tt) = Fitplot_Asc1(tajust);
    ttt = ID_fitting+tt-1;
    Norm_Asc1RMSE (tt)= Norm_Asc1(ttt);
end
[h,p] = ttest2(Norm_Asc1RMSE,Fitajust_Asc1); %H0
RMSE = sqrt(mean((Norm_Asc1RMSE - Fitajust_Asc1).^2)); % Compute RMSE

%Sortides de variables a un excel
T = table(Fitting_date(1), paramfit(1), abs(conf1(1,1)-paramfit(1)), paramfit(3), abs(conf1(3,1)-paramfit(3)),p, RMSE,...
    'VariableNames',['Inici Fit',"Beta_OBA1","error_B_OBA1","R0_OBA1","error_R0_OBA1","p-value","RMSE"])
Tname = ".\Variables_hist_variants_OBA1\BetaR0_DeltaVSOBA1_altres"+Country+".xlsx";
NameSheet = "Full ID " + ID_fitting;
writetable(T,Tname,"Sheet",NameSheet);

% Sortida de dades experimentals de SIVIC normalitzades segons variants i
% agrupades les "no importants" a Altres
PlotSeqVar_delta_OBA1 = table(Day_plot', Norm_Desc, Desc_int, Norm_Asc1, Asc1_int, Norm_Ctt, Ctt_int);
PlotSeqVar_delta_OBA1.Properties.VariableNames = ['Dia',"Perc_delta",'Error_delta',"Perc_OBA1",'Error_OBA1',"Perc_altres","Error_altres"];
Plotname = ".\DadesCSV_hist_variants_OBA1\Plot_SeqVar_delta_OBA1_altres" + Country + ".csv";
writetable(PlotSeqVar_delta_OBA1,Plotname)

% Preparem la figura: dades SIVIC, observacions ("reals")
figure
errorbar(Day_plot,Norm_Desc,Desc_int,Desc_int,'o','Color',[0.85 0.33 0.1])
hold on
errorbar(Day_plot,Norm_Asc1,Asc1_int,Asc1_int,'o','Color',[0.85 0. 0.70])
errorbar(Day_plot,Norm_Ctt,Ctt_int,Ctt_int,'o','Color',[0.93 0.69 0.13])

% Definim l'escala del plot perquè després queda massa gran amb el FIT
tstart_plot = datetime(tstart,'InputFormat','dd/MM/yyyy');
tend_plot = datetime(tend,'InputFormat','dd/MM/yyyy');
xlim([tstart_plot tend_plot]);
ylim([0 100]);
%Finalment afegim a la imatge els fits
                    Fitting_date_plot=(Fitting_date(1)-2):(Fitting_date(1)+length(t_plot)-3);
plot(Fitting_date_plot,Fitplot_Desc,'-','Color',[0.85 0.33 0.1])
plot(Fitting_date_plot,Fitplot_Asc1,'-','Color',[0.85 0. 0.70])
plot(Fitting_date_plot,Fitplot_Ctt,'-','Color',[0.93 0.69 0.13])

fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_DescMIN flip(Fitplot_DescMAX)],'r','FaceColor',[0.85 0.33 0.1],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc1MIN flip(Fitplot_Asc1MAX)],'r','FaceColor',[0.85 0. 0.70],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_CttMIN flip(Fitplot_CttMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
yline(5,'--'); 

Fit_delta_OBA1 = table(Fitting_date_plot', Fitplot_Desc',Fitplot_DescMAX',Fitplot_DescMIN', Fitplot_Asc1',Fitplot_Asc1MAX',Fitplot_Asc1MIN',Fitplot_Ctt',Fitplot_CttMAX',Fitplot_CttMIN');
Fit_delta_OBA1.Properties.VariableNames = ['Dia',"Perc_delta_dia","Perc_delta_dia_errMAX","Perc_delta_dia_errMIN","Perc_OBA1_dia","Perc_OBA1_dia_errMAX","Perc_OBA1_dia_errMIN","Perc_altres_dia","Perc_altres_dia_errMAX","Perc_altres_dia_errMIN"];
Fitname = ".\DadesCSV_hist_variants_OBA1\Fit_SeqVar_delta_OBA1_altres"+Country+".csv";
writetable(Fit_delta_OBA1,Fitname)

textCaption = ".\Figures_hist_variants_OBA1\" + Country + " Delta VS OBA1 + Altres " + ID_fitting;
lgd = legend ('Delta','OBA1','Others','Model Delta','Model OBA1','Linear Others','Location','best');
lgd.FontSize = 7;
title(Country + " Delta VS OBA1")
xlim([Day_plot(ID_fitting)-1 Day_plot(final)+1]);
 print(textCaption,'-dpng','-r300')
close

                else
                                       n;
                end %aquí acaba les imatges i/o càlculs... el segon "if"
        else 
            n;
        end %aquí acabarà el programa quan n=>4

    end %aquí acaba el primer "if" el de fer només 3 pasos
    BOBA1=paramfit(1); BerrOBA1=abs(conf1(1,1)-paramfit(1)); R0OBA1=paramfit(3); R0errOBA1=abs(conf1(3,1)-paramfit(3));
    DayOBA1 = Fitting_date_plot(find(Fitplot_Asc1 > 5,1));
        DayOBA120 = Fitting_date_plot(find(Fitplot_Asc1 > 20,1));
        DayOBA140 = Fitting_date_plot(find(Fitplot_Asc1 > 40,1));
    DayOBA160 = Fitting_date_plot(find(Fitplot_Asc1 > 60,1));
        DayOBA180 = Fitting_date_plot(find(Fitplot_Asc1 > 80,1));
end %aquí acaba per tots els països