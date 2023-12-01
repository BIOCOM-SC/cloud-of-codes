function     [BAlpha,BerrAlpha,R0Alpha,R0errAlpha,DayAlpha,DayAlpha20,DayAlpha40,DayAlpha60,DayAlpha80] = FWuhanAlphab(N_Desc, N_Asc1, N_Ctt,Country,WeekThurs)
% Substitution process for the Wuhan vs Alpha substitution

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

% Trobem els errors "binomial" (o tinc la variant o NO la tinc) de les
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
        if Country =="Spain"
            principi = princ1 - 7;
        elseif (Country =="Croatia" || Country == "Cyprus" )
            principi = princ1 - 3;
        elseif Country == "Austria"
            principi = princ1 - 8;
        elseif Country == "Slovakia"
            principi = princ1 + 5;
        elseif (Country == "Poland" || Country == "Belgium" )
            principi = princ1 - 5; 
        elseif Country =="Portugal" || Country == "Finland" 
            principi = princ1 - 6;
        elseif Country == "Czechia" || Country == "Romania" || Country == "France"
            principi = princ1 - 8;
        elseif Country == "Greece" 
            principi = princ1 +0 ;
        elseif Country=="Ireland"
            principi = princ1 - 5;
        else
        principi = princ1-4;
        end

        if principi == 0
            principi = 1;
        end
% i on l'acabem!!
final2 = 0;
final1 = find(Norm_Asc1>70,1);

% Preparem on ACABEM el fitting, perquè sigui automàtic
            try
                while final2 == 0
                    final2 = Norm_Asc1(final1)>80 && Norm_Asc1(final1)>Norm_Asc1(final1+1) && Norm_Asc1(final1+1)>75;
                    final1 = final1+1;
                end
                final = final1-1; %recuperem l'ultim valor que hem analitzat  
            catch
                        final = find(Norm_Asc1 == max(Norm_Asc1),1);
            end
                if ( Country == "Greece"  || Country == "Estonia" || Country == "Austria" || Country == "Latvia" )
                    final = final + 3;
                elseif Country == "Romania"
                    final = final + 7;
                elseif Country =="Finland"
                    final = final-6;
                elseif (Country == "Cyprus" || Country=="Denmark")
                    final = final + 3;
                elseif Country == "Iceland"
                    final = final +5;
                elseif Country == "Italy"
                    final = final + 0;
                elseif Country == "Slovakia"
                    final = final + 10;
                elseif  Country == "France"
                    final = final +3;
                elseif Country =="Spain"
                    final = final + 0;
                end
% Els paràmetres Beta i R0 necessiten un valor inicial que després s'anirà
% ajustant:
aa=0.3;ab=0.2;ac=0.01;ad=0.02;
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

                if (fit(3) > 0.004 && fit(1)>fit(2) && fit(2) > 0 && fit(1)<5) %original fit(3) > 0.004
                    n=n+1;

% Pasem de setmanes a dies, he tret el 7* que la Clara multiplicava al length ja que anava MASSA al futur
                t_plot=(1-2/7):1/7:(length(t)+2/7);
% això (desde 1) es per fer tot el càlcul...amb el 0 és per les imatges.
                [paramfit,Resid,Jacob,CovB,~,~] = nlinfit(t,global_fit_data,global_fit_function,[fit(1) fit(2) fit(3) fit(4)]);
                [Ypercen,YCI] = nlpredci(global_fit_function,t_plot,paramfit,Resid,'Covar',CovB);
Ypercen(Ypercen<0)=0;

                conf1 = nlparci(paramfit,Resid,'jacobian',Jacob);
%                 conf2 = nlparci(paramfit,Resid,'covariance',CovB);
% De manera automàtica el programa agafarà els paràmetres fitejats anteriorment com punt de partida
                aa=fit(1);ab=fit(2);ac=fit(3);ad=fit(4);

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

% A continuació hi ha unes linies per calcular el RMSE de manera manual
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
                        'VariableNames',['Inici Fit',"Beta_alfa","error_B_alfa","R0_alfa","error_R0_alfa","Beta_Altres","error_B_Altres","R0_Altres","error_R0_Altres","p-value","RMSE"])
                    Tname = ".\Variables_hist_variants_Alfa\BetaR0_WuhanVSAlfa_altres"+Country+".xlsx";
                    NameSheet = "Full ID " + ID_fitting;
                    writetable(T,Tname,"Sheet",NameSheet);
% Sortida de dades experimentals de SIVIC normalitzades segons variants i agrupades les "no importants" a Altres
                    PlotSeqVar_wuhan_alfa = table(Day_plot', Norm_Desc, Desc_int, Norm_Asc1, Asc1_int, Norm_Ctt, Ctt_int);
                    PlotSeqVar_wuhan_alfa.Properties.VariableNames = ['Dia',"Perc_wuhan",'Error_wuhan',"Perc_alfa",'Error_alfa',"Perc_altres","Error_altres"];
                    Plotname = ".\DadesCSV_hist_variants_Alfa\Plot_SeqVar_wuhan_alfa_altres" + Country + ".csv";
                    writetable(PlotSeqVar_wuhan_alfa,Plotname)
% Preparem la figura: dades SIVIC, observacions ("reals")
                    figure
                    errorbar(Day_plot,Norm_Desc,Desc_int,Desc_int,'o','Color',[1 0. 0.10])
                    hold on
                    errorbar(Day_plot,Norm_Asc1,Asc1_int,Asc1_int,'o','Color',[0.00 0.45 0.74])
                    errorbar(Day_plot,Norm_Ctt,Ctt_int,Ctt_int,'o','Color',[0.93 0.69 0.13])
% Definim l'escala del plot perquè després queda massa gran amb el FIT
                    tstart_plot = datetime(tstart,'InputFormat','dd/MM/yyyy');
                    tend_plot = datetime(tend,'InputFormat','dd/MM/yyyy');
                    xlim([tstart_plot tend_plot]);
                    ylim([0 100]);
%Finalment afegim a la imatge els fits
                    Fitting_date_plot=(Fitting_date(1)-2):(Fitting_date(1)+length(t_plot)-3);
                    plot(Fitting_date_plot,Fitplot_Desc,'-','Color',[1 0. 0.10])
                    plot(Fitting_date_plot,Fitplot_Asc1,'-','Color',[0.00 0.45 0.74])
                    plot(Fitting_date_plot,Fitplot_Ctt,'-','Color',[0.93 0.69 0.13])
                    
                    fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_DescMIN flip(Fitplot_DescMAX)],'r','FaceColor',[1 0. 0.10],'FaceAlpha',0.3,'EdgeColor','none');
                    fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc1MIN flip(Fitplot_Asc1MAX)],'r','FaceColor',[0.00 0.45 0.740],'FaceAlpha',0.3,'EdgeColor','none');
                    fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_CttMIN flip(Fitplot_CttMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
                    yline(5,'--'); 

                    Fit_wuhan_alfa = table(Fitting_date_plot', Fitplot_Desc',Fitplot_DescMAX',Fitplot_DescMIN', Fitplot_Asc1',Fitplot_Asc1MAX',Fitplot_Asc1MIN',Fitplot_Ctt',Fitplot_CttMAX',Fitplot_CttMIN');
                    Fit_wuhan_alfa.Properties.VariableNames = ['Dia',"Perc_wuhan_dia","Perc_wuhan_dia_errMAX","Perc_wuhan_dia_errMIN","Perc_alfa_dia","Perc_alfa_dia_errMAX","Perc_alfa_dia_errMIN","Perc_altres_dia","Perc_altres_dia_errMAX","Perc_altres_dia_errMIN"];
                    Fitname = ".\DadesCSV_hist_variants_Alfa\Fit_SeqVar_wuhan_alfa_altres"+Country+".csv";
                    writetable(Fit_wuhan_alfa,Fitname)
                    
                    textCaption = ".\Figures_hist_variants_Alfa\" + Country + " pre-Alpha VS Alpha + Altres " + ID_fitting;
                    lgd = legend ('pre-Alpha','Alpha','Others','Model pre-Alpha','Model Alpha','Model Others','Location','best');
                    lgd.FontSize = 7;
                    title(Country + " pre-Alpha VS Alpha")
                    xlim([Day_plot(ID_fitting)-1 Day_plot(final)+1]);
                    print(textCaption,'-dpng','-r300')

                elseif ((fit(3) > 0.004 && fit(1)<fit(2) && fit(1)<5) || (fit(3) > 0.004 && fit(2) < 0 && fit(1)<5))
                    %original fit(3) > 0.004
                    global_fit_data = [Fit_Asc1;Fit_Ctt]'; 
                    global_fit_function = @(params,t) [params(3)*exp(params(1)*t)./(1+params(3)*exp(params(1)*t)),...
                        params(4)+(params(2)*t)]; % Fitting functions
                    squared_errors = @(params) norm(global_fit_data - global_fit_function(params,t));
                    options=optimset('MaxFunEvals', 10000000, 'MaxIter',10000000, 'Display', 'final', 'TolX', 1e-0012);
                    fit = fminsearch(squared_errors,[aa ab ac ad],options); % BetaAlpha, BetaOther; Ratio_ini_Alpha, Ratio_ini_Other
                t_plot=(1-2/7):1/7:(length(t)+2/7);
                    [paramfit,Resid,Jacob,CovB,MSE,ErrorModelInfo] = nlinfit(t,global_fit_data,global_fit_function,[fit(1) fit(2) fit(3) fit(4)]);
                    [Ypercen,YCI] = nlpredci(global_fit_function,t_plot,paramfit,Resid,'Covar',CovB);
Ypercen(Ypercen<0)=0;

                    conf1 = nlparci(paramfit,Resid,'jacobian',Jacob);
                    aa=fit(1);ab=fit(2);ac=fit(3);ad=fit(4);
                        n=n+1;
                    Fitplot_Asc1no = 100*Ypercen(1:length(t_plot));
                    Fitplot_Cttno = 100*Ypercen((length(t_plot)+1):end);
                    Fitplot_Descno = 100 - Fitplot_Asc1no;
                    Fitplot_total = Fitplot_Asc1no + Fitplot_Cttno + Fitplot_Descno;
                    Fitplot_Asc1 = 100*Fitplot_Asc1no./Fitplot_total;
                    Fitplot_Ctt = 100*Fitplot_Cttno./Fitplot_total;
                    Fitplot_Desc = 100*Fitplot_Descno./Fitplot_total;
                    
                    Fitplot_Asc1MAX = Fitplot_Asc1+100*YCI(1:length(t_plot));
                    Fitplot_Asc1MIN = Fitplot_Asc1-100*YCI(1:length(t_plot));
                    Fitplot_CttMAX = Fitplot_Ctt+100*YCI((length(t_plot)+1):end);
                    Fitplot_CttMIN = Fitplot_Ctt-100*YCI((length(t_plot)+1):end);
                    Fitplot_DescMAX = Fitplot_Desc + 100*sqrt(YCI(1:length(t_plot)).^2);
                    Fitplot_DescMIN = Fitplot_Desc - 100*sqrt(YCI(1:length(t_plot)).^2);
                    
                    for tt = 1:length(t)
                        tajust = tt*7-6;
                        Fitajust_Asc1 (tt) = Fitplot_Asc1(tajust);
                        ttt = ID_fitting+tt-1;
                        Norm_Asc1RMSE (tt)= Norm_Asc1(ttt);
                    end
                    [h,p] = ttest2(Norm_Asc1RMSE,Fitajust_Asc1); %H0
                    RMSE = sqrt(mean((Norm_Asc1RMSE - Fitajust_Asc1).^2)); % Compute RMSE
                    
                    T = table(Fitting_date(1), paramfit(1), abs(conf1(1,1)-paramfit(1)), paramfit(3), abs(conf1(3,1)-paramfit(3)), p, RMSE,...
                        'VariableNames',['Inici Fit',"Beta_alfa","error_B_alfa","R0_alfa","error_R0_alfa","p-value","RMSE"])
                    Tname = ".\Variables_hist_variants_Alfa\BetaR0_WuhanVSAlfa_altres"+Country+".xlsx";
                    NameSheet = "Full ID " + ID_fitting;
                    writetable(T,Tname,"Sheet",NameSheet);
                    
                    PlotSeqVar_wuhan_alfa = table(Day_plot', Norm_Desc, Desc_int, Norm_Asc1, Asc1_int, Norm_Ctt, Ctt_int);
                    PlotSeqVar_wuhan_alfa.Properties.VariableNames = ['Dia',"Perc_wuhan",'Error_wuhan',"Perc_alfa",'Error_alfa',"Perc_altres","Error_altres"];
                    Plotname = ".\DadesCSV_hist_variants_Alfa\Plot_SeqVar_wuhan_alfa_altres" + Country + ".csv";
                    writetable(PlotSeqVar_wuhan_alfa,Plotname)
                    
                    figure
                    errorbar(Day_plot,Norm_Desc,Desc_int,Desc_int,'o','Color',[1 0. 0.10])
                    hold on
                    errorbar(Day_plot,Norm_Asc1,Asc1_int,Asc1_int,'o','Color',[0.00 0.45 0.74])
                    errorbar(Day_plot,Norm_Ctt,Ctt_int,Ctt_int,'o','Color',[0.93 0.69 0.13])
                    
                    tstart_plot = datetime(tstart,'InputFormat','dd/MM/yyyy');
                    tend_plot = datetime(tend,'InputFormat','dd/MM/yyyy');
                    xlim([tstart_plot tend_plot]);
                    ylim([0 100]);
                    Fitting_date_plot=(Fitting_date(1)-2):(Fitting_date(1)+length(t_plot)-3);                    
                    plot(Fitting_date_plot,Fitplot_Desc,'-','Color',[1 0. 0.10])
                    plot(Fitting_date_plot,Fitplot_Asc1,'-','Color',[0.00 0.45 0.74])
                    plot(Fitting_date_plot,Fitplot_Ctt,'-','Color',[0.93 0.69 0.13])
                    
                    fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_DescMIN flip(Fitplot_DescMAX)],'r','FaceColor',[1 0. 0.10],'FaceAlpha',0.3,'EdgeColor','none');
                    fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc1MIN flip(Fitplot_Asc1MAX)],'r','FaceColor',[0.00 0.45 0.740],'FaceAlpha',0.3,'EdgeColor','none');
                    fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_CttMIN flip(Fitplot_CttMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
                    yline(5,'--'); 

                    Fit_wuhan_alfa = table(Fitting_date_plot', Fitplot_Desc',Fitplot_DescMAX',Fitplot_DescMIN', Fitplot_Asc1',Fitplot_Asc1MAX',Fitplot_Asc1MIN',Fitplot_Ctt',Fitplot_CttMAX',Fitplot_CttMIN');
                    Fit_wuhan_alfa.Properties.VariableNames = ['Dia',"Perc_wuhan_dia","Perc_wuhan_dia_errMAX","Perc_wuhan_dia_errMIN","Perc_alfa_dia","Perc_alfa_dia_errMAX","Perc_alfa_dia_errMIN","Perc_altres_dia","Perc_altres_dia_errMAX","Perc_altres_dia_errMIN"];
                    Fitname = ".\DadesCSV_hist_variants_Alfa\Fit_SeqVar_wuhan_alfa_altres"+Country+".csv";
                    writetable(Fit_wuhan_alfa,Fitname)
                    
                    textCaption = ".\Figures_hist_variants_Alfa\" + Country + " pre-Alpha VS Alpha + Altres " + ID_fitting;
                    lgd = legend ('pre-Alpha','Alpha','Others','Model pre-Alpha','Model Alpha','Linear Others','Location','best');
                    lgd.FontSize = 7;
                    title(Country + " pre-Alpha VS Alpha")
                    xlim([Day_plot(ID_fitting)-1 Day_plot(final)+1]);
                    print(textCaption,'-dpng','-r300')

                end
        else
            n;
        end %aquí acaba les imatges i/o càlculs... el segon "if"
    end %aquí acabarà el programa quan n=>4
    BAlpha=paramfit(1); BerrAlpha=abs(conf1(1,1)-paramfit(1)); R0Alpha=paramfit(3); R0errAlpha=abs(conf1(3,1)-paramfit(3));
    DayAlpha = Fitting_date_plot(find(Fitplot_Asc1 > 5,1));
    DayAlpha20 = Fitting_date_plot(find(Fitplot_Asc1 > 20,1));
        DayAlpha40 = Fitting_date_plot(find(Fitplot_Asc1 > 40,1));
    DayAlpha60 = Fitting_date_plot(find(Fitplot_Asc1 > 60,1));
        DayAlpha80 = Fitting_date_plot(find(Fitplot_Asc1 > 80,1));
            close all

end %aquí acaba el primer "if" el de fer només 3 pasos