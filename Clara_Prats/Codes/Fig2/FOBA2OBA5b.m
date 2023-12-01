function     [BOBA5,BerrOBA5,R0OBA5,R0errOBA5,DayOBA5,DayOBA520,DayOBA540,DayOBA560,DayOBA580] = FOBA2OBA5b(N_Desc, N_Asc1, N_Asc2, N_Ctt, Country, WeekThurs)

N_total = N_Desc + N_Asc1 + N_Asc2 + N_Ctt;

% Les normalitzem respecte a les 3 variants (o les que siguin) a estudiar
for i=1:length(N_total)
    if N_total(i)==0 
        N_total(i)=1;
    end
end

Norm_Desc = 100*N_Desc ./ N_total;
Norm_Asc1 = 100*N_Asc1 ./ N_total;
Norm_Asc2 = 100*N_Asc2 ./ N_total;
Norm_Ctt = 100*N_Ctt ./ N_total;

% Trobem els errors "binaris" (o tinc la variant o NO la tinc) de les
% nostres dades experimentals
Desc_int = 100*sqrt(N_total .* (N_Desc ./ N_total) .* (1-(N_Desc ./ N_total))) ./ N_total;
Asc1_int = 100*sqrt(N_total .* (N_Asc1 ./ N_total) .* (1-(N_Asc1 ./ N_total))) ./ N_total;
Asc2_int = 100*sqrt(N_total .* (N_Asc2 ./ N_total) .* (1-(N_Asc2 ./ N_total))) ./ N_total;
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
        princ2 = Norm_Asc1(princ1)>2 && Norm_Asc1(princ1)<Norm_Asc1(princ1+1) && Norm_Asc1(princ1)<Norm_Asc1(princ1+2);
        princ1 = princ1+1;
        end
        if (Country == "Spain")
            principi = princ1 - 1;
        elseif Country=="Poland" || Country == "Slovenia" || Country =="Europe"
            principi = princ1-3;
        else
            principi = princ1-2; %recuperem l'ultim valor que hem analitzat
        end
% i on l'acabem!!
final2 = 0;
final1 = find(Norm_Asc1>70,1);
% Preparem on comencem el fitting, perquè sigui automàtic
        try
            while final2 == 0
            final2 = Norm_Asc1(final1)>80 && Norm_Asc1(final1)>Norm_Asc1(final1+1) && Norm_Asc1(final1+1)>80;
            final1 = final1+1;
            end
        final = final1-1; %recuperem l'ultim valor que hem analitzat  
        catch
                final = find(Norm_Asc1 == max(Norm_Asc1),1);
        end
        if Country =="Norway" || Country == "Romania" || Country =="Spain"
            final = final +2;
        end
% Els paràmetres Beta i R0 necessiten un valor inicial que després s'anirà
% ajustant:
aa=0.7; ab=0.5; ac=0.2; ad=0.01; ae=0.01; af=0.01;

    for ID_fitting = (principi):1:final  

        if (n<2)
Fitting_date=Day_plot(ID_fitting:final);
t=1:length(Fitting_date)';
Fit_Desc = Norm_Desc(ID_fitting:final)/100;
Fit_Asc1 = Norm_Asc1(ID_fitting:final)/100;
Fit_Asc2 = Norm_Asc2(ID_fitting:final)/100;
Fit_Ctt = Norm_Ctt(ID_fitting:final)/100;

global_fit_data = [Fit_Asc1;Fit_Asc2;Fit_Ctt]'; 
global_fit_function = @(params,t) [params(4)*exp(params(1)*t)./(1+params(4)*exp(params(1)*t)+params(5)*exp(params(2)*t)+params(6)*exp(params(3)*t)),...
    params(5)*exp(params(2)*t)./(1+params(4)*exp(params(1)*t)+params(5)*exp(params(2)*t)+params(6)*exp(params(3)*t)),...
    params(6)*exp(params(3)*t)./(1+params(4)*exp(params(1)*t)+params(5)*exp(params(2)*t)+params(6)*exp(params(3)*t))]; % Fitting functions
%estimem els parametres que utilitzarem
squared_errors = @(params) norm(global_fit_data - global_fit_function(params,t));
options=optimset('MaxFunEvals', 10000000, 'MaxIter',10000000, 'Display', 'final', 'TolX', 1e-0012);
fit = fminsearch(squared_errors,[aa ab ac ad ae af],options); % BetaBA4, BetaBA5; Ratio_ini_BA4, Ratio_ini_BA5
                if (fit(4) > 0.005 && fit(1)>fit(2) && fit(1)>fit(3) && fit(2)>0 && fit(3)>0)
    n=n+1;
    close

    % Pasem de setmanes a dies, he tret el 7* que la Clara multiplicava al length ja que anava MASSA al futur
                t_plot=(1-2/7):1/7:(length(t)+2/7);
% això (desde 1) es per fer tot el càlcul...amb el 0 és per les imatges.
[paramfit,Resid,Jacob,CovB,MSE,ErrorModelInfo] = nlinfit(t,global_fit_data,global_fit_function,[fit(1) fit(2) fit(3) fit(4) fit(5) fit(6)]);
[Ypercen,YCI] = nlpredci(global_fit_function,t_plot,paramfit,Resid,'Covar',CovB);
                        Ypercen(Ypercen<0)=0;
paramfit;
conf1 = nlparci(paramfit,Resid,'jacobian',Jacob);
conf2 = nlparci(paramfit,Resid,'covariance',CovB);
% De manera automàtica el programa agafarà els paràmetres fitejats anteriorment com punt de partida
aa=fit(1);ab=fit(2);ac=fit(3);ad=fit(4);ae=fit(5);af=fit(6);

% Les normalitzem respecte a les 3 variants a estudiar
Fitplot_Asc1no = 100*Ypercen(1:length(t_plot));
Fitplot_Asc2no = 100*Ypercen((length(t_plot)+1):(2*length(t_plot)));
Fitplot_Cttno = 100*Ypercen((2*length(t_plot)+1):end);
Fitplot_Descno = 100 - Fitplot_Asc1no - Fitplot_Asc2no - Fitplot_Cttno;
Fitplot_total = Fitplot_Asc1no + Fitplot_Asc2no + Fitplot_Cttno + Fitplot_Descno;
Fitplot_Asc1 = 100*Fitplot_Asc1no./Fitplot_total;
Fitplot_Asc2 = 100*Fitplot_Asc2no./Fitplot_total;
Fitplot_Ctt = 100*Fitplot_Cttno./Fitplot_total;
Fitplot_Desc = 100*Fitplot_Descno./Fitplot_total;

% Trobem els errors
Fitplot_Asc1MAX = Fitplot_Asc1+100*YCI(1:length(t_plot));
Fitplot_Asc1MIN = Fitplot_Asc1-100*YCI(1:length(t_plot));
Fitplot_Asc2MAX = Fitplot_Asc2+100*YCI((length(t_plot)+1):(2*length(t_plot)));
Fitplot_Asc2MIN = Fitplot_Asc2-100*YCI((length(t_plot)+1):(2*length(t_plot)));
Fitplot_CttMAX = Fitplot_Ctt+100*YCI((2*length(t_plot)+1):end);
Fitplot_CttMIN = Fitplot_Ctt-100*YCI((2*length(t_plot)+1):end);
Fitplot_DescMAX = Fitplot_Desc + 100*sqrt(YCI(1:length(t_plot)).^2 + YCI((length(t_plot)+1):(2*length(t_plot))).^2 + YCI((2*length(t_plot)+1):end).^2);
Fitplot_DescMIN = Fitplot_Desc - 100*sqrt(YCI(1:length(t_plot)).^2 + YCI((length(t_plot)+1):(2*length(t_plot))).^2 + YCI((2*length(t_plot)+1):end).^2);

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
T = table(Fitting_date(1), paramfit(1), abs(conf1(1,1)-paramfit(1)), paramfit(4), abs(conf1(4,1)-paramfit(4)),...
    paramfit(2), abs(conf1(2,1)-paramfit(2)), paramfit(5), abs(conf1(5,1)-paramfit(5)),...
    paramfit(3), abs(conf1(3,1)-paramfit(3)), paramfit(6), abs(conf1(6,1)-paramfit(6)),p, RMSE,...
    'VariableNames',['Inici Fit',"Beta_OBA5","error_B_OBA5","R0_OBA5","error_R0_OBA5",...
    "Beta_OBA4","error_B_OBA4","R0_OBA4","error_R0_OBA4","Beta_Altres","error_B_Altres","R0_Altres","error_R0_Altres","p-value","RMSE"])
Tname = ".\Variables_hist_variants_OBA5\BetaR0_OBA2VSOBA5_altres"+Country+".xlsx";
NameSheet = "Full ID " + ID_fitting;
writetable(T,Tname,"Sheet",NameSheet);

% Sortida de dades experimentals de SIVIC normalitzades segons variants i
% agrupades les "no importants" a Altres
PlotSeqVar_oBA2_oBA5 = table(Day_plot', Norm_Desc, Desc_int, Norm_Asc1, Asc1_int, Norm_Asc2, Asc2_int, Norm_Ctt, Ctt_int);
PlotSeqVar_oBA2_oBA5.Properties.VariableNames = ['Dia',"Perc_oBA2",'Error_oBA2',"Perc_oBA5",'Error_oBA5',"Perc_oBA4",'Error_oBA4',"Perc_altres","Error_altres"];
Plotname = ".\DadesCSV_hist_variants_OBA5\Plot_SeqVar_oBA2_oBA5_altres" + Country + ".csv";
writetable(PlotSeqVar_oBA2_oBA5,Plotname)

% Preparem la figura: dades SIVIC, observacions ("reals")
figure
errorbar(Day_plot,Norm_Desc,Desc_int,Desc_int,'o','Color',[0.2 0.8 0.20])
hold on
errorbar(Day_plot,Norm_Asc1,Asc1_int,Asc1_int,'o','Color',[0.2 0.8 0.80])
errorbar(Day_plot,Norm_Asc2,Asc2_int,Asc2_int,'o','Color',[0.5 0.05 0.04])
errorbar(Day_plot,Norm_Ctt,Ctt_int,Ctt_int,'o','Color',[0.93 0.69 0.13])

% Definim l'escala del plot perquè després queda massa gran amb el FIT
tstart_plot = datetime(tstart,'InputFormat','dd/MM/yyyy');
tend_plot = datetime(tend,'InputFormat','dd/MM/yyyy');
xlim([tstart_plot tend_plot]);
ylim([0 100]);
%Finalment afegim a la imatge els fits
                    Fitting_date_plot=(Fitting_date(1)-2):(Fitting_date(1)+length(t_plot)-3);
plot(Fitting_date_plot,Fitplot_Desc,'-','Color',[0.2 0.8 0.20])
plot(Fitting_date_plot,Fitplot_Asc1,'-','Color',[0.2 0.8 0.80])
plot(Fitting_date_plot,Fitplot_Asc2,'-','Color',[0.5 0.05 0.04])
plot(Fitting_date_plot,Fitplot_Ctt,'-','Color',[0.93 0.69 0.13])

fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_DescMIN flip(Fitplot_DescMAX)],'r','FaceColor',[0.2 0.8 0.20],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc1MIN flip(Fitplot_Asc1MAX)],'r','FaceColor',[0.2 0.8 0.80],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc2MIN flip(Fitplot_Asc2MAX)],'r','FaceColor',[0.5 0.05 0.04],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_CttMIN flip(Fitplot_CttMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
yline(5,'--'); 

Fit_oBA2_oBA5 = table(Fitting_date_plot', Fitplot_Desc',Fitplot_DescMAX',Fitplot_DescMIN', Fitplot_Asc1',Fitplot_Asc1MAX',Fitplot_Asc1MIN',Fitplot_Asc2',Fitplot_Asc2MAX',Fitplot_Asc2MIN',Fitplot_Ctt',Fitplot_CttMAX',Fitplot_CttMIN');
Fit_oBA2_oBA5.Properties.VariableNames = ['Dia',"Perc_oBA2_dia","Perc_oBA2_dia_errMAX","Perc_oBA2_dia_errMIN","Perc_oBA5_dia","Perc_oBA5_dia_errMAX","Perc_oBA5_dia_errMIN",...
    "Perc_oBA4_dia","Perc_oBA4_dia_errMAX","Perc_oBA4_dia_errMIN","Perc_altres_dia","Perc_altres_dia_errMAX","Perc_altres_dia_errMIN"];
Fitname = ".\DadesCSV_hist_variants_OBA5\Fit_SeqVar_oBA2_oBA5_oBA4_altres"+Country+".csv";
writetable(Fit_oBA2_oBA5,Fitname)

textCaption = ".\Figures_hist_variants_OBA5\" + Country + " oBA2 VS oBA5 + oBA4 + Altres " + ID_fitting;
lgd = legend ('oBA2','oBA5','oBA4','Others','Model oBA2','Model oBA5','Model oBA4','Model Others','Location','east');
lgd.FontSize = 7;
title(Country + " oBA2 VS oBA5 + oBA4")
xlim([Day_plot(ID_fitting)-1 Day_plot(final)+1]);
print(textCaption,'-dpng','-r300')
close

                elseif (fit(4) > 0.008 && fit(1)>fit(2) && (fit(1)<fit(3)|| fit(3)<0) || (fit(3)<0 && fit(4) > 0.008))
                disp("*********************is working!!****************")
                
global_fit_data = [Fit_Asc1;Fit_Asc2;Fit_Ctt]'; 
global_fit_function = @(params,t) [params(4)*exp(params(1)*t)./(1+params(4)*exp(params(1)*t)+params(5)*exp(params(2)*t)),...
    params(5)*exp(params(2)*t)./(1+params(4)*exp(params(1)*t)+params(5)*exp(params(2)*t)),...
    params(6)+(params(3)*t)]; % Fitting functions
%estimem els parametres que utilitzarem
squared_errors = @(params) norm(global_fit_data - global_fit_function(params,t));
options=optimset('MaxFunEvals', 10000000, 'MaxIter',10000000, 'Display', 'final', 'TolX', 1e-0012);
fit = fminsearch(squared_errors,[aa ab ac ad ae af],options); % BetaBA4, BetaBA5; Ratio_ini_BA4, Ratio_ini_BA5
% Pasem de setmanes a dies, he tret el 7* que la Clara multiplicava al length ja que anava MASSA al futur
                t_plot=(1-2/7):1/7:(length(t)+2/7);
% això (desde 1) es per fer tot el càlcul...amb el 0 és per les imatges.
[paramfit,Resid,Jacob,CovB,MSE,ErrorModelInfo] = nlinfit(t,global_fit_data,global_fit_function,[fit(1) fit(2) fit(3) fit(4) fit(5) fit(6)]);
[Ypercen,YCI] = nlpredci(global_fit_function,t_plot,paramfit,Resid,'Covar',CovB);
                        Ypercen(Ypercen<0)=0;
paramfit;
conf1 = nlparci(paramfit,Resid,'jacobian',Jacob);
conf2 = nlparci(paramfit,Resid,'covariance',CovB);
% De manera automàtica el programa agafarà els paràmetres fitejats anteriorment com punt de partida
aa=fit(1);ab=fit(2);ac=fit(3);ad=fit(4);ae=fit(5);af=fit(6);
n=n+1;
    close
% Les normalitzem respecte a les 3 variants a estudiar
Fitplot_Asc1no = 100*Ypercen(1:length(t_plot));
Fitplot_Asc2no = 100*Ypercen((length(t_plot)+1):(2*length(t_plot)));
Fitplot_Cttno = 100*Ypercen((2*length(t_plot)+1):end);
Fitplot_Descno = 100 - Fitplot_Asc1no - Fitplot_Asc2no;
Fitplot_total = Fitplot_Asc1no + Fitplot_Asc2no + Fitplot_Cttno + Fitplot_Descno;
Fitplot_Asc1 = 100*Fitplot_Asc1no./Fitplot_total;
Fitplot_Asc2 = 100*Fitplot_Asc2no./Fitplot_total;
Fitplot_Ctt = 100*Fitplot_Cttno./Fitplot_total;
Fitplot_Desc = 100*Fitplot_Descno./Fitplot_total;

% Trobem els errors
Fitplot_Asc1MAX = Fitplot_Asc1+100*YCI(1:length(t_plot));
Fitplot_Asc1MIN = Fitplot_Asc1-100*YCI(1:length(t_plot));
Fitplot_Asc2MAX = Fitplot_Asc2+100*YCI((length(t_plot)+1):(2*length(t_plot)));
Fitplot_Asc2MIN = Fitplot_Asc2-100*YCI((length(t_plot)+1):(2*length(t_plot)));
Fitplot_CttMAX = Fitplot_Ctt+100*YCI((2*length(t_plot)+1):end);
Fitplot_CttMIN = Fitplot_Ctt-100*YCI((2*length(t_plot)+1):end);
Fitplot_DescMAX = Fitplot_Desc + 100*sqrt(YCI(1:length(t_plot)).^2 + YCI((length(t_plot)+1):(2*length(t_plot))).^2);
Fitplot_DescMIN = Fitplot_Desc - 100*sqrt(YCI(1:length(t_plot)).^2 + YCI((length(t_plot)+1):(2*length(t_plot))).^2);

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
T = table(Fitting_date(1), paramfit(1), abs(conf1(1,1)-paramfit(1)), paramfit(4), abs(conf1(4,1)-paramfit(4)),...
    paramfit(2), abs(conf1(2,1)-paramfit(2)), paramfit(5), abs(conf1(5,1)-paramfit(5)),p, RMSE,...
    'VariableNames',['Inici Fit',"Beta_OBA5","error_B_OBA5","R0_OBA5","error_R0_OBA5",...
    "Beta_OBA4","error_B_OBA4","R0_OBA4","error_R0_OBA4","p-value","RMSE"])
Tname = ".\Variables_hist_variants_OBA5\BetaR0_OBA2VSOBA5_altres"+Country+".xlsx";
NameSheet = "Full ID " + ID_fitting;
writetable(T,Tname,"Sheet",NameSheet);

% Sortida de dades experimentals de SIVIC normalitzades segons variants i
% agrupades les "no importants" a Altres
PlotSeqVar_oBA2_oBA5 = table(Day_plot', Norm_Desc, Desc_int, Norm_Asc1, Asc1_int, Norm_Asc2, Asc2_int, Norm_Ctt, Ctt_int);
PlotSeqVar_oBA2_oBA5.Properties.VariableNames = ['Dia',"Perc_oBA2",'Error_oBA2',"Perc_oBA5",'Error_oBA5',"Perc_oBA4",'Error_oBA4',"Perc_altres","Error_altres"];
Plotname = ".\DadesCSV_hist_variants_OBA5\Plot_SeqVar_oBA2_oBA5_altres" + Country + ".csv";
writetable(PlotSeqVar_oBA2_oBA5,Plotname)

% Preparem la figura: dades SIVIC, observacions ("reals")
figure
errorbar(Day_plot,Norm_Desc,Desc_int,Desc_int,'o','Color',[0.2 0.8 0.20])
hold on
errorbar(Day_plot,Norm_Asc1,Asc1_int,Asc1_int,'o','Color',[0.2 0.8 0.80])
errorbar(Day_plot,Norm_Asc2,Asc2_int,Asc2_int,'o','Color',[0.5 0.05 0.04])
errorbar(Day_plot,Norm_Ctt,Ctt_int,Ctt_int,'o','Color',[0.93 0.69 0.13])

% Definim l'escala del plot perquè després queda massa gran amb el FIT
tstart_plot = datetime(tstart,'InputFormat','dd/MM/yyyy');
tend_plot = datetime(tend,'InputFormat','dd/MM/yyyy');
xlim([tstart_plot tend_plot]);
ylim([0 100]);
%Finalment afegim a la imatge els fits
                    Fitting_date_plot=(Fitting_date(1)-2):(Fitting_date(1)+length(t_plot)-3);
plot(Fitting_date_plot,Fitplot_Desc,'-','Color',[0.2 0.8 0.20])
plot(Fitting_date_plot,Fitplot_Asc1,'-','Color',[0.2 0.8 0.80])
plot(Fitting_date_plot,Fitplot_Asc2,'-','Color',[0.5 0.05 0.04])
plot(Fitting_date_plot,Fitplot_Ctt,'-','Color',[0.93 0.69 0.13])

fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_DescMIN flip(Fitplot_DescMAX)],'r','FaceColor',[0.2 0.8 0.20],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc1MIN flip(Fitplot_Asc1MAX)],'r','FaceColor',[0.2 0.8 0.80],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc2MIN flip(Fitplot_Asc2MAX)],'r','FaceColor',[0.5 0.05 0.04],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_CttMIN flip(Fitplot_CttMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
yline(5,'--'); 

Fit_oBA2_oBA5 = table(Fitting_date_plot', Fitplot_Desc',Fitplot_DescMAX',Fitplot_DescMIN', Fitplot_Asc1',Fitplot_Asc1MAX',Fitplot_Asc1MIN',Fitplot_Asc2',Fitplot_Asc2MAX',Fitplot_Asc2MIN',Fitplot_Ctt',Fitplot_CttMAX',Fitplot_CttMIN');
Fit_oBA2_oBA5.Properties.VariableNames = ['Dia',"Perc_oBA2_dia","Perc_oBA2_dia_errMAX","Perc_oBA2_dia_errMIN","Perc_oBA5_dia","Perc_oBA5_dia_errMAX","Perc_oBA5_dia_errMIN",...
    "Perc_oBA4_dia","Perc_oBA4_dia_errMAX","Perc_oBA4_dia_errMIN","Perc_altres_dia","Perc_altres_dia_errMAX","Perc_altres_dia_errMIN"];
Fitname = ".\DadesCSV_hist_variants_OBA5\Fit_SeqVar_oBA2_oBA5_oBA4_altres"+Country+".csv";
writetable(Fit_oBA2_oBA5,Fitname)

textCaption = ".\Figures_hist_variants_OBA5\" + Country + " oBA2 VS oBA5 + oBA4 + Altres " + ID_fitting;
lgd = legend ('oBA2','oBA5','oBA4','Others','Model oBA2','Model oBA5','Model oBA4','Linear Others','Location','east');
lgd.FontSize = 7;
title(Country + " oBA2 VS oBA5 + oBA4")
xlim([Day_plot(ID_fitting)-1 Day_plot(final)+1]);
print(textCaption,'-dpng','-r300')
close

                elseif ((fit(4) > 0.005 && (fit(1)<fit(2) || fit(2)<0) && (fit(1)<fit(3) || fit(3)<0)) || (fit(4) > 0.005 && fit(2)<0 && fit(3)<0))
                disp("*********************is working!!****************")
global_fit_data = [Fit_Asc1;Fit_Asc2;Fit_Ctt]'; 
global_fit_function = @(params,t) [params(4)*exp(params(1)*t)./(1+params(4)*exp(params(1)*t)),...
    params(5)+(params(2)*t),...
    params(6)+(params(3)*t)]; % Fitting functions
%estimem els parametres que utilitzarem
squared_errors = @(params) norm(global_fit_data - global_fit_function(params,t));
options=optimset('MaxFunEvals', 10000000, 'MaxIter',10000000, 'Display', 'final', 'TolX', 1e-0012);
fit = fminsearch(squared_errors,[aa ab ac ad ae af],options); % BetaBA4, BetaBA5; Ratio_ini_BA4, Ratio_ini_BA5
% Pasem de setmanes a dies, he tret el 7* que la Clara multiplicava al length ja que anava MASSA al futur
                t_plot=(1-2/7):1/7:(length(t)+2/7);
% això (desde 1) es per fer tot el càlcul...amb el 0 és per les imatges.
[paramfit,Resid,Jacob,CovB,MSE,ErrorModelInfo] = nlinfit(t,global_fit_data,global_fit_function,[fit(1) fit(2) fit(3) fit(4) fit(5) fit(6)]);
[Ypercen,YCI] = nlpredci(global_fit_function,t_plot,paramfit,Resid,'Covar',CovB);
                        Ypercen(Ypercen<0)=0;
paramfit;
conf1 = nlparci(paramfit,Resid,'jacobian',Jacob);
conf2 = nlparci(paramfit,Resid,'covariance',CovB);
% De manera automàtica el programa agafarà els paràmetres fitejats anteriorment com punt de partida
aa=fit(1);ab=fit(2);ac=fit(3);ad=fit(4);ae=fit(5);af=fit(6);
n=n+1;
    close
% Les normalitzem respecte a les 3 variants a estudiar
Fitplot_Asc1no = 100*Ypercen(1:length(t_plot));
Fitplot_Asc2no = 100*Ypercen((length(t_plot)+1):(2*length(t_plot)));
Fitplot_Cttno = 100*Ypercen((2*length(t_plot)+1):end);
Fitplot_Descno = 100 - Fitplot_Asc1no;
Fitplot_total = Fitplot_Asc1no + Fitplot_Asc2no + Fitplot_Cttno + Fitplot_Descno;
Fitplot_Asc1 = 100*Fitplot_Asc1no./Fitplot_total;
Fitplot_Asc2 = 100*Fitplot_Asc2no./Fitplot_total;
Fitplot_Ctt = 100*Fitplot_Cttno./Fitplot_total;
Fitplot_Desc = 100*Fitplot_Descno./Fitplot_total;

% Trobem els errors
Fitplot_Asc1MAX = Fitplot_Asc1+100*YCI(1:length(t_plot));
Fitplot_Asc1MIN = Fitplot_Asc1-100*YCI(1:length(t_plot));
Fitplot_Asc2MAX = Fitplot_Asc2+100*YCI((length(t_plot)+1):(2*length(t_plot)));
Fitplot_Asc2MIN = Fitplot_Asc2-100*YCI((length(t_plot)+1):(2*length(t_plot)));
Fitplot_CttMAX = Fitplot_Ctt+100*YCI((2*length(t_plot)+1):end);
Fitplot_CttMIN = Fitplot_Ctt-100*YCI((2*length(t_plot)+1):end);
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
T = table(Fitting_date(1), paramfit(1), abs(conf1(1,1)-paramfit(1)), paramfit(4), abs(conf1(4,1)-paramfit(4)),p, RMSE,...
    'VariableNames',['Inici Fit',"Beta_OBA5","error_B_OBA5","R0_OBA5","error_R0_OBA5","p-value","RMSE"])
Tname = ".\Variables_hist_variants_OBA5\BetaR0_OBA2VSOBA5_altres"+Country+".xlsx";
NameSheet = "Full ID " + ID_fitting;
writetable(T,Tname,"Sheet",NameSheet);

% Sortida de dades experimentals de SIVIC normalitzades segons variants i
% agrupades les "no importants" a Altres
PlotSeqVar_oBA2_oBA5 = table(Day_plot', Norm_Desc, Desc_int, Norm_Asc1, Asc1_int, Norm_Asc2, Asc2_int, Norm_Ctt, Ctt_int);
PlotSeqVar_oBA2_oBA5.Properties.VariableNames = ['Dia',"Perc_oBA2",'Error_oBA2',"Perc_oBA5",'Error_oBA5',"Perc_oBA4",'Error_oBA4',"Perc_altres","Error_altres"];
Plotname = ".\DadesCSV_hist_variants_OBA5\Plot_SeqVar_oBA2_oBA5_altres" + Country + ".csv";
writetable(PlotSeqVar_oBA2_oBA5,Plotname)

% Preparem la figura: dades SIVIC, observacions ("reals")
figure
errorbar(Day_plot,Norm_Desc,Desc_int,Desc_int,'o','Color',[0.2 0.8 0.20])
hold on
errorbar(Day_plot,Norm_Asc1,Asc1_int,Asc1_int,'o','Color',[0.2 0.8 0.80])
errorbar(Day_plot,Norm_Asc2,Asc2_int,Asc2_int,'o','Color',[0.5 0.05 0.04])
errorbar(Day_plot,Norm_Ctt,Ctt_int,Ctt_int,'o','Color',[0.93 0.69 0.13])

% Definim l'escala del plot perquè després queda massa gran amb el FIT
tstart_plot = datetime(tstart,'InputFormat','dd/MM/yyyy');
tend_plot = datetime(tend,'InputFormat','dd/MM/yyyy');
xlim([tstart_plot tend_plot]);
ylim([0 100]);
%Finalment afegim a la imatge els fits
                    Fitting_date_plot=(Fitting_date(1)-2):(Fitting_date(1)+length(t_plot)-3);
plot(Fitting_date_plot,Fitplot_Desc,'-','Color',[0.2 0.8 0.20])
plot(Fitting_date_plot,Fitplot_Asc1,'-','Color',[0.2 0.8 0.80])
plot(Fitting_date_plot,Fitplot_Asc2,'-','Color',[0.5 0.05 0.04])
plot(Fitting_date_plot,Fitplot_Ctt,'-','Color',[0.93 0.69 0.13])

fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_DescMIN flip(Fitplot_DescMAX)],'r','FaceColor',[0.2 0.8 0.20],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc1MIN flip(Fitplot_Asc1MAX)],'r','FaceColor',[0.2 0.8 0.80],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc2MIN flip(Fitplot_Asc2MAX)],'r','FaceColor',[0.5 0.05 0.04],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_CttMIN flip(Fitplot_CttMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
yline(5,'--'); 

Fit_oBA2_oBA5 = table(Fitting_date_plot', Fitplot_Desc',Fitplot_DescMAX',Fitplot_DescMIN', Fitplot_Asc1',Fitplot_Asc1MAX',Fitplot_Asc1MIN',Fitplot_Asc2',Fitplot_Asc2MAX',Fitplot_Asc2MIN',Fitplot_Ctt',Fitplot_CttMAX',Fitplot_CttMIN');
Fit_oBA2_oBA5.Properties.VariableNames = ['Dia',"Perc_oBA2_dia","Perc_oBA2_dia_errMAX","Perc_oBA2_dia_errMIN","Perc_oBA5_dia","Perc_oBA5_dia_errMAX","Perc_oBA5_dia_errMIN",...
    "Perc_oBA4_dia","Perc_oBA4_dia_errMAX","Perc_oBA4_dia_errMIN","Perc_altres_dia","Perc_altres_dia_errMAX","Perc_altres_dia_errMIN"];
Fitname = ".\DadesCSV_hist_variants_OBA5\Fit_SeqVar_oBA2_oBA5_oBA4_altres"+Country+".csv";
writetable(Fit_oBA2_oBA5,Fitname)

textCaption = ".\Figures_hist_variants_OBA5\" + Country + " oBA2 VS oBA5 + oBA4 + Altres " + ID_fitting;
lgd = legend ('oBA2','oBA5','oBA4','Others','Model oBA2','Model oBA5','Linear oBA4','Linear Others','Location','east');
lgd.FontSize = 7;
title(Country + " oBA2 VS oBA5 + oBA4")
xlim([Day_plot(ID_fitting)-1 Day_plot(final)+1]);
print(textCaption,'-dpng','-r300')
close

                elseif ((fit(4) > 0.005 && (fit(1)<fit(2) || fit(2)<0) && fit(1)>fit(3) && fit(3)>0) || (fit(4) > 0.005 && fit(2)<0))
                disp("*********************is working!!****************")
                
global_fit_data = [Fit_Asc1;Fit_Asc2;Fit_Ctt]'; 
global_fit_function = @(params,t) [params(4)*exp(params(1)*t)./(1+params(4)*exp(params(1)*t)+params(6)*exp(params(3)*t)),...
    params(5)+(params(2)*t),...
    params(6)*exp(params(3)*t)./(1+params(4)*exp(params(1)*t)+params(6)*exp(params(3)*t))]; % Fitting functions
%estimem els parametres que utilitzarem
squared_errors = @(params) norm(global_fit_data - global_fit_function(params,t));
options=optimset('MaxFunEvals', 10000000, 'MaxIter',10000000, 'Display', 'final', 'TolX', 1e-0012);
fit = fminsearch(squared_errors,[aa ab ac ad ae af],options); % BetaBA4, BetaBA5; Ratio_ini_BA4, Ratio_ini_BA5
% Pasem de setmanes a dies, he tret el 7* que la Clara multiplicava al length ja que anava MASSA al futur
                t_plot=(1-2/7):1/7:(length(t)+2/7);
% això (desde 1) es per fer tot el càlcul...amb el 0 és per les imatges.
[paramfit,Resid,Jacob,CovB,MSE,ErrorModelInfo] = nlinfit(t,global_fit_data,global_fit_function,[fit(1) fit(2) fit(3) fit(4) fit(5) fit(6)]);
[Ypercen,YCI] = nlpredci(global_fit_function,t_plot,paramfit,Resid,'Covar',CovB);
                        Ypercen(Ypercen<0)=0;
paramfit;
conf1 = nlparci(paramfit,Resid,'jacobian',Jacob);
conf2 = nlparci(paramfit,Resid,'covariance',CovB);
% De manera automàtica el programa agafarà els paràmetres fitejats anteriorment com punt de partida
aa=fit(1);ab=fit(2);ac=fit(3);ad=fit(4);ae=fit(5);af=fit(6);
n=n+1;
    close
% Les normalitzem respecte a les 3 variants a estudiar
Fitplot_Asc1no = 100*Ypercen(1:length(t_plot));
Fitplot_Asc2no = 100*Ypercen((length(t_plot)+1):(2*length(t_plot)));
Fitplot_Cttno = 100*Ypercen((2*length(t_plot)+1):end);
Fitplot_Descno = 100 - Fitplot_Asc1no - Fitplot_Cttno;
Fitplot_total = Fitplot_Asc1no + Fitplot_Asc2no + Fitplot_Cttno + Fitplot_Descno;
Fitplot_Asc1 = 100*Fitplot_Asc1no./Fitplot_total;
Fitplot_Asc2 = 100*Fitplot_Asc2no./Fitplot_total;
Fitplot_Ctt = 100*Fitplot_Cttno./Fitplot_total;
Fitplot_Desc = 100*Fitplot_Descno./Fitplot_total;

% Trobem els errors
Fitplot_Asc1MAX = Fitplot_Asc1+100*YCI(1:length(t_plot));
Fitplot_Asc1MIN = Fitplot_Asc1-100*YCI(1:length(t_plot));
Fitplot_Asc2MAX = Fitplot_Asc2+100*YCI((length(t_plot)+1):(2*length(t_plot)));
Fitplot_Asc2MIN = Fitplot_Asc2-100*YCI((length(t_plot)+1):(2*length(t_plot)));
Fitplot_CttMAX = Fitplot_Ctt+100*YCI((2*length(t_plot)+1):end);
Fitplot_CttMIN = Fitplot_Ctt-100*YCI((2*length(t_plot)+1):end);
Fitplot_DescMAX = Fitplot_Desc + 100*sqrt(YCI(1:length(t_plot)).^2 + YCI((2*length(t_plot)+1):end).^2);
Fitplot_DescMIN = Fitplot_Desc - 100*sqrt(YCI(1:length(t_plot)).^2 + YCI((2*length(t_plot)+1):end).^2);

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
T = table(Fitting_date(1), paramfit(1), abs(conf1(1,1)-paramfit(1)), paramfit(4), abs(conf1(4,1)-paramfit(4)),...
    paramfit(3), abs(conf1(3,1)-paramfit(3)), paramfit(6), abs(conf1(6,1)-paramfit(6)),p, RMSE,...
    'VariableNames',['Inici Fit',"Beta_OBA5","error_B_OBA5","R0_OBA5","error_R0_OBA5",...
    "Beta_Altres","error_B_Altres","R0_Altres","error_R0_Altres","p-value","RMSE"])
Tname = ".\Variables_hist_variants_OBA5\BetaR0_OBA2VSOBA5_altres"+Country+".xlsx";
NameSheet = "Full ID " + ID_fitting;
writetable(T,Tname,"Sheet",NameSheet);

% Sortida de dades experimentals de SIVIC normalitzades segons variants i
% agrupades les "no importants" a Altres
PlotSeqVar_oBA2_oBA5 = table(Day_plot', Norm_Desc, Desc_int, Norm_Asc1, Asc1_int, Norm_Asc2, Asc2_int, Norm_Ctt, Ctt_int);
PlotSeqVar_oBA2_oBA5.Properties.VariableNames = ['Dia',"Perc_oBA2",'Error_oBA2',"Perc_oBA5",'Error_oBA5',"Perc_oBA4",'Error_oBA4',"Perc_altres","Error_altres"];
Plotname = ".\DadesCSV_hist_variants_OBA5\Plot_SeqVar_oBA2_oBA5_altres" + Country + ".csv";
writetable(PlotSeqVar_oBA2_oBA5,Plotname)

% Preparem la figura: dades SIVIC, observacions ("reals")
figure
errorbar(Day_plot,Norm_Desc,Desc_int,Desc_int,'o','Color',[0.2 0.8 0.20])
hold on
errorbar(Day_plot,Norm_Asc1,Asc1_int,Asc1_int,'o','Color',[0.2 0.8 0.80])
errorbar(Day_plot,Norm_Asc2,Asc2_int,Asc2_int,'o','Color',[0.5 0.05 0.04])
errorbar(Day_plot,Norm_Ctt,Ctt_int,Ctt_int,'o','Color',[0.93 0.69 0.13])

% Definim l'escala del plot perquè després queda massa gran amb el FIT
tstart_plot = datetime(tstart,'InputFormat','dd/MM/yyyy');
tend_plot = datetime(tend,'InputFormat','dd/MM/yyyy');
xlim([tstart_plot tend_plot]);
ylim([0 100]);
%Finalment afegim a la imatge els fits
                    Fitting_date_plot=(Fitting_date(1)-2):(Fitting_date(1)+length(t_plot)-3);
plot(Fitting_date_plot,Fitplot_Desc,'-','Color',[0.2 0.8 0.20])
plot(Fitting_date_plot,Fitplot_Asc1,'-','Color',[0.2 0.8 0.80])
plot(Fitting_date_plot,Fitplot_Asc2,'-','Color',[0.5 0.05 0.04])
plot(Fitting_date_plot,Fitplot_Ctt,'-','Color',[0.93 0.69 0.13])

fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_DescMIN flip(Fitplot_DescMAX)],'r','FaceColor',[0.2 0.8 0.20],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc1MIN flip(Fitplot_Asc1MAX)],'r','FaceColor',[0.2 0.8 0.80],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc2MIN flip(Fitplot_Asc2MAX)],'r','FaceColor',[0.5 0.05 0.04],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_CttMIN flip(Fitplot_CttMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
yline(5,'--'); 

Fit_oBA2_oBA5 = table(Fitting_date_plot', Fitplot_Desc',Fitplot_DescMAX',Fitplot_DescMIN', Fitplot_Asc1',Fitplot_Asc1MAX',Fitplot_Asc1MIN',Fitplot_Asc2',Fitplot_Asc2MAX',Fitplot_Asc2MIN',Fitplot_Ctt',Fitplot_CttMAX',Fitplot_CttMIN');
Fit_oBA2_oBA5.Properties.VariableNames = ['Dia',"Perc_oBA2_dia","Perc_oBA2_dia_errMAX","Perc_oBA2_dia_errMIN","Perc_oBA5_dia","Perc_oBA5_dia_errMAX","Perc_oBA5_dia_errMIN",...
    "Perc_oBA4_dia","Perc_oBA4_dia_errMAX","Perc_oBA4_dia_errMIN","Perc_altres_dia","Perc_altres_dia_errMAX","Perc_altres_dia_errMIN"];
Fitname = ".\DadesCSV_hist_variants_OBA5\Fit_SeqVar_oBA2_oBA5_oBA4_altres"+Country+".csv";
writetable(Fit_oBA2_oBA5,Fitname)

textCaption = ".\Figures_hist_variants_OBA5\" + Country + " oBA2 VS oBA5 + oBA4 + Altres " + ID_fitting;
lgd = legend ('oBA2','oBA5','oBA4','Others','Model oBA2','Model oBA5','Linear oBA4','Model Others','Location','east');
lgd.FontSize = 7;
title(Country + " oBA2 VS oBA5 + oBA4")
xlim([Day_plot(ID_fitting)-1 Day_plot(final)+1]);
print(textCaption,'-dpng','-r300')
close

                elseif ((fit(4) > 0.005 && fit(1)>fit(2) && (fit(1)<fit(3) || fit(3)<0) && fit(2)>0) || (fit(4) > 0.005 && fit(3)<0))
                disp("*********************is working!!****************")
                
global_fit_data = [Fit_Asc1;Fit_Asc2;Fit_Ctt]'; 
global_fit_function = @(params,t) [params(4)*exp(params(1)*t)./(1+params(4)*exp(params(1)*t)+params(5)*exp(params(2)*t)),...
    params(5)*exp(params(2)*t)./(1+params(4)*exp(params(1)*t)+params(5)*exp(params(2)*t)),...
    params(6)+(params(3)*t)]; % Fitting functions
%estimem els parametres que utilitzarem
squared_errors = @(params) norm(global_fit_data - global_fit_function(params,t));
options=optimset('MaxFunEvals', 10000000, 'MaxIter',10000000, 'Display', 'final', 'TolX', 1e-0012);
fit = fminsearch(squared_errors,[aa ab ac ad ae af],options); % BetaBA4, BetaBA5; Ratio_ini_BA4, Ratio_ini_BA5
% Pasem de setmanes a dies, he tret el 7* que la Clara multiplicava al length ja que anava MASSA al futur
                t_plot=(1-2/7):1/7:(length(t)+2/7);
% això (desde 1) es per fer tot el càlcul...amb el 0 és per les imatges.
[paramfit,Resid,Jacob,CovB,MSE,ErrorModelInfo] = nlinfit(t,global_fit_data,global_fit_function,[fit(1) fit(2) fit(3) fit(4) fit(5) fit(6)]);
[Ypercen,YCI] = nlpredci(global_fit_function,t_plot,paramfit,Resid,'Covar',CovB);
                        Ypercen(Ypercen<0)=0;
paramfit;
conf1 = nlparci(paramfit,Resid,'jacobian',Jacob);
conf2 = nlparci(paramfit,Resid,'covariance',CovB);
% De manera automàtica el programa agafarà els paràmetres fitejats anteriorment com punt de partida
aa=fit(1);ab=fit(2);ac=fit(3);ad=fit(4);ae=fit(5);af=fit(6);
n=n+1;
    close
% Les normalitzem respecte a les 3 variants a estudiar
Fitplot_Asc1no = 100*Ypercen(1:length(t_plot));
Fitplot_Asc2no = 100*Ypercen((length(t_plot)+1):(2*length(t_plot)));
Fitplot_Cttno = 100*Ypercen((2*length(t_plot)+1):end);
Fitplot_Descno = 100 - Fitplot_Asc1no - Fitplot_Cttno;
Fitplot_total = Fitplot_Asc1no + Fitplot_Asc2no + Fitplot_Cttno + Fitplot_Descno;
Fitplot_Asc1 = 100*Fitplot_Asc1no./Fitplot_total;
Fitplot_Asc2 = 100*Fitplot_Asc2no./Fitplot_total;
Fitplot_Ctt = 100*Fitplot_Cttno./Fitplot_total;
Fitplot_Desc = 100*Fitplot_Descno./Fitplot_total;

% Trobem els errors
Fitplot_Asc1MAX = Fitplot_Asc1+100*YCI(1:length(t_plot));
Fitplot_Asc1MIN = Fitplot_Asc1-100*YCI(1:length(t_plot));
Fitplot_Asc2MAX = Fitplot_Asc2+100*YCI((length(t_plot)+1):(2*length(t_plot)));
Fitplot_Asc2MIN = Fitplot_Asc2-100*YCI((length(t_plot)+1):(2*length(t_plot)));
Fitplot_CttMAX = Fitplot_Ctt+100*YCI((2*length(t_plot)+1):end);
Fitplot_CttMIN = Fitplot_Ctt-100*YCI((2*length(t_plot)+1):end);
Fitplot_DescMAX = Fitplot_Desc + 100*sqrt(YCI(1:length(t_plot)).^2 + YCI((2*length(t_plot)+1):end).^2);
Fitplot_DescMIN = Fitplot_Desc - 100*sqrt(YCI(1:length(t_plot)).^2 + YCI((2*length(t_plot)+1):end).^2);

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
T = table(Fitting_date(1), paramfit(1), abs(conf1(1,1)-paramfit(1)), paramfit(4), abs(conf1(4,1)-paramfit(4)),...
    paramfit(2), abs(conf1(2,1)-paramfit(2)), paramfit(5), abs(conf1(5,1)-paramfit(5)),p, RMSE,...
    'VariableNames',['Inici Fit',"Beta_OBA5","error_B_OBA5","R0_OBA5","error_R0_OBA5",...
    "Beta_OBA4","error_B_OBA4","R0_OBA4","error_R0_OBA4","p-value","RMSE"])
Tname = ".\Variables_hist_variants_OBA5\BetaR0_OBA2VSOBA5_altres"+Country+".xlsx";
NameSheet = "Full ID " + ID_fitting;
writetable(T,Tname,"Sheet",NameSheet);

% Sortida de dades experimentals de SIVIC normalitzades segons variants i
% agrupades les "no importants" a Altres
PlotSeqVar_oBA2_oBA5 = table(Day_plot', Norm_Desc, Desc_int, Norm_Asc1, Asc1_int, Norm_Asc2, Asc2_int, Norm_Ctt, Ctt_int);
PlotSeqVar_oBA2_oBA5.Properties.VariableNames = ['Dia',"Perc_oBA2",'Error_oBA2',"Perc_oBA5",'Error_oBA5',"Perc_oBA4",'Error_oBA4',"Perc_altres","Error_altres"];
Plotname = ".\DadesCSV_hist_variants_OBA5\Plot_SeqVar_oBA2_oBA5_altres" + Country + ".csv";
writetable(PlotSeqVar_oBA2_oBA5,Plotname)

% Preparem la figura: dades SIVIC, observacions ("reals")
figure
errorbar(Day_plot,Norm_Desc,Desc_int,Desc_int,'o','Color',[0.2 0.8 0.20])
hold on
errorbar(Day_plot,Norm_Asc1,Asc1_int,Asc1_int,'o','Color',[0.2 0.8 0.80])
errorbar(Day_plot,Norm_Asc2,Asc2_int,Asc2_int,'o','Color',[0.5 0.05 0.04])
errorbar(Day_plot,Norm_Ctt,Ctt_int,Ctt_int,'o','Color',[0.93 0.69 0.13])

% Definim l'escala del plot perquè després queda massa gran amb el FIT
tstart_plot = datetime(tstart,'InputFormat','dd/MM/yyyy');
tend_plot = datetime(tend,'InputFormat','dd/MM/yyyy');
xlim([tstart_plot tend_plot]);
ylim([0 100]);
%Finalment afegim a la imatge els fits
                    Fitting_date_plot=(Fitting_date(1)-2):(Fitting_date(1)+length(t_plot)-3);
plot(Fitting_date_plot,Fitplot_Desc,'-','Color',[0.2 0.8 0.20])
plot(Fitting_date_plot,Fitplot_Asc1,'-','Color',[0.2 0.8 0.80])
plot(Fitting_date_plot,Fitplot_Asc2,'-','Color',[0.5 0.05 0.04])
plot(Fitting_date_plot,Fitplot_Ctt,'-','Color',[0.93 0.69 0.13])

fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_DescMIN flip(Fitplot_DescMAX)],'r','FaceColor',[0.2 0.8 0.20],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc1MIN flip(Fitplot_Asc1MAX)],'r','FaceColor',[0.2 0.8 0.80],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc2MIN flip(Fitplot_Asc2MAX)],'r','FaceColor',[0.5 0.05 0.04],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_CttMIN flip(Fitplot_CttMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
yline(5,'--'); 

Fit_oBA2_oBA5 = table(Fitting_date_plot', Fitplot_Desc',Fitplot_DescMAX',Fitplot_DescMIN', Fitplot_Asc1',Fitplot_Asc1MAX',Fitplot_Asc1MIN',Fitplot_Asc2',Fitplot_Asc2MAX',Fitplot_Asc2MIN',Fitplot_Ctt',Fitplot_CttMAX',Fitplot_CttMIN');
Fit_oBA2_oBA5.Properties.VariableNames = ['Dia',"Perc_oBA2_dia","Perc_oBA2_dia_errMAX","Perc_oBA2_dia_errMIN","Perc_oBA5_dia","Perc_oBA5_dia_errMAX","Perc_oBA5_dia_errMIN",...
    "Perc_oBA4_dia","Perc_oBA4_dia_errMAX","Perc_oBA4_dia_errMIN","Perc_altres_dia","Perc_altres_dia_errMAX","Perc_altres_dia_errMIN"];
Fitname = ".\DadesCSV_hist_variants_OBA5\Fit_SeqVar_oBA2_oBA5_oBA4_altres"+Country+".csv";
writetable(Fit_oBA2_oBA5,Fitname)

textCaption = ".\Figures_hist_variants_OBA5\" + Country + " oBA2 VS oBA5 + oBA4 + Altres " + ID_fitting;
lgd = legend ('oBA2','oBA5','oBA4','Others','Model oBA2','Model oBA5','Model oBA4','Linear Others','Location','east');
lgd.FontSize = 7;
title(Country + " oBA2 VS oBA5 + oBA4")
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
    BOBA5=paramfit(1); BerrOBA5=abs(conf1(1,1)-paramfit(1)); R0OBA5=paramfit(4); R0errOBA5=abs(conf1(4,1)-paramfit(4));
        DayOBA5 = Fitting_date_plot(find(Fitplot_Asc1 > 5,1));
            DayOBA520 = Fitting_date_plot(find(Fitplot_Asc1 > 20,1));
        DayOBA540 = Fitting_date_plot(find(Fitplot_Asc1 > 40,1));
    DayOBA560 = Fitting_date_plot(find(Fitplot_Asc1 > 60,1));
        DayOBA580 = Fitting_date_plot(find(Fitplot_Asc1 > 80,1));
end %aquí acaba per tots els països
