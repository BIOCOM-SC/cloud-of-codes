function     [BDelta,BerrDelta,R0Delta,R0errDelta,DayDelta,DayDelta20,DayDelta40,DayDelta60,DayDelta80] = FAlphaDelta(N_Desc, N_Asc1, N_Asc2, N_Asc4, N_Ctt,Country,WeekThurs)
% Substitution process for the Alpha vs Delta substitution
N_total = N_Desc + N_Asc1 + N_Asc2 + N_Asc4 + N_Ctt;

if (Country == "Estonia" || Country == "Bulgaria" || Country == "Finland" || Country == "Greece" || Country == "Slovakia" || Country == "Cyprus" || Country == "Czechia")
            % Les normalitzem respecte a les 3 variants (o les que siguin) a estudiar
            for i=1:length(N_total)
                if N_total(i)==0 
                    N_total(i)=1;
                end
            end
            Norm_Desc = 100*N_Desc ./ N_total;
            Norm_Asc1 = 100*N_Asc1 ./ N_total;
            Norm_Ctt = 100*(N_Ctt+N_Asc2+N_Asc4) ./ N_total;
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
            principi = princ1 - 1; %recuperem l'ultim valor que hem analitzat
            % i on l'acabem!!
        if principi == 0
            principi = 1;
        end
        if (Country == "Bulgaria" )
            principi = principi - 3;
        elseif Country == "Czechia" || Country == "Estonia"
            principi = principi - 9;
        elseif  Country == "Cyprus" 
            principi = principi - 2;
        end

            final2 = 0;
            final1 = find(Norm_Asc1>80,1);
            % Preparem on comencem el fitting, perquè sigui automàtic
                try
                    while final2 == 0
                    final2 = Norm_Asc1(final1)>90 && Norm_Asc1(final1+1)>95;
                    final1 = final1+1;
                    end
                final = final1 + 1; %recuperem l'ultim valor que hem analitzat  
                catch
                        final = find(Norm_Asc1 == max(Norm_Asc1),1);
                end
                if Country == "Cyprus" || Country=="Finland"
                    final = final + 4;
                elseif Country == "Bulgaria"
                    final = final +2;
                elseif Country == "Czechia"
                    final = final + 2;
                end
            % Els paràmetres Beta i R0 necessiten un valor inicial que després s'anirà
            % ajustant automàticament:
            aa=0.8; ad=0.1; ae=0.01; ah=0.01;
                for ID_fitting = (principi):1:final  
                    if (n<2) % Changing number "2" allow to repeat the process for future weeks as initial date for substitution
                        Fitting_date=Day_plot(ID_fitting:final);
                        t=1:length(Fitting_date)';
                        Fit_Desc = Norm_Desc(ID_fitting:final)/100;
                        Fit_Asc1 = Norm_Asc1(ID_fitting:final)/100;
                        Fit_Ctt = Norm_Ctt(ID_fitting:final)/100;
                % Condicions del primer "if" primer busquem que ens hauria de donar si tot
                % fos substitució!
                        global_fit_data = [Fit_Asc1;Fit_Ctt]'; 
                        global_fit_function = @(params,t) [params(3)*exp(params(1)*t)./(1+params(3)*exp(params(1)*t)),...
                        params(4)+(params(2)*t)]; % Fitting functions
                        %estimem els parametres que utilitzarem
                        squared_errors = @(params) norm(global_fit_data - global_fit_function(params,t));
                        options=optimset('MaxFunEvals', 10000000, 'MaxIter',10000000, 'Display', 'final', 'TolX', 1e-0012);
                        fit = fminsearch(squared_errors,[aa ad ae ah],options); % BetaBQ, BetaBA2, BetaBA4, Beta_Altres; Ratio_ini_BQ, Ratio_ini_BA2, Ratio_ini_BA4, Ratio_ini_Altres
                if (fit(3) > 0.001 && fit(1)>fit(2)) % ha de posar fit(3) > 0.006  !!!
                    n=n+1;
                        % Pasem de setmanes a dies, he tret el 7* que la Clara multiplicava al length ja que anava MASSA al futur
                        t_plot=(1-2/7):1/7:(length(t)+2/7);
                        [paramfit,Resid,Jacob,CovB,MSE,ErrorModelInfo] = nlinfit(t,global_fit_data,global_fit_function,[fit(1) fit(2) fit(3) fit(4)]);
                        [Ypercen,YCI] = nlpredci(global_fit_function,t_plot,paramfit,Resid,'Covar',CovB);
Ypercen(Ypercen<0)=0;
                        paramfit;
                        conf1 = nlparci(paramfit,Resid,'jacobian',Jacob);
                        conf2 = nlparci(paramfit,Resid,'covariance',CovB);
                        % De manera automàtica el programa agafarà els paràmetres fitejats anteriorment com punt de partida
                        aa=fit(1);ad=fit(2);ae=fit(3);ah=fit(4);
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
                        Fitplot_DescMAX = Fitplot_Desc + 100*sqrt(YCI(1:length(t_plot)).^2 );
                        Fitplot_DescMIN = Fitplot_Desc - 100*sqrt(YCI(1:length(t_plot)).^2 );
                        
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
                            'VariableNames',['Inici Fit',"Beta_Delta","error_B_Delta","R0_Delta","error_R0_Delta","p-value","RMSE"])
                        Tname = ".\Variables_hist_variants_Delta\BetaR0_AlfaVSDelta_Gamma_Beta_altres"+Country+".xlsx";
                        NameSheet = "Full ID " + ID_fitting;
                        writetable(T,Tname,"Sheet",NameSheet);
                        Norm_Ascjoker = zeros(length(Norm_Asc1),1);
                        % Sortida de dades experimentals de SIVIC normalitzades segons variants i
                        % agrupades les "no importants" a Altres
                        PlotSeqVar_alfa_delta = table(Day_plot', Norm_Desc, Desc_int, Norm_Asc1, Asc1_int, Norm_Ascjoker, Norm_Ascjoker, Norm_Ascjoker, Norm_Ascjoker, Norm_Ctt, Ctt_int);
                        PlotSeqVar_alfa_delta.Properties.VariableNames = ['Dia',"Perc_alfa",'Error_alfa',"Perc_delta",'Error_delta',"Perc_gamma",'Error_gamma',"Perc_Beta",'Error_Beta',"Perc_altres","Error_altres"];
                        Plotname = ".\DadesCSV_hist_variants_Delta\Plot_SeqVar_alfa_delta_gamma_Beta_altres" + Country + ".csv";
                        writetable(PlotSeqVar_alfa_delta,Plotname)
                        
                        % Preparem la figura: dades SIVIC, observacions ("reals")
                        figure
                        errorbar(Day_plot,Norm_Desc,Desc_int,Desc_int,'o','Color',[0.00 0.45 0.74])
                        hold on
                        errorbar(Day_plot,Norm_Asc1,Asc1_int,Asc1_int,'o','Color',[0.85 0.33 0.10])
                        errorbar(Day_plot,Norm_Ctt,Ctt_int,Ctt_int,'o','Color',[0.93 0.69 0.13])
                        
                        % Definim l'escala del plot perquè després queda massa gran amb el FIT
                        tstart_plot = datetime(tstart,'InputFormat','dd/MM/yyyy');
                        tend_plot = datetime(tend,'InputFormat','dd/MM/yyyy');
                        xlim([tstart_plot tend_plot]);
                        ylim([0 100]);
                        %Finalment afegim a la imatge els fits
                        Fitting_date_plot=(Fitting_date(1)-2):(Fitting_date(1)+length(t_plot)-3);
                        plot(Fitting_date_plot,Fitplot_Desc,'-','Color',[0.00 0.45 0.74])
                        plot(Fitting_date_plot,Fitplot_Asc1,'-','Color',[0.85 0.33 0.10])
                        plot(Fitting_date_plot,Fitplot_Ctt,'-','Color',[0.93 0.69 0.13])
                        
                        fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_DescMIN flip(Fitplot_DescMAX)],'r','FaceColor',[0.00 0.45 0.74],'FaceAlpha',0.3,'EdgeColor','none');
                        fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc1MIN flip(Fitplot_Asc1MAX)],'r','FaceColor',[0.85 0.33 0.10],'FaceAlpha',0.3,'EdgeColor','none');
                        fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_CttMIN flip(Fitplot_CttMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
                        yline(5,'--'); 

                        Fitplot_Joker = zeros(length(Fitplot_DescMAX),1);
                        Fit_alfa_delta = table(Fitting_date_plot', Fitplot_Desc',Fitplot_DescMAX',Fitplot_DescMIN', Fitplot_Asc1',Fitplot_Asc1MAX',Fitplot_Asc1MIN',...
                            Fitplot_Joker,Fitplot_Joker,Fitplot_Joker,Fitplot_Joker,Fitplot_Joker,Fitplot_Joker,Fitplot_Ctt',Fitplot_CttMAX',Fitplot_CttMIN');
                        Fit_alfa_delta.Properties.VariableNames = ['Dia',"Perc_alfa_dia","Perc_alfa_dia_errMAX","Perc_alfa_dia_errMIN","Perc_delta_dia","Perc_delta_dia_errMAX","Perc_delta_dia_errMIN",...
    "Perc_gamma_dia","Perc_gamma_dia_errMAX","Perc_gamma_dia_errMIN","Perc_Beta_dia","Perc_Beta_dia_errMAX","Perc_Beta_dia_errMIN","Perc_altres_dia","Perc_altres_dia_errMAX","Perc_altres_dia_errMIN"];
                        Fitname = ".\DadesCSV_hist_variants_Delta\Fit_SeqVar_alfa_delta_gamma_Beta_altres"+Country+".csv";
                        writetable(Fit_alfa_delta,Fitname)
                        
                        textCaption = ".\Figures_hist_variants_Delta\" + Country + " Alpha VS Delta + Other " + ID_fitting;
                        lgd = legend ('Alpha','Delta','Others','Model Alpha','Model Delta','Linear Others','Location','east');
                        lgd.FontSize = 7;
                        title(Country + " Alpha VS Delta")
                        xlim([Day_plot(ID_fitting)-1 Day_plot(final)+1]);
                        print(textCaption,'-dpng','-r300')
                       
                else
                    n;
                end
                end
                end
        BDelta=paramfit(1); BerrDelta=abs(conf1(1,1)-paramfit(1)); R0Delta=paramfit(3); R0errDelta=abs(conf1(3,1)-paramfit(3));
        DayDelta = Fitting_date_plot(find(Fitplot_Asc1 > 5,1));
        DayDelta20 = Fitting_date_plot(find(Fitplot_Asc1 > 20,1));
                DayDelta40 = Fitting_date_plot(find(Fitplot_Asc1 > 40,1));
        DayDelta60 = Fitting_date_plot(find(Fitplot_Asc1 > 60,1));
            DayDelta80 = Fitting_date_plot(find(Fitplot_Asc1 > 80,1));

else % per tota la resta de països

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
    princ2 = Norm_Asc1(princ1)>1 && Norm_Asc1(princ1+1)>3; % && Norm_Asc1(princ1)<Norm_Asc1(princ1+1), && Norm_Asc1(princ1)<Norm_Asc1(princ1+2);
    princ1 = princ1+1;
    end
principi = princ1-6; %recuperem l'ultim valor que hem analitzat
        if principi == 0
            principi = 1;
        elseif Country == "Iceland"
            principi = principi - 3;
        elseif Country == "Romania"
            principi = principi -0;
        end
% i on l'acabem!!
final2 = 0;
final1 = find(Norm_Asc1>80,1);
    % Preparem on comencem el fitting, perquè sigui automàtic
        try
            while final2 == 0
            final2 = Norm_Asc1(final1)>95 && Norm_Asc1(final1+1)>96;
            final1 = final1+1;
            end
        final = final1 + 1; %recuperem l'ultim valor que hem analitzat  
        catch
                final = find(Norm_Asc1 == max(Norm_Asc1),1);
        end
    if Country == "Luxembourg"
        final = final + 6;
    elseif Country == "Romania"
        final = final + 6;
    elseif Country == "Latvia"
        final = final + 1;
    elseif Country == "Iceland"
        final = final + 2;
    elseif Country == "Croatia"
        final = final -1;
    elseif (Country == "Norway" || Country == "Poland" || Country == "Portugal" || Country == "Slovakia" )
        final = final + 0;
    elseif Country == "Lithuania"
        final = final + 1;
    elseif Country == "Denmark"
        final = final - 3;
    end
% Els paràmetres Beta i R0 necessiten un valor inicial que després s'anirà
% ajustant automàticament:
aa=0.8; ab=0.05; ac=0.1; ad=0.1; ae=0.01; af=0.01; ag=0.01; ah=0.01;

    for ID_fitting = (principi):1:final  
        if (n<2) % Changing number "2" allow to repeat the process for future weeks as initial date for substitution
            Fitting_date=Day_plot(ID_fitting:final);
            t=1:length(Fitting_date)';
            Fit_Desc = Norm_Desc(ID_fitting:final)/100;
            Fit_Asc1 = Norm_Asc1(ID_fitting:final)/100;
            Fit_Asc2 = Norm_Asc2(ID_fitting:final)/100;
            Fit_Asc4 = Norm_Asc4(ID_fitting:final)/100;
            Fit_Ctt = Norm_Ctt(ID_fitting:final)/100;

% Condicions del primer "if" primer busquem que ens hauria de donar si tot
% fos substitució!
global_fit_data = [Fit_Asc1;Fit_Asc2;Fit_Asc4;Fit_Ctt]'; 
global_fit_function = @(params,t) [params(5)*exp(params(1)*t)./(1+params(5)*exp(params(1)*t)+params(7)*exp(params(3)*t)+params(6)*exp(params(2)*t)+params(8)*exp(params(4)*t)),...
    params(6)*exp(params(2)*t)./(1+params(5)*exp(params(1)*t)+params(7)*exp(params(3)*t)+params(6)*exp(params(2)*t)+params(8)*exp(params(4)*t)),...
params(7)*exp(params(3)*t)./(1+params(5)*exp(params(1)*t)+params(7)*exp(params(3    )*t)+params(6)*exp(params(2)*t)+params(8)*exp(params(4)*t)),...
params(8)*exp(params(4)*t)./(1+params(5)*exp(params(1)*t)+params(7)*exp(params(3)*t)+params(6)*exp(params(2)*t)+params(8)*exp(params(4)*t))]; % Fitting functions
%estimem els parametres que utilitzarem
squared_errors = @(params) norm(global_fit_data - global_fit_function(params,t));
options=optimset('MaxFunEvals', 10000000, 'MaxIter',10000000, 'Display', 'final', 'TolX', 1e-0012);
fit = fminsearch(squared_errors,[aa ab ac ad ae af ag ah],options); % BetaBQ, BetaBA2, BetaBA4, Beta_Altres; Ratio_ini_BQ, Ratio_ini_BA2, Ratio_ini_BA4, Ratio_ini_Altres
                % Conditions for Delta, Gamma, Beta and Other substitution processes
                if (fit(5) > 0.006 && fit(1)>fit(2) && fit(1)>fit(3) && fit(1)>fit(4) && fit(2)>0 && fit(3)>0 && fit(4)>0)
                    n=n+1;
% Pasem de setmanes a dies, he tret el 7* que la Clara multiplicava al length ja que anava MASSA al futur
t_plot=(1-2/7):1/7:(length(t)+2/7);
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
Fitplot_Descno = 100 - Fitplot_Asc1no - Fitplot_Asc2no - Fitplot_Asc4no - Fitplot_Cttno;
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
Fitplot_DescMAX = Fitplot_Desc + 100*sqrt(YCI(1:length(t_plot)).^2 + YCI((length(t_plot)+1):(2*length(t_plot))).^2 + YCI((2*length(t_plot)+1):(3*length(t_plot))).^2 + YCI((3*length(t_plot)+1):end).^2);
Fitplot_DescMIN = Fitplot_Desc - 100*sqrt(YCI(1:length(t_plot)).^2 + YCI((length(t_plot)+1):(2*length(t_plot))).^2 + YCI((2*length(t_plot)+1):(3*length(t_plot))).^2 + YCI((3*length(t_plot)+1):end).^2);

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
    paramfit(3), abs(conf1(3,1)-paramfit(3)), paramfit(7), abs(conf1(7,1)-paramfit(7)),...
    paramfit(4), abs(conf1(4,1)-paramfit(4)), paramfit(8), abs(conf1(8,1)-paramfit(8)),p, RMSE,...
    'VariableNames',['Inici Fit',"Beta_Delta","error_B_Delta","R0_Delta","error_R0_Delta",...
    "Beta_Gamma","error_B_Gamma","R0_Gamma","error_R0_Gamma",...
    "Beta_Beta","error_B_Beta","R0_Beta","error_R0_Beta",...
    "Beta_Altres","error_B_Altres","R0_Altres","error_R0_Altres","p-value","RMSE"])
Tname = ".\Variables_hist_variants_Delta\BetaR0_AlfaVSDelta_Gamma_Beta_altres"+Country+".xlsx";
NameSheet = "Full ID " + ID_fitting;
writetable(T,Tname,"Sheet",NameSheet);

% Sortida de dades experimentals de SIVIC normalitzades segons variants i
% agrupades les "no importants" a Altres
PlotSeqVar_alfa_delta = table(Day_plot', Norm_Desc, Desc_int, Norm_Asc1, Asc1_int, Norm_Asc2, Asc2_int,Norm_Asc4, Asc4_int, Norm_Ctt, Ctt_int);
PlotSeqVar_alfa_delta.Properties.VariableNames = ['Dia',"Perc_alfa",'Error_alfa',"Perc_delta",'Error_delta',"Perc_gamma",'Error_gamma',"Perc_Beta",'Error_Beta',"Perc_altres","Error_altres"];
Plotname = ".\DadesCSV_hist_variants_Delta\Plot_SeqVar_alfa_delta_gamma_Beta_altres" + Country + ".csv";
writetable(PlotSeqVar_alfa_delta,Plotname)

% Preparem la figura: dades SIVIC, observacions ("reals")
figure
errorbar(Day_plot,Norm_Desc,Desc_int,Desc_int,'o','Color',[0.00 0.45 0.74])
hold on
errorbar(Day_plot,Norm_Asc1,Asc1_int,Asc1_int,'o','Color',[0.85 0.33 0.10])
errorbar(Day_plot,Norm_Asc2,Asc2_int,Asc2_int,'o','Color',[1 0.45 0.54])
errorbar(Day_plot,Norm_Asc4,Asc4_int,Asc4_int,'o','Color',[0.1 0.1 0.9])
errorbar(Day_plot,Norm_Ctt,Ctt_int,Ctt_int,'o','Color',[0.93 0.69 0.13])

% Definim l'escala del plot perquè després queda massa gran amb el FIT
tstart_plot = datetime(tstart,'InputFormat','dd/MM/yyyy');
tend_plot = datetime(tend,'InputFormat','dd/MM/yyyy');
xlim([tstart_plot tend_plot]);
ylim([0 100]);
%Finalment afegim a la imatge els fits
Fitting_date_plot=(Fitting_date(1)-2):(Fitting_date(1)+length(t_plot)-3);
plot(Fitting_date_plot,Fitplot_Desc,'-','Color',[0.00 0.45 0.74])
plot(Fitting_date_plot,Fitplot_Asc1,'-','Color',[0.85 0.33 0.10])
plot(Fitting_date_plot,Fitplot_Asc2,'-','Color',[1 0.45 0.54])
plot(Fitting_date_plot,Fitplot_Asc4,'-','Color',[0.1 0.1 0.9])
plot(Fitting_date_plot,Fitplot_Ctt,'-','Color',[0.93 0.69 0.13])

fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_DescMIN flip(Fitplot_DescMAX)],'r','FaceColor',[0.00 0.45 0.74],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc1MIN flip(Fitplot_Asc1MAX)],'r','FaceColor',[0.85 0.33 0.10],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc2MIN flip(Fitplot_Asc2MAX)],'r','FaceColor',[1 0.45 0.54],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc4MIN flip(Fitplot_Asc4MAX)],'r','FaceColor',[0.1 0.1 0.9],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_CttMIN flip(Fitplot_CttMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
yline(5,'--'); 

Fit_alfa_delta = table(Fitting_date_plot', Fitplot_Desc',Fitplot_DescMAX',Fitplot_DescMIN', Fitplot_Asc1',Fitplot_Asc1MAX',Fitplot_Asc1MIN',...
    Fitplot_Asc2',Fitplot_Asc2MAX',Fitplot_Asc2MIN',Fitplot_Asc4',Fitplot_Asc4MAX',Fitplot_Asc4MIN',Fitplot_Ctt',Fitplot_CttMAX',Fitplot_CttMIN');
Fit_alfa_delta.Properties.VariableNames = ['Dia',"Perc_alfa_dia","Perc_alfa_dia_errMAX","Perc_alfa_dia_errMIN","Perc_delta_dia","Perc_delta_dia_errMAX","Perc_delta_dia_errMIN",...
    "Perc_gamma_dia","Perc_gamma_dia_errMAX","Perc_gamma_dia_errMIN","Perc_Beta_dia","Perc_Beta_dia_errMAX","Perc_Beta_dia_errMIN","Perc_altres_dia","Perc_altres_dia_errMAX","Perc_altres_dia_errMIN"];
Fitname = ".\DadesCSV_hist_variants_Delta\Fit_SeqVar_alfa_delta_gamma_Beta_altres"+Country+".csv";
writetable(Fit_alfa_delta,Fitname)

textCaption = ".\Figures_hist_variants_Delta\" + Country + " Alpha VS Delta + Gamma + Beta + Other " + ID_fitting;
lgd = legend ('Alpha','Delta','Gamma','Beta','Others','Model Alpha','Model Delta','Model Gamma','Model Beta','Model Others','Location','east');
lgd.FontSize = 7;
title(Country + " Alpha VS Delta + Gamma + Beta")
xlim([Day_plot(ID_fitting)-1 Day_plot(final)+1]);
print(textCaption,'-dpng','-r300')
% % close
                % Conditions for Delta substitution proces. 
                % Gamma, Beta and Other is considered linear.
                elseif ((fit(5) > 0.006 && (fit(1)<fit(2) || fit(2)<0) && (fit(1)<fit(3) || fit(3)<0) && (fit(1)<fit(4) || fit(4)<0)) || (fit(5) > 0.006 && fit(2)<0 && fit(3)<0 && fit(4)<0))
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
[paramfit,Resid,Jacob,CovB,MSE,ErrorModelInfo] = nlinfit(t,global_fit_data,global_fit_function,[fit(1) fit(2) fit(3) fit(4) fit(5) fit(6) fit(7) fit(8)]);
[Ypercen,YCI] = nlpredci(global_fit_function,t_plot,paramfit,Resid,'Covar',CovB);
                        Ypercen(Ypercen<0)=0;
paramfit;
conf1 = nlparci(paramfit,Resid,'jacobian',Jacob);
conf2 = nlparci(paramfit,Resid,'covariance',CovB);
% De manera automàtica el programa agafarà els paràmetres fitejats anteriorment com punt de partida
aa=fit(1);ab=fit(2);ac=fit(3);ad=fit(4);ae=fit(5);af=fit(6);ag=fit(7);ah=fit(8);
    n=n+1;
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
Fitplot_DescMAX = Fitplot_Desc + 100*sqrt(YCI(1:length(t_plot)).^2 );
Fitplot_DescMIN = Fitplot_Desc - 100*sqrt(YCI(1:length(t_plot)).^2 );

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
    'VariableNames',['Inici Fit',"Beta_Delta","error_B_Delta","R0_Delta","error_R0_Delta","p-value","RMSE"])
Tname = ".\Variables_hist_variants_Delta\BetaR0_AlfaVSDelta_Gamma_Beta_altres"+Country+".xlsx";
NameSheet = "Full ID " + ID_fitting;
writetable(T,Tname,"Sheet",NameSheet);

% Sortida de dades experimentals de SIVIC normalitzades segons variants i
% agrupades les "no importants" a Altres
PlotSeqVar_alfa_delta = table(Day_plot', Norm_Desc, Desc_int, Norm_Asc1, Asc1_int, Norm_Asc2, Asc2_int,Norm_Asc4, Asc4_int, Norm_Ctt, Ctt_int);
PlotSeqVar_alfa_delta.Properties.VariableNames = ['Dia',"Perc_alfa",'Error_alfa',"Perc_delta",'Error_delta',"Perc_gamma",'Error_gamma',"Perc_Beta",'Error_Beta',"Perc_altres","Error_altres"];
Plotname = ".\DadesCSV_hist_variants_Delta\Plot_SeqVar_alfa_delta_gamma_Beta_altres" + Country + ".csv";
writetable(PlotSeqVar_alfa_delta,Plotname)

% Preparem la figura: dades SIVIC, observacions ("reals")
figure
errorbar(Day_plot,Norm_Desc,Desc_int,Desc_int,'o','Color',[0.00 0.45 0.74])
hold on
errorbar(Day_plot,Norm_Asc1,Asc1_int,Asc1_int,'o','Color',[0.85 0.33 0.10])
errorbar(Day_plot,Norm_Asc2,Asc2_int,Asc2_int,'o','Color',[1 0.45 0.54])
errorbar(Day_plot,Norm_Asc4,Asc4_int,Asc4_int,'o','Color',[0.1 0.1 0.9])
errorbar(Day_plot,Norm_Ctt,Ctt_int,Ctt_int,'o','Color',[0.93 0.69 0.13])

% Definim l'escala del plot perquè després queda massa gran amb el FIT
tstart_plot = datetime(tstart,'InputFormat','dd/MM/yyyy');
tend_plot = datetime(tend,'InputFormat','dd/MM/yyyy');
xlim([tstart_plot tend_plot]);
ylim([0 100]);
%Finalment afegim a la imatge els fits
Fitting_date_plot=(Fitting_date(1)-2):(Fitting_date(1)+length(t_plot)-3);
plot(Fitting_date_plot,Fitplot_Desc,'-','Color',[0.00 0.45 0.74])
plot(Fitting_date_plot,Fitplot_Asc1,'-','Color',[0.85 0.33 0.10])
plot(Fitting_date_plot,Fitplot_Asc2,'-','Color',[1 0.45 0.54])
plot(Fitting_date_plot,Fitplot_Asc4,'-','Color',[0.1 0.1 0.9])
plot(Fitting_date_plot,Fitplot_Ctt,'-','Color',[0.93 0.69 0.13])

fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_DescMIN flip(Fitplot_DescMAX)],'r','FaceColor',[0.00 0.45 0.74],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc1MIN flip(Fitplot_Asc1MAX)],'r','FaceColor',[0.85 0.33 0.10],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc2MIN flip(Fitplot_Asc2MAX)],'r','FaceColor',[1 0.45 0.54],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc4MIN flip(Fitplot_Asc4MAX)],'r','FaceColor',[0.1 0.1 0.9],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_CttMIN flip(Fitplot_CttMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
yline(5,'--'); 

Fit_alfa_delta = table(Fitting_date_plot', Fitplot_Desc',Fitplot_DescMAX',Fitplot_DescMIN', Fitplot_Asc1',Fitplot_Asc1MAX',Fitplot_Asc1MIN',...
    Fitplot_Asc2',Fitplot_Asc2MAX',Fitplot_Asc2MIN',Fitplot_Asc4',Fitplot_Asc4MAX',Fitplot_Asc4MIN',Fitplot_Ctt',Fitplot_CttMAX',Fitplot_CttMIN');
Fit_alfa_delta.Properties.VariableNames = ['Dia',"Perc_alfa_dia","Perc_alfa_dia_errMAX","Perc_alfa_dia_errMIN","Perc_delta_dia","Perc_delta_dia_errMAX","Perc_delta_dia_errMIN",...
    "Perc_gamma_dia","Perc_gamma_dia_errMAX","Perc_gamma_dia_errMIN","Perc_Beta_dia","Perc_Beta_dia_errMAX","Perc_Beta_dia_errMIN","Perc_altres_dia","Perc_altres_dia_errMAX","Perc_altres_dia_errMIN"];
Fitname = ".\DadesCSV_hist_variants_Delta\Fit_SeqVar_alfa_delta_gamma_Beta_altres"+Country+".csv";
writetable(Fit_alfa_delta,Fitname)

textCaption = ".\Figures_hist_variants_Delta\" + Country + " Alpha VS Delta + Gamma + Beta + Other " + ID_fitting;
lgd = legend ('Alpha','Delta','Gamma','Beta','Others','Model Alpha','Model Delta','Linear Gamma','Linear Beta','Linear Others','Location','east');
lgd.FontSize = 7;
title(Country + " Alpha VS Delta + Gamma + Beta")
xlim([Day_plot(ID_fitting)-1 Day_plot(final)+1]);
print(textCaption,'-dpng','-r300')

                % Conditions for Delta and Gamma substitution processes.
                % Beta and Other is considered linear.
                elseif ((fit(5) > 0.006 && fit(1)>fit(2) && (fit(1)<fit(3) || fit(3)<0) && (fit(1)<fit(4) || fit(4)<0) && fit(2)>0) || (fit(3)<0 && fit(4)<0 && fit(5) > 0.006)) % ||(Country == "Luxembourg")
                global_fit_data = [Fit_Asc1;Fit_Asc2;Fit_Asc4;Fit_Ctt]'; 
global_fit_function = @(params,t) [params(5)*exp(params(1)*t)./(1+params(5)*exp(params(1)*t)+params(6)*exp(params(2)*t)),...
    params(6)*exp(params(2)*t)./(1+params(5)*exp(params(1)*t)+params(6)*exp(params(2)*t)),...
    params(7)+(params(3)*t),...
    params(8)+(params(4)*t)]; % Fitting functions
%estimem els parametres que utilitzarem
squared_errors = @(params) norm(global_fit_data - global_fit_function(params,t));
options=optimset('MaxFunEvals', 10000000, 'MaxIter',10000000, 'Display', 'final', 'TolX', 1e-0012);
fit = fminsearch(squared_errors,[aa ab ac ad ae af ag ah],options); % BetaBQ, BetaBA2, BetaBA4, Beta_Altres; Ratio_ini_BQ, Ratio_ini_BA2, Ratio_ini_BA4, Ratio_ini_Altres
% Pasem de setmanes a dies, he tret el 7* que la Clara multiplicava al length ja que anava MASSA al futur
t_plot=(1-2/7):1/7:(length(t)+2/7); 
[paramfit,Resid,Jacob,CovB,MSE,ErrorModelInfo] = nlinfit(t,global_fit_data,global_fit_function,[fit(1) fit(2) fit(3) fit(4) fit(5) fit(6) fit(7) fit(8)]);
[Ypercen,YCI] = nlpredci(global_fit_function,t_plot,paramfit,Resid,'Covar',CovB);
                        Ypercen(Ypercen<0)=0;
paramfit;
conf1 = nlparci(paramfit,Resid,'jacobian',Jacob);
conf2 = nlparci(paramfit,Resid,'covariance',CovB);
% De manera automàtica el programa agafarà els paràmetres fitejats anteriorment com punt de partida
aa=fit(1);ab=fit(2);ac=fit(3);ad=fit(4);ae=fit(5);af=fit(6);ag=fit(7);ah=fit(8);
    n=n+1;
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
    'VariableNames',['Inici Fit',"Beta_Delta","error_B_Delta","R0_Delta","error_R0_Delta",...
    "Beta_Gamma","error_B_Gamma","R0_Gamma","error_R0_Gamma","p-value","RMSE"])
Tname = ".\Variables_hist_variants_Delta\BetaR0_AlfaVSDelta_Gamma_Beta_altres"+Country+".xlsx";
NameSheet = "Full ID " + ID_fitting;
writetable(T,Tname,"Sheet",NameSheet);

% Sortida de dades experimentals de SIVIC normalitzades segons variants i
% agrupades les "no importants" a Altres
PlotSeqVar_alfa_delta = table(Day_plot', Norm_Desc, Desc_int, Norm_Asc1, Asc1_int, Norm_Asc2, Asc2_int,Norm_Asc4, Asc4_int, Norm_Ctt, Ctt_int);
PlotSeqVar_alfa_delta.Properties.VariableNames = ['Dia',"Perc_alfa",'Error_alfa',"Perc_delta",'Error_delta',"Perc_gamma",'Error_gamma',"Perc_Beta",'Error_Beta',"Perc_altres","Error_altres"];
Plotname = ".\DadesCSV_hist_variants_Delta\Plot_SeqVar_alfa_delta_gamma_Beta_altres" + Country + ".csv";
writetable(PlotSeqVar_alfa_delta,Plotname)

% Preparem la figura: dades SIVIC, observacions ("reals")
figure
errorbar(Day_plot,Norm_Desc,Desc_int,Desc_int,'o','Color',[0.00 0.45 0.74])
hold on
errorbar(Day_plot,Norm_Asc1,Asc1_int,Asc1_int,'o','Color',[0.85 0.33 0.10])
errorbar(Day_plot,Norm_Asc2,Asc2_int,Asc2_int,'o','Color',[1 0.45 0.54])
errorbar(Day_plot,Norm_Asc4,Asc4_int,Asc4_int,'o','Color',[0.1 0.1 0.9])
errorbar(Day_plot,Norm_Ctt,Ctt_int,Ctt_int,'o','Color',[0.93 0.69 0.13])

% Definim l'escala del plot perquè després queda massa gran amb el FIT
tstart_plot = datetime(tstart,'InputFormat','dd/MM/yyyy');
tend_plot = datetime(tend,'InputFormat','dd/MM/yyyy');
xlim([tstart_plot tend_plot]);
ylim([0 100]);
%Finalment afegim a la imatge els fits
Fitting_date_plot=(Fitting_date(1)-2):(Fitting_date(1)+length(t_plot)-3);
plot(Fitting_date_plot,Fitplot_Desc,'-','Color',[0.00 0.45 0.74])
plot(Fitting_date_plot,Fitplot_Asc1,'-','Color',[0.85 0.33 0.10])
plot(Fitting_date_plot,Fitplot_Asc2,'-','Color',[1 0.45 0.54])
plot(Fitting_date_plot,Fitplot_Asc4,'-','Color',[0.1 0.1 0.9])
plot(Fitting_date_plot,Fitplot_Ctt,'-','Color',[0.93 0.69 0.13])

fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_DescMIN flip(Fitplot_DescMAX)],'r','FaceColor',[0.00 0.45 0.74],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc1MIN flip(Fitplot_Asc1MAX)],'r','FaceColor',[0.85 0.33 0.10],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc2MIN flip(Fitplot_Asc2MAX)],'r','FaceColor',[1 0.45 0.54],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc4MIN flip(Fitplot_Asc4MAX)],'r','FaceColor',[0.1 0.1 0.9],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_CttMIN flip(Fitplot_CttMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
yline(5,'--'); 

Fit_alfa_delta = table(Fitting_date_plot', Fitplot_Desc',Fitplot_DescMAX',Fitplot_DescMIN', Fitplot_Asc1',Fitplot_Asc1MAX',Fitplot_Asc1MIN',...
    Fitplot_Asc2',Fitplot_Asc2MAX',Fitplot_Asc2MIN',Fitplot_Asc4',Fitplot_Asc4MAX',Fitplot_Asc4MIN',Fitplot_Ctt',Fitplot_CttMAX',Fitplot_CttMIN');
Fit_alfa_delta.Properties.VariableNames = ['Dia',"Perc_alfa_dia","Perc_alfa_dia_errMAX","Perc_alfa_dia_errMIN","Perc_delta_dia","Perc_delta_dia_errMAX","Perc_delta_dia_errMIN",...
    "Perc_gamma_dia","Perc_gamma_dia_errMAX","Perc_gamma_dia_errMIN","Perc_Beta_dia","Perc_Beta_dia_errMAX","Perc_Beta_dia_errMIN","Perc_altres_dia","Perc_altres_dia_errMAX","Perc_altres_dia_errMIN"];
Fitname = ".\DadesCSV_hist_variants_Delta\Fit_SeqVar_alfa_delta_gamma_Beta_altres"+Country+".csv";
writetable(Fit_alfa_delta,Fitname)

textCaption = ".\Figures_hist_variants_Delta\" + Country + " Alpha VS Delta + Gamma + Beta + Other " + ID_fitting;
lgd = legend ('Alpha','Delta','Gamma','Beta','Others','Model Alpha','Model Delta','Model Gamma','Linear Beta','Linear Others','Location','east');
lgd.FontSize = 7;
title(Country + " Alpha VS Delta + Gamma + Beta")
xlim([Day_plot(ID_fitting)-1 Day_plot(final)+1]);
print(textCaption,'-dpng','-r300')

                % Conditions for Delta and Beta substitution processes.
                % Gamma and Other is considered linear.
                elseif ((fit(5) > 0.006 && (fit(1)<fit(2) || fit(2)<0) && fit(1)>fit(3) && (fit(1)<fit(4) || fit(4)<0) && fit(3)>0) || (fit(2)<0 && fit(4)<0 && fit(5) > 0.006))                              
                global_fit_data = [Fit_Asc1;Fit_Asc2;Fit_Asc4;Fit_Ctt]'; 
global_fit_function = @(params,t) [params(5)*exp(params(1)*t)./(1+params(5)*exp(params(1)*t)+params(7)*exp(params(3)*t)),...
    params(6)+(params(2)*t),...
    params(7)*exp(params(3)*t)./(1+params(5)*exp(params(1)*t)+params(7)*exp(params(3)*t)),...
    params(8)+(params(4)*t)]; % Fitting functions
%estimem els parametres que utilitzarem
squared_errors = @(params) norm(global_fit_data - global_fit_function(params,t));
options=optimset('MaxFunEvals', 10000000, 'MaxIter',10000000, 'Display', 'final', 'TolX', 1e-0012);
fit = fminsearch(squared_errors,[aa ab ac ad ae af ag ah],options); % BetaBQ, BetaBA2, BetaBA4, Beta_Altres; Ratio_ini_BQ, Ratio_ini_BA2, Ratio_ini_BA4, Ratio_ini_Altres
% Pasem de setmanes a dies, he tret el 7* que la Clara multiplicava al length ja que anava MASSA al futur
t_plot=(1-2/7):1/7:(length(t)+2/7); 
[paramfit,Resid,Jacob,CovB,MSE,ErrorModelInfo] = nlinfit(t,global_fit_data,global_fit_function,[fit(1) fit(2) fit(3) fit(4) fit(5) fit(6) fit(7) fit(8)]);
[Ypercen,YCI] = nlpredci(global_fit_function,t_plot,paramfit,Resid,'Covar',CovB);
                        Ypercen(Ypercen<0)=0;
paramfit;
conf1 = nlparci(paramfit,Resid,'jacobian',Jacob);
conf2 = nlparci(paramfit,Resid,'covariance',CovB);
% De manera automàtica el programa agafarà els paràmetres fitejats anteriorment com punt de partida
aa=fit(1);ab=fit(2);ac=fit(3);ad=fit(4);ae=fit(5);af=fit(6);ag=fit(7);ah=fit(8);
    n=n+1;
    % close
% Les normalitzem respecte a les 3 variants a estudiar
Fitplot_Asc1no = 100*Ypercen(1:length(t_plot));
Fitplot_Asc2no = 100*Ypercen((length(t_plot)+1):(2*length(t_plot)));
Fitplot_Asc4no = 100*Ypercen((2*length(t_plot)+1):(3*length(t_plot)));
Fitplot_Cttno = 100*Ypercen((3*length(t_plot)+1):end);
Fitplot_Descno = 100 - Fitplot_Asc1no - Fitplot_Asc4no;
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
Fitplot_DescMAX = Fitplot_Desc + 100*sqrt(YCI(1:length(t_plot)).^2 + YCI((2*length(t_plot)+1):(3*length(t_plot))).^2);
Fitplot_DescMIN = Fitplot_Desc - 100*sqrt(YCI(1:length(t_plot)).^2 + YCI((2*length(t_plot)+1):(3*length(t_plot))).^2);

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
    paramfit(3), abs(conf1(3,1)-paramfit(3)), paramfit(7), abs(conf1(7,1)-paramfit(7)),p, RMSE,...
    'VariableNames',['Inici Fit',"Beta_Delta","error_B_Delta","R0_Delta","error_R0_Delta",...
    "Beta_Beta","error_B_Beta","R0_Beta","error_R0_Beta","p-value","RMSE"])
Tname = ".\Variables_hist_variants_Delta\BetaR0_AlfaVSDelta_Gamma_Beta_altres"+Country+".xlsx";
NameSheet = "Full ID " + ID_fitting;
writetable(T,Tname,"Sheet",NameSheet);

% Sortida de dades experimentals de SIVIC normalitzades segons variants i
% agrupades les "no importants" a Altres
PlotSeqVar_alfa_delta = table(Day_plot', Norm_Desc, Desc_int, Norm_Asc1, Asc1_int, Norm_Asc2, Asc2_int,Norm_Asc4, Asc4_int, Norm_Ctt, Ctt_int);
PlotSeqVar_alfa_delta.Properties.VariableNames = ['Dia',"Perc_alfa",'Error_alfa',"Perc_delta",'Error_delta',"Perc_gamma",'Error_gamma',"Perc_Beta",'Error_Beta',"Perc_altres","Error_altres"];
Plotname = ".\DadesCSV_hist_variants_Delta\Plot_SeqVar_alfa_delta_gamma_Beta_altres" + Country + ".csv";
writetable(PlotSeqVar_alfa_delta,Plotname)

% Preparem la figura: dades SIVIC, observacions ("reals")
figure
errorbar(Day_plot,Norm_Desc,Desc_int,Desc_int,'o','Color',[0.00 0.45 0.74])
hold on
errorbar(Day_plot,Norm_Asc1,Asc1_int,Asc1_int,'o','Color',[0.85 0.33 0.10])
errorbar(Day_plot,Norm_Asc2,Asc2_int,Asc2_int,'o','Color',[1 0.45 0.54])
errorbar(Day_plot,Norm_Asc4,Asc4_int,Asc4_int,'o','Color',[0.1 0.1 0.9])
errorbar(Day_plot,Norm_Ctt,Ctt_int,Ctt_int,'o','Color',[0.93 0.69 0.13])

% Definim l'escala del plot perquè després queda massa gran amb el FIT
tstart_plot = datetime(tstart,'InputFormat','dd/MM/yyyy');
tend_plot = datetime(tend,'InputFormat','dd/MM/yyyy');
xlim([tstart_plot tend_plot]);
ylim([0 100]);
%Finalment afegim a la imatge els fits
Fitting_date_plot=(Fitting_date(1)-2):(Fitting_date(1)+length(t_plot)-3);
plot(Fitting_date_plot,Fitplot_Desc,'-','Color',[0.00 0.45 0.74])
plot(Fitting_date_plot,Fitplot_Asc1,'-','Color',[0.85 0.33 0.10])
plot(Fitting_date_plot,Fitplot_Asc2,'-','Color',[1 0.45 0.54])
plot(Fitting_date_plot,Fitplot_Asc4,'-','Color',[0.1 0.1 0.9])
plot(Fitting_date_plot,Fitplot_Ctt,'-','Color',[0.93 0.69 0.13])

fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_DescMIN flip(Fitplot_DescMAX)],'r','FaceColor',[0.00 0.45 0.74],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc1MIN flip(Fitplot_Asc1MAX)],'r','FaceColor',[0.85 0.33 0.10],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc2MIN flip(Fitplot_Asc2MAX)],'r','FaceColor',[1 0.45 0.54],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc4MIN flip(Fitplot_Asc4MAX)],'r','FaceColor',[0.1 0.1 0.9],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_CttMIN flip(Fitplot_CttMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
yline(5,'--'); 

Fit_alfa_delta = table(Fitting_date_plot', Fitplot_Desc',Fitplot_DescMAX',Fitplot_DescMIN', Fitplot_Asc1',Fitplot_Asc1MAX',Fitplot_Asc1MIN',...
    Fitplot_Asc2',Fitplot_Asc2MAX',Fitplot_Asc2MIN',Fitplot_Asc4',Fitplot_Asc4MAX',Fitplot_Asc4MIN',Fitplot_Ctt',Fitplot_CttMAX',Fitplot_CttMIN');
Fit_alfa_delta.Properties.VariableNames = ['Dia',"Perc_alfa_dia","Perc_alfa_dia_errMAX","Perc_alfa_dia_errMIN","Perc_delta_dia","Perc_delta_dia_errMAX","Perc_delta_dia_errMIN",...
    "Perc_gamma_dia","Perc_gamma_dia_errMAX","Perc_gamma_dia_errMIN","Perc_Beta_dia","Perc_Beta_dia_errMAX","Perc_Beta_dia_errMIN","Perc_altres_dia","Perc_altres_dia_errMAX","Perc_altres_dia_errMIN"];
Fitname = ".\DadesCSV_hist_variants_Delta\Fit_SeqVar_alfa_delta_gamma_Beta_altres"+Country+".csv";
writetable(Fit_alfa_delta,Fitname)

textCaption = ".\Figures_hist_variants_Delta\" + Country + " Alpha VS Delta + Gamma + Beta + Other " + ID_fitting;
lgd = legend ('Alpha','Delta','Gamma','Beta','Others','Model Alpha','Model Delta','Linear Gamma','Model Beta','Linear Others','Location','east');
lgd.FontSize = 7;
title(Country + " Alpha VS Delta + Gamma + Beta")
xlim([Day_plot(ID_fitting)-1 Day_plot(final)+1]);
print(textCaption,'-dpng','-r300')               

                % Conditions for Delta and Other substitution processes.
                % Gamma and Beta is considered linear.
                elseif ((fit(5) > 0.006 && (fit(1)<fit(2) || fit(2)<0) && (fit(1)<fit(3) || fit(3)<0) && fit(1)>fit(4) && fit(4)>0) || (fit(2)<0 && fit(3)<0 && fit(5) > 0.006))               
                global_fit_data = [Fit_Asc1;Fit_Asc2;Fit_Asc4;Fit_Ctt]'; 
global_fit_function = @(params,t) [params(5)*exp(params(1)*t)./(1+params(5)*exp(params(1)*t)+params(8)*exp(params(4)*t)),...
    params(6)+(params(2)*t),...
    params(7)+(params(3)*t),...
    params(8)*exp(params(4)*t)./(1+params(5)*exp(params(1)*t)+params(8)*exp(params(4)*t))]; % Fitting functions
%estimem els parametres que utilitzarem
squared_errors = @(params) norm(global_fit_data - global_fit_function(params,t));
options=optimset('MaxFunEvals', 10000000, 'MaxIter',10000000, 'Display', 'final', 'TolX', 1e-0012);
fit = fminsearch(squared_errors,[aa ab ac ad ae af ag ah],options); % BetaBQ, BetaBA2, BetaBA4, Beta_Altres; Ratio_ini_BQ, Ratio_ini_BA2, Ratio_ini_BA4, Ratio_ini_Altres
% Pasem de setmanes a dies, he tret el 7* que la Clara multiplicava al length ja que anava MASSA al futur
t_plot=(1-2/7):1/7:(length(t)+2/7);
[paramfit,Resid,Jacob,CovB,MSE,ErrorModelInfo] = nlinfit(t,global_fit_data,global_fit_function,[fit(1) fit(2) fit(3) fit(4) fit(5) fit(6) fit(7) fit(8)]);
[Ypercen,YCI] = nlpredci(global_fit_function,t_plot,paramfit,Resid,'Covar',CovB);
                        Ypercen(Ypercen<0)=0;
paramfit;
conf1 = nlparci(paramfit,Resid,'jacobian',Jacob);
conf2 = nlparci(paramfit,Resid,'covariance',CovB);
% De manera automàtica el programa agafarà els paràmetres fitejats anteriorment com punt de partida
aa=fit(1);ab=fit(2);ac=fit(3);ad=fit(4);ae=fit(5);af=fit(6);ag=fit(7);ah=fit(8);
    n=n+1;
    % close
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
    'VariableNames',['Inici Fit',"Beta_Delta","error_B_Delta","R0_Delta","error_R0_Delta",...
    "Beta_Altres","error_B_Altres","R0_Altres","error_R0_Altres","p-value","RMSE"])
Tname = ".\Variables_hist_variants_Delta\BetaR0_AlfaVSDelta_Gamma_Beta_altres"+Country+".xlsx";
NameSheet = "Full ID " + ID_fitting;
writetable(T,Tname,"Sheet",NameSheet);

% Sortida de dades experimentals de SIVIC normalitzades segons variants i
% agrupades les "no importants" a Altres
PlotSeqVar_alfa_delta = table(Day_plot', Norm_Desc, Desc_int, Norm_Asc1, Asc1_int, Norm_Asc2, Asc2_int,Norm_Asc4, Asc4_int, Norm_Ctt, Ctt_int);
PlotSeqVar_alfa_delta.Properties.VariableNames = ['Dia',"Perc_alfa",'Error_alfa',"Perc_delta",'Error_delta',"Perc_gamma",'Error_gamma',"Perc_Beta",'Error_Beta',"Perc_altres","Error_altres"];
Plotname = ".\DadesCSV_hist_variants_Delta\Plot_SeqVar_alfa_delta_gamma_Beta_altres" + Country + ".csv";
writetable(PlotSeqVar_alfa_delta,Plotname)

% Preparem la figura: dades SIVIC, observacions ("reals")
figure
errorbar(Day_plot,Norm_Desc,Desc_int,Desc_int,'o','Color',[0.00 0.45 0.74])
hold on
errorbar(Day_plot,Norm_Asc1,Asc1_int,Asc1_int,'o','Color',[0.85 0.33 0.10])
errorbar(Day_plot,Norm_Asc2,Asc2_int,Asc2_int,'o','Color',[1 0.45 0.54])
errorbar(Day_plot,Norm_Asc4,Asc4_int,Asc4_int,'o','Color',[0.1 0.1 0.9])
errorbar(Day_plot,Norm_Ctt,Ctt_int,Ctt_int,'o','Color',[0.93 0.69 0.13])

% Definim l'escala del plot perquè després queda massa gran amb el FIT
tstart_plot = datetime(tstart,'InputFormat','dd/MM/yyyy');
tend_plot = datetime(tend,'InputFormat','dd/MM/yyyy');
xlim([tstart_plot tend_plot]);
ylim([0 100]);
%Finalment afegim a la imatge els fits
Fitting_date_plot=(Fitting_date(1)-2):(Fitting_date(1)+length(t_plot)-3);
plot(Fitting_date_plot,Fitplot_Desc,'-','Color',[0.00 0.45 0.74])
plot(Fitting_date_plot,Fitplot_Asc1,'-','Color',[0.85 0.33 0.10])
plot(Fitting_date_plot,Fitplot_Asc2,'-','Color',[1 0.45 0.54])
plot(Fitting_date_plot,Fitplot_Asc4,'-','Color',[0.1 0.1 0.9])
plot(Fitting_date_plot,Fitplot_Ctt,'-','Color',[0.93 0.69 0.13])

fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_DescMIN flip(Fitplot_DescMAX)],'r','FaceColor',[0.00 0.45 0.74],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc1MIN flip(Fitplot_Asc1MAX)],'r','FaceColor',[0.85 0.33 0.10],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc2MIN flip(Fitplot_Asc2MAX)],'r','FaceColor',[1 0.45 0.54],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc4MIN flip(Fitplot_Asc4MAX)],'r','FaceColor',[0.1 0.1 0.9],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_CttMIN flip(Fitplot_CttMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
yline(5,'--'); 

Fit_alfa_delta = table(Fitting_date_plot', Fitplot_Desc',Fitplot_DescMAX',Fitplot_DescMIN', Fitplot_Asc1',Fitplot_Asc1MAX',Fitplot_Asc1MIN',...
    Fitplot_Asc2',Fitplot_Asc2MAX',Fitplot_Asc2MIN',Fitplot_Asc4',Fitplot_Asc4MAX',Fitplot_Asc4MIN',Fitplot_Ctt',Fitplot_CttMAX',Fitplot_CttMIN');
Fit_alfa_delta.Properties.VariableNames = ['Dia',"Perc_alfa_dia","Perc_alfa_dia_errMAX","Perc_alfa_dia_errMIN","Perc_delta_dia","Perc_delta_dia_errMAX","Perc_delta_dia_errMIN",...
    "Perc_gamma_dia","Perc_gamma_dia_errMAX","Perc_gamma_dia_errMIN","Perc_Beta_dia","Perc_Beta_dia_errMAX","Perc_Beta_dia_errMIN","Perc_altres_dia","Perc_altres_dia_errMAX","Perc_altres_dia_errMIN"];
Fitname = ".\DadesCSV_hist_variants_Delta\Fit_SeqVar_alfa_delta_gamma_Beta_altres"+Country+".csv";
writetable(Fit_alfa_delta,Fitname)

textCaption = ".\Figures_hist_variants_Delta\" + Country + " Alpha VS Delta + Gamma + Beta + Other " + ID_fitting;
lgd = legend ('Alpha','Delta','Gamma','Beta','Others','Model Alpha','Model Delta','Linear Gamma','Linear Beta','Model Others','Location','east');
lgd.FontSize = 7;
title(Country + " Alpha VS Delta + Gamma + Beta")
xlim([Day_plot(ID_fitting)-1 Day_plot(final)+1]);
print(textCaption,'-dpng','-r300')

                % Conditions for Delta, Gamma and Beta substitution
                % processes. Other is considered linear.
                elseif ((fit(5) > 0.006 && fit(1)>fit(2) && fit(1)>fit(3) && (fit(1)<fit(4) || fit(4)<0) && fit(2)>0 && fit(3)>0)||(fit(5) > 0.006 && fit(4)<0))
                global_fit_data = [Fit_Asc1;Fit_Asc2;Fit_Asc4;Fit_Ctt]'; 
global_fit_function = @(params,t) [params(5)*exp(params(1)*t)./(1+params(5)*exp(params(1)*t)+params(7)*exp(params(3)*t)+params(6)*exp(params(2)*t)),...
    params(6)*exp(params(2)*t)./(1+params(5)*exp(params(1)*t)+params(7)*exp(params(3)*t)+params(6)*exp(params(2)*t)),...
params(7)*exp(params(3)*t)./(1+params(5)*exp(params(1)*t)+params(7)*exp(params(3)*t)+params(6)*exp(params(2)*t)),...
params(8)+(params(4)*t)]; % Fitting functions
%estimem els parametres que utilitzarem
squared_errors = @(params) norm(global_fit_data - global_fit_function(params,t));
options=optimset('MaxFunEvals', 10000000, 'MaxIter',10000000, 'Display', 'final', 'TolX', 1e-0012);
fit = fminsearch(squared_errors,[aa ab ac ad ae af ag ah],options); % BetaBQ, BetaBA2, BetaBA4, Beta_Altres; Ratio_ini_BQ, Ratio_ini_BA2, Ratio_ini_BA4, Ratio_ini_Altres
% Pasem de setmanes a dies, he tret el 7* que la Clara multiplicava al length ja que anava MASSA al futur
t_plot=(1-2/7):1/7:(length(t)+2/7);
[paramfit,Resid,Jacob,CovB,MSE,ErrorModelInfo] = nlinfit(t,global_fit_data,global_fit_function,[fit(1) fit(2) fit(3) fit(4) fit(5) fit(6) fit(7) fit(8)]);
[Ypercen,YCI] = nlpredci(global_fit_function,t_plot,paramfit,Resid,'Covar',CovB);
                        Ypercen(Ypercen<0)=0;
paramfit;
conf1 = nlparci(paramfit,Resid,'jacobian',Jacob);
conf2 = nlparci(paramfit,Resid,'covariance',CovB);
% De manera automàtica el programa agafarà els paràmetres fitejats anteriorment com punt de partida
aa=fit(1);ab=fit(2);ac=fit(3);ad=fit(4);ae=fit(5);af=fit(6);ag=fit(7);ah=fit(8);

                    n=n+1;
% Les normalitzem respecte a les 3 variants a estudiar
Fitplot_Asc1no = 100*Ypercen(1:length(t_plot));
Fitplot_Asc2no = 100*Ypercen((length(t_plot)+1):(2*length(t_plot)));
Fitplot_Asc4no = 100*Ypercen((2*length(t_plot)+1):(3*length(t_plot)));
Fitplot_Cttno = 100*Ypercen((3*length(t_plot)+1):end);
Fitplot_Descno = 100 - Fitplot_Asc1no - Fitplot_Asc2no - Fitplot_Asc4no;
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
Fitplot_DescMAX = Fitplot_Desc + 100*sqrt(YCI(1:length(t_plot)).^2 + YCI((length(t_plot)+1):(2*length(t_plot))).^2 + YCI((2*length(t_plot)+1):(3*length(t_plot))).^2);
Fitplot_DescMIN = Fitplot_Desc - 100*sqrt(YCI(1:length(t_plot)).^2 + YCI((length(t_plot)+1):(2*length(t_plot))).^2 + YCI((2*length(t_plot)+1):(3*length(t_plot))).^2);

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
    paramfit(3), abs(conf1(3,1)-paramfit(3)), paramfit(7), abs(conf1(7,1)-paramfit(7)),p, RMSE,...
    'VariableNames',['Inici Fit',"Beta_Delta","error_B_Delta","R0_Delta","error_R0_Delta",...
    "Beta_Gamma","error_B_Gamma","R0_Gamma","error_R0_Gamma",...
    "Beta_Beta","error_B_Beta","R0_Beta","error_R0_Beta","p-value","RMSE"])
Tname = ".\Variables_hist_variants_Delta\BetaR0_AlfaVSDelta_Gamma_Beta_altres"+Country+".xlsx";
NameSheet = "Full ID " + ID_fitting;
writetable(T,Tname,"Sheet",NameSheet);

% Sortida de dades experimentals de SIVIC normalitzades segons variants i
% agrupades les "no importants" a Altres
PlotSeqVar_alfa_delta = table(Day_plot', Norm_Desc, Desc_int, Norm_Asc1, Asc1_int, Norm_Asc2, Asc2_int,Norm_Asc4, Asc4_int, Norm_Ctt, Ctt_int);
PlotSeqVar_alfa_delta.Properties.VariableNames = ['Dia',"Perc_alfa",'Error_alfa',"Perc_delta",'Error_delta',"Perc_gamma",'Error_gamma',"Perc_Beta",'Error_Beta',"Perc_altres","Error_altres"];
Plotname = ".\DadesCSV_hist_variants_Delta\Plot_SeqVar_alfa_delta_gamma_Beta_altres" + Country + ".csv";
writetable(PlotSeqVar_alfa_delta,Plotname)

% Preparem la figura: dades SIVIC, observacions ("reals")
figure
errorbar(Day_plot,Norm_Desc,Desc_int,Desc_int,'o','Color',[0.00 0.45 0.74])
hold on
errorbar(Day_plot,Norm_Asc1,Asc1_int,Asc1_int,'o','Color',[0.85 0.33 0.10])
errorbar(Day_plot,Norm_Asc2,Asc2_int,Asc2_int,'o','Color',[1 0.45 0.54])
errorbar(Day_plot,Norm_Asc4,Asc4_int,Asc4_int,'o','Color',[0.1 0.1 0.9])
errorbar(Day_plot,Norm_Ctt,Ctt_int,Ctt_int,'o','Color',[0.93 0.69 0.13])

% Definim l'escala del plot perquè després queda massa gran amb el FIT
tstart_plot = datetime(tstart,'InputFormat','dd/MM/yyyy');
tend_plot = datetime(tend,'InputFormat','dd/MM/yyyy');
xlim([tstart_plot tend_plot]);
ylim([0 100]);
%Finalment afegim a la imatge els fits
Fitting_date_plot=(Fitting_date(1)-2):(Fitting_date(1)+length(t_plot)-3);
plot(Fitting_date_plot,Fitplot_Desc,'-','Color',[0.00 0.45 0.74])
plot(Fitting_date_plot,Fitplot_Asc1,'-','Color',[0.85 0.33 0.10])
plot(Fitting_date_plot,Fitplot_Asc2,'-','Color',[1 0.45 0.54])
plot(Fitting_date_plot,Fitplot_Asc4,'-','Color',[0.1 0.1 0.9])
plot(Fitting_date_plot,Fitplot_Ctt,'-','Color',[0.93 0.69 0.13])

fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_DescMIN flip(Fitplot_DescMAX)],'r','FaceColor',[0.00 0.45 0.74],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc1MIN flip(Fitplot_Asc1MAX)],'r','FaceColor',[0.85 0.33 0.10],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc2MIN flip(Fitplot_Asc2MAX)],'r','FaceColor',[1 0.45 0.54],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc4MIN flip(Fitplot_Asc4MAX)],'r','FaceColor',[0.1 0.1 0.9],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_CttMIN flip(Fitplot_CttMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
yline(5,'--'); 

Fit_alfa_delta = table(Fitting_date_plot', Fitplot_Desc',Fitplot_DescMAX',Fitplot_DescMIN', Fitplot_Asc1',Fitplot_Asc1MAX',Fitplot_Asc1MIN',...
    Fitplot_Asc2',Fitplot_Asc2MAX',Fitplot_Asc2MIN',Fitplot_Asc4',Fitplot_Asc4MAX',Fitplot_Asc4MIN',Fitplot_Ctt',Fitplot_CttMAX',Fitplot_CttMIN');
Fit_alfa_delta.Properties.VariableNames = ['Dia',"Perc_alfa_dia","Perc_alfa_dia_errMAX","Perc_alfa_dia_errMIN","Perc_delta_dia","Perc_delta_dia_errMAX","Perc_delta_dia_errMIN",...
    "Perc_gamma_dia","Perc_gamma_dia_errMAX","Perc_gamma_dia_errMIN","Perc_Beta_dia","Perc_Beta_dia_errMAX","Perc_Beta_dia_errMIN","Perc_altres_dia","Perc_altres_dia_errMAX","Perc_altres_dia_errMIN"];
Fitname = ".\DadesCSV_hist_variants_Delta\Fit_SeqVar_alfa_delta_gamma_Beta_altres"+Country+".csv";
writetable(Fit_alfa_delta,Fitname)

textCaption = ".\Figures_hist_variants_Delta\" + Country + " Alpha VS Delta + Gamma + Beta + Other " + ID_fitting;
lgd = legend ('Alpha','Delta','Gamma','Beta','Others','Model Alpha','Model Delta','Model Gamma','Model Beta','Linear Others','Location','east');
lgd.FontSize = 7;
title(Country + " Alpha VS Delta + Gamma + Beta")
xlim([Day_plot(ID_fitting)-1 Day_plot(final)+1]);
print(textCaption,'-dpng','-r300')

                % Conditions for Delta, Beta and Other substitution
                % processes. Gamma is considered linear.
                elseif ((fit(5) > 0.006 && (fit(1)<fit(2) || fit(2)<0) && fit(1)>fit(3) && fit(1)>fit(4) && fit(3)>0 && fit(4)>0)||(fit(5) > 0.006 && fit(2)<0))
global_fit_data = [Fit_Asc1;Fit_Asc2;Fit_Asc4;Fit_Ctt]'; 
global_fit_function = @(params,t) [params(5)*exp(params(1)*t)./(1+params(5)*exp(params(1)*t)+params(7)*exp(params(3)*t)+params(8)*exp(params(4)*t)),...
    params(6)+(params(2)*t),...
params(7)*exp(params(3)*t)./(1+params(5)*exp(params(1)*t)+params(7)*exp(params(3)*t)+params(8)*exp(params(4)*t)),...
params(8)*exp(params(4)*t)./(1+params(5)*exp(params(1)*t)+params(7)*exp(params(3)*t)+params(8)*exp(params(4)*t))]; % Fitting functions
%estimem els parametres que utilitzarem
squared_errors = @(params) norm(global_fit_data - global_fit_function(params,t));
options=optimset('MaxFunEvals', 10000000, 'MaxIter',10000000, 'Display', 'final', 'TolX', 1e-0012);
fit = fminsearch(squared_errors,[aa ab ac ad ae af ag ah],options); % BetaBQ, BetaBA2, BetaBA4, Beta_Altres; Ratio_ini_BQ, Ratio_ini_BA2, Ratio_ini_BA4, Ratio_ini_Altres
% Pasem de setmanes a dies, he tret el 7* que la Clara multiplicava al length ja que anava MASSA al futur
t_plot=(1-2/7):1/7:(length(t)+2/7);
[paramfit,Resid,Jacob,CovB,MSE,ErrorModelInfo] = nlinfit(t,global_fit_data,global_fit_function,[fit(1) fit(2) fit(3) fit(4) fit(5) fit(6) fit(7) fit(8)]);
[Ypercen,YCI] = nlpredci(global_fit_function,t_plot,paramfit,Resid,'Covar',CovB);
                        Ypercen(Ypercen<0)=0;
paramfit;
conf1 = nlparci(paramfit,Resid,'jacobian',Jacob);
conf2 = nlparci(paramfit,Resid,'covariance',CovB);
% De manera automàtica el programa agafarà els paràmetres fitejats anteriorment com punt de partida
aa=fit(1);ab=fit(2);ac=fit(3);ad=fit(4);ae=fit(5);af=fit(6);ag=fit(7);ah=fit(8);

        n=n+1;
% Les normalitzem respecte a les 3 variants a estudiar
Fitplot_Asc1no = 100*Ypercen(1:length(t_plot));
Fitplot_Asc2no = 100*Ypercen((length(t_plot)+1):(2*length(t_plot)));
Fitplot_Asc4no = 100*Ypercen((2*length(t_plot)+1):(3*length(t_plot)));
Fitplot_Cttno = 100*Ypercen((3*length(t_plot)+1):end);
Fitplot_Descno = 100 - Fitplot_Asc1no - Fitplot_Asc4no - Fitplot_Cttno;
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
Fitplot_DescMAX = Fitplot_Desc + 100*sqrt(YCI(1:length(t_plot)).^2 + YCI((2*length(t_plot)+1):(3*length(t_plot))).^2 + YCI((3*length(t_plot)+1):end).^2);
Fitplot_DescMIN = Fitplot_Desc - 100*sqrt(YCI(1:length(t_plot)).^2 + YCI((2*length(t_plot)+1):(3*length(t_plot))).^2 + YCI((3*length(t_plot)+1):end).^2);

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
    paramfit(3), abs(conf1(3,1)-paramfit(3)), paramfit(7), abs(conf1(7,1)-paramfit(7)),...
    paramfit(4), abs(conf1(4,1)-paramfit(4)), paramfit(8), abs(conf1(8,1)-paramfit(8)),p, RMSE,...
    'VariableNames',['Inici Fit',"Beta_Delta","error_B_Delta","R0_Delta","error_R0_Delta",...
    "Beta_Beta","error_B_Beta","R0_Beta","error_R0_Beta",...
    "Beta_Altres","error_B_Altres","R0_Altres","error_R0_Altres","p-value","RMSE"])
Tname = ".\Variables_hist_variants_Delta\BetaR0_AlfaVSDelta_Gamma_Beta_altres"+Country+".xlsx";
NameSheet = "Full ID " + ID_fitting;
writetable(T,Tname,"Sheet",NameSheet);

% Sortida de dades experimentals de SIVIC normalitzades segons variants i
% agrupades les "no importants" a Altres
PlotSeqVar_alfa_delta = table(Day_plot', Norm_Desc, Desc_int, Norm_Asc1, Asc1_int, Norm_Asc2, Asc2_int,Norm_Asc4, Asc4_int, Norm_Ctt, Ctt_int);
PlotSeqVar_alfa_delta.Properties.VariableNames = ['Dia',"Perc_alfa",'Error_alfa',"Perc_delta",'Error_delta',"Perc_gamma",'Error_gamma',"Perc_Beta",'Error_Beta',"Perc_altres","Error_altres"];
Plotname = ".\DadesCSV_hist_variants_Delta\Plot_SeqVar_alfa_delta_gamma_Beta_altres" + Country + ".csv";
writetable(PlotSeqVar_alfa_delta,Plotname)

% Preparem la figura: dades SIVIC, observacions ("reals")
figure
errorbar(Day_plot,Norm_Desc,Desc_int,Desc_int,'o','Color',[0.00 0.45 0.74])
hold on
errorbar(Day_plot,Norm_Asc1,Asc1_int,Asc1_int,'o','Color',[0.85 0.33 0.10])
errorbar(Day_plot,Norm_Asc2,Asc2_int,Asc2_int,'o','Color',[1 0.45 0.54])
errorbar(Day_plot,Norm_Asc4,Asc4_int,Asc4_int,'o','Color',[0.1 0.1 0.9])
errorbar(Day_plot,Norm_Ctt,Ctt_int,Ctt_int,'o','Color',[0.93 0.69 0.13])

% Definim l'escala del plot perquè després queda massa gran amb el FIT
tstart_plot = datetime(tstart,'InputFormat','dd/MM/yyyy');
tend_plot = datetime(tend,'InputFormat','dd/MM/yyyy');
xlim([tstart_plot tend_plot]);
ylim([0 100]);
%Finalment afegim a la imatge els fits
Fitting_date_plot=(Fitting_date(1)-2):(Fitting_date(1)+length(t_plot)-3);
plot(Fitting_date_plot,Fitplot_Desc,'-','Color',[0.00 0.45 0.74])
plot(Fitting_date_plot,Fitplot_Asc1,'-','Color',[0.85 0.33 0.10])
plot(Fitting_date_plot,Fitplot_Asc2,'-','Color',[1 0.45 0.54])
plot(Fitting_date_plot,Fitplot_Asc4,'-','Color',[0.1 0.1 0.9])
plot(Fitting_date_plot,Fitplot_Ctt,'-','Color',[0.93 0.69 0.13])

fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_DescMIN flip(Fitplot_DescMAX)],'r','FaceColor',[0.00 0.45 0.74],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc1MIN flip(Fitplot_Asc1MAX)],'r','FaceColor',[0.85 0.33 0.10],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc2MIN flip(Fitplot_Asc2MAX)],'r','FaceColor',[1 0.45 0.54],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc4MIN flip(Fitplot_Asc4MAX)],'r','FaceColor',[0.1 0.1 0.9],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_CttMIN flip(Fitplot_CttMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
yline(5,'--'); 

Fit_alfa_delta = table(Fitting_date_plot', Fitplot_Desc',Fitplot_DescMAX',Fitplot_DescMIN', Fitplot_Asc1',Fitplot_Asc1MAX',Fitplot_Asc1MIN',...
    Fitplot_Asc2',Fitplot_Asc2MAX',Fitplot_Asc2MIN',Fitplot_Asc4',Fitplot_Asc4MAX',Fitplot_Asc4MIN',Fitplot_Ctt',Fitplot_CttMAX',Fitplot_CttMIN');
Fit_alfa_delta.Properties.VariableNames = ['Dia',"Perc_alfa_dia","Perc_alfa_dia_errMAX","Perc_alfa_dia_errMIN","Perc_delta_dia","Perc_delta_dia_errMAX","Perc_delta_dia_errMIN",...
    "Perc_gamma_dia","Perc_gamma_dia_errMAX","Perc_gamma_dia_errMIN","Perc_Beta_dia","Perc_Beta_dia_errMAX","Perc_Beta_dia_errMIN","Perc_altres_dia","Perc_altres_dia_errMAX","Perc_altres_dia_errMIN"];
Fitname = ".\DadesCSV_hist_variants_Delta\Fit_SeqVar_alfa_delta_gamma_Beta_altres"+Country+".csv";
writetable(Fit_alfa_delta,Fitname)

textCaption = ".\Figures_hist_variants_Delta\" + Country + " Alpha VS Delta + Gamma + Beta + Other " + ID_fitting;
lgd = legend ('Alpha','Delta','Gamma','Beta','Others','Model Alpha','Model Delta','Linear Gamma','Model Beta','Model Others','Location','east');
lgd.FontSize = 7;
title(Country + " Alpha VS Delta + Gamma + Beta")
xlim([Day_plot(ID_fitting)-1 Day_plot(final)+1]);
print(textCaption,'-dpng','-r300')

                % Conditions for Delta, Gamma and Other substitution
                % processes. Beta is considered linear.
                elseif ((fit(5) > 0.006 && fit(1)>fit(2) && (fit(1)<fit(3) || fit(3)<0) && fit(1)>fit(4) && fit(2)>0 && fit(4)>0)||(fit(5) > 0.006 && fit(3)<0))
global_fit_data = [Fit_Asc1;Fit_Asc2;Fit_Asc4;Fit_Ctt]'; 
global_fit_function = @(params,t) [params(5)*exp(params(1)*t)./(1+params(5)*exp(params(1)*t)+params(6)*exp(params(2)*t)+params(8)*exp(params(4)*t)),...
    params(6)*exp(params(2)*t)./(1+params(5)*exp(params(1)*t)+params(6)*exp(params(2)*t)+params(8)*exp(params(4)*t)),...
params(7)+(params(3)*t),...
params(8)*exp(params(4)*t)./(1+params(5)*exp(params(1)*t)+params(6)*exp(params(2)*t)+params(8)*exp(params(4)*t))]; % Fitting functions
%estimem els parametres que utilitzarem
squared_errors = @(params) norm(global_fit_data - global_fit_function(params,t));
options=optimset('MaxFunEvals', 10000000, 'MaxIter',10000000, 'Display', 'final', 'TolX', 1e-0012);
fit = fminsearch(squared_errors,[aa ab ac ad ae af ag ah],options); % BetaBQ, BetaBA2, BetaBA4, Beta_Altres; Ratio_ini_BQ, Ratio_ini_BA2, Ratio_ini_BA4, Ratio_ini_Altres
% Pasem de setmanes a dies, he tret el 7* que la Clara multiplicava al length ja que anava MASSA al futur
t_plot=(1-2/7):1/7:(length(t)+2/7);
[paramfit,Resid,Jacob,CovB,MSE,ErrorModelInfo] = nlinfit(t,global_fit_data,global_fit_function,[fit(1) fit(2) fit(3) fit(4) fit(5) fit(6) fit(7) fit(8)]);
[Ypercen,YCI] = nlpredci(global_fit_function,t_plot,paramfit,Resid,'Covar',CovB);
                        Ypercen(Ypercen<0)=0;
paramfit;
conf1 = nlparci(paramfit,Resid,'jacobian',Jacob);
conf2 = nlparci(paramfit,Resid,'covariance',CovB);
% De manera automàtica el programa agafarà els paràmetres fitejats anteriorment com punt de partida
aa=fit(1);ab=fit(2);ac=fit(3);ad=fit(4);ae=fit(5);af=fit(6);ag=fit(7);ah=fit(8);

        n=n+1;
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
    'VariableNames',['Inici Fit',"Beta_Delta","error_B_Delta","R0_Delta","error_R0_Delta",...
    "Beta_Gamma","error_B_Gamma","R0_Gamma","error_R0_Gamma",...
    "Beta_Altres","error_B_Altres","R0_Altres","error_R0_Altres","p-value","RMSE"])
Tname = ".\Variables_hist_variants_Delta\BetaR0_AlfaVSDelta_Gamma_Beta_altres"+Country+".xlsx";
NameSheet = "Full ID " + ID_fitting;
writetable(T,Tname,"Sheet",NameSheet);

% Sortida de dades experimentals de SIVIC normalitzades segons variants i
% agrupades les "no importants" a Altres
PlotSeqVar_alfa_delta = table(Day_plot', Norm_Desc, Desc_int, Norm_Asc1, Asc1_int, Norm_Asc2, Asc2_int,Norm_Asc4, Asc4_int, Norm_Ctt, Ctt_int);
PlotSeqVar_alfa_delta.Properties.VariableNames = ['Dia',"Perc_alfa",'Error_alfa',"Perc_delta",'Error_delta',"Perc_gamma",'Error_gamma',"Perc_Beta",'Error_Beta',"Perc_altres","Error_altres"];
Plotname = ".\DadesCSV_hist_variants_Delta\Plot_SeqVar_alfa_delta_gamma_Beta_altres" + Country + ".csv";
writetable(PlotSeqVar_alfa_delta,Plotname)

% Preparem la figura: dades SIVIC, observacions ("reals")
figure
errorbar(Day_plot,Norm_Desc,Desc_int,Desc_int,'o','Color',[0.00 0.45 0.74])
hold on
errorbar(Day_plot,Norm_Asc1,Asc1_int,Asc1_int,'o','Color',[0.85 0.33 0.10])
errorbar(Day_plot,Norm_Asc2,Asc2_int,Asc2_int,'o','Color',[1 0.45 0.54])
errorbar(Day_plot,Norm_Asc4,Asc4_int,Asc4_int,'o','Color',[0.1 0.1 0.9])
errorbar(Day_plot,Norm_Ctt,Ctt_int,Ctt_int,'o','Color',[0.93 0.69 0.13])

% Definim l'escala del plot perquè després queda massa gran amb el FIT
tstart_plot = datetime(tstart,'InputFormat','dd/MM/yyyy');
tend_plot = datetime(tend,'InputFormat','dd/MM/yyyy');
xlim([tstart_plot tend_plot]);
ylim([0 100]);
%Finalment afegim a la imatge els fits
Fitting_date_plot=(Fitting_date(1)-2):(Fitting_date(1)+length(t_plot)-3);
plot(Fitting_date_plot,Fitplot_Desc,'-','Color',[0.00 0.45 0.74])
plot(Fitting_date_plot,Fitplot_Asc1,'-','Color',[0.85 0.33 0.10])
plot(Fitting_date_plot,Fitplot_Asc2,'-','Color',[1 0.45 0.54])
plot(Fitting_date_plot,Fitplot_Asc4,'-','Color',[0.1 0.1 0.9])
plot(Fitting_date_plot,Fitplot_Ctt,'-','Color',[0.93 0.69 0.13])

fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_DescMIN flip(Fitplot_DescMAX)],'r','FaceColor',[0.00 0.45 0.74],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc1MIN flip(Fitplot_Asc1MAX)],'r','FaceColor',[0.85 0.33 0.10],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc2MIN flip(Fitplot_Asc2MAX)],'r','FaceColor',[1 0.45 0.54],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_Asc4MIN flip(Fitplot_Asc4MAX)],'r','FaceColor',[0.1 0.1 0.9],'FaceAlpha',0.3,'EdgeColor','none');
fill([Fitting_date_plot flip(Fitting_date_plot)], [Fitplot_CttMIN flip(Fitplot_CttMAX)],'r','FaceColor',[0.93 0.69 0.13],'FaceAlpha',0.3,'EdgeColor','none');
yline(5,'--'); 

Fit_alfa_delta = table(Fitting_date_plot', Fitplot_Desc',Fitplot_DescMAX',Fitplot_DescMIN', Fitplot_Asc1',Fitplot_Asc1MAX',Fitplot_Asc1MIN',...
    Fitplot_Asc2',Fitplot_Asc2MAX',Fitplot_Asc2MIN',Fitplot_Asc4',Fitplot_Asc4MAX',Fitplot_Asc4MIN',Fitplot_Ctt',Fitplot_CttMAX',Fitplot_CttMIN');
Fit_alfa_delta.Properties.VariableNames = ['Dia',"Perc_alfa_dia","Perc_alfa_dia_errMAX","Perc_alfa_dia_errMIN","Perc_delta_dia","Perc_delta_dia_errMAX","Perc_delta_dia_errMIN",...
    "Perc_gamma_dia","Perc_gamma_dia_errMAX","Perc_gamma_dia_errMIN","Perc_Beta_dia","Perc_Beta_dia_errMAX","Perc_Beta_dia_errMIN","Perc_altres_dia","Perc_altres_dia_errMAX","Perc_altres_dia_errMIN"];
Fitname = ".\DadesCSV_hist_variants_Delta\Fit_SeqVar_alfa_delta_gamma_Beta_altres"+Country+".csv";
writetable(Fit_alfa_delta,Fitname)

textCaption = ".\Figures_hist_variants_Delta\" + Country + " Alpha VS Delta + Gamma + Beta + Other " + ID_fitting;
lgd = legend ('Alpha','Delta','Gamma','Beta','Others','Model Alpha','Model Delta','Model Gamma','Linear Beta','Model Others','Location','east');
lgd.FontSize = 7;
title(Country + " Alpha VS Delta + Gamma + Beta")
xlim([Day_plot(ID_fitting)-1 Day_plot(final)+1]);
print(textCaption,'-dpng','-r300')

                else
                    n;

                end %aquí acaba les imatges i/o càlculs... el segon "if"
        else 
            n;
        end %aquí acabarà el programa quan n=>4

    end %aquí acaba el primer "if" el de fer només 3 pasos
        BDelta=paramfit(1); BerrDelta=abs(conf1(1,1)-paramfit(1)); R0Delta=paramfit(5); R0errDelta=abs(conf1(5,1)-paramfit(5));
    DayDelta = Fitting_date_plot(find(Fitplot_Asc1 > 5,1));
    DayDelta20 = Fitting_date_plot(find(Fitplot_Asc1 > 20,1));
        DayDelta40 = Fitting_date_plot(find(Fitplot_Asc1 > 40,1));
    DayDelta60 = Fitting_date_plot(find(Fitplot_Asc1 > 60,1));
        DayDelta80 = Fitting_date_plot(find(Fitplot_Asc1 > 80,1));
end %Estonia
        close all
end 