function     [BOBQ,BerrOBQ,R0OBQ,R0errOBQ,DayOBQ,DayOBQ20] = FOBA5OBQb(N_Desc, N_Asc1, N_Asc2, N_Asc4, N_Ctt, Country, WeekThurs)

N_total = N_Desc + N_Asc1 + N_Asc2 + N_Asc4 + N_Ctt;

% Les normalitzem respecte a les 3 variants (o les que siguin) a estudiar
for i=1:length(N_total)
    if N_total(i)==0 
        N_total(i)=1;
    end
end

Norm_Desc = 100*N_Desc ./ N_total;
Norm_Asc1 = 100*N_Asc1 ./ N_total;
Norm_Asc2 = 100*N_Asc2 ./ N_total;
Norm_Asc4 = 100*N_Asc4 ./ N_total;
Norm_Ctt = 100*N_Ctt ./ N_total;

% Trobem els errors "binaris" (o tinc la variant o NO la tinc) de les
% nostres dades experimentals
Desc_int = 100*sqrt(N_total .* (N_Desc ./ N_total) .* (1-(N_Desc ./ N_total))) ./ N_total;
Asc1_int = 100*sqrt(N_total .* (N_Asc1 ./ N_total) .* (1-(N_Asc1 ./ N_total))) ./ N_total;
Asc2_int = 100*sqrt(N_total .* (N_Asc2 ./ N_total) .* (1-(N_Asc2 ./ N_total))) ./ N_total;
Asc4_int = 100*sqrt(N_total .* (N_Asc4 ./ N_total) .* (1-(N_Asc4 ./ N_total))) ./ N_total;
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
            princ2 = Norm_Asc1(princ1)>1 && Norm_Asc1(princ1)<Norm_Asc1(princ1+1) && Norm_Asc1(princ1)<Norm_Asc1(princ1+2);
            princ1 = princ1+1;
            end
            if (Country == "Italy" || Country == "Austria")
                principi = princ1 - 2;
            elseif (Country == "Denmark" || Country == "Croatia" || Country == "Luxembourg" || Country == "Portugal" || Country == "Finland" || Country=="Romania")
                principi = princ1 - 3;
            elseif Country =="Norway" || Country =="Sweden"
                principi = princ1 - 4;
            elseif Country =="Slovenia"
                principi = princ1-5;
            else
                principi = princ1-1; %recuperem l'ultim valor que hem analitzat
            end
% i on l'acabem!!
final2 = 0;
final1 = find(Norm_Asc1>70,1);
% Preparem on comencem el fitting, perquè sigui automàtic
        if Country == "Romania"
            final = 23;

        else
           
            try
                while final2 == 0
                final2 = Norm_Asc1(final1)>70 && Norm_Asc1(final1)>Norm_Asc1(final1+1) && Norm_Asc1(final1+1)>70;
                final1 = final1+1;
                end
            final = final1-1; %recuperem l'ultim valor que hem analitzat  
            catch
                    final = find(Norm_Asc1 == max(Norm_Asc1),1);
            end
        end

        if (Country == "Denmark")
            final = final + 0;
        elseif Country == "Portugal"
            final = final +3;
        elseif Country == "Austria" || Country=="Bulgaria" || Country == "Sweden" || Country =="Europe"
            final = final -1;
        elseif  Country=="Belgium"
            final = final +0;
        end

% Els paràmetres Beta i R0 necessiten un valor inicial que després s'anirà
% ajustant automàticament:
aa=0.7; ab=0.5; ac=0.2; ad=0.1; ae=0.01; af=0.01; ag=0.01; ah=0.01;

    for ID_fitting = (principi):1:final  
        if (n<2)
Fitting_date=Day_plot(ID_fitting:final);
        t=1:length(Fitting_date)';
        Fit_Desc = Norm_Desc(ID_fitting:final)/100;
        Fit_Asc1 = Norm_Asc1(ID_fitting:final)/100;
        Fit_Asc2 = Norm_Asc2(ID_fitting:final)/100;
        Fit_Asc4 = Norm_Asc4(ID_fitting:final)/100;
        Fit_Ctt = Norm_Ctt(ID_fitting:final)/100;

        global_fit_data = [Fit_Asc1;Fit_Asc2;Fit_Asc4;Fit_Ctt]'; 
global_fit_function = @(params,t) [params(5)*exp(params(1)*t)./(1+params(5)*exp(params(1)*t)+params(6)*exp(params(2)*t)+params(8)*exp(params(4)*t)),...
    params(6)*exp(params(2)*t)./(1+params(5)*exp(params(1)*t)+params(6)*exp(params(2)*t)+params(8)*exp(params(4)*t)),...
    params(7)+(params(3)*t),...
    params(8)*exp(params(4)*t)./(1+params(5)*exp(params(1)*t)+params(6)*exp(params(2)*t)+params(8)*exp(params(4)*t))]; % Fitting functions
%estimem els parametres que utilitzarem
squared_errors = @(params) norm(global_fit_data - global_fit_function(params,t));
options=optimset('MaxFunEvals', 10000000, 'MaxIter',10000000, 'Display', 'final', 'TolX', 1e-0012);
fit = fminsearch(squared_errors,[aa ab ac ad ae af ag ah],options); % BetaBQ, BetaBA2, BetaBA4, Beta_Altres; Ratio_ini_BQ, Ratio_ini_BA2, Ratio_ini_BA4, Ratio_ini_Altres

                % if (fit(5) > 0.005 && fit(1)>fit(2) && fit(1)>fit(4) && fit(2)>0 && fit(4)>0)
                if (fit(5) > 0.005 && fit(1)>fit(2) && fit(2)>0 && fit(4)>0)
    n=n+1;
    close
% Pasem de setmanes a dies, he tret el 7* que la Clara multiplicava al length ja que anava MASSA al futur
                t_plot=(1-2/7):1/7:(length(t)+2/7);
% això (desde 1) es per fer tot el càlcul...amb el 0 és per les imatges.
[paramfit,Resid,Jacob,CovB,MSE,ErrorModelInfo] = nlinfit(t,global_fit_data,global_fit_function,[fit(1) fit(2) fit(3) fit(4) fit(5) fit(6) fit(7) fit(8)]);
[Ypercen,YCI] = nlpredci(global_fit_function,t_plot,paramfit,Resid,'Covar',CovB);
                        Ypercen(Ypercen<0)=0;
paramfit;
conf1 = nlparci(paramfit,Resid,'jacobian',Jacob);
conf2 = nlparci(paramfit,Resid,'covariance',CovB);
% De manera automàtica el programa agafarà els paràmetres fitejats anteriorment com punt de partida
aa=fit(1);ab=fit(2);ac=fit(3);ad=fit(4);ae=fit(5);af=fit(6);ag=fit(7);ah=fit(8);

% Les normalitzem respecte a les 3 variants a estudiar
Fitplot_Asc1no = 100*Ypercen(1:length(t_plot));
Fitplot_Asc2no = 100*Ypercen((length(t_plot)+1):(2*length(t_plot)));
Fitplot_Asc4no = 100*Ypercen((2*length(t_plot)+1):(3*length(t_plot)));
Fitplot_Cttno = 100*Ypercen((3*length(t_plot)+1):end);
Fitplot_Descno = 100 - Fitplot_Asc1no - Fitplot_Asc2no - Fitplot_Cttno;
Fitplot_total = Fitplot_Asc1no + Fitplot_Asc2no + Fitplot_Asc4no + Fitplot_Cttno + Fitplot_Descno;
Fitplot_Asc1 = 100*Fitplot_Asc1no./Fitplot_total;
Fitplot_Asc2 = 100*Fitplot_Asc2no./Fitplot_total;
Fitplot_Asc4 = 100*Fitplot_Asc4no./Fitplot_total;
Fitplot_Ctt = 100*Fitplot_Cttno./Fitplot_total;
Fitplot_Desc = 100*Fitplot_Descno./Fitplot_total;

% Trobem els errors
Fitplot_Asc1MAX = Fitplot_Asc1+100*YCI(1:length(t_plot));
Fitplot_Asc1MIN = Fitplot_Asc1-100*YCI(1:length(t_plot));
Fitplot_Asc2MAX = Fitplot_Asc2+100*YCI((length(t_plot)+1):(2*length(t_plot)));
Fitplot_Asc2MIN = Fitplot_Asc2-100*YCI((length(t_plot)+1):(2*length(t_plot)));
Fitplot_Asc4MAX = Fitplot_Asc4+100*YCI((2*length(t_plot)+1):(3*length(t_plot)));
Fitplot_Asc4MIN = Fitplot_Asc4-100*YCI((2*length(t_plot)+1):(3*length(t_plot)));
Fitplot_CttMAX = Fitplot_Ctt+100*YCI((3*length(t_plot)+1):end);
Fitplot_CttMIN = Fitplot_Ctt-100*YCI((3*length(t_plot)+1):end);
Fitplot_DescMAX = Fitplot_Desc + 100*sqrt(YCI(1:length(t_plot)).^2 + YCI((length(t_plot)+1):(2*length(t_plot))).^2 + YCI((3*length(t_plot)+1):end).^2);
Fitplot_DescMIN = Fitplot_Desc - 100*sqrt(YCI(1:length(t_plot)).^2 + YCI((length(t_plot)+1):(2*length(t_plot))).^2 + YCI((3*length(t_plot)+1):end).^2);

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
T = table(Fitting_date(1), paramfit(1), abs(conf1(1,1)-paramfit(1)), paramfit(5), abs(conf1(5,1)-paramfit(5)),...
    paramfit(2), abs(conf1(2,1)-paramfit(2)), paramfit(6), abs(conf1(6,1)-paramfit(6)),...
    paramfit(4), abs(conf1(4,1)-paramfit(4)), paramfit(8), abs(conf1(8,1)-paramfit(8)),p, RMSE,...
    'VariableNames',['Inici Fit',"Beta_OBQ","error_B_OBQ","R0_OBQ","error_R0_OBQ",...
    "Beta_OBA2","error_B_OBA2","R0_OBA2","error_R0_OBA2",...
    "Beta_Altres","error_B_Altres","R0_Altres","error_R0_Altres","p-value","RMSE"])
Tname = ".\Variables_hist_variants_OBQ\BetaR0_OBA5VSOBQ_altres"+Country+".xlsx";
NameSheet = "Full ID " + ID_fitting;
writetable(T,Tname,"Sheet",NameSheet);

% Sortida de dades experimentals de SIVIC normalitzades segons variants i
% agrupades les "no importants" a Altres
PlotSeqVar_oBA5_oBQ = table(Day_plot', Norm_Desc, Desc_int, Norm_Asc1, Asc1_int, Norm_Asc2, Asc2_int,Norm_Asc4, Asc4_int, Norm_Ctt, Ctt_int);
PlotSeqVar_oBA5_oBQ.Properties.VariableNames = ['Dia',"Perc_oBA5",'Error_oBA5',"Perc_oBQ",'Error_oBQ',"Perc_oBA2",'Error_oBA2',"Perc_oBA4",'Error_oBA4',"Perc_altres","Error_altres"];
Plotname = ".\DadesCSV_hist_variants_OBQ\Plot_SeqVar_oBA5_oBQ_altres" + Country + ".csv";
writetable(PlotSeqVar_oBA5_oBQ,Plotname)

% Preparem la figura: dades SIVIC, observacions ("reals")
figure
errorbar(Day_plot,Norm_Desc,Desc_int,Desc_int,'o','Color',[0.2 0.8 0.80])
hold on
errorbar(Day_plot,Norm_Asc1,Asc1_int,Asc1_int,'o','Color',[0.4 0.2 0.60])
errorbar(Day_plot,Norm_Asc2,Asc2_int,Asc2_int,'o','Color',[0.2 0.8 0.20])
errorbar(Day_plot,Norm_Asc4,Asc4_int,Asc4_int,'o','Color',[0.5 0.05 0.04])
errorbar(Day_plot,Norm_Ctt,Ctt_int,Ctt_int,'o','Color',[0.93 0.69 0.13])

% Definim l'escala del plot perquè després queda massa gran amb el FIT
tstart_plot = datetime(tstart,'InputFormat','dd/MM/yyyy');
tend_plot = datetime(tend,'InputFormat','dd/MM/yyyy');
xlim([tstart_plot tend_plot]);
ylim([0 100]);
%Finalment afegim a la imatge els fits
                    Fitting_date_plot=(Fitting_date(1)-2):(Fitting_date(1)+length(t_plot)-3);
plot(Fitting_date_plot,Fitplot_Desc,'-','Color',[0.2 0.8 0.80])
plot(Fitting_date_plot,Fitplot_Asc1,'-','Color',[0.4 0.2 0.60])
plot(Fitting_date_plot,Fitplot_Asc2,'-','Color',[0.2 0.8 0.2])
plot(Fitting_date_plot,Fitplot_Asc4,'-','Color',[0.5 0.05 0.04])
plot(Fitting_date_plot,Fitplot_Ctt,'-','Color',[0.93 0.69 0.13])

fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_DescMIN flip(Fitplot_DescMAX)],'r','FaceColor',[0.2 0.8 0.80],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc1MIN flip(Fitplot_Asc1MAX)],'r','FaceColor',[0.4 0.2 0.60],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc2MIN flip(Fitplot_Asc2MAX)],'r','FaceColor',[0.2 0.8 0.2],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc4MIN flip(Fitplot_Asc4MAX)],'r','FaceColor',[0.5 0.05 0.04],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_CttMIN flip(Fitplot_CttMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
yline(5,'--'); 

Fit_oBA5_oBQ = table(Fitting_date_plot', Fitplot_Desc',Fitplot_DescMAX',Fitplot_DescMIN', Fitplot_Asc1',Fitplot_Asc1MAX',Fitplot_Asc1MIN',...
    Fitplot_Asc2',Fitplot_Asc2MAX',Fitplot_Asc2MIN',Fitplot_Asc4',Fitplot_Asc4MAX',Fitplot_Asc4MIN',Fitplot_Ctt',Fitplot_CttMAX',Fitplot_CttMIN');
Fit_oBA5_oBQ.Properties.VariableNames = ['Dia',"Perc_oBA5_dia","Perc_oBA5_dia_errMAX","Perc_oBA5_dia_errMIN","Perc_oBQ_dia","Perc_oBQ_dia_errMAX","Perc_oBQ_dia_errMIN",...
    "Perc_oBA2_dia","Perc_oBA2_dia_errMAX","Perc_oBA2_dia_errMIN","Perc_oBA4_dia","Perc_oBA4_dia_errMAX","Perc_oBA4_dia_errMIN","Perc_altres_dia","Perc_altres_dia_errMAX","Perc_altres_dia_errMIN"];
Fitname = ".\DadesCSV_hist_variants_OBQ\Fit_SeqVar_oBA5_oBQ_oBA2_altres"+Country+".csv";
writetable(Fit_oBA5_oBQ,Fitname)

textCaption = ".\Figures_hist_variants_OBQ\" + Country + " oBA5 VS oBQ + oBA2 + oBA4 + Altres " + ID_fitting;
lgd = legend ('oBA5','oBQ','oBA2','oBA4','Others','Model oBA5','Model oBQ','Model oBA2','Linear oBA4','Model Others','Location','west');
lgd.FontSize = 7;
title(Country + " oBA5 VS oBQ + oBA2")
xlim([Day_plot(ID_fitting)-1 Day_plot(final)+1]);
print(textCaption,'-dpng','-r300')
saveas(gcf,textCaption,'fig');
close

                elseif ((fit(5) > 0.005 && (fit(1)<fit(2)|| fit(2)<0) && fit(4)>0) || (fit(5) > 0.005 && fit(2)<0))
global_fit_data = [Fit_Asc1;Fit_Asc2;Fit_Asc4;Fit_Ctt]'; 
global_fit_function = @(params,t) [params(5)*exp(params(1)*t)./(1+params(5)*exp(params(1)*t)+params(8)*exp(params(4)*t)),...
    params(6)+(params(2)*t),...
    params(7)+(params(3)*t),...
    params(8)*exp(params(4)*t)./(1+params(5)*exp(params(1)*t)+params(8)*exp(params(4)*t))]; % Fitting functions%estimem els parametres que utilitzarem
squared_errors = @(params) norm(global_fit_data - global_fit_function(params,t));
options=optimset('MaxFunEvals', 10000000, 'MaxIter',10000000, 'Display', 'final', 'TolX', 1e-0012);
fit = fminsearch(squared_errors,[aa ab ac ad ae af ag ah],options); % BetaBQ, BetaBA2, BetaBA4, Beta_Altres; Ratio_ini_BQ, Ratio_ini_BA2, Ratio_ini_BA4, Ratio_ini_Altres
% Pasem de setmanes a dies, he tret el 7* que la Clara multiplicava al length ja que anava MASSA al futur
                t_plot=(1-2/7):1/7:(length(t)+2/7);
% això (desde 1) es per fer tot el càlcul...amb el 0 és per les imatges.
[paramfit,Resid,Jacob,CovB,MSE,ErrorModelInfo] = nlinfit(t,global_fit_data,global_fit_function,[fit(1) fit(2) fit(3) fit(4) fit(5) fit(6) fit(7) fit(8)]);
[Ypercen,YCI] = nlpredci(global_fit_function,t_plot,paramfit,Resid,'Covar',CovB);
                        Ypercen(Ypercen<0)=0;
paramfit;
conf1 = nlparci(paramfit,Resid,'jacobian',Jacob);
conf2 = nlparci(paramfit,Resid,'covariance',CovB);
% De manera automàtica el programa agafarà els paràmetres fitejats anteriorment com punt de partida
aa=fit(1);ab=fit(2);ac=fit(3);ad=fit(4);ae=fit(5);af=fit(6);ag=fit(7);ah=fit(8);
    n=n+1;
    close
% Les normalitzem respecte a les 3 variants a estudiar
Fitplot_Asc1no = 100*Ypercen(1:length(t_plot));
Fitplot_Asc2no = 100*Ypercen((length(t_plot)+1):(2*length(t_plot)));
Fitplot_Asc4no = 100*Ypercen((2*length(t_plot)+1):(3*length(t_plot)));
Fitplot_Cttno = 100*Ypercen((3*length(t_plot)+1):end);
Fitplot_Descno = 100 - Fitplot_Asc1no - Fitplot_Cttno;
Fitplot_total = Fitplot_Asc1no + Fitplot_Asc2no + Fitplot_Asc4no + Fitplot_Cttno + Fitplot_Descno;
Fitplot_Asc1 = 100*Fitplot_Asc1no./Fitplot_total;
Fitplot_Asc2 = 100*Fitplot_Asc2no./Fitplot_total;
Fitplot_Asc4 = 100*Fitplot_Asc4no./Fitplot_total;
Fitplot_Ctt = 100*Fitplot_Cttno./Fitplot_total;
Fitplot_Desc = 100*Fitplot_Descno./Fitplot_total;

% Trobem els errors
Fitplot_Asc1MAX = Fitplot_Asc1+100*YCI(1:length(t_plot));
Fitplot_Asc1MIN = Fitplot_Asc1-100*YCI(1:length(t_plot));
Fitplot_Asc2MAX = Fitplot_Asc2+100*YCI((length(t_plot)+1):(2*length(t_plot)));
Fitplot_Asc2MIN = Fitplot_Asc2-100*YCI((length(t_plot)+1):(2*length(t_plot)));
Fitplot_Asc4MAX = Fitplot_Asc4+100*YCI((2*length(t_plot)+1):(3*length(t_plot)));
Fitplot_Asc4MIN = Fitplot_Asc4-100*YCI((2*length(t_plot)+1):(3*length(t_plot)));
Fitplot_CttMAX = Fitplot_Ctt+100*YCI((3*length(t_plot)+1):end);
Fitplot_CttMIN = Fitplot_Ctt-100*YCI((3*length(t_plot)+1):end);
Fitplot_DescMAX = Fitplot_Desc + 100*sqrt(YCI(1:length(t_plot)).^2 + YCI((3*length(t_plot)+1):end).^2);
Fitplot_DescMIN = Fitplot_Desc - 100*sqrt(YCI(1:length(t_plot)).^2 + YCI((3*length(t_plot)+1):end).^2);

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
T = table(Fitting_date(1), paramfit(1), abs(conf1(1,1)-paramfit(1)), paramfit(5), abs(conf1(5,1)-paramfit(5)),...
    paramfit(4), abs(conf1(4,1)-paramfit(4)), paramfit(8), abs(conf1(8,1)-paramfit(8)),p, RMSE,...
    'VariableNames',['Inici Fit',"Beta_OBQ","error_B_OBQ","R0_OBQ","error_R0_OBQ",...
    "Beta_Altres","error_B_Altres","R0_Altres","error_R0_Altres","p-value","RMSE"])
Tname = ".\Variables_hist_variants_OBQ\BetaR0_OBA5VSOBQ_altres"+Country+".xlsx";
NameSheet = "Full ID " + ID_fitting;
writetable(T,Tname,"Sheet",NameSheet);

% Sortida de dades experimentals de SIVIC normalitzades segons variants i
% agrupades les "no importants" a Altres
PlotSeqVar_oBA5_oBQ = table(Day_plot', Norm_Desc, Desc_int, Norm_Asc1, Asc1_int, Norm_Asc2, Asc2_int,Norm_Asc4, Asc4_int, Norm_Ctt, Ctt_int);
PlotSeqVar_oBA5_oBQ.Properties.VariableNames = ['Dia',"Perc_oBA5",'Error_oBA5',"Perc_oBQ",'Error_oBQ',"Perc_oBA2",'Error_oBA2',"Perc_oBA4",'Error_oBA4',"Perc_altres","Error_altres"];
Plotname = ".\DadesCSV_hist_variants_OBQ\Plot_SeqVar_oBA5_oBQ_altres" + Country + ".csv";
writetable(PlotSeqVar_oBA5_oBQ,Plotname)

% Preparem la figura: dades SIVIC, observacions ("reals")
figure
errorbar(Day_plot,Norm_Desc,Desc_int,Desc_int,'o','Color',[0.2 0.8 0.80])
hold on
errorbar(Day_plot,Norm_Asc1,Asc1_int,Asc1_int,'o','Color',[0.4 0.2 0.60])
errorbar(Day_plot,Norm_Asc2,Asc2_int,Asc2_int,'o','Color',[0.2 0.8 0.20])
errorbar(Day_plot,Norm_Asc4,Asc4_int,Asc4_int,'o','Color',[0.5 0.05 0.04])
errorbar(Day_plot,Norm_Ctt,Ctt_int,Ctt_int,'o','Color',[0.93 0.69 0.13])

% Definim l'escala del plot perquè després queda massa gran amb el FIT
tstart_plot = datetime(tstart,'InputFormat','dd/MM/yyyy');
tend_plot = datetime(tend,'InputFormat','dd/MM/yyyy');
xlim([tstart_plot tend_plot]);
ylim([0 100]);
%Finalment afegim a la imatge els fits
                    Fitting_date_plot=(Fitting_date(1)-2):(Fitting_date(1)+length(t_plot)-3);
plot(Fitting_date_plot,Fitplot_Desc,'-','Color',[0.2 0.8 0.80])
plot(Fitting_date_plot,Fitplot_Asc1,'-','Color',[0.4 0.2 0.60])
plot(Fitting_date_plot,Fitplot_Asc2,'-','Color',[0.2 0.8 0.2])
plot(Fitting_date_plot,Fitplot_Asc4,'-','Color',[0.5 0.05 0.04])
plot(Fitting_date_plot,Fitplot_Ctt,'-','Color',[0.93 0.69 0.13])

fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_DescMIN flip(Fitplot_DescMAX)],'r','FaceColor',[0.2 0.8 0.80],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc1MIN flip(Fitplot_Asc1MAX)],'r','FaceColor',[0.4 0.2 0.60],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc2MIN flip(Fitplot_Asc2MAX)],'r','FaceColor',[0.2 0.8 0.2],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc4MIN flip(Fitplot_Asc4MAX)],'r','FaceColor',[0.5 0.05 0.04],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_CttMIN flip(Fitplot_CttMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
yline(5,'--'); 

Fit_oBA5_oBQ = table(Fitting_date_plot', Fitplot_Desc',Fitplot_DescMAX',Fitplot_DescMIN', Fitplot_Asc1',Fitplot_Asc1MAX',Fitplot_Asc1MIN',...
    Fitplot_Asc2',Fitplot_Asc2MAX',Fitplot_Asc2MIN',Fitplot_Asc4',Fitplot_Asc4MAX',Fitplot_Asc4MIN',Fitplot_Ctt',Fitplot_CttMAX',Fitplot_CttMIN');
Fit_oBA5_oBQ.Properties.VariableNames = ['Dia',"Perc_oBA5_dia","Perc_oBA5_dia_errMAX","Perc_oBA5_dia_errMIN","Perc_oBQ_dia","Perc_oBQ_dia_errMAX","Perc_oBQ_dia_errMIN",...
    "Perc_oBA2_dia","Perc_oBA2_dia_errMAX","Perc_oBA2_dia_errMIN","Perc_oBA4_dia","Perc_oBA4_dia_errMAX","Perc_oBA4_dia_errMIN","Perc_altres_dia","Perc_altres_dia_errMAX","Perc_altres_dia_errMIN"];
Fitname = ".\DadesCSV_hist_variants_OBQ\Fit_SeqVar_oBA5_oBQ_oBA2_altres"+Country+".csv";
writetable(Fit_oBA5_oBQ,Fitname)

textCaption = ".\Figures_hist_variants_OBQ\" + Country + " oBA5 VS oBQ + oBA2 + oBA4 + Altres " + ID_fitting;
lgd = legend ('oBA5','oBQ','oBA2','oBA4','Others','Model oBA5','Model oBQ','Linear oBA2','Linear oBA4','Model Others','Location','west');
lgd.FontSize = 7;
title(Country + " oBA5 VS oBQ + oBA2")
xlim([Day_plot(ID_fitting)-1 Day_plot(final)+1]);
print(textCaption,'-dpng','-r300')
saveas(gcf,textCaption,'fig');
close

                elseif ((fit(5) > 0.005 && (fit(1)<fit(2) || fit(2)<0) && (fit(1)<fit(4) || fit(4)<0)) || (fit(5) > 0.005 && fit(2)<0 && fit(4)<0))
global_fit_data = [Fit_Asc1;Fit_Asc2;Fit_Asc4;Fit_Ctt]'; 
global_fit_function = @(params,t) [params(5)*exp(params(1)*t)./(1+params(5)*exp(params(1)*t)),...
    params(6)+(params(2)*t),...
    params(7)+(params(3)*t),...
    params(8)+(params(4)*t)]; % Fitting functions
%estimem els parametres que utilitzarem
squared_errors = @(params) norm(global_fit_data - global_fit_function(params,t));
options=optimset('MaxFunEvals', 10000000, 'MaxIter',10000000, 'Display', 'final', 'TolX', 1e-0012);
fit = fminsearch(squared_errors,[aa ab ac ad ae af ag ah],options); % BetaBQ, BetaBA2, BetaBA4, Beta_Altres; Ratio_ini_BQ, Ratio_ini_BA2, Ratio_ini_BA4, Ratio_ini_Altres
% Pasem de setmanes a dies, he tret el 7* que la Clara multiplicava al length ja que anava MASSA al futur
                t_plot=(1-2/7):1/7:(length(t)+2/7);
% això (desde 1) es per fer tot el càlcul...amb el 0 és per les imatges.
[paramfit,Resid,Jacob,CovB,MSE,ErrorModelInfo] = nlinfit(t,global_fit_data,global_fit_function,[fit(1) fit(2) fit(3) fit(4) fit(5) fit(6) fit(7) fit(8)]);
[Ypercen,YCI] = nlpredci(global_fit_function,t_plot,paramfit,Resid,'Covar',CovB);
                        Ypercen(Ypercen<0)=0;
paramfit;
conf1 = nlparci(paramfit,Resid,'jacobian',Jacob);
conf2 = nlparci(paramfit,Resid,'covariance',CovB);
% De manera automàtica el programa agafarà els paràmetres fitejats anteriorment com punt de partida
aa=fit(1);ab=fit(2);ac=fit(3);ad=fit(4);ae=fit(5);af=fit(6);ag=fit(7);ah=fit(8);
    n=n+1;
    close
% Les normalitzem respecte a les 3 variants a estudiar
Fitplot_Asc1no = 100*Ypercen(1:length(t_plot));
Fitplot_Asc2no = 100*Ypercen((length(t_plot)+1):(2*length(t_plot)));
Fitplot_Asc4no = 100*Ypercen((2*length(t_plot)+1):(3*length(t_plot)));
Fitplot_Cttno = 100*Ypercen((3*length(t_plot)+1):end);
Fitplot_Descno = 100 - Fitplot_Asc1no;
Fitplot_total = Fitplot_Asc1no + Fitplot_Asc2no + Fitplot_Asc4no + Fitplot_Cttno + Fitplot_Descno;
Fitplot_Asc1 = 100*Fitplot_Asc1no./Fitplot_total;
Fitplot_Asc2 = 100*Fitplot_Asc2no./Fitplot_total;
Fitplot_Asc4 = 100*Fitplot_Asc4no./Fitplot_total;
Fitplot_Ctt = 100*Fitplot_Cttno./Fitplot_total;
Fitplot_Desc = 100*Fitplot_Descno./Fitplot_total;

% Trobem els errors
Fitplot_Asc1MAX = Fitplot_Asc1+100*YCI(1:length(t_plot));
Fitplot_Asc1MIN = Fitplot_Asc1-100*YCI(1:length(t_plot));
Fitplot_Asc2MAX = Fitplot_Asc2+100*YCI((length(t_plot)+1):(2*length(t_plot)));
Fitplot_Asc2MIN = Fitplot_Asc2-100*YCI((length(t_plot)+1):(2*length(t_plot)));
Fitplot_Asc4MAX = Fitplot_Asc4+100*YCI((2*length(t_plot)+1):(3*length(t_plot)));
Fitplot_Asc4MIN = Fitplot_Asc4-100*YCI((2*length(t_plot)+1):(3*length(t_plot)));
Fitplot_CttMAX = Fitplot_Ctt+100*YCI((3*length(t_plot)+1):end);
Fitplot_CttMIN = Fitplot_Ctt-100*YCI((3*length(t_plot)+1):end);
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
T = table(Fitting_date(1), paramfit(1), abs(conf1(1,1)-paramfit(1)), paramfit(5), abs(conf1(5,1)-paramfit(5)),p, RMSE,...
    'VariableNames',['Inici Fit',"Beta_OBQ","error_B_OBQ","R0_OBQ","error_R0_OBQ","p-value","RMSE"])
Tname = ".\Variables_hist_variants_OBQ\BetaR0_OBA5VSOBQ_altres"+Country+".xlsx";
NameSheet = "Full ID " + ID_fitting;
writetable(T,Tname,"Sheet",NameSheet);

% Sortida de dades experimentals de SIVIC normalitzades segons variants i
% agrupades les "no importants" a Altres
PlotSeqVar_oBA5_oBQ = table(Day_plot', Norm_Desc, Desc_int, Norm_Asc1, Asc1_int, Norm_Asc2, Asc2_int,Norm_Asc4, Asc4_int, Norm_Ctt, Ctt_int);
PlotSeqVar_oBA5_oBQ.Properties.VariableNames = ['Dia',"Perc_oBA5",'Error_oBA5',"Perc_oBQ",'Error_oBQ',"Perc_oBA2",'Error_oBA2',"Perc_oBA4",'Error_oBA4',"Perc_altres","Error_altres"];
Plotname = ".\DadesCSV_hist_variants_OBQ\Plot_SeqVar_oBA5_oBQ_altres" + Country + ".csv";
writetable(PlotSeqVar_oBA5_oBQ,Plotname)

% Preparem la figura: dades SIVIC, observacions ("reals")
figure
errorbar(Day_plot,Norm_Desc,Desc_int,Desc_int,'o','Color',[0.2 0.8 0.80])
hold on
errorbar(Day_plot,Norm_Asc1,Asc1_int,Asc1_int,'o','Color',[0.4 0.2 0.60])
errorbar(Day_plot,Norm_Asc2,Asc2_int,Asc2_int,'o','Color',[0.2 0.8 0.20])
errorbar(Day_plot,Norm_Asc4,Asc4_int,Asc4_int,'o','Color',[0.5 0.05 0.04])
errorbar(Day_plot,Norm_Ctt,Ctt_int,Ctt_int,'o','Color',[0.93 0.69 0.13])

% Definim l'escala del plot perquè després queda massa gran amb el FIT
tstart_plot = datetime(tstart,'InputFormat','dd/MM/yyyy');
tend_plot = datetime(tend,'InputFormat','dd/MM/yyyy');
xlim([tstart_plot tend_plot]);
ylim([0 100]);
%Finalment afegim a la imatge els fits
                    Fitting_date_plot=(Fitting_date(1)-2):(Fitting_date(1)+length(t_plot)-3);
plot(Fitting_date_plot,Fitplot_Desc,'-','Color',[0.2 0.8 0.80])
plot(Fitting_date_plot,Fitplot_Asc1,'-','Color',[0.4 0.2 0.60])
plot(Fitting_date_plot,Fitplot_Asc2,'-','Color',[0.2 0.8 0.2])
plot(Fitting_date_plot,Fitplot_Asc4,'-','Color',[0.5 0.05 0.04])
plot(Fitting_date_plot,Fitplot_Ctt,'-','Color',[0.93 0.69 0.13])

fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_DescMIN flip(Fitplot_DescMAX)],'r','FaceColor',[0.2 0.8 0.80],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc1MIN flip(Fitplot_Asc1MAX)],'r','FaceColor',[0.4 0.2 0.60],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc2MIN flip(Fitplot_Asc2MAX)],'r','FaceColor',[0.2 0.8 0.2],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc4MIN flip(Fitplot_Asc4MAX)],'r','FaceColor',[0.5 0.05 0.04],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_CttMIN flip(Fitplot_CttMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
yline(5,'--'); 

Fit_oBA5_oBQ = table(Fitting_date_plot', Fitplot_Desc',Fitplot_DescMAX',Fitplot_DescMIN', Fitplot_Asc1',Fitplot_Asc1MAX',Fitplot_Asc1MIN',...
    Fitplot_Asc2',Fitplot_Asc2MAX',Fitplot_Asc2MIN',Fitplot_Asc4',Fitplot_Asc4MAX',Fitplot_Asc4MIN',Fitplot_Ctt',Fitplot_CttMAX',Fitplot_CttMIN');
Fit_oBA5_oBQ.Properties.VariableNames = ['Dia',"Perc_oBA5_dia","Perc_oBA5_dia_errMAX","Perc_oBA5_dia_errMIN","Perc_oBQ_dia","Perc_oBQ_dia_errMAX","Perc_oBQ_dia_errMIN",...
    "Perc_oBA2_dia","Perc_oBA2_dia_errMAX","Perc_oBA2_dia_errMIN","Perc_oBA4_dia","Perc_oBA4_dia_errMAX","Perc_oBA4_dia_errMIN","Perc_altres_dia","Perc_altres_dia_errMAX","Perc_altres_dia_errMIN"];
Fitname = ".\DadesCSV_hist_variants_OBQ\Fit_SeqVar_oBA5_oBQ_oBA2_altres"+Country+".csv";
writetable(Fit_oBA5_oBQ,Fitname)

textCaption = ".\Figures_hist_variants_OBQ\" + Country + " oBA5 VS oBQ + oBA2 + oBA4 + Altres " + ID_fitting;
lgd = legend ('oBA5','oBQ','oBA2','oBA4','Others','Model oBA5','Model oBQ','Linear oBA2','Linear oBA4','Linear Others','Location','west');
lgd.FontSize = 7;
title(Country + " oBA5 VS oBQ + oBA2")
xlim([Day_plot(ID_fitting)-1 Day_plot(final)+1]);
print(textCaption,'-dpng','-r300')
saveas(gcf,textCaption,'fig');
close

                elseif ((fit(5) > 0.005 && fit(1)>fit(2) && (fit(1)<fit(4) || fit(4)<0) && fit(2)>0) || (fit(5) > 0.005 && fit(4)<0))
                disp("*********************is working!!****************")
                
global_fit_data = [Fit_Asc1;Fit_Asc2;Fit_Asc4;Fit_Ctt]'; 
global_fit_function = @(params,t) [params(5)*exp(params(1)*t)./(1+params(5)*exp(params(1)*t)+params(6)*exp(params(2)*t)),...
    params(6)*exp(params(2)*t)./(1+params(5)*exp(params(1)*t)+params(6)*exp(params(2)*t)),...
    params(7)+(params(3)*t),...
    params(8)+(params(4)*t)]; % Fitting functionssquared_errors = @(params) norm(global_fit_data - global_fit_function(params,t));
options=optimset('MaxFunEvals', 10000000, 'MaxIter',10000000, 'Display', 'final', 'TolX', 1e-0012);
fit = fminsearch(squared_errors,[aa ab ac ad ae af ag ah],options); % BetaBQ, BetaBA2, BetaBA4, Beta_Altres; Ratio_ini_BQ, Ratio_ini_BA2, Ratio_ini_BA4, Ratio_ini_Altres
% Pasem de setmanes a dies, he tret el 7* que la Clara multiplicava al length ja que anava MASSA al futur
                t_plot=(1-2/7):1/7:(length(t)+2/7);
% això (desde 1) es per fer tot el càlcul...amb el 0 és per les imatges.
[paramfit,Resid,Jacob,CovB,MSE,ErrorModelInfo] = nlinfit(t,global_fit_data,global_fit_function,[fit(1) fit(2) fit(3) fit(4) fit(5) fit(6) fit(7) fit(8)]);
[Ypercen,YCI] = nlpredci(global_fit_function,t_plot,paramfit,Resid,'Covar',CovB);
                        Ypercen(Ypercen<0)=0;
paramfit;
conf1 = nlparci(paramfit,Resid,'jacobian',Jacob);
conf2 = nlparci(paramfit,Resid,'covariance',CovB);
% De manera automàtica el programa agafarà els paràmetres fitejats anteriorment com punt de partida
aa=fit(1);ab=fit(2);ac=fit(3);ad=fit(4);ae=fit(5);af=fit(6);ag=fit(7);ah=fit(8);
    n=n+1;
    close
% Les normalitzem respecte a les 3 variants a estudiar
Fitplot_Asc1no = 100*Ypercen(1:length(t_plot));
Fitplot_Asc2no = 100*Ypercen((length(t_plot)+1):(2*length(t_plot)));
Fitplot_Asc4no = 100*Ypercen((2*length(t_plot)+1):(3*length(t_plot)));
Fitplot_Cttno = 100*Ypercen((3*length(t_plot)+1):end);
Fitplot_Descno = 100 - Fitplot_Asc1no - Fitplot_Asc2no;
Fitplot_total = Fitplot_Asc1no + Fitplot_Asc2no + Fitplot_Asc4no + Fitplot_Cttno + Fitplot_Descno;
Fitplot_Asc1 = 100*Fitplot_Asc1no./Fitplot_total;
Fitplot_Asc2 = 100*Fitplot_Asc2no./Fitplot_total;
Fitplot_Asc4 = 100*Fitplot_Asc4no./Fitplot_total;
Fitplot_Ctt = 100*Fitplot_Cttno./Fitplot_total;
Fitplot_Desc = 100*Fitplot_Descno./Fitplot_total;

% Trobem els errors
Fitplot_Asc1MAX = Fitplot_Asc1+100*YCI(1:length(t_plot));
Fitplot_Asc1MIN = Fitplot_Asc1-100*YCI(1:length(t_plot));
Fitplot_Asc2MAX = Fitplot_Asc2+100*YCI((length(t_plot)+1):(2*length(t_plot)));
Fitplot_Asc2MIN = Fitplot_Asc2-100*YCI((length(t_plot)+1):(2*length(t_plot)));
Fitplot_Asc4MAX = Fitplot_Asc4+100*YCI((2*length(t_plot)+1):(3*length(t_plot)));
Fitplot_Asc4MIN = Fitplot_Asc4-100*YCI((2*length(t_plot)+1):(3*length(t_plot)));
Fitplot_CttMAX = Fitplot_Ctt+100*YCI((3*length(t_plot)+1):end);
Fitplot_CttMIN = Fitplot_Ctt-100*YCI((3*length(t_plot)+1):end);
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
T = table(Fitting_date(1), paramfit(1), abs(conf1(1,1)-paramfit(1)), paramfit(5), abs(conf1(5,1)-paramfit(5)),...
    paramfit(2), abs(conf1(2,1)-paramfit(2)), paramfit(6), abs(conf1(6,1)-paramfit(6)),p, RMSE,...
    'VariableNames',['Inici Fit',"Beta_OBQ","error_B_OBQ","R0_OBQ","error_R0_OBQ",...
    "Beta_OBA2","error_B_OBA2","R0_OBA2","error_R0_OBA2","p-value","RMSE"])
Tname = ".\Variables_hist_variants_OBQ\BetaR0_OBA5VSOBQ_altres"+Country+".xlsx";
NameSheet = "Full ID " + ID_fitting;
writetable(T,Tname,"Sheet",NameSheet);

% Sortida de dades experimentals de SIVIC normalitzades segons variants i
% agrupades les "no importants" a Altres
PlotSeqVar_oBA5_oBQ = table(Day_plot', Norm_Desc, Desc_int, Norm_Asc1, Asc1_int, Norm_Asc2, Asc2_int,Norm_Asc4, Asc4_int, Norm_Ctt, Ctt_int);
PlotSeqVar_oBA5_oBQ.Properties.VariableNames = ['Dia',"Perc_oBA5",'Error_oBA5',"Perc_oBQ",'Error_oBQ',"Perc_oBA2",'Error_oBA2',"Perc_oBA4",'Error_oBA4',"Perc_altres","Error_altres"];
Plotname = ".\DadesCSV_hist_variants_OBQ\Plot_SeqVar_oBA5_oBQ_altres" + Country + ".csv";
writetable(PlotSeqVar_oBA5_oBQ,Plotname)

% Preparem la figura: dades SIVIC, observacions ("reals")
figure
errorbar(Day_plot,Norm_Desc,Desc_int,Desc_int,'o','Color',[0.2 0.8 0.80])
hold on
errorbar(Day_plot,Norm_Asc1,Asc1_int,Asc1_int,'o','Color',[0.4 0.2 0.60])
errorbar(Day_plot,Norm_Asc2,Asc2_int,Asc2_int,'o','Color',[0.2 0.8 0.20])
errorbar(Day_plot,Norm_Asc4,Asc4_int,Asc4_int,'o','Color',[0.5 0.05 0.04])
errorbar(Day_plot,Norm_Ctt,Ctt_int,Ctt_int,'o','Color',[0.93 0.69 0.13])

% Definim l'escala del plot perquè després queda massa gran amb el FIT
tstart_plot = datetime(tstart,'InputFormat','dd/MM/yyyy');
tend_plot = datetime(tend,'InputFormat','dd/MM/yyyy');
xlim([tstart_plot tend_plot]);
ylim([0 100]);
%Finalment afegim a la imatge els fits
                    Fitting_date_plot=(Fitting_date(1)-2):(Fitting_date(1)+length(t_plot)-3);
plot(Fitting_date_plot,Fitplot_Desc,'-','Color',[0.2 0.8 0.80])
plot(Fitting_date_plot,Fitplot_Asc1,'-','Color',[0.4 0.2 0.60])
plot(Fitting_date_plot,Fitplot_Asc2,'-','Color',[0.2 0.8 0.2])
plot(Fitting_date_plot,Fitplot_Asc4,'-','Color',[0.5 0.05 0.04])
plot(Fitting_date_plot,Fitplot_Ctt,'-','Color',[0.93 0.69 0.13])

fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_DescMIN flip(Fitplot_DescMAX)],'r','FaceColor',[0.2 0.8 0.80],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc1MIN flip(Fitplot_Asc1MAX)],'r','FaceColor',[0.4 0.2 0.60],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc2MIN flip(Fitplot_Asc2MAX)],'r','FaceColor',[0.2 0.8 0.2],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc4MIN flip(Fitplot_Asc4MAX)],'r','FaceColor',[0.5 0.05 0.04],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_CttMIN flip(Fitplot_CttMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
yline(5,'--'); 

Fit_oBA5_oBQ = table(Fitting_date_plot', Fitplot_Desc',Fitplot_DescMAX',Fitplot_DescMIN', Fitplot_Asc1',Fitplot_Asc1MAX',Fitplot_Asc1MIN',...
    Fitplot_Asc2',Fitplot_Asc2MAX',Fitplot_Asc2MIN',Fitplot_Asc4',Fitplot_Asc4MAX',Fitplot_Asc4MIN',Fitplot_Ctt',Fitplot_CttMAX',Fitplot_CttMIN');
Fit_oBA5_oBQ.Properties.VariableNames = ['Dia',"Perc_oBA5_dia","Perc_oBA5_dia_errMAX","Perc_oBA5_dia_errMIN","Perc_oBQ_dia","Perc_oBQ_dia_errMAX","Perc_oBQ_dia_errMIN",...
    "Perc_oBA2_dia","Perc_oBA2_dia_errMAX","Perc_oBA2_dia_errMIN","Perc_oBA4_dia","Perc_oBA4_dia_errMAX","Perc_oBA4_dia_errMIN","Perc_altres_dia","Perc_altres_dia_errMAX","Perc_altres_dia_errMIN"];
Fitname = ".\DadesCSV_hist_variants_OBQ\Fit_SeqVar_oBA5_oBQ_oBA2_altres"+Country+".csv";
writetable(Fit_oBA5_oBQ,Fitname)

textCaption = ".\Figures_hist_variants_OBQ\" + Country + " oBA5 VS oBQ + oBA2 + oBA4 + Altres " + ID_fitting;
lgd = legend ('oBA5','oBQ','oBA2','oBA4','Others','Model oBA5','Model oBQ','Model oBA2','Linear oBA4','Linear Others','Location','west');
lgd.FontSize = 7;
title(Country + " oBA5 VS oBQ + oBA2")
xlim([Day_plot(ID_fitting)-1 Day_plot(final)+1]);
print(textCaption,'-dpng','-r300')
saveas(gcf,textCaption,'fig');
close
                else
                    n;
                end %aquí acaba les imatges i/o càlculs... el segon "if"
        else 
            n;
        end %aquí acabarà el programa quan n=>4

    end %aquí acaba el primer "if" el de fer només 3 pasos
        BOBQ=paramfit(1); BerrOBQ=abs(conf1(1,1)-paramfit(1)); R0OBQ=paramfit(5); R0errOBQ=abs(conf1(5,1)-paramfit(5));
        DayOBQ = Fitting_date_plot(find(Fitplot_Asc1 > 5,1));
        DayOBQ20 = Fitting_date_plot(find(Fitplot_Asc1 > 20,1));
        
end %aquí acaba per tots els països
